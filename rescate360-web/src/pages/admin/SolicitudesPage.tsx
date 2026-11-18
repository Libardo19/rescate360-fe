import { useEffect, useMemo, useState } from 'react'
import { Search, X, Sparkles, UserCog, Building2, Siren } from 'lucide-react'
import { listarSolicitudes, actualizarSolicitud, asignarOrganizacion } from '../../services/solicitudes.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import { mensajeDeError } from '../../services/api'
import { useAuth } from '../../context/AuthContext'
import { useConsultaPeriodica } from '../../hooks/useConsultaPeriodica'
import Semaforo from '../../components/panel/Semaforo'
import { useAhora, minutosDesde } from '../../utils/espera'
import CeldaVoluntario from '../../components/CeldaVoluntario'
import type { Organizacion } from '../../types/organizacion'
import { prioridadEfectiva } from '../../types/solicitud'
import type { Solicitud, CambiosSolicitud, EstadoSolicitud, Prioridad, TipoAyuda } from '../../types/solicitud'

const etiquetaTipo: Record<TipoAyuda, string> = {
  medica: 'Médica',
  alimentaria: 'Alimentaria',
  refugio: 'Refugio',
  rescate: 'Rescate',
  ropa: 'Ropa',
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

const etiquetaPrioridad: Record<Prioridad, string> = {
  critica: 'Crítica',
  alta: 'Alta',
  media: 'Media',
  baja: 'Baja',
  pendiente: 'Sin clasificar',
}

const colorPrioridad: Record<Prioridad, string> = {
  critica: 'bg-red-600 text-white',
  alta: 'bg-red-100 text-red-700',
  media: 'bg-amber-100 text-amber-700',
  baja: 'bg-green-100 text-green-700',
  pendiente: 'bg-slate-200 text-slate-600',
}

// Lo crítico primero; lo que la IA no ha clasificado va justo después, para que alguien lo revise
const peso: Record<Prioridad, number> = { critica: 0, pendiente: 1, alta: 2, media: 3, baja: 4 }

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function SolicitudesPage() {
  // Reloj del semáforo de espera: se actualiza solo cada 30 s.
  const ahora = useAhora()
  const [solicitudes, setSolicitudes] = useState<Solicitud[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoSolicitud>('todos')
  const [filtroPrioridad, setFiltroPrioridad] = useState<'todas' | Prioridad>('todas')
  const [filtroTipo, setFiltroTipo] = useState<'todos' | TipoAyuda>('todos')
  const [seleccionada, setSeleccionada] = useState<Solicitud | null>(null)
  const [guardando, setGuardando] = useState(false)
  const { usuario } = useAuth()
  const esSuperAdmin = usuario?.rol === 'super_admin'
  const [organizaciones, setOrganizaciones] = useState<Organizacion[]>([])

  // Se refresca sola: cuando el voluntario finaliza, el admin la ve "Atendida" sin recargar
  useConsultaPeriodica(() => {
    listarSolicitudes()
      .then((lista) => {
        setSolicitudes(lista)
        setSeleccionada((actual) => (actual ? (lista.find((s) => s.id === actual.id) ?? actual) : actual))
      })
      .catch((e) => setError(mensajeDeError(e, 'No se pudieron cargar las solicitudes.')))
  })

  useEffect(() => {
    if (esSuperAdmin) listarOrganizaciones().then(setOrganizaciones).catch(() => {})
  }, [esSuperAdmin])

  const nombreOrganizacion = (id: string | null) =>
    id ? (organizaciones.find((o) => o.id === id)?.nombre ?? 'Asignada') : 'Sin organización'

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

  const guardar = async (accion: () => Promise<Solicitud>) => {
    setGuardando(true)
    setError('')
    try {
      const actualizada = await accion()
      setSolicitudes((lista) => lista?.map((s) => (s.id === actualizada.id ? actualizada : s)) ?? null)
      setSeleccionada(actualizada)
    } catch (e) {
      setError(mensajeDeError(e, 'No se pudo actualizar la solicitud.'))
    } finally {
      setGuardando(false)
    }
  }

  const aplicar = (cambios: CambiosSolicitud) => {
    if (seleccionada) guardar(() => actualizarSolicitud(seleccionada.id, cambios))
  }

  const enrutar = (organizacionId: string) => {
    if (seleccionada && organizacionId) guardar(() => asignarOrganizacion(seleccionada.id, organizacionId))
  }

  if (error && !solicitudes) return <p className="text-panel-accent">{error}</p>
  if (!solicitudes) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
        <span className="h-1.5 w-1.5 rounded-full bg-brand" />
        Operación
      </p>
      <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Solicitudes de ayuda</h1>
      <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">
        Las solicitudes se ordenan por prioridad. La IA propone una prioridad, pero la que tú definas manualmente
        prevalece.
      </p>

      {error && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

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

      <div className="mt-2 max-w-full overflow-x-auto rounded-3xl border border-panel-border bg-panel-card">
        <table className="w-full min-w-[850px] text-left text-sm">
          <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Prioridad</th>
              <th className="px-5 py-3">Tipo</th>
              <th className="px-5 py-3">Descripción</th>
              <th className="px-5 py-3">Solicitante</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3">Voluntario</th>
              <th className="px-5 py-3">Espera</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && (
              <tr>
                <td colSpan={8} className="px-5 py-10 text-center text-panel-text-soft">
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
                    <p className="mt-1 text-[11px] text-panel-text-muted">
                      {s.prioridadManual ? 'Manual' : s.prioridadIA === 'pendiente' ? 'Sin clasificar' : 'Sugerida por IA'}
                    </p>
                  </td>
                  <td className="px-5 py-3 font-medium">
                    {s.origen === 'sos' ? (
                      <span className="inline-flex items-center gap-1 text-red-600">
                        <Siren size={14} /> SOS
                      </span>
                    ) : (
                      etiquetaTipo[s.tipo]
                    )}
                    {esSuperAdmin && <p className="text-[11px] font-normal text-panel-text-muted">{nombreOrganizacion(s.organizacionId)}</p>}
                  </td>
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
                  <td className="px-5 py-3">
                    <CeldaVoluntario atencion={s.atencion} />
                  </td>
                  <td className="whitespace-nowrap px-5 py-3">
                    {/* Semáforo: cuenta mientras nadie ha tomado la solicitud (verde, ámbar +15 min, rojo +30 min). */}
                    {s.estado === 'pendiente' && <Semaforo minutos={minutosDesde(s.fecha, ahora)} compacto />}
                    <p className={`text-[11px] text-panel-text-muted ${s.estado === 'pendiente' ? 'mt-1' : ''}`}>{formatearFecha(s.fecha)}</p>
                  </td>
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
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setSeleccionada(null)}
        >
          <div
            className="max-h-[calc(100dvh-2rem)] w-full max-w-lg overflow-y-auto rounded-2xl bg-panel-card p-6 shadow-2xl sm:max-h-[calc(100dvh-3rem)]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-xl font-semibold tracking-[-0.02em]">
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
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Descripción</dt>
                <dd>{seleccionada.descripcion}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Ubicación</dt>
                <dd>{seleccionada.ubicacion}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Solicitante</dt>
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
                {(['critica', 'alta', 'media', 'baja'] as Prioridad[]).map((p) => (
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
              </div>
            </div>

            {esSuperAdmin && (
              <div className="mt-5">
                <label htmlFor="organizacion" className="flex items-center gap-2 text-sm font-semibold">
                  <Building2 size={16} className="text-panel-primary" /> Organización que la atiende
                </label>
                <select
                  id="organizacion"
                  value={seleccionada.organizacionId ?? ''}
                  disabled={guardando}
                  onChange={(e) => enrutar(e.target.value)}
                  className={`${campo} mt-2 w-full`}
                >
                  <option value="" disabled>
                    Sin organización: elige una
                  </option>
                  {organizaciones
                    .filter((o) => o.activa)
                    .map((o) => (
                      <option key={o.id} value={o.id}>
                        {o.nombre}
                      </option>
                    ))}
                </select>
                <p className="mt-1 text-xs text-panel-text-muted">Al asignarla, su administrador y sus voluntarios la ven y la pueden tomar.</p>
              </div>
            )}

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