import { useEffect, useMemo, useState } from 'react'
import { ScrollText, LogIn, SquarePen, TriangleAlert, ChevronLeft, ChevronRight } from 'lucide-react'
import { listarEventos } from '../../services/auditoria.service'
import type { EventoAuditoria, TipoEvento, ModuloAuditoria } from '../../types/auditoria'

const POR_PAGINA = 6

const tipos: Record<TipoEvento, { etiqueta: string; clase: string }> = {
  acceso: { etiqueta: 'Acceso', clase: 'bg-blue-100 text-blue-700' },
  cambio: { etiqueta: 'Cambio', clase: 'bg-green-100 text-green-700' },
  error: { etiqueta: 'Error', clase: 'bg-red-100 text-red-700' },
}

const modulos: Record<ModuloAuditoria, string> = {
  acceso: 'Acceso',
  reportes: 'Reportes',
  solicitudes: 'Solicitudes',
  usuarios: 'Usuarios',
  zonas: 'Zonas peligrosas',
  centros: 'Centros de ayuda',
  alertas: 'Alertas',
  donaciones: 'Donaciones',
  desaparecidos: 'Personas desaparecidas',
}

interface Filtros {
  desde: string
  hasta: string
  tipo: 'todos' | TipoEvento
  usuario: string
  modulo: 'todos' | ModuloAuditoria
}

const filtrosVacios: Filtros = { desde: '', hasta: '', tipo: 'todos', usuario: 'todos', modulo: 'todos' }

const iniciales = (nombre: string) =>
  nombre
    .split(' ')
    .map((p) => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const numero = new Intl.NumberFormat('es-CO')

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

export default function AuditoriaPage() {
  const [eventos, setEventos] = useState<EventoAuditoria[] | null>(null)
  const [error, setError] = useState('')
  const [borrador, setBorrador] = useState<Filtros>(filtrosVacios)
  const [aplicados, setAplicados] = useState<Filtros>(filtrosVacios)
  const [errorFiltro, setErrorFiltro] = useState('')
  const [pagina, setPagina] = useState(1)

  useEffect(() => {
    listarEventos()
      .then(setEventos)
      .catch(() => setError('No se pudo cargar el historial.'))
  }, [])

  const usuarios = useMemo(() => Array.from(new Set((eventos ?? []).map((e) => e.usuario))).sort(), [eventos])

  const filtrados = useMemo(() => {
    if (!eventos) return []
    return eventos
      .filter((e) => {
        const dia = e.fecha.slice(0, 10)
        return (
          (!aplicados.desde || dia >= aplicados.desde) &&
          (!aplicados.hasta || dia <= aplicados.hasta) &&
          (aplicados.tipo === 'todos' || e.tipo === aplicados.tipo) &&
          (aplicados.usuario === 'todos' || e.usuario === aplicados.usuario) &&
          (aplicados.modulo === 'todos' || e.modulo === aplicados.modulo)
        )
      })
      .sort((a, b) => b.fecha.localeCompare(a.fecha))
  }, [eventos, aplicados])

  const resumen = useMemo(
    () => ({
      total: filtrados.length,
      accesos: filtrados.filter((e) => e.tipo === 'acceso').length,
      cambios: filtrados.filter((e) => e.tipo === 'cambio').length,
      errores: filtrados.filter((e) => e.tipo === 'error').length,
    }),
    [filtrados],
  )

  const totalPaginas = Math.max(1, Math.ceil(filtrados.length / POR_PAGINA))
  const paginaActual = Math.min(pagina, totalPaginas)
  const inicio = (paginaActual - 1) * POR_PAGINA
  const visibles = filtrados.slice(inicio, inicio + POR_PAGINA)

  const aplicar = () => {
    if (borrador.desde && borrador.hasta && borrador.desde > borrador.hasta) {
      setErrorFiltro('La fecha inicial no puede ser posterior a la final.')
      return
    }
    setErrorFiltro('')
    setAplicados(borrador)
    setPagina(1)
  }

  const limpiar = () => {
    setErrorFiltro('')
    setBorrador(filtrosVacios)
    setAplicados(filtrosVacios)
    setPagina(1)
  }

  if (error) return <p className="text-panel-accent">{error}</p>
  if (!eventos) return <p className="text-panel-text-soft">Cargando…</p>

  const tarjetas = [
    { valor: resumen.total, titulo: 'Total eventos', icono: ScrollText, color: 'bg-violet-500' },
    { valor: resumen.accesos, titulo: 'Accesos', icono: LogIn, color: 'bg-blue-500' },
    { valor: resumen.cambios, titulo: 'Cambios', icono: SquarePen, color: 'bg-green-600' },
    { valor: resumen.errores, titulo: 'Errores', icono: TriangleAlert, color: 'bg-amber-500' },
  ]

  return (
    <div className="min-w-0">
      <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
        <span className="h-1.5 w-1.5 rounded-full bg-brand" />
        Administración
      </p>
      <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Auditoría</h1>
      <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">Consulta el historial de acciones y eventos del sistema.</p>

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, icono: Icono }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-3xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border border-panel-border text-panel-text-soft`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className="text-2xl font-extrabold">{numero.format(valor)}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 grid min-w-0 gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,1fr)]">
        <section className="min-w-0 rounded-3xl border border-panel-border bg-panel-card">
          <h2 className="px-5 pt-5 text-lg font-semibold tracking-[-0.02em]">Registro de auditoría</h2>

          <div className="mt-3 max-w-full overflow-x-auto">
            <table className="w-full min-w-[680px] text-left text-sm">
              <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Fecha / hora</th>
                  <th className="px-5 py-3">Usuario</th>
                  <th className="px-5 py-3">Acción</th>
                  <th className="hidden px-5 py-3 md:table-cell">Módulo</th>
                  <th className="px-5 py-3">Evento</th>
                  <th className="hidden px-5 py-3 lg:table-cell">Detalle</th>
                  <th className="hidden px-5 py-3 2xl:table-cell">IP</th>
                </tr>
              </thead>
              <tbody>
                {visibles.length === 0 && (
                  <tr>
                    <td colSpan={7} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay eventos con esos filtros.
                    </td>
                  </tr>
                )}
                {visibles.map((e) => (
                  <tr key={e.id} className="border-t border-panel-border">
                    <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(e.fecha)}</td>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-panel-primary/10 text-xs font-bold text-panel-primary">
                          {iniciales(e.usuario)}
                        </span>
                        <span className="font-medium">{e.usuario}</span>
                      </div>
                    </td>
                    <td className="px-5 py-3">{e.accion}</td>
                    <td className="hidden px-5 py-3 text-panel-text-soft md:table-cell">{modulos[e.modulo]}</td>
                    <td className="px-5 py-3">
                      <span className={`rounded-full px-3 py-1 text-xs font-medium ${tipos[e.tipo].clase}`}>
                        {tipos[e.tipo].etiqueta}
                      </span>
                    </td>
                    <td className="hidden max-w-xs truncate px-5 py-3 text-panel-text-soft lg:table-cell" title={e.detalle}>
                      {e.detalle}
                    </td>
                    <td className="hidden px-5 py-3 text-panel-text-muted 2xl:table-cell">{e.ip}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="flex flex-col items-center justify-between gap-3 border-t border-panel-border px-5 py-4 text-xs text-panel-text-muted sm:flex-row">
            <div className="flex items-center gap-1">
              <button
                onClick={() => setPagina(paginaActual - 1)}
                disabled={paginaActual === 1}
                aria-label="Página anterior"
                className="rounded p-1.5 hover:bg-panel-bg disabled:opacity-30"
              >
                <ChevronLeft size={16} />
              </button>
              {Array.from({ length: totalPaginas }, (_, i) => i + 1).map((n) => (
                <button
                  key={n}
                  onClick={() => setPagina(n)}
                  className={`h-7 min-w-7 rounded px-2 font-medium ${
                    n === paginaActual ? 'bg-panel-info text-white' : 'text-panel-text-soft hover:bg-panel-bg'
                  }`}
                >
                  {n}
                </button>
              ))}
              <button
                onClick={() => setPagina(paginaActual + 1)}
                disabled={paginaActual === totalPaginas}
                aria-label="Página siguiente"
                className="rounded p-1.5 hover:bg-panel-bg disabled:opacity-30"
              >
                <ChevronRight size={16} />
              </button>
            </div>
            <p>
              {filtrados.length === 0
                ? 'Sin resultados'
                : `Mostrando ${inicio + 1} - ${inicio + visibles.length} de ${numero.format(filtrados.length)} eventos`}
            </p>
          </div>
        </section>

        <section className="h-fit min-w-0 rounded-3xl border border-panel-border bg-panel-card p-5">
          <h2 className="text-lg font-semibold tracking-[-0.02em]">Filtros</h2>

          <div className="mt-4 space-y-4">
            <div className="grid grid-cols-2 gap-3 xl:grid-cols-1">
              <div>
                <label htmlFor="desde" className="text-xs font-medium text-panel-text-soft">
                  Desde
                </label>
                <input
                  id="desde"
                  type="date"
                  value={borrador.desde}
                  onChange={(e) => setBorrador({ ...borrador, desde: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="hasta" className="text-xs font-medium text-panel-text-soft">
                  Hasta
                </label>
                <input
                  id="hasta"
                  type="date"
                  value={borrador.hasta}
                  onChange={(e) => setBorrador({ ...borrador, hasta: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
            </div>

            <div>
              <label htmlFor="tipo" className="text-xs font-medium text-panel-text-soft">
                Tipo de evento
              </label>
              <select
                id="tipo"
                value={borrador.tipo}
                onChange={(e) => setBorrador({ ...borrador, tipo: e.target.value as Filtros['tipo'] })}
                className={`${campo} mt-1`}
              >
                <option value="todos">Todos</option>
                {(Object.keys(tipos) as TipoEvento[]).map((t) => (
                  <option key={t} value={t}>
                    {tipos[t].etiqueta}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="usuario" className="text-xs font-medium text-panel-text-soft">
                Usuario
              </label>
              <select
                id="usuario"
                value={borrador.usuario}
                onChange={(e) => setBorrador({ ...borrador, usuario: e.target.value })}
                className={`${campo} mt-1`}
              >
                <option value="todos">Todos</option>
                {usuarios.map((u) => (
                  <option key={u} value={u}>
                    {u}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="modulo" className="text-xs font-medium text-panel-text-soft">
                Módulo
              </label>
              <select
                id="modulo"
                value={borrador.modulo}
                onChange={(e) => setBorrador({ ...borrador, modulo: e.target.value as Filtros['modulo'] })}
                className={`${campo} mt-1`}
              >
                <option value="todos">Todos</option>
                {(Object.keys(modulos) as ModuloAuditoria[]).map((m) => (
                  <option key={m} value={m}>
                    {modulos[m]}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {errorFiltro && <p className="mt-4 rounded-2xl bg-red-50 px-3 py-2 text-xs text-red-700">{errorFiltro}</p>}

          <button
            onClick={aplicar}
            className="mt-5 w-full rounded-full bg-navy-950 px-5 py-2.5 text-sm font-semibold text-white shadow-[0_12px_28px_-12px_rgba(11,27,54,0.8)] transition hover:bg-navy-800 active:scale-[0.98] dark:bg-white dark:text-navy-950"
          >
            Aplicar filtros
          </button>
          <button
            onClick={limpiar}
            className="mt-2 w-full rounded-lg px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
          >
            Limpiar
          </button>
        </section>
      </div>
    </div>
  )
}