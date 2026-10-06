import { useEffect, useMemo, useState } from 'react'
import { Search, X, CheckCircle2, XCircle, Copy } from 'lucide-react'
import { listarReportes, cambiarEstadoReporte } from '../../services/reportes.service'
import type { Reporte, EstadoReporte, TipoIncidente } from '../../types/reporte'

const etiquetaTipo: Record<TipoIncidente, string> = {
  accidente: 'Accidente',
  robo: 'Robo',
  inundacion: 'Inundación',
  deslizamiento: 'Deslizamiento',
  incendio: 'Incendio',
  otro: 'Otro',
}

const etiquetaEstado: Record<EstadoReporte, string> = {
  pendiente: 'Pendiente',
  verificado: 'Verificado',
  rechazado: 'Rechazado',
  duplicado: 'Duplicado',
}

const colorEstado: Record<EstadoReporte, string> = {
  pendiente: 'bg-amber-100 text-amber-700',
  verificado: 'bg-green-100 text-green-700',
  rechazado: 'bg-red-100 text-red-700',
  duplicado: 'bg-slate-200 text-slate-600',
}

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function ReportesPage() {
  const [reportes, setReportes] = useState<Reporte[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoReporte>('todos')
  const [filtroTipo, setFiltroTipo] = useState<'todos' | TipoIncidente>('todos')
  const [seleccionado, setSeleccionado] = useState<Reporte | null>(null)
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarReportes()
      .then(setReportes)
      .catch(() => setError('No se pudieron cargar los reportes.'))
  }, [])

  const filtrados = useMemo(() => {
    if (!reportes) return []
    const texto = busqueda.trim().toLowerCase()
    return reportes.filter((r) => {
      const coincideTexto =
        !texto ||
        r.descripcion.toLowerCase().includes(texto) ||
        r.ubicacion.toLowerCase().includes(texto) ||
        r.reportante.toLowerCase().includes(texto)
      const coincideEstado = filtroEstado === 'todos' || r.estado === filtroEstado
      const coincideTipo = filtroTipo === 'todos' || r.tipo === filtroTipo
      return coincideTexto && coincideEstado && coincideTipo
    })
  }, [reportes, busqueda, filtroEstado, filtroTipo])

  const cambiarEstado = async (estado: Exclude<EstadoReporte, 'pendiente'>) => {
    if (!seleccionado) return
    setGuardando(true)
    try {
      const actualizado = await cambiarEstadoReporte(seleccionado.id, estado)
      setReportes((lista) => lista?.map((r) => (r.id === actualizado.id ? actualizado : r)) ?? null)
      setSeleccionado(actualizado)
    } catch {
      setError('No se pudo actualizar el reporte.')
    } finally {
      setGuardando(false)
    }
  }

  if (error && !reportes) return <p className="text-panel-accent">{error}</p>
  if (!reportes) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Reportes</h1>
      <p className="mt-1 text-sm text-panel-text-soft">
        Revisa los reportes de tu organización y verifícalos, recházalos o márcalos como duplicados.
      </p>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 flex flex-col gap-3 sm:flex-row">
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
        <select
          value={filtroTipo}
          onChange={(e) => setFiltroTipo(e.target.value as 'todos' | TipoIncidente)}
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
        Mostrando {filtrados.length} de {reportes.length} reportes
      </p>

      <div className="mt-2 overflow-x-auto rounded-2xl border border-panel-border bg-panel-card">
        <table className="w-full text-left text-sm">
          <thead className="text-xs uppercase text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Tipo</th>
              <th className="px-5 py-3">Descripción</th>
              <th className="px-5 py-3">Reportante</th>
              <th className="px-5 py-3">Fecha</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {filtrados.length === 0 && (
              <tr>
                <td colSpan={6} className="px-5 py-10 text-center text-panel-text-soft">
                  No hay reportes con esos filtros.
                </td>
              </tr>
            )}
            {filtrados.map((r) => (
              <tr key={r.id} className="border-t border-panel-border">
                <td className="px-5 py-3 font-medium">{etiquetaTipo[r.tipo]}</td>
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
                <td className="px-5 py-3 text-right">
                  <button
                    onClick={() => setSeleccionado(r)}
                    className="text-sm font-semibold text-panel-primary hover:underline"
                  >
                    Ver detalle
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {seleccionado && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setSeleccionado(null)}
        >
          <div
            className="w-full max-w-lg rounded-2xl bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-xl font-extrabold text-panel-primary">{etiquetaTipo[seleccionado.tipo]}</h2>
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
                <dt className="text-xs uppercase text-panel-text-muted">Descripción</dt>
                <dd>{seleccionado.descripcion}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Ubicación</dt>
                <dd>{seleccionado.ubicacion}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Reportado por</dt>
                <dd>{seleccionado.reportante}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Fecha</dt>
                <dd>{formatearFecha(seleccionado.fecha)}</dd>
              </div>
            </dl>

            <div className="mt-6 flex flex-col gap-2 sm:flex-row">
              <button
                disabled={guardando || seleccionado.estado === 'verificado'}
                onClick={() => cambiarEstado('verificado')}
                className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-panel-success px-4 py-2 text-sm font-semibold text-white transition hover:opacity-90 disabled:opacity-40"
              >
                <CheckCircle2 size={16} /> Verificar
              </button>
              <button
                disabled={guardando || seleccionado.estado === 'rechazado'}
                onClick={() => cambiarEstado('rechazado')}
                className="flex flex-1 items-center justify-center gap-2 rounded-lg border border-panel-accent px-4 py-2 text-sm font-semibold text-panel-accent transition hover:bg-red-50 disabled:opacity-40"
              >
                <XCircle size={16} /> Rechazar
              </button>
              <button
                disabled={guardando || seleccionado.estado === 'duplicado'}
                onClick={() => cambiarEstado('duplicado')}
                className="flex flex-1 items-center justify-center gap-2 rounded-lg border border-panel-border px-4 py-2 text-sm font-semibold text-panel-text-soft transition hover:bg-panel-bg disabled:opacity-40"
              >
                <Copy size={16} /> Duplicado
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}