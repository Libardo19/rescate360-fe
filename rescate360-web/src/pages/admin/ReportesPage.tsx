import { useEffect, useMemo, useState } from 'react'
import { Search, X, CheckCircle2, XCircle, Copy, Building2, Image as ImagenIcono, Sparkles } from 'lucide-react'
import {
  listarReportes,
  listarTipos,
  verificarReporte,
  rechazarReporte,
  marcarDuplicado,
  asignarOrganizacionReporte,
} from '../../services/reportes.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import { mensajeDeError } from '../../services/api'
import { useAuth } from '../../context/AuthContext'
import { useConsultaPeriodica } from '../../hooks/useConsultaPeriodica'
import CeldaVoluntario from '../../components/CeldaVoluntario'
import { prioridadEfectivaReporte } from '../../types/reporte'
import type { Reporte, EstadoReporte, TipoSugerido } from '../../types/reporte'
import type { Organizacion } from '../../types/organizacion'
import type { Prioridad } from '../../types/solicitud'

const etiquetaEstado: Record<EstadoReporte, string> = {
  pendiente: 'Pendiente',
  verificado: 'Verificado',
  atendido: 'Atendido',
  rechazado: 'Rechazado',
  duplicado: 'Duplicado',
  no_verificable: 'No verificable',
}

const colorEstado: Record<EstadoReporte, string> = {
  pendiente: 'bg-amber-100 text-amber-700',
  verificado: 'bg-green-100 text-green-700',
  atendido: 'bg-blue-100 text-blue-700',
  rechazado: 'bg-red-100 text-red-700',
  duplicado: 'bg-slate-200 text-slate-600',
  no_verificable: 'bg-slate-200 text-slate-600',
}

const etiquetaPrioridad: Record<Prioridad, string> = {
  pendiente: 'Sin clasificar',
  baja: 'Baja',
  media: 'Media',
  alta: 'Alta',
  critica: 'Crítica',
}

const colorPrioridad: Record<Prioridad, string> = {
  pendiente: 'bg-slate-200 text-slate-600',
  baja: 'bg-slate-100 text-slate-600',
  media: 'bg-amber-100 text-amber-700',
  alta: 'bg-orange-100 text-orange-700',
  critica: 'bg-red-100 text-red-700',
}

// Valor especial del filtro: todo lo que el ciudadano escribió y no está en la lista sugerida
const OTROS = 'otros'

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function ReportesPage() {
  const [reportes, setReportes] = useState<Reporte[] | null>(null)
  const [tipos, setTipos] = useState<TipoSugerido[]>([])
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoReporte>('todos')
  const [filtroTipo, setFiltroTipo] = useState('todos')
  const [seleccionado, setSeleccionado] = useState<Reporte | null>(null)
  const [guardando, setGuardando] = useState(false)
  const [motivo, setMotivo] = useState('')
  const [original, setOriginal] = useState('')
  const { usuario } = useAuth()
  const esSuperAdmin = usuario?.rol === 'super_admin'
  const [organizaciones, setOrganizaciones] = useState<Organizacion[]>([])

  // Se refresca sola: cuando el voluntario finaliza, el admin lo ve "Atendido" sin recargar
  useConsultaPeriodica(() => {
    listarReportes()
      .then((lista) => {
        setReportes(lista)
        setSeleccionado((actual) => (actual ? (lista.find((r) => r.id === actual.id) ?? actual) : actual))
      })
      .catch((e) => setError(mensajeDeError(e, 'No se pudieron cargar los reportes.')))
  })

  useEffect(() => {
    listarTipos().then(setTipos).catch(() => {})
  }, [])

  useEffect(() => {
    if (esSuperAdmin) listarOrganizaciones().then(setOrganizaciones).catch(() => {})
  }, [esSuperAdmin])

  const sugeridos = useMemo(() => new Set(tipos.map((t) => t.valor)), [tipos])

  const filtrados = useMemo(() => {
    if (!reportes) return []
    const texto = busqueda.trim().toLowerCase()
    return reportes.filter((r) => {
      const coincideTexto =
        !texto ||
        r.descripcion.toLowerCase().includes(texto) ||
        r.ubicacion.toLowerCase().includes(texto) ||
        r.reportante.toLowerCase().includes(texto) ||
        r.tipoEtiqueta.toLowerCase().includes(texto)
      const coincideEstado = filtroEstado === 'todos' || r.estado === filtroEstado
      const coincideTipo =
        filtroTipo === 'todos' || (filtroTipo === OTROS ? !sugeridos.has(r.tipo) : r.tipo === filtroTipo)
      return coincideTexto && coincideEstado && coincideTipo
    })
  }, [reportes, busqueda, filtroEstado, filtroTipo, sugeridos])

  const abrir = (r: Reporte) => {
    setSeleccionado(r)
    setMotivo('')
    setOriginal('')
    setError('')
  }

  const guardar = async (accion: () => Promise<Reporte>) => {
    setGuardando(true)
    setError('')
    try {
      const actualizado = await accion()
      setReportes((lista) => lista?.map((r) => (r.id === actualizado.id ? actualizado : r)) ?? null)
      setSeleccionado(actualizado)
    } catch (e) {
      setError(mensajeDeError(e, 'No se pudo actualizar el reporte.'))
    } finally {
      setGuardando(false)
    }
  }

  if (error && !reportes) return <p className="text-panel-accent">{error}</p>
  if (!reportes) return <p className="text-panel-text-soft">Cargando…</p>

  const pendiente = seleccionado?.estado === 'pendiente'
  // Candidatos a "original" de un duplicado: los demás reportes del mismo tipo primero
  const candidatos = seleccionado
    ? reportes
        .filter((r) => r.id !== seleccionado.id && r.estado !== 'duplicado' && r.estado !== 'rechazado')
        .sort((a, b) => Number(b.tipo === seleccionado.tipo) - Number(a.tipo === seleccionado.tipo))
    : []

  return (
    <div>
      <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
        <span className="h-1.5 w-1.5 rounded-full bg-brand" />
        Operación
      </p>
      <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Reportes</h1>
      <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">
        Revisa los reportes de tu organización y verifícalos, recházalos o márcalos como duplicados. Un reporte
        verificado aparece en el mapa de todos los ciudadanos.
      </p>

      {error && !seleccionado && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 flex flex-col gap-3 sm:flex-row">
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
          <input
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            placeholder="Buscar por tipo, descripción, ubicación o persona"
            className={`${campo} w-full pl-9`}
          />
        </div>
        <select
          value={filtroEstado}
          onChange={(e) => setFiltroEstado(e.target.value as 'todos' | EstadoReporte)}
          className={campo}
        >
          <option value="todos">Todos los estados</option>
          {Object.entries(etiquetaEstado).map(([valor, etiqueta]) => (
            <option key={valor} value={valor}>
              {etiqueta}
            </option>
          ))}
        </select>
        <select value={filtroTipo} onChange={(e) => setFiltroTipo(e.target.value)} className={campo}>
          <option value="todos">Todos los tipos</option>
          {tipos.map((t) => (
            <option key={t.valor} value={t.valor}>
              {t.etiqueta}
            </option>
          ))}
          <option value={OTROS}>Otros (escritos por el ciudadano)</option>
        </select>
      </div>

      <p className="mt-3 text-xs text-panel-text-muted">
        Mostrando {filtrados.length} de {reportes.length} reportes
      </p>

      <div className="mt-2 max-w-full overflow-x-auto rounded-3xl border border-panel-border bg-panel-card">
        <table className="w-full min-w-[740px] text-left text-sm">
          <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Prioridad</th>
              <th className="px-5 py-3">Tipo</th>
              <th className="px-5 py-3">Descripción</th>
              <th className="px-5 py-3">Reportante</th>
              <th className="px-5 py-3">Fecha</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3">Voluntario</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {filtrados.length === 0 && (
              <tr>
                <td colSpan={8} className="px-5 py-10 text-center text-panel-text-soft">
                  No hay reportes con esos filtros.
                </td>
              </tr>
            )}
            {filtrados.map((r) => {
              const prioridad = prioridadEfectivaReporte(r)
              return (
                <tr key={r.id} className="border-t border-panel-border">
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorPrioridad[prioridad]}`}>
                      {etiquetaPrioridad[prioridad]}
                    </span>
                    <p className="mt-1 text-[11px] text-panel-text-muted">
                      {r.prioridadManual ? 'Manual' : r.prioridadIA === 'pendiente' ? 'Sin clasificar' : 'Sugerida por IA'}
                    </p>
                  </td>
                  <td className="px-5 py-3 font-medium">
                    {r.tipoEtiqueta}
                    {r.evidencias.length > 0 && (
                      <span className="ml-2 inline-flex items-center gap-0.5 text-xs font-normal text-panel-text-muted">
                        <ImagenIcono size={12} /> {r.evidencias.length}
                      </span>
                    )}
                  </td>
                  <td className="px-5 py-3">
                    <p className="max-w-xs truncate">{r.descripcion}</p>
                    <p className="text-xs text-panel-text-muted">{r.ubicacion}</p>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">{r.reportante}</td>
                  <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(r.fecha)}</td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorEstado[r.estado]}`}>
                      {etiquetaEstado[r.estado]}
                    </span>
                  </td>
                  <td className="px-5 py-3">
                    <CeldaVoluntario atencion={r.atencion} />
                  </td>
                  <td className="px-5 py-3 text-right">
                    <button onClick={() => abrir(r)} className="text-sm font-semibold text-panel-primary hover:underline">
                      Ver detalle
                    </button>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {seleccionado && (
        <div
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setSeleccionado(null)}
        >
          <div
            className="max-h-[calc(100dvh-2rem)] w-full max-w-lg overflow-y-auto rounded-2xl bg-panel-card p-6 shadow-2xl sm:max-h-[calc(100dvh-3rem)]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-xl font-semibold tracking-[-0.02em]">{seleccionado.tipoEtiqueta}</h2>
                <span
                  className={`mt-2 inline-block rounded-full px-3 py-1 text-xs font-medium ${colorEstado[seleccionado.estado]}`}
                >
                  {etiquetaEstado[seleccionado.estado]}
                </span>
              </div>
              <button onClick={() => setSeleccionado(null)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <dl className="mt-5 space-y-3 text-sm">
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Descripción</dt>
                <dd>{seleccionado.descripcion}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Ubicación</dt>
                <dd>{seleccionado.ubicacion}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Reportado por</dt>
                <dd>{seleccionado.reportante}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Fecha</dt>
                <dd>{formatearFecha(seleccionado.fecha)}</dd>
              </div>
              {seleccionado.motivoRechazo && (
                <div>
                  <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Motivo del rechazo</dt>
                  <dd>{seleccionado.motivoRechazo}</dd>
                </div>
              )}
            </dl>

            <div className="mt-5 rounded-xl bg-panel-bg p-4 text-sm">
              <p className="flex items-center gap-2 font-semibold">
                <Sparkles size={16} className="text-panel-info" />
                Sugerencia de la IA:
                <span className={`rounded-full px-2 py-0.5 text-xs ${colorPrioridad[seleccionado.prioridadIA]}`}>
                  {etiquetaPrioridad[seleccionado.prioridadIA]}
                </span>
              </p>
              <p className="mt-1 text-panel-text-soft">{seleccionado.motivoIA}</p>
              {seleccionado.confianzaIA !== null && (
                <p className="mt-1 text-xs text-panel-text-muted">
                  Confianza: {Math.round(seleccionado.confianzaIA * 100)}%
                </p>
              )}
            </div>

            {seleccionado.evidencias.length > 0 && (
              <div className="mt-5 grid grid-cols-2 gap-2 sm:grid-cols-3">
                {seleccionado.evidencias.map((e) =>
                  e.tipo === 'foto' ? (
                    <a key={e.id} href={e.url} target="_blank" rel="noreferrer">
                      <img src={e.url} alt="Evidencia del reporte" className="h-28 w-full rounded-lg object-cover" />
                    </a>
                  ) : (
                    <video key={e.id} src={e.url} controls className="h-28 w-full rounded-lg bg-black object-cover" />
                  ),
                )}
              </div>
            )}

            {esSuperAdmin && (
              <div className="mt-5">
                <label htmlFor="organizacion" className="flex items-center gap-2 text-sm font-semibold">
                  <Building2 size={16} className="text-panel-primary" /> Organización que lo atiende
                </label>
                <select
                  id="organizacion"
                  value={seleccionado.organizacionId ?? ''}
                  disabled={guardando || !pendiente}
                  onChange={(e) => e.target.value && guardar(() => asignarOrganizacionReporte(seleccionado.id, e.target.value))}
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
              </div>
            )}

            {error && <p className="mt-4 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

            {pendiente ? (
              <div className="mt-6 space-y-3">
                <button
                  disabled={guardando}
                  onClick={() => guardar(() => verificarReporte(seleccionado.id))}
                  className="flex w-full items-center justify-center gap-2 rounded-lg bg-panel-success px-4 py-2 text-sm font-semibold text-white transition hover:opacity-90 disabled:opacity-40"
                >
                  <CheckCircle2 size={16} /> Verificar
                </button>

                <div className="flex gap-2">
                  <input
                    value={motivo}
                    onChange={(e) => setMotivo(e.target.value)}
                    maxLength={200}
                    placeholder="Motivo del rechazo (opcional)"
                    className={`${campo} flex-1`}
                  />
                  <button
                    disabled={guardando}
                    onClick={() => guardar(() => rechazarReporte(seleccionado.id, motivo.trim()))}
                    className="flex items-center justify-center gap-2 rounded-lg border border-panel-accent px-4 py-2 text-sm font-semibold text-panel-accent transition hover:bg-red-50 disabled:opacity-40"
                  >
                    <XCircle size={16} /> Rechazar
                  </button>
                </div>

                <div className="flex gap-2">
                  <select value={original} onChange={(e) => setOriginal(e.target.value)} className={`${campo} min-w-0 flex-1`}>
                    <option value="">Es duplicado de…</option>
                    {candidatos.map((r) => (
                      <option key={r.id} value={r.id}>
                        {r.tipoEtiqueta} · {r.ubicacion} · {formatearFecha(r.fecha)}
                      </option>
                    ))}
                  </select>
                  <button
                    disabled={guardando || !original}
                    onClick={() => guardar(() => marcarDuplicado(seleccionado.id, original))}
                    className="flex items-center justify-center gap-2 rounded-full border border-panel-border px-4 py-2 text-sm font-semibold text-panel-text-soft transition hover:bg-panel-bg disabled:opacity-40"
                  >
                    <Copy size={16} /> Duplicado
                  </button>
                </div>
              </div>
            ) : (
              <p className="mt-6 rounded-lg bg-panel-bg px-3 py-2 text-xs text-panel-text-soft">
                Este reporte ya fue revisado. Solo los reportes pendientes se pueden verificar, rechazar o marcar como duplicados.
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
