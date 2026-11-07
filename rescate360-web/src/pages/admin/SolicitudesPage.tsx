import { useEffect, useMemo, useState } from 'react'
import { Search, X, Sparkles, UserCog, Smartphone, Activity, ArrowRightLeft } from 'lucide-react'
import { listarSolicitudes, actualizarSolicitud } from '../../services/solicitudes.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import { useAuth } from '../../context/AuthContext'
import { prioridadEfectiva, organizacionEfectiva } from '../../types/solicitud'
import type {
  Solicitud,
  CambiosSolicitud,
  EstadoSolicitud,
  OrigenSolicitud,
  Prioridad,
  PrioridadIA,
} from '../../types/solicitud'
import type { Organizacion } from '../../types/organizacion'

const etiquetaEstado: Record<EstadoSolicitud, string> = {
  pendiente: 'Pendiente',
  en_atencion: 'En atención',
  resuelta: 'Resuelta',
}

const colorEstado: Record<EstadoSolicitud, string> = {
  pendiente: 'bg-amber-100 text-amber-700',
  en_atencion: 'bg-blue-100 text-blue-700',
  resuelta: 'bg-green-100 text-green-700',
}

const etiquetaPrioridad: Record<PrioridadIA, string> = {
  critica: 'Crítica',
  alta: 'Alta',
  media: 'Media',
  baja: 'Baja',
  pendiente: 'Sin clasificar',
}

const colorPrioridad: Record<PrioridadIA, string> = {
  critica: 'bg-red-600 text-white',
  alta: 'bg-red-100 text-red-700',
  media: 'bg-amber-100 text-amber-700',
  baja: 'bg-green-100 text-green-700',
  pendiente: 'bg-slate-200 text-slate-600',
}

// Las que la IA aún no clasificó van primero: hay que revisarlas a mano.
const peso: Record<PrioridadIA, number> = { pendiente: 0, critica: 1, alta: 2, media: 3, baja: 4 }

const origen: Record<OrigenSolicitud, { etiqueta: string; icono: typeof Smartphone }> = {
  manual: { etiqueta: 'Manual', icono: Smartphone },
  acelerometro: { etiqueta: 'Detección automática', icono: Activity },
}

const prioridadesManuales: Prioridad[] = ['critica', 'alta', 'media', 'baja']

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function SolicitudesPage() {
  const { usuario } = useAuth()
  const [solicitudes, setSolicitudes] = useState<Solicitud[] | null>(null)
  const [organizaciones, setOrganizaciones] = useState<Organizacion[]>([])
  const [error, setError] = useState('')
  const [aviso, setAviso] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoSolicitud>('todos')
  const [filtroPrioridad, setFiltroPrioridad] = useState<'todas' | PrioridadIA>('todas')
  const [filtroOrigen, setFiltroOrigen] = useState<'todos' | OrigenSolicitud>('todos')
  const [seleccionada, setSeleccionada] = useState<Solicitud | null>(null)
  const [destino, setDestino] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarSolicitudes()
      .then(setSolicitudes)
      .catch(() => setError('No se pudieron cargar las solicitudes.'))
    listarOrganizaciones()
      .then(setOrganizaciones)
      .catch(() => setOrganizaciones([]))
  }, [])

  const nombreOrganizacion = (id: string | null) =>
    organizaciones.find((o) => o.id === id)?.nombre ?? 'Sin asignar'

  const otrasOrganizaciones = organizaciones.filter((o) => o.id !== usuario?.organizacion_id)

  const filtradas = useMemo(() => {
    if (!solicitudes) return []
    const texto = busqueda.trim().toLowerCase()
    return solicitudes
      .filter((s) => {
        const coincideTexto =
          !texto ||
          s.descripcion.toLowerCase().includes(texto) ||
          s.ubicacion.toLowerCase().includes(texto) ||
          s.solicitante.toLowerCase().includes(texto)
        const coincideEstado = filtroEstado === 'todos' || s.estado === filtroEstado
        const coincidePrioridad = filtroPrioridad === 'todas' || prioridadEfectiva(s) === filtroPrioridad
        const coincideOrigen = filtroOrigen === 'todos' || s.origen === filtroOrigen
        return coincideTexto && coincideEstado && coincidePrioridad && coincideOrigen
      })
      .sort((a, b) => {
        const porPrioridad = peso[prioridadEfectiva(a)] - peso[prioridadEfectiva(b)]
        return porPrioridad !== 0 ? porPrioridad : b.fecha.localeCompare(a.fecha)
      })
  }, [solicitudes, busqueda, filtroEstado, filtroPrioridad, filtroOrigen])

  const abrir = (s: Solicitud) => {
    setDestino('')
    setSeleccionada(s)
  }

  const aplicar = async (cambios: CambiosSolicitud) => {
    if (!seleccionada) return
    setGuardando(true)
    setError('')
    try {
      const actualizada = await actualizarSolicitud(seleccionada.id, cambios)
      setSolicitudes((lista) => lista?.map((s) => (s.id === actualizada.id ? actualizada : s)) ?? null)
      setSeleccionada(actualizada)
    } catch {
      setError('No se pudo actualizar la solicitud.')
    } finally {
      setGuardando(false)
    }
  }

  // Al reasignarla, la solicitud pasa a la otra organización y este admin deja de tener acceso.
  const reasignar = async () => {
    if (!seleccionada || !destino) return
    const nombre = nombreOrganizacion(destino)
    if (!window.confirm(`¿Reasignar esta solicitud a ${nombre}? Dejará de aparecer en tu lista.`)) return
    setGuardando(true)
    setError('')
    try {
      await actualizarSolicitud(seleccionada.id, { organizacionManualId: destino })
      setSolicitudes((lista) => lista?.filter((s) => s.id !== seleccionada.id) ?? null)
      setSeleccionada(null)
      setAviso(`La solicitud se reasignó a ${nombre}.`)
    } catch {
      setError('No se pudo reasignar la solicitud.')
    } finally {
      setGuardando(false)
    }
  }

  if (error && !solicitudes) return <p className="text-panel-accent">{error}</p>
  if (!solicitudes) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Solicitudes de ayuda</h1>
      <p className="mt-1 text-sm text-panel-text-soft">
        Las solicitudes se ordenan por prioridad. La IA propone una prioridad, pero la que tú definas manualmente
        prevalece.
      </p>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
      {aviso && (
        <p className="mt-3 flex items-center justify-between gap-3 rounded-lg bg-green-50 px-3 py-2 text-sm text-green-700">
          {aviso}
          <button onClick={() => setAviso('')} aria-label="Cerrar aviso">
            <X size={14} />
          </button>
        </p>
      )}

      <div className="mt-6 flex flex-col gap-3 lg:flex-row">
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
          <input
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            placeholder="Buscar por descripción, ubicación o persona"
            className={`${campo} w-full pl-9`}
          />
        </div>
        <select
          value={filtroPrioridad}
          onChange={(e) => setFiltroPrioridad(e.target.value as 'todas' | PrioridadIA)}
          className={campo}
        >
          <option value="todas">Todas las prioridades</option>
          {Object.entries(etiquetaPrioridad).map(([valor, etiqueta]) => (
            <option key={valor} value={valor}>
              {etiqueta}
            </option>
          ))}
        </select>
        <select
          value={filtroEstado}
          onChange={(e) => setFiltroEstado(e.target.value as 'todos' | EstadoSolicitud)}
          className={campo}
        >
          <option value="todos">Todos los estados</option>
          {Object.entries(etiquetaEstado).map(([valor, etiqueta]) => (
            <option key={valor} value={valor}>
              {etiqueta}
            </option>
          ))}
        </select>
        <select
          value={filtroOrigen}
          onChange={(e) => setFiltroOrigen(e.target.value as 'todos' | OrigenSolicitud)}
          className={campo}
        >
          <option value="todos">Todos los orígenes</option>
          {(Object.keys(origen) as OrigenSolicitud[]).map((o) => (
            <option key={o} value={o}>
              {origen[o].etiqueta}
            </option>
          ))}
        </select>
      </div>

      <p className="mt-3 text-xs text-panel-text-muted">
        Mostrando {filtradas.length} de {solicitudes.length} solicitudes
      </p>

      <div className="mt-2 max-w-full overflow-x-auto rounded-2xl border border-panel-border bg-panel-card">
        <table className="w-full min-w-[850px] text-left text-sm">
          <thead className="text-xs uppercase text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Prioridad</th>
              <th className="px-5 py-3">Descripción</th>
              <th className="px-5 py-3">Origen</th>
              <th className="px-5 py-3">Solicitante</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3">Fecha</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && (
              <tr>
                <td colSpan={7} className="px-5 py-10 text-center text-panel-text-soft">
                  No hay solicitudes con esos filtros.
                </td>
              </tr>
            )}
            {filtradas.map((s) => {
              const prioridad = prioridadEfectiva(s)
              const { etiqueta, icono: IconoOrigen } = origen[s.origen]
              return (
                <tr key={s.id} className="border-t border-panel-border">
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorPrioridad[prioridad]}`}>
                      {etiquetaPrioridad[prioridad]}
                    </span>
                    <p className="mt-1 text-[11px] text-panel-text-muted">
                      {s.prioridadManual ? 'Manual' : 'Sugerida por IA'}
                    </p>
                  </td>
                  <td className="px-5 py-3">
                    <p className="max-w-xs truncate">{s.descripcion}</p>
                    <p className="text-xs text-panel-text-muted">{s.ubicacion}</p>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">
                    <span className="flex items-center gap-1.5 whitespace-nowrap">
                      <IconoOrigen size={14} /> {etiqueta}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">{s.solicitante}</td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorEstado[s.estado]}`}>
                      {etiquetaEstado[s.estado]}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(s.fecha)}</td>
                  <td className="px-5 py-3 text-right">
                    <button onClick={() => abrir(s)} className="text-sm font-semibold text-panel-primary hover:underline">
                      Gestionar
                    </button>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {seleccionada && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setSeleccionada(null)}
        >
          <div
            className="w-full max-w-lg rounded-2xl bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-xl font-extrabold text-panel-primary">Solicitud de ayuda</h2>
                <p className="mt-1 text-xs text-panel-text-muted">
                  {formatearFecha(seleccionada.fecha)} · {origen[seleccionada.origen].etiqueta}
                </p>
              </div>
              <button onClick={() => setSeleccionada(null)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <dl className="mt-5 space-y-3 text-sm">
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Descripción</dt>
                <dd>{seleccionada.descripcion}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Ubicación</dt>
                <dd>{seleccionada.ubicacion}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Solicitante</dt>
                <dd>
                  {seleccionada.solicitante} · {seleccionada.telefono}
                </dd>
              </div>
            </dl>

            <div className="mt-5 rounded-xl bg-panel-bg p-4 text-sm">
              <p className="flex flex-wrap items-center gap-2 font-semibold">
                <Sparkles size={16} className="text-panel-info" />
                Sugerencia de la IA:
                <span className={`rounded-full px-2 py-0.5 text-xs ${colorPrioridad[seleccionada.prioridadIA]}`}>
                  {etiquetaPrioridad[seleccionada.prioridadIA]}
                </span>
                {seleccionada.confianzaIA !== null && (
                  <span className="text-xs font-normal text-panel-text-muted">
                    {Math.round(seleccionada.confianzaIA * 100)}% de confianza
                  </span>
                )}
              </p>
              <p className="mt-1 text-panel-text-soft">{seleccionada.motivoIA}</p>
            </div>

            <div className="mt-5">
              <p className="flex items-center gap-2 text-sm font-semibold">
                <UserCog size={16} className="text-panel-primary" /> Prioridad manual
              </p>
              <div className="mt-2 flex flex-wrap gap-2">
                {prioridadesManuales.map((p) => (
                  <button
                    key={p}
                    disabled={guardando}
                    onClick={() => aplicar({ prioridadManual: p })}
                    className={`rounded-lg border px-4 py-2 text-sm font-medium transition disabled:opacity-50 ${
                      seleccionada.prioridadManual === p
                        ? 'border-panel-primary bg-panel-primary text-white'
                        : 'border-panel-border text-panel-text-soft hover:bg-panel-bg'
                    }`}
                  >
                    {etiquetaPrioridad[p]}
                  </button>
                ))}
                {seleccionada.prioridadManual && (
                  <button
                    disabled={guardando}
                    onClick={() => aplicar({ prioridadManual: null })}
                    className="rounded-lg px-3 py-2 text-sm text-panel-primary hover:underline disabled:opacity-50"
                  >
                    Usar la de la IA
                  </button>
                )}
              </div>
            </div>

            <div className="mt-5">
              <label htmlFor="estado" className="text-sm font-semibold">
                Estado
              </label>
              <select
                id="estado"
                value={seleccionada.estado}
                disabled={guardando}
                onChange={(e) => aplicar({ estado: e.target.value as EstadoSolicitud })}
                className={`${campo} mt-2 w-full`}
              >
                {Object.entries(etiquetaEstado).map(([valor, etiqueta]) => (
                  <option key={valor} value={valor}>
                    {etiqueta}
                  </option>
                ))}
              </select>
            </div>

            <div className="mt-5 border-t border-panel-border pt-5">
              <p className="flex items-center gap-2 text-sm font-semibold">
                <ArrowRightLeft size={16} className="text-panel-primary" /> Organización
              </p>
              <p className="mt-1 text-xs text-panel-text-muted">
                Asignada a {nombreOrganizacion(organizacionEfectiva(seleccionada))}
                {seleccionada.organizacionManualId ? ' (reasignada manualmente)' : ''}. Si otra entidad debe
                atenderla, reasígnala.
              </p>
              <div className="mt-2 flex flex-col gap-2 sm:flex-row">
                <select
                  aria-label="Organización destino"
                  value={destino}
                  disabled={guardando}
                  onChange={(e) => setDestino(e.target.value)}
                  className={`${campo} flex-1`}
                >
                  <option value="">Elegir organización…</option>
                  {otrasOrganizaciones.map((o) => (
                    <option key={o.id} value={o.id}>
                      {o.nombre}
                    </option>
                  ))}
                </select>
                <button
                  disabled={guardando || !destino}
                  onClick={reasignar}
                  className="rounded-lg border border-panel-primary px-4 py-2 text-sm font-semibold text-panel-primary transition hover:bg-panel-bg disabled:opacity-40"
                >
                  Reasignar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
