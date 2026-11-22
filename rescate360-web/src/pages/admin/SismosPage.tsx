import { useCallback, useState } from 'react'
import { Activity, Globe2, MapPin, Siren, X } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { mensajeDeError } from '../../services/api'
import { checkInsDeSismo, listarSismos, simularSismo } from '../../services/sismos.service'
import { useConsultaPeriodica } from '../../hooks/useConsultaPeriodica'
import { colorMagnitud } from '../../utils/sismos'
import type { CheckInsSismo, EstadoCheckIn, RegionSismo, Sismo } from '../../types/sismo'

const REGIONES: { valor: RegionSismo; etiqueta: string }[] = [
  { valor: 'todos', etiqueta: 'Todo el mundo' },
  { valor: 'colombia', etiqueta: 'Colombia' },
  { valor: 'mundo', etiqueta: 'Fuera de Colombia' },
]

const MAGNITUDES = [
  { valor: undefined, etiqueta: 'Todas las magnitudes' },
  { valor: 2.5, etiqueta: 'M 2.5 o más' },
  { valor: 4.5, etiqueta: 'M 4.5 o más' },
  { valor: 6, etiqueta: 'M 6 o más' },
]

const ESTADOS: Record<EstadoCheckIn, { etiqueta: string; color: string }> = {
  necesito_ayuda: { etiqueta: 'Necesita ayuda', color: 'bg-red-100 text-red-700' },
  sin_respuesta: { etiqueta: 'Sin respuesta', color: 'bg-amber-100 text-amber-800' },
  pendiente: { etiqueta: 'Pendiente', color: 'bg-slate-100 text-slate-700' },
  a_salvo: { etiqueta: 'A salvo', color: 'bg-green-100 text-green-700' },
}

const haceCuanto = (iso: string) => {
  const minutos = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60_000))
  if (minutos < 60) return `hace ${minutos} min`
  const horas = Math.round(minutos / 60)
  return horas < 24 ? `hace ${horas} h` : new Date(iso).toLocaleDateString('es-CO', { dateStyle: 'medium' })
}

const hora = (iso: string) => new Date(iso).toLocaleString('es-CO', { dateStyle: 'short', timeStyle: 'short' })

export default function SismosPage() {
  const { usuario } = useAuth()
  const [region, setRegion] = useState<RegionSismo>('todos')
  const [magnitudMin, setMagnitudMin] = useState<number | undefined>(undefined)
  const [sismos, setSismos] = useState<Sismo[] | null>(null)
  const [error, setError] = useState('')
  const [elegido, setElegido] = useState<Sismo | null>(null)
  const [checkIns, setCheckIns] = useState<CheckInsSismo | null>(null)
  const [simulando, setSimulando] = useState(false)
  const [aviso, setAviso] = useState('')

  const cargar = useCallback(() => {
    listarSismos(region, magnitudMin)
      .then((lista) => {
        setSismos(lista)
        setError('')
      })
      .catch((e) => setError(mensajeDeError(e, 'No se pudieron cargar los sismos.')))
  }, [region, magnitudMin])

  // El feed se lee cada minuto en el backend: no hace falta consultar más seguido
  useConsultaPeriodica(cargar, 60_000)

  const abrir = (s: Sismo) => {
    setElegido(s)
    setCheckIns(null)
    if (s.alertaId) {
      checkInsDeSismo(s.id)
        .then(setCheckIns)
        .catch((e) => setError(mensajeDeError(e, 'No se pudo cargar el "¿Estás bien?" de ese sismo.')))
    }
  }

  const simular = async () => {
    setSimulando(true)
    setAviso('')
    try {
      const nuevo = await simularSismo(6.2)
      setAviso(`Simulacro creado: M${nuevo.magnitud.toFixed(1)} en ${nuevo.lugar}. Se enviaron la alerta SOS a quienes están cerca y el aviso al resto.`)
      cargar()
      abrir(nuevo)
    } catch (e) {
      setError(mensajeDeError(e, 'No se pudo crear el simulacro.'))
    } finally {
      setSimulando(false)
    }
  }

  const enColombia = sismos?.filter((s) => s.enColombia).length ?? 0
  const fuertes = sismos?.filter((s) => s.magnitud >= 6).length ?? 0

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-brand" />
            Operación
          </p>
          <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Sismos</h1>
          <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">
            Sismos de todo el mundo en tiempo real (USGS). Solo los de Colombia alertan: si es muy fuerte, quien está cerca recibe la alerta SOS y el resto un aviso.
          </p>
        </div>
        {usuario?.rol === 'super_admin' && (
          <button
            onClick={simular}
            disabled={simulando}
            className="flex items-center justify-center gap-2 rounded-full bg-panel-primary px-5 py-2.5 text-sm font-semibold text-white transition hover:opacity-90 disabled:opacity-60"
          >
            <Siren size={16} /> {simulando ? 'Simulando…' : 'Simular sismo fuerte'}
          </button>
        )}
      </div>

      {error && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
      {aviso && <p className="mt-3 rounded-2xl bg-green-50 px-3 py-2 text-sm text-green-800">{aviso}</p>}

      <div className="mt-5 grid gap-3 sm:grid-cols-3">
        {[
          { titulo: 'Sismos en la lista', valor: sismos?.length, icono: Globe2 },
          { titulo: 'En Colombia', valor: enColombia, icono: MapPin },
          { titulo: 'M 6 o más', valor: fuertes, icono: Activity },
        ].map(({ titulo, valor, icono: Icono }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-3xl border border-panel-border bg-panel-card p-5">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border border-panel-border text-panel-text-soft">
              <Icono size={22} />
            </div>
            <div>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className="text-2xl font-extrabold">{sismos ? valor : '…'}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-5 flex flex-wrap items-center gap-2">
        {REGIONES.map((r) => (
          <button
            key={r.valor}
            onClick={() => setRegion(r.valor)}
            className={`rounded-full border px-4 py-2 text-sm transition ${
              region === r.valor ? 'border-panel-primary bg-panel-card font-semibold text-panel-text' : 'border-panel-border bg-panel-bg text-panel-text-muted'
            }`}
          >
            {r.etiqueta}
          </button>
        ))}
        <select
          value={magnitudMin ?? ''}
          onChange={(e) => setMagnitudMin(e.target.value ? Number(e.target.value) : undefined)}
          className="rounded-full border border-panel-border bg-panel-card px-4 py-2 text-sm"
          aria-label="Magnitud mínima"
        >
          {MAGNITUDES.map((m) => (
            <option key={m.etiqueta} value={m.valor ?? ''}>
              {m.etiqueta}
            </option>
          ))}
        </select>
      </div>

      <div className="mt-4 grid gap-4 xl:grid-cols-[1fr_380px]">
        <div className="overflow-x-auto rounded-2xl border border-panel-border bg-panel-card">
          {!sismos ? (
            <p className="p-5 text-panel-text-soft">Cargando…</p>
          ) : sismos.length === 0 ? (
            <p className="p-5 text-panel-text-soft">No hay sismos con esos filtros.</p>
          ) : (
            <table className="w-full min-w-[640px] text-sm">
              <thead className="text-left text-xs uppercase tracking-wide text-panel-text-muted">
                <tr className="border-b border-panel-border">
                  <th className="px-4 py-3">Magnitud</th>
                  <th className="px-4 py-3">Lugar</th>
                  <th className="px-4 py-3">Profundidad</th>
                  <th className="px-4 py-3">Cuándo</th>
                  <th className="px-4 py-3">Región</th>
                </tr>
              </thead>
              <tbody>
                {sismos.map((s) => (
                  <tr
                    key={s.id}
                    onClick={() => abrir(s)}
                    className={`cursor-pointer border-b border-panel-border last:border-0 hover:bg-panel-bg ${elegido?.id === s.id ? 'bg-panel-bg' : ''}`}
                  >
                    <td className="px-4 py-3">
                      <span className="inline-flex min-w-12 justify-center rounded-full px-2.5 py-1 text-xs font-bold text-white" style={{ backgroundColor: colorMagnitud(s.magnitud) }}>
                        M {s.magnitud.toFixed(1)}
                      </span>
                    </td>
                    <td className="px-4 py-3 font-medium">
                      {s.lugar}
                      {s.fuente === 'simulado' && <span className="ml-2 rounded bg-violet-100 px-1.5 py-0.5 text-[11px] text-violet-700">simulacro</span>}
                    </td>
                    <td className="px-4 py-3 text-panel-text-soft">{s.profundidadKm !== null ? `${Math.round(s.profundidadKm)} km` : '—'}</td>
                    <td className="px-4 py-3 text-panel-text-soft" title={hora(s.ocurridoEn)}>
                      {haceCuanto(s.ocurridoEn)}
                    </td>
                    <td className="px-4 py-3">
                      {s.enColombia ? (
                        <span className="rounded-full bg-amber-100 px-2.5 py-1 text-xs font-semibold text-amber-800">{s.alertaId ? 'Colombia · alertado' : 'Colombia'}</span>
                      ) : (
                        <span className="rounded-full bg-slate-100 px-2.5 py-1 text-xs text-slate-600">Mundo</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <aside className="rounded-2xl border border-panel-border bg-panel-card p-5">
          {!elegido ? (
            <p className="text-sm text-panel-text-soft">Elige un sismo para ver sus datos y, si alertó, quién respondió el "¿Estás bien?".</p>
          ) : (
            <div>
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="text-2xl font-extrabold" style={{ color: colorMagnitud(elegido.magnitud) }}>
                    M {elegido.magnitud.toFixed(1)}
                  </p>
                  <p className="mt-1 font-medium">{elegido.lugar}</p>
                  <p className="text-xs text-panel-text-muted">
                    {hora(elegido.ocurridoEn)} · {elegido.lat.toFixed(3)}, {elegido.lng.toFixed(3)}
                  </p>
                </div>
                <button onClick={() => setElegido(null)} aria-label="Cerrar" className="text-panel-text-muted hover:text-panel-text">
                  <X size={18} />
                </button>
              </div>
              {!elegido.alertaId ? (
                <p className="mt-4 rounded-xl bg-slate-50 px-3 py-2 text-sm text-slate-700">
                  {elegido.enColombia ? 'Por su magnitud no generó alerta.' : 'Fuera de Colombia: solo informativo, no genera alerta.'}
                </p>
              ) : !checkIns ? (
                <p className="mt-4 text-sm text-panel-text-soft">Cargando el "¿Estás bien?"…</p>
              ) : (
                <div className="mt-4">
                  <p className="text-sm font-semibold">"¿Estás bien?" en la zona afectada</p>
                  <div className="mt-2 grid grid-cols-2 gap-2">
                    {(Object.keys(ESTADOS) as EstadoCheckIn[]).map((e) => (
                      <div key={e} className={`rounded-xl px-3 py-2 ${ESTADOS[e].color}`}>
                        <p className="text-xs">{ESTADOS[e].etiqueta}</p>
                        <p className="text-xl font-extrabold">{checkIns.resumen[e] ?? 0}</p>
                      </div>
                    ))}
                  </div>
                  <ul className="mt-3 max-h-72 divide-y divide-panel-border overflow-y-auto text-sm">
                    {checkIns.personas.map((p) => (
                      <li key={p.id} className="flex items-center justify-between gap-2 py-2">
                        <div>
                          <p className="font-medium">{p.nombre}</p>
                          {p.telefono && <p className="text-xs text-panel-text-muted">{p.telefono}</p>}
                        </div>
                        <span className={`rounded-full px-2 py-0.5 text-[11px] font-semibold ${ESTADOS[p.estado].color}`}>{ESTADOS[p.estado].etiqueta}</span>
                      </li>
                    ))}
                    {checkIns.personas.length === 0 && <li className="py-2 text-panel-text-soft">Nadie tenía su ubicación dentro del radio.</li>}
                  </ul>
                </div>
              )}
            </div>
          )}
        </aside>
      </div>

      <p className="mt-4 text-xs text-panel-text-muted">
        Información de fuentes sismológicas públicas (USGS); no es una alerta temprana oficial. Sigue las indicaciones del Servicio Geológico Colombiano y de la UNGRD.
      </p>
    </div>
  )
}
