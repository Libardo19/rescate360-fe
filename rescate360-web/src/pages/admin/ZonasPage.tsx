import { useEffect, useMemo, useState } from 'react'
import { MapContainer, TileLayer, Polygon, Polyline, CircleMarker, Popup, useMap, useMapEvents } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import {
  Waves,
  Mountain,
  Flame,
  ShieldAlert,
  Building,
  TriangleAlert,
  Plus,
  Undo2,
  CheckCircle2,
  RotateCcw,
  MousePointerClick,
  Ruler,
  type LucideIcon,
} from 'lucide-react'
import { listarZonas, crearZona, cambiarEstadoZona } from '../../services/zonas.service'
import { hectareas, type Coordenada, type EstadoZona, type TipoRiesgo, type ZonaPeligrosa } from '../../types/zona'
import CabeceraPanel, { botonCabeceraPrincipal } from '../../components/panel/CabeceraPanel'

const CENTRO_MAPA: Coordenada = [10.4731, -73.2582]

const riesgos: Record<TipoRiesgo, { etiqueta: string; icono: LucideIcon; clase: string; color: string }> = {
  inundacion: { etiqueta: 'Inundación', icono: Waves, clase: 'bg-blue-100 text-blue-600', color: '#3e7bfa' },
  deslizamiento: { etiqueta: 'Deslizamiento', icono: Mountain, clase: 'bg-amber-100 text-amber-700', color: '#d97706' },
  incendio: { etiqueta: 'Incendio', icono: Flame, clase: 'bg-red-100 text-red-600', color: '#e5534b' },
  inseguridad: { etiqueta: 'Inseguridad', icono: ShieldAlert, clase: 'bg-violet-100 text-violet-600', color: '#7c5cd6' },
  estructural: { etiqueta: 'Riesgo estructural', icono: Building, clase: 'bg-slate-200 text-slate-700', color: '#475569' },
  otro: { etiqueta: 'Otro', icono: TriangleAlert, clase: 'bg-slate-100 text-slate-600', color: '#64748b' },
}

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const formatearHa = (ha: number) => `${ha.toLocaleString('es-CO', { maximumFractionDigits: 1 })} ha`

const campo =
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

// Mientras se dibuja, cada clic en el mapa agrega un vértice.
function CapturarClics({ activo, onPunto }: { activo: boolean; onPunto: (p: Coordenada) => void }) {
  useMapEvents({
    click(e) {
      if (activo) onPunto([Number(e.latlng.lat.toFixed(6)), Number(e.latlng.lng.toFixed(6))])
    },
  })
  return null
}

function EncuadrarZona({ zona }: { zona: ZonaPeligrosa | null }) {
  const map = useMap()
  useEffect(() => {
    if (zona) map.flyToBounds(zona.area, { padding: [40, 40], maxZoom: 16, duration: 0.6 })
  }, [zona, map])
  return null
}

export default function ZonasPage() {
  const [zonas, setZonas] = useState<ZonaPeligrosa[] | null>(null)
  const [error, setError] = useState('')
  const [pestana, setPestana] = useState<EstadoZona>('activa')
  const [enfocada, setEnfocada] = useState<ZonaPeligrosa | null>(null)
  const [dibujando, setDibujando] = useState(false)
  const [puntos, setPuntos] = useState<Coordenada[]>([])
  const [tipoNuevo, setTipoNuevo] = useState<TipoRiesgo>('inundacion')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarZonas()
      .then(setZonas)
      .catch(() => setError('No se pudieron cargar las zonas peligrosas.'))
  }, [])

  const visibles = useMemo(
    () =>
      (zonas ?? [])
        .filter((z) => z.estado === pestana)
        .sort((a, b) => b.actualizadoEn.localeCompare(a.actualizadoEn)),
    [zonas, pestana],
  )

  const resumen = useMemo(() => {
    const activas = (zonas ?? []).filter((z) => z.estado === 'activa')
    return {
      activas: activas.length,
      resueltas: (zonas ?? []).length - activas.length,
      hectareas: Math.round(activas.reduce((s, z) => s + hectareas(z.area), 0)),
    }
  }, [zonas])

  const empezarDibujo = () => {
    setEnfocada(null)
    setPuntos([])
    setTipoNuevo('inundacion')
    setDibujando(true)
    setError('')
  }

  const cancelarDibujo = () => {
    setDibujando(false)
    setPuntos([])
  }

  const guardarZona = async () => {
    if (puntos.length < 3) return
    setGuardando(true)
    setError('')
    try {
      const nueva = await crearZona({ tipoRiesgo: tipoNuevo, area: puntos })
      setZonas((lista) => [nueva, ...(lista ?? [])])
      setPestana('activa')
      setEnfocada(nueva)
      cancelarDibujo()
    } catch {
      setError('No se pudo guardar la zona.')
    } finally {
      setGuardando(false)
    }
  }

  const alternarEstado = async (z: ZonaPeligrosa) => {
    const nuevo: EstadoZona = z.estado === 'activa' ? 'resuelta' : 'activa'
    const pregunta =
      nuevo === 'resuelta'
        ? `¿Marcar como resuelta la zona de ${riesgos[z.tipoRiesgo].etiqueta.toLowerCase()}? Dejará de mostrarse como peligro a los ciudadanos.`
        : `¿Volver a activar la zona de ${riesgos[z.tipoRiesgo].etiqueta.toLowerCase()}?`
    if (!window.confirm(pregunta)) return
    setError('')
    try {
      const actualizada = await cambiarEstadoZona(z.id, nuevo)
      setZonas((lista) => lista?.map((x) => (x.id === actualizada.id ? actualizada : x)) ?? null)
      if (enfocada?.id === actualizada.id) setEnfocada(null)
    } catch {
      setError('No se pudo cambiar el estado de la zona.')
    }
  }

  if (error && !zonas) return <p className="text-panel-accent">{error}</p>
  if (!zonas) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <CabeceraPanel
        seccion="Recursos"
        titulo="Zonas peligrosas"
        descripcion="Delimita en el mapa las áreas de riesgo que verán los ciudadanos en la app."
        acciones={
          !dibujando && (
            <button onClick={empezarDibujo} className={botonCabeceraPrincipal}>
              <Plus size={16} /> Nueva zona
            </button>
          )
        }
        estadisticas={[
          {
            titulo: 'Zonas activas',
            valor: resumen.activas,
            icono: TriangleAlert,
            pie: 'Visibles como peligro',
            tono: resumen.activas > 0 ? 'alerta' : 'bien',
          },
          { titulo: 'Zonas resueltas', valor: resumen.resueltas, icono: CheckCircle2, pie: 'Ya sin riesgo' },
          { titulo: 'Hectáreas en riesgo', valor: resumen.hectareas, icono: Ruler, pie: 'Área aproximada de zonas activas' },
        ]}
      />

      {error && <p className="mb-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,3fr)]">
        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card p-5">
          {dibujando ? (
            <div>
              <h2 className="font-bold">Nueva zona peligrosa</h2>
              <ol className="mt-3 space-y-2 text-sm text-panel-text-soft">
                <li className="flex gap-2">
                  <MousePointerClick size={16} className="mt-0.5 shrink-0 text-panel-info" />
                  Haz clic en el mapa para marcar cada esquina del área. Necesitas al menos 3 puntos.
                </li>
              </ol>

              <label htmlFor="tipoRiesgo" className="mt-5 block text-sm font-medium">
                Tipo de riesgo
              </label>
              <select
                id="tipoRiesgo"
                value={tipoNuevo}
                onChange={(e) => setTipoNuevo(e.target.value as TipoRiesgo)}
                className={`${campo} mt-1`}
              >
                {(Object.keys(riesgos) as TipoRiesgo[]).map((t) => (
                  <option key={t} value={t}>
                    {riesgos[t].etiqueta}
                  </option>
                ))}
              </select>

              <div className="mt-4 flex items-center justify-between rounded-xl bg-panel-bg px-4 py-3 text-sm">
                <span>
                  <span className="font-semibold tabular-nums">{puntos.length}</span> puntos marcados
                </span>
                <span className="tabular-nums text-panel-text-soft">
                  {puntos.length >= 3 ? formatearHa(hectareas(puntos)) : '—'}
                </span>
              </div>

              <div className="mt-5 flex flex-wrap gap-2">
                <button
                  onClick={() => setPuntos((p) => p.slice(0, -1))}
                  disabled={puntos.length === 0 || guardando}
                  className="flex items-center gap-2 rounded-lg border border-panel-border px-3 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg disabled:opacity-40"
                >
                  <Undo2 size={16} /> Deshacer punto
                </button>
                <button
                  onClick={cancelarDibujo}
                  disabled={guardando}
                  className="rounded-lg border border-panel-border px-3 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
                >
                  Cancelar
                </button>
                <button
                  onClick={guardarZona}
                  disabled={puntos.length < 3 || guardando}
                  className="ml-auto rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark active:scale-[0.98] disabled:opacity-40"
                >
                  {guardando ? 'Guardando…' : 'Guardar zona'}
                </button>
              </div>
            </div>
          ) : (
            <div>
              <div className="inline-flex rounded-lg border border-panel-border bg-panel-bg p-1 text-sm">
                {(['activa', 'resuelta'] as const).map((p) => (
                  <button
                    key={p}
                    onClick={() => setPestana(p)}
                    className={`rounded-md px-4 py-1.5 font-medium transition ${
                      pestana === p ? 'bg-panel-primary text-white' : 'text-panel-text-soft hover:text-panel-text'
                    }`}
                  >
                    {p === 'activa' ? `Activas (${resumen.activas})` : `Resueltas (${resumen.resueltas})`}
                  </button>
                ))}
              </div>

              <ul className="mt-4 space-y-2">
                {visibles.length === 0 && (
                  <li className="rounded-xl border border-dashed border-panel-border px-4 py-10 text-center text-sm text-panel-text-soft">
                    {pestana === 'activa' ? 'No hay zonas peligrosas activas.' : 'No hay zonas resueltas.'}
                  </li>
                )}
                {visibles.map((z) => {
                  const { etiqueta, icono: Icono, clase } = riesgos[z.tipoRiesgo]
                  const seleccionada = enfocada?.id === z.id
                  return (
                    <li
                      key={z.id}
                      className={`flex items-center gap-3 rounded-xl border p-3 transition ${
                        seleccionada ? 'border-panel-primary bg-panel-bg' : 'border-panel-border'
                      }`}
                    >
                      <button
                        onClick={() => setEnfocada(z)}
                        className="flex min-w-0 flex-1 items-center gap-3 text-left"
                        aria-label={`Ver ${etiqueta} en el mapa`}
                      >
                        <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full ${clase}`}>
                          <Icono size={18} />
                        </span>
                        <span className="min-w-0">
                          <span className="block font-semibold">{etiqueta}</span>
                          <span className="block truncate text-xs text-panel-text-muted">
                            {formatearHa(hectareas(z.area))} · {formatearFecha(z.actualizadoEn)} · {z.gestionadoPor}
                          </span>
                        </span>
                      </button>
                      <button
                        onClick={() => alternarEstado(z)}
                        title={z.estado === 'activa' ? 'Marcar como resuelta' : 'Volver a activar'}
                        aria-label={z.estado === 'activa' ? 'Marcar como resuelta' : 'Volver a activar'}
                        className="rounded p-2 text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-primary"
                      >
                        {z.estado === 'activa' ? <CheckCircle2 size={18} /> : <RotateCcw size={18} />}
                      </button>
                    </li>
                  )
                })}
              </ul>
            </div>
          )}
        </section>

        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card p-5">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <h2 className="font-bold">Mapa de zonas</h2>
            {dibujando && (
              <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-700">
                Modo dibujo: haz clic en el mapa
              </span>
            )}
          </div>
          <div className="relative z-0 mt-4 overflow-hidden rounded-xl border border-panel-border">
            <MapContainer
              center={CENTRO_MAPA}
              zoom={14}
              scrollWheelZoom
              className={`h-[480px] w-full ${dibujando ? 'cursor-crosshair' : ''}`}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <CapturarClics activo={dibujando} onPunto={(p) => setPuntos((lista) => [...lista, p])} />
              <EncuadrarZona zona={enfocada} />

              {zonas.map((z) => {
                const activa = z.estado === 'activa'
                const resaltada = enfocada?.id === z.id
                return (
                  <Polygon
                    key={z.id}
                    positions={z.area}
                    pathOptions={{
                      color: riesgos[z.tipoRiesgo].color,
                      weight: resaltada ? 4 : 2,
                      dashArray: activa ? undefined : '6 6',
                      fillOpacity: activa ? (resaltada ? 0.4 : 0.25) : 0.08,
                    }}
                    eventHandlers={{ click: () => !dibujando && setEnfocada(z) }}
                  >
                    {!dibujando && (
                      <Popup>
                        <p className="font-bold">{riesgos[z.tipoRiesgo].etiqueta}</p>
                        <p>
                          {activa ? 'Activa' : 'Resuelta'} · {formatearHa(hectareas(z.area))}
                        </p>
                      </Popup>
                    )}
                  </Polygon>
                )
              })}

              {dibujando && puntos.length >= 3 && (
                <Polygon
                  positions={puntos}
                  pathOptions={{ color: riesgos[tipoNuevo].color, weight: 2, dashArray: '4 4', fillOpacity: 0.2 }}
                />
              )}
              {dibujando && puntos.length === 2 && (
                <Polyline positions={puntos} pathOptions={{ color: riesgos[tipoNuevo].color, dashArray: '4 4' }} />
              )}
              {dibujando &&
                puntos.map((p, i) => (
                  <CircleMarker
                    key={`${p[0]}-${p[1]}-${i}`}
                    center={p}
                    radius={5}
                    pathOptions={{ color: '#ffffff', weight: 2, fillColor: riesgos[tipoNuevo].color, fillOpacity: 1 }}
                  />
                ))}
            </MapContainer>
          </div>
          <div className="mt-3 flex flex-wrap gap-x-4 gap-y-1 text-xs text-panel-text-soft">
            {(Object.keys(riesgos) as TipoRiesgo[]).map((t) => (
              <span key={t} className="flex items-center gap-1.5">
                <span className="h-2.5 w-2.5 rounded-sm" style={{ backgroundColor: riesgos[t].color }} />
                {riesgos[t].etiqueta}
              </span>
            ))}
            <span className="flex items-center gap-1.5">
              <span className="h-2.5 w-4 rounded-sm border border-dashed border-slate-400" /> Resuelta
            </span>
          </div>
        </section>
      </div>
    </div>
  )
}
