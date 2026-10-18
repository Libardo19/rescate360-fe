import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { MapContainer, TileLayer, Circle, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import {
  TriangleAlert,
  ShieldAlert,
  MapPin,
  Eye,
  Search,
  Plus,
  Pencil,
  Power,
  X,
  Waves,
  Mountain,
  Flame,
  type LucideIcon,
} from 'lucide-react'
import VolarA from '../../components/VolarA'
import { listarZonas, crearZona, actualizarZona } from '../../services/zonas.service'
import type { Zona, DatosZona, EstadoZona, NivelRiesgo, TipoRiesgo } from '../../types/zona'

const CENTRO_MAPA: [number, number] = [10.4631, -73.2532]

const riesgos: Record<TipoRiesgo, { etiqueta: string; icono: LucideIcon }> = {
  inundacion: { etiqueta: 'Inundación', icono: Waves },
  deslizamiento: { etiqueta: 'Deslizamiento', icono: Mountain },
  incendio: { etiqueta: 'Incendio', icono: Flame },
  seguridad: { etiqueta: 'Seguridad', icono: ShieldAlert },
}

const niveles: Record<NivelRiesgo, { etiqueta: string; clase: string; color: string }> = {
  alto: { etiqueta: 'Alto', clase: 'bg-red-100 text-red-700', color: '#e5534b' },
  medio: { etiqueta: 'Medio', clase: 'bg-amber-100 text-amber-700', color: '#f5a524' },
  bajo: { etiqueta: 'Bajo', clase: 'bg-green-100 text-green-700', color: '#2fa96b' },
}

const estados: Record<EstadoZona, { etiqueta: string; clase: string }> = {
  activa: { etiqueta: 'Activa', clase: 'bg-green-100 text-green-700' },
  en_monitoreo: { etiqueta: 'En monitoreo', clase: 'bg-amber-100 text-amber-700' },
  inactiva: { etiqueta: 'Inactiva', clase: 'bg-slate-200 text-slate-600' },
}

const campo =
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

interface FormZona {
  nombre: string
  tipoRiesgo: TipoRiesgo
  nivel: NivelRiesgo
  estado: EstadoZona
  descripcion: string
  lat: string
  lng: string
  radio: string
}

const formVacio: FormZona = {
  nombre: '',
  tipoRiesgo: 'inundacion',
  nivel: 'medio',
  estado: 'activa',
  descripcion: '',
  lat: String(CENTRO_MAPA[0]),
  lng: String(CENTRO_MAPA[1]),
  radio: '500',
}

type Modal = { modo: 'crear' } | { modo: 'editar'; zona: Zona } | null

export default function ZonasPage() {
  const [zonas, setZonas] = useState<Zona[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroRiesgo, setFiltroRiesgo] = useState<'todos' | TipoRiesgo>('todos')
  const [filtroNivel, setFiltroNivel] = useState<'todos' | NivelRiesgo>('todos')
  const [enfocada, setEnfocada] = useState<Zona | null>(null)
  const [modal, setModal] = useState<Modal>(null)
  const [form, setForm] = useState<FormZona>(formVacio)
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  const enfocarZonaEnMapa = (zona: Zona) => {
    setEnfocada(zona)
    document.getElementById('zonas-map')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  useEffect(() => {
    listarZonas()
      .then(setZonas)
      .catch(() => setError('No se pudieron cargar las zonas.'))
  }, [])

  const filtradas = useMemo(() => {
    if (!zonas) return []
    const texto = busqueda.trim().toLowerCase()
    return zonas.filter((z) => {
      const coincideTexto = !texto || z.nombre.toLowerCase().includes(texto)
      const coincideRiesgo = filtroRiesgo === 'todos' || z.tipoRiesgo === filtroRiesgo
      const coincideNivel = filtroNivel === 'todos' || z.nivel === filtroNivel
      return coincideTexto && coincideRiesgo && coincideNivel
    })
  }, [zonas, busqueda, filtroRiesgo, filtroNivel])

  const resumen = useMemo(() => {
    const lista = zonas ?? []
    return {
      total: lista.length,
      altas: lista.filter((z) => z.nivel === 'alto' && z.estado !== 'inactiva').length,
      activas: lista.filter((z) => z.estado === 'activa').length,
      monitoreo: lista.filter((z) => z.estado === 'en_monitoreo').length,
    }
  }, [zonas])

  const abrirCrear = () => {
    setForm(formVacio)
    setErrorForm('')
    setModal({ modo: 'crear' })
  }

  const abrirEditar = (z: Zona) => {
    setForm({
      nombre: z.nombre,
      tipoRiesgo: z.tipoRiesgo,
      nivel: z.nivel,
      estado: z.estado,
      descripcion: z.descripcion,
      lat: String(z.lat),
      lng: String(z.lng),
      radio: String(z.radio),
    })
    setErrorForm('')
    setModal({ modo: 'editar', zona: z })
  }

  const guardar = async (e: FormEvent) => {
    e.preventDefault()
    const actual = modal
    if (!actual) return

    const lat = Number(form.lat)
    const lng = Number(form.lng)
    const radio = Number(form.radio)
    if (!form.nombre.trim() || !form.descripcion.trim()) {
      setErrorForm('Completa el nombre y la descripción.')
      return
    }
    if (!Number.isFinite(lat) || !Number.isFinite(lng) || Math.abs(lat) > 90 || Math.abs(lng) > 180) {
      setErrorForm('La latitud o la longitud no son válidas.')
      return
    }
    if (!Number.isFinite(radio) || radio <= 0) {
      setErrorForm('El radio debe ser un número mayor que cero.')
      return
    }

    const datos: DatosZona = {
      nombre: form.nombre.trim(),
      tipoRiesgo: form.tipoRiesgo,
      nivel: form.nivel,
      estado: form.estado,
      descripcion: form.descripcion.trim(),
      lat,
      lng,
      radio,
    }

    setGuardando(true)
    setErrorForm('')
    try {
      if (actual.modo === 'crear') {
        const nueva = await crearZona(datos)
        setZonas((lista) => [nueva, ...(lista ?? [])])
        setEnfocada(nueva)
      } else {
        const actualizada = await actualizarZona(actual.zona.id, datos)
        setZonas((lista) => lista?.map((z) => (z.id === actualizada.id ? actualizada : z)) ?? null)
        setEnfocada(actualizada)
      }
      setModal(null)
    } catch {
      setErrorForm('No se pudo guardar la zona.')
    } finally {
      setGuardando(false)
    }
  }

  const alternarEstado = async (z: Zona) => {
    const nuevo: EstadoZona = z.estado === 'inactiva' ? 'activa' : 'inactiva'
    const verbo = nuevo === 'inactiva' ? 'desactivar' : 'activar'
    if (!window.confirm(`¿Seguro que quieres ${verbo} la zona "${z.nombre}"?`)) return
    setError('')
    try {
      const actualizada = await actualizarZona(z.id, { estado: nuevo })
      setZonas((lista) => lista?.map((x) => (x.id === actualizada.id ? actualizada : x)) ?? null)
    } catch {
      setError('No se pudo cambiar el estado de la zona.')
    }
  }

  if (error && !zonas) return <p className="text-panel-accent">{error}</p>
  if (!zonas) return <p className="text-panel-text-soft">Cargando…</p>

  const tarjetas = [
    { valor: resumen.total, titulo: 'Zonas de riesgo', pie: 'Identificadas', icono: TriangleAlert, color: 'bg-red-500', pieColor: 'text-red-600' },
    { valor: resumen.altas, titulo: 'Con nivel alto', pie: 'Requieren atención', icono: ShieldAlert, color: 'bg-orange-500', pieColor: 'text-orange-600' },
    { valor: resumen.activas, titulo: 'Zonas activas', pie: 'Vigentes', icono: MapPin, color: 'bg-blue-500', pieColor: 'text-blue-600' },
    { valor: resumen.monitoreo, titulo: 'En monitoreo', pie: 'En observación', icono: Eye, color: 'bg-green-600', pieColor: 'text-green-600' },
  ]

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-panel-primary">Zonas peligrosas</h1>
          <p className="mt-1 text-sm text-panel-info">
            Consulta y gestiona las zonas de riesgo identificadas en tu comunidad.
          </p>
        </div>
        <button
          onClick={abrirCrear}
          className="flex items-center justify-center gap-2 rounded-lg bg-panel-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark"
        >
          <Plus size={16} /> Nueva zona
        </button>
      </div>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, pie, icono: Icono, color, pieColor }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-14 w-14 items-center justify-center rounded-full text-white ${color}`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-2xl font-extrabold">{valor}</p>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className={`text-xs font-medium ${pieColor}`}>{pie}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,3fr)]">
        <section id="zonas-map" className="min-w-0 scroll-mt-4 rounded-2xl border border-panel-border bg-panel-card p-5">
          <h2 className="font-bold">Mapa de zonas de riesgo</h2>
          <div className="mt-3 flex flex-wrap gap-3 text-xs text-panel-text-soft">
            {(Object.keys(niveles) as NivelRiesgo[]).map((n) => (
              <span key={n} className="flex items-center gap-1.5">
                <span className="h-3 w-3 rounded-full" style={{ backgroundColor: niveles[n].color }} />
                Nivel {niveles[n].etiqueta.toLowerCase()}
              </span>
            ))}
          </div>
          <div className="mt-3 overflow-hidden rounded-xl border border-panel-border">
            <MapContainer center={CENTRO_MAPA} zoom={12} scrollWheelZoom className="h-[420px] w-full">
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <VolarA lat={enfocada?.lat} lng={enfocada?.lng} zoom={14} />
              {filtradas.map((z) => (
                <Circle
                  key={z.id}
                  center={[z.lat, z.lng]}
                  radius={z.radio}
                  pathOptions={{
                    color: niveles[z.nivel].color,
                    weight: enfocada?.id === z.id ? 4 : 2,
                    fillColor: niveles[z.nivel].color,
                    fillOpacity: z.estado === 'inactiva' ? 0.06 : 0.25,
                    dashArray: z.estado === 'inactiva' ? '6' : undefined,
                  }}
                >
                  <Popup>
                    <p className="font-bold">{z.nombre}</p>
                    <p>
                      {riesgos[z.tipoRiesgo].etiqueta} · Nivel {niveles[z.nivel].etiqueta.toLowerCase()}
                    </p>
                    <p className="mt-1 text-xs">{z.descripcion}</p>
                  </Popup>
                </Circle>
              ))}
            </MapContainer>
          </div>
        </section>

        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card">
          <h2 className="px-5 pt-5 font-bold">Lista de zonas de riesgo</h2>

          <div className="flex flex-col gap-3 px-5 py-4 lg:flex-row">
            <div className="relative flex-1">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
              <input
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar zona"
                className={`${campo} pl-9`}
              />
            </div>
            <select
              value={filtroRiesgo}
              onChange={(e) => setFiltroRiesgo(e.target.value as 'todos' | TipoRiesgo)}
              className={`${campo} lg:w-40`}
            >
              <option value="todos">Todos los riesgos</option>
              {(Object.keys(riesgos) as TipoRiesgo[]).map((t) => (
                <option key={t} value={t}>
                  {riesgos[t].etiqueta}
                </option>
              ))}
            </select>
            <select
              value={filtroNivel}
              onChange={(e) => setFiltroNivel(e.target.value as 'todos' | NivelRiesgo)}
              className={`${campo} lg:w-36`}
            >
              <option value="todos">Todos los niveles</option>
              {(Object.keys(niveles) as NivelRiesgo[]).map((n) => (
                <option key={n} value={n}>
                  {niveles[n].etiqueta}
                </option>
              ))}
            </select>
          </div>

          <div className="max-w-full overflow-x-auto">
            <table className="w-full min-w-[600px] text-left text-sm">
              <thead className="text-xs uppercase text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Zona</th>
                  <th className="px-5 py-3">Tipo de riesgo</th>
                  <th className="px-5 py-3">Nivel</th>
                  <th className="px-5 py-3">Estado</th>
                  <th className="px-5 py-3 text-right">Acciones</th>
                </tr>
              </thead>
              <tbody>
                {filtradas.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay zonas con esos filtros.
                    </td>
                  </tr>
                )}
                {filtradas.map((z) => {
                  const { icono: Icono, etiqueta } = riesgos[z.tipoRiesgo]
                  return (
                    <tr key={z.id} className="border-t border-panel-border">
                      <td className="px-5 py-3 font-medium">{z.nombre}</td>
                      <td className="px-5 py-3">
                        <span className="flex items-center gap-2 text-panel-text-soft">
                          <Icono size={16} /> {etiqueta}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <span className={`rounded-full px-3 py-1 text-xs font-medium ${niveles[z.nivel].clase}`}>
                          {niveles[z.nivel].etiqueta}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <span className={`rounded-full px-3 py-1 text-xs font-medium ${estados[z.estado].clase}`}>
                          {estados[z.estado].etiqueta}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <div className="flex justify-end gap-1 text-panel-text-soft">
                          <button
                            onClick={() => enfocarZonaEnMapa(z)}
                            title="Ver en el mapa"
                            aria-label="Ver en el mapa"
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                          >
                            <MapPin size={16} />
                          </button>
                          <button
                            onClick={() => abrirEditar(z)}
                            title="Ver detalles y editar"
                            aria-label="Ver detalles y editar"
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                          >
                            <Pencil size={16} />
                          </button>
                          <button
                            onClick={() => alternarEstado(z)}
                            title={z.estado === 'inactiva' ? 'Activar' : 'Desactivar'}
                            aria-label={z.estado === 'inactiva' ? 'Activar' : 'Desactivar'}
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-accent"
                          >
                            <Power size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </section>
      </div>

      {modal && (
        <div
          className="fixed inset-0 z-[1000] flex items-center justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setModal(null)}
        >
          <form
            onSubmit={guardar}
            className="w-full max-w-lg rounded-2xl bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-extrabold text-panel-primary">
                {modal.modo === 'crear' ? 'Nueva zona de riesgo' : 'Detalles de la zona'}
              </h2>
              <button type="button" onClick={() => setModal(null)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="nombre" className="text-sm font-medium">
                  Nombre de la zona
                </label>
                <input
                  id="nombre"
                  value={form.nombre}
                  onChange={(e) => setForm({ ...form, nombre: e.target.value })}
                  placeholder="Ej: Ladera La Esperanza"
                  className={`${campo} mt-1`}
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-3">
                <div>
                  <label htmlFor="riesgo" className="text-sm font-medium">
                    Tipo de riesgo
                  </label>
                  <select
                    id="riesgo"
                    value={form.tipoRiesgo}
                    onChange={(e) => setForm({ ...form, tipoRiesgo: e.target.value as TipoRiesgo })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(riesgos) as TipoRiesgo[]).map((t) => (
                      <option key={t} value={t}>
                        {riesgos[t].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label htmlFor="nivel" className="text-sm font-medium">
                    Nivel
                  </label>
                  <select
                    id="nivel"
                    value={form.nivel}
                    onChange={(e) => setForm({ ...form, nivel: e.target.value as NivelRiesgo })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(niveles) as NivelRiesgo[]).map((n) => (
                      <option key={n} value={n}>
                        {niveles[n].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label htmlFor="estado" className="text-sm font-medium">
                    Estado
                  </label>
                  <select
                    id="estado"
                    value={form.estado}
                    onChange={(e) => setForm({ ...form, estado: e.target.value as EstadoZona })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(estados) as EstadoZona[]).map((s) => (
                      <option key={s} value={s}>
                        {estados[s].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label htmlFor="descripcion" className="text-sm font-medium">
                  Descripción
                </label>
                <textarea
                  id="descripcion"
                  rows={3}
                  value={form.descripcion}
                  onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
                  placeholder="Por qué es una zona de riesgo"
                  className={`${campo} mt-1`}
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-3">
                <div>
                  <label htmlFor="lat" className="text-sm font-medium">
                    Latitud
                  </label>
                  <input
                    id="lat"
                    type="number"
                    step="any"
                    value={form.lat}
                    onChange={(e) => setForm({ ...form, lat: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="lng" className="text-sm font-medium">
                    Longitud
                  </label>
                  <input
                    id="lng"
                    type="number"
                    step="any"
                    value={form.lng}
                    onChange={(e) => setForm({ ...form, lng: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="radio" className="text-sm font-medium">
                    Radio (metros)
                  </label>
                  <input
                    id="radio"
                    type="number"
                    min="1"
                    value={form.radio}
                    onChange={(e) => setForm({ ...form, radio: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
              </div>
            </div>

            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setModal(null)}
                className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark disabled:opacity-60"
              >
                {guardando ? 'Guardando…' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}