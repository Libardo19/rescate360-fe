import { useEffect, useMemo, useState } from 'react'
import { Search, X, Sparkles, UserCog } from 'lucide-react'
import { listarSolicitudes, actualizarSolicitud } from '../../services/solicitudes.service'
import { prioridadEfectiva } from '../../types/solicitud'
import type { Solicitud, CambiosSolicitud, EstadoSolicitud, Prioridad, TipoAyuda } from '../../types/solicitud'

const etiquetaTipo: Record<TipoAyuda, string> = {
  medica: 'Médica',
  alimentaria: 'Alimentaria',
  refugio: 'Refugio',
  rescate: 'Rescate',
  otro: 'Otro',
}

const etiquetaEstado: Record<EstadoSolicitud, string> = {
  pendiente: 'Pendiente',
  en_proceso: 'En proceso',
  atendida: 'Atendida',
  cancelada: 'Cancelada',
}

const colorEstado: Record<EstadoSolicitud, string> = {
  pendiente: 'bg-amber-100 text-amber-700',
  en_proceso: 'bg-blue-100 text-blue-700',
  atendida: 'bg-green-100 text-green-700',
  cancelada: 'bg-slate-200 text-slate-600',
}

const etiquetaPrioridad: Record<Prioridad, string> = { alta: 'Alta', media: 'Media', baja: 'Baja' }

const colorPrioridad: Record<Prioridad, string> = {
  alta: 'bg-red-100 text-red-700',
  media: 'bg-amber-100 text-amber-700',
  baja: 'bg-green-100 text-green-700',
}

const peso: Record<Prioridad, number> = { alta: 0, media: 1, baja: 2 }

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function SolicitudesPage() {
  const [solicitudes, setSolicitudes] = useState<Solicitud[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoSolicitud>('todos')
  const [filtroPrioridad, setFiltroPrioridad] = useState<'todas' | Prioridad>('todas')
  const [filtroTipo, setFiltroTipo] = useState<'todos' | TipoAyuda>('todos')
  const [seleccionada, setSeleccionada] = useState<Solicitud | null>(null)
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarSolicitudes()
      .then(setSolicitudes)
      .catch(() => setError('No se pudieron cargar las solicitudes.'))
  }, [])

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
        const coincideTipo = filtroTipo === 'todos' || s.tipo === filtroTipo
        return coincideTexto && coincideEstado && coincidePrioridad && coincideTipo
      })
      .sort((a, b) => {
        const porPrioridad = peso[prioridadEfectiva(a)] - peso[prioridadEfectiva(b)]
        return porPrioridad !== 0 ? porPrioridad : b.fecha.localeCompare(a.fecha)
      })
  }, [solicitudes, busqueda, filtroEstado, filtroPrioridad, filtroTipo])

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
          onChange={(e) => setFiltroPrioridad(e.target.value as 'todas' | Prioridad)}
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
          value={filtroTipo}
          onChange={(e) => setFiltroTipo(e.target.value as 'todos' | TipoAyuda)}
          className={campo}
        >
          <option value="todos">Todos los tipos</option>
          {Object.entries(etiquetaTipo).map(([valor, etiqueta]) => (
            <option key={valor} value={valor}>
              {etiqueta}
            </option>
          ))}
        </select>
      </div>

      <p className="mt-3 text-xs text-panel-text-muted">
        Mostrando {filtradas.length} de {solicitudes.length} solicitudes
      </p>

      <div className="mt-2 overflow-x-auto rounded-2xl border border-panel-border bg-panel-card">
        <table className="w-full text-left text-sm">
          <thead className="text-xs uppercase text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Prioridad</th>
              <th className="px-5 py-3">Tipo</th>
              <th className="px-5 py-3">Descripción</th>
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
              return (
                <tr key={s.id} className="border-t border-panel-border">
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorPrioridad[prioridad]}`}>
                      {etiquetaPrioridad[prioridad]}
                    </span>
                    <p className="mt-1 text-[11px] text-panel-text-muted">{s.prioridadManual ? 'Manual' : 'Sugerida por IA'}</p>
                  </td>
                  <td className="px-5 py-3 font-medium">{etiquetaTipo[s.tipo]}</td>
                  <td className="px-5 py-3">
                    <p className="max-w-xs truncate">{s.descripcion}</p>
                    <p className="text-xs text-panel-text-muted">{s.ubicacion}</p>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">{s.solicitante}</td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorEstado[s.estado]}`}>
                      {etiquetaEstado[s.estado]}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(s.fecha)}</td>
                  <td className="px-5 py-3 text-right">
                    <button
                      onClick={() => setSeleccionada(s)}
                      className="text-sm font-semibold text-panel-primary hover:underline"
                    >
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
                <h2 className="text-xl font-extrabold text-panel-primary">
                  Ayuda {etiquetaTipo[seleccionada.tipo].toLowerCase()}
                </h2>
                <p className="mt-1 text-xs text-panel-text-muted">{formatearFecha(seleccionada.fecha)}</p>
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
              <p className="flex items-center gap-2 font-semibold">
                <Sparkles size={16} className="text-panel-info" />
                Sugerencia de la IA:
                <span className={`rounded-full px-2 py-0.5 text-xs ${colorPrioridad[seleccionada.prioridadIA]}`}>
                  {etiquetaPrioridad[seleccionada.prioridadIA]}
                </span>
              </p>
              <p className="mt-1 text-panel-text-soft">{seleccionada.motivoIA}</p>
            </div>

            <div className="mt-5">
              <p className="flex items-center gap-2 text-sm font-semibold">
                <UserCog size={16} className="text-panel-primary" /> Prioridad manual
              </p>
              <div className="mt-2 flex flex-wrap gap-2">
                {(['alta', 'media', 'baja'] as Prioridad[]).map((p) => (
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
          </div>
        </div>
      )}
    </div>
  )
}