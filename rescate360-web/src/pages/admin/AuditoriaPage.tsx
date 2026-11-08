import { useEffect, useMemo, useState } from 'react'
import { Search, Plus, Pencil, Trash2, Bot, ChevronLeft, ChevronRight, ClipboardList, type LucideIcon } from 'lucide-react'
import CabeceraPanel from '../../components/panel/CabeceraPanel'
import { listarAuditoria } from '../../services/auditoria.service'
import type { DatosFila, Operacion, RegistroAuditoria, TablaAuditada } from '../../types/auditoria'
import Modal from '../../components/panel/Modal'

const POR_PAGINA = 10

const etiquetaTabla: Record<TablaAuditada, string> = {
  usuarios: 'Usuarios',
  reportes: 'Reportes',
  solicitudes_ayuda: 'Solicitudes de ayuda',
  personas_desaparecidas: 'Personas desaparecidas',
  zonas_peligrosas: 'Zonas peligrosas',
  alertas: 'Alertas',
}

const operaciones: Record<Operacion, { etiqueta: string; icono: LucideIcon; clase: string }> = {
  INSERT: { etiqueta: 'Creación', icono: Plus, clase: 'bg-green-100 text-green-700' },
  UPDATE: { etiqueta: 'Modificación', icono: Pencil, clase: 'bg-blue-100 text-blue-700' },
  DELETE: { etiqueta: 'Eliminación', icono: Trash2, clase: 'bg-red-100 text-red-700' },
}

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

const mostrarValor = (v: unknown) => {
  if (v === null || v === undefined) return <span className="italic text-panel-text-muted">vacío</span>
  if (typeof v === 'object') return <code className="break-all text-xs">{JSON.stringify(v)}</code>
  return String(v)
}

// Resumen corto para la tabla: qué campos cambiaron, o qué se creó/eliminó.
function resumenCambio(r: RegistroAuditoria) {
  if (r.operacion === 'UPDATE') {
    const campos = r.camposModificados ?? []
    return campos.length ? `Cambió: ${campos.join(', ')}` : 'Sin cambios de campos'
  }
  return r.operacion === 'INSERT' ? 'Registro creado' : 'Registro eliminado'
}

function TablaCampos({ titulo, datos }: { titulo: string; datos: DatosFila }) {
  return (
    <div>
      <p className="text-xs uppercase tracking-wide text-panel-text-muted">{titulo}</p>
      <dl className="mt-2 divide-y divide-panel-border rounded-xl border border-panel-border text-sm">
        {Object.entries(datos).map(([k, v]) => (
          <div key={k} className="grid grid-cols-[160px_minmax(0,1fr)] gap-3 px-4 py-2">
            <dt className="font-mono text-xs text-panel-text-soft">{k}</dt>
            <dd className="min-w-0 break-words">{mostrarValor(v)}</dd>
          </div>
        ))}
      </dl>
    </div>
  )
}

export default function AuditoriaPage() {
  const [registros, setRegistros] = useState<RegistroAuditoria[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroTabla, setFiltroTabla] = useState<'todas' | TablaAuditada>('todas')
  const [filtroOperacion, setFiltroOperacion] = useState<'todas' | Operacion>('todas')
  const [desde, setDesde] = useState('')
  const [hasta, setHasta] = useState('')
  const [pagina, setPagina] = useState(0)
  const [seleccionado, setSeleccionado] = useState<RegistroAuditoria | null>(null)

  useEffect(() => {
    listarAuditoria()
      .then(setRegistros)
      .catch(() => setError('No se pudo cargar el historial de auditoría.'))
  }, [])

  const filtrados = useMemo(() => {
    const texto = busqueda.trim().toLowerCase()
    return (registros ?? [])
      .filter((r) => filtroTabla === 'todas' || r.tabla === filtroTabla)
      .filter((r) => filtroOperacion === 'todas' || r.operacion === filtroOperacion)
      .filter((r) => !desde || r.creadoEn.slice(0, 10) >= desde)
      .filter((r) => !hasta || r.creadoEn.slice(0, 10) <= hasta)
      .filter(
        (r) =>
          !texto ||
          (r.usuarioNombre ?? 'sistema').toLowerCase().includes(texto) ||
          r.registroId.toLowerCase().includes(texto) ||
          (r.camposModificados ?? []).some((c) => c.toLowerCase().includes(texto)),
      )
      .sort((a, b) => b.creadoEn.localeCompare(a.creadoEn))
  }, [registros, busqueda, filtroTabla, filtroOperacion, desde, hasta])

  const totalPaginas = Math.max(1, Math.ceil(filtrados.length / POR_PAGINA))
  // Si un filtro deja menos páginas, se muestra la última disponible.
  const paginaActual = Math.min(pagina, totalPaginas - 1)
  const visibles = filtrados.slice(paginaActual * POR_PAGINA, (paginaActual + 1) * POR_PAGINA)

  const limpiar = () => {
    setBusqueda('')
    setFiltroTabla('todas')
    setFiltroOperacion('todas')
    setDesde('')
    setHasta('')
    setPagina(0)
  }
  const hayFiltros = busqueda || filtroTabla !== 'todas' || filtroOperacion !== 'todas' || desde || hasta

  if (error) return <p className="text-panel-accent">{error}</p>
  if (!registros) return <p className="text-panel-text-soft">Cargando…</p>

  const porOperacion = (o: Operacion) => registros.filter((r) => r.operacion === o).length

  return (
    <div>
      <CabeceraPanel
        seccion="Administración"
        titulo="Auditoría"
        descripcion="Historial de cambios sobre usuarios, reportes, solicitudes, desaparecidos, zonas y alertas. Solo lectura."
        estadisticas={[
          { titulo: 'Registros', valor: registros.length, icono: ClipboardList, pie: 'Cambios auditados' },
          { titulo: 'Creaciones', valor: porOperacion('INSERT'), icono: Plus, pie: 'Registros nuevos' },
          { titulo: 'Modificaciones', valor: porOperacion('UPDATE'), icono: Pencil, pie: 'Registros editados' },
          { titulo: 'Eliminaciones', valor: porOperacion('DELETE'), icono: Trash2, pie: 'Registros borrados' },
        ]}
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-[minmax(0,1fr)_auto_auto_auto_auto]">
        <div className="relative sm:col-span-2 xl:col-span-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
          <input
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            placeholder="Buscar por usuario, id de registro o campo"
            className={`${campo} w-full pl-9`}
          />
        </div>
        <select
          aria-label="Tabla"
          value={filtroTabla}
          onChange={(e) => setFiltroTabla(e.target.value as 'todas' | TablaAuditada)}
          className={campo}
        >
          <option value="todas">Todas las tablas</option>
          {(Object.keys(etiquetaTabla) as TablaAuditada[]).map((t) => (
            <option key={t} value={t}>
              {etiquetaTabla[t]}
            </option>
          ))}
        </select>
        <select
          aria-label="Operación"
          value={filtroOperacion}
          onChange={(e) => setFiltroOperacion(e.target.value as 'todas' | Operacion)}
          className={campo}
        >
          <option value="todas">Todas las operaciones</option>
          {(Object.keys(operaciones) as Operacion[]).map((o) => (
            <option key={o} value={o}>
              {operaciones[o].etiqueta}
            </option>
          ))}
        </select>
        <label className="flex items-center gap-2 text-sm text-panel-text-soft">
          Desde
          <input type="date" value={desde} max={hasta || undefined} onChange={(e) => setDesde(e.target.value)} className={`${campo} min-w-0 flex-1`} />
        </label>
        <label className="flex items-center gap-2 text-sm text-panel-text-soft">
          Hasta
          <input type="date" value={hasta} min={desde || undefined} onChange={(e) => setHasta(e.target.value)} className={`${campo} min-w-0 flex-1`} />
        </label>
      </div>

      <div className="mt-3 flex items-center justify-between text-xs text-panel-text-muted">
        <span>
          {filtrados.length} de {registros.length} registros
        </span>
        {hayFiltros && (
          <button onClick={limpiar} className="font-semibold text-panel-primary hover:underline">
            Limpiar filtros
          </button>
        )}
      </div>

      <div className="mt-2 max-w-full overflow-x-auto rounded-3xl border border-panel-border bg-panel-card">
        <table className="w-full min-w-[860px] text-left text-sm">
          <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Fecha</th>
              <th className="px-5 py-3">Usuario</th>
              <th className="px-5 py-3">Operación</th>
              <th className="px-5 py-3">Tabla</th>
              <th className="px-5 py-3">Cambio</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {visibles.length === 0 && (
              <tr>
                <td colSpan={6} className="px-5 py-10 text-center text-panel-text-soft">
                  No hay registros con esos filtros.
                </td>
              </tr>
            )}
            {visibles.map((r) => {
              const { etiqueta, icono: Icono, clase } = operaciones[r.operacion]
              return (
                <tr key={r.id} className="border-t border-panel-border">
                  <td className="whitespace-nowrap px-5 py-3 tabular-nums text-panel-text-soft">{formatearFecha(r.creadoEn)}</td>
                  <td className="px-5 py-3">
                    {r.usuarioNombre ?? (
                      <span className="flex items-center gap-1.5 text-panel-text-muted">
                        <Bot size={14} /> Sistema
                      </span>
                    )}
                  </td>
                  <td className="px-5 py-3">
                    <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium ${clase}`}>
                      <Icono size={12} /> {etiqueta}
                    </span>
                  </td>
                  <td className="px-5 py-3">
                    <p>{etiquetaTabla[r.tabla]}</p>
                    <p className="font-mono text-[11px] text-panel-text-muted">id {r.registroId}</p>
                  </td>
                  <td className="max-w-xs truncate px-5 py-3 text-panel-text-soft">{resumenCambio(r)}</td>
                  <td className="px-5 py-3 text-right">
                    <button onClick={() => setSeleccionado(r)} className="text-sm font-semibold text-panel-primary hover:underline">
                      Ver detalle
                    </button>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {totalPaginas > 1 && (
        <div className="mt-3 flex items-center justify-end gap-2 text-sm">
          <button
            onClick={() => setPagina(paginaActual - 1)}
            disabled={paginaActual === 0}
            aria-label="Página anterior"
            className="rounded-lg border border-panel-border p-2 text-panel-text-soft transition hover:bg-panel-card disabled:opacity-40"
          >
            <ChevronLeft size={16} />
          </button>
          <span className="tabular-nums text-panel-text-soft">
            Página {paginaActual + 1} de {totalPaginas}
          </span>
          <button
            onClick={() => setPagina(paginaActual + 1)}
            disabled={paginaActual >= totalPaginas - 1}
            aria-label="Página siguiente"
            className="rounded-lg border border-panel-border p-2 text-panel-text-soft transition hover:bg-panel-card disabled:opacity-40"
          >
            <ChevronRight size={16} />
          </button>
        </div>
      )}

      {seleccionado && (
        <Modal
          titulo={`${operaciones[seleccionado.operacion].etiqueta} en ${etiquetaTabla[seleccionado.tabla].toLowerCase()}`}
          subtitulo={`${formatearFecha(seleccionado.creadoEn)} · ${seleccionado.usuarioNombre ?? 'Sistema'} · registro ${seleccionado.registroId}`}
          onCerrar={() => setSeleccionado(null)}
          ancho="lg"
        >
          <div className="mt-5 space-y-5">
            {seleccionado.operacion === 'UPDATE' && seleccionado.datosAnteriores && seleccionado.datosNuevos ? (
              <div>
                <p className="text-xs uppercase tracking-wide text-panel-text-muted">Campos modificados</p>
                <div className="mt-2 overflow-x-auto rounded-xl border border-panel-border">
                  <table className="w-full min-w-[480px] text-left text-sm">
                    <thead className="bg-panel-bg text-xs uppercase text-panel-text-muted">
                      <tr>
                        <th className="px-4 py-2">Campo</th>
                        <th className="px-4 py-2">Antes</th>
                        <th className="px-4 py-2">Después</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(seleccionado.camposModificados ?? []).map((c) => (
                        <tr key={c} className="border-t border-panel-border">
                          <td className="px-4 py-2 font-mono text-xs text-panel-text-soft">{c}</td>
                          <td className="px-4 py-2">
                            <span className="rounded bg-red-50 px-1.5 py-0.5 text-red-800">
                              {mostrarValor(seleccionado.datosAnteriores?.[c])}
                            </span>
                          </td>
                          <td className="px-4 py-2">
                            <span className="rounded bg-green-50 px-1.5 py-0.5 text-green-800">
                              {mostrarValor(seleccionado.datosNuevos?.[c])}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            ) : seleccionado.datosNuevos ? (
              <TablaCampos titulo="Datos creados" datos={seleccionado.datosNuevos} />
            ) : seleccionado.datosAnteriores ? (
              <TablaCampos titulo="Datos eliminados" datos={seleccionado.datosAnteriores} />
            ) : (
              <p className="text-sm text-panel-text-soft">Este registro no guarda datos.</p>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
