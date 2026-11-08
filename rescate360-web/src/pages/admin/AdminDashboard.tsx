import { useEffect, useState, type ReactNode } from 'react'
import { Link, useOutletContext } from 'react-router-dom'
import { motion, useReducedMotion, type Variants } from 'motion/react'
import {
  FileWarning,
  LifeBuoy,
  Bell,
  Building2,
  AlertCircle,
  TriangleAlert,
  PackageX,
  Search,
  HeartHandshake,
  Activity,
  Smartphone,
  Plus,
  Pencil,
  Trash2,
  Bot,
  ChevronRight,
  ArrowRight,
  ArrowUpRight,
  type LucideIcon,
} from 'lucide-react'
import { obtenerDashboardAdmin } from '../../services/dashboard.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import { useAuth } from '../../context/AuthContext'
import { prioridadEfectiva, type PrioridadIA } from '../../types/solicitud'
import type { EstadoReporte } from '../../types/reporte'
import type { DashboardAdmin } from '../../types/dashboard'
import type { Operacion, TablaAuditada } from '../../types/auditoria'
import CountUp from '../../components/reactbits/CountUp/CountUp'
import GraficoActividad from '../../components/panel/graficos/GraficoActividad'
import GraficoDona, { type Segmento } from '../../components/panel/graficos/GraficoDona'
import BarrasHorizontales from '../../components/panel/graficos/BarrasHorizontales'
import { botonCabeceraPrincipal, botonCabeceraSecundario } from '../../components/panel/CabeceraPanel'
import type { ContextoPanel } from '../../layouts/PanelLayout'

// Colores validados para daltonismo (orden fijo), sobre fondo claro y sobre la banda azul marino.
// "Duplicado" va en gris neutro porque no aporta información nueva.
const estadosReporte: { clave: EstadoReporte; etiqueta: string; color: string }[] = [
  { clave: 'verificado', etiqueta: 'Verificado', color: '#2fa96b' },
  { clave: 'pendiente', etiqueta: 'Pendiente', color: '#d97706' },
  { clave: 'no_verificable', etiqueta: 'No verificable', color: '#7c5cd6' },
  { clave: 'rechazado', etiqueta: 'Rechazado', color: '#e5534b' },
  { clave: 'duplicado', etiqueta: 'Duplicado', color: '#8592ab' },
]

const prioridades: { clave: PrioridadIA; etiqueta: string }[] = [
  { clave: 'critica', etiqueta: 'Crítica' },
  { clave: 'alta', etiqueta: 'Alta' },
  { clave: 'media', etiqueta: 'Media' },
  { clave: 'baja', etiqueta: 'Baja' },
  { clave: 'pendiente', etiqueta: 'Sin clasificar' },
]

const colorPrioridad: Record<PrioridadIA, string> = {
  critica: 'bg-red-600 text-white',
  alta: 'bg-red-100 text-red-700',
  media: 'bg-amber-100 text-amber-700',
  baja: 'bg-green-100 text-green-700',
  pendiente: 'bg-slate-200 text-slate-600',
}

const etiquetaTabla: Record<TablaAuditada, string> = {
  usuarios: 'usuarios',
  reportes: 'reportes',
  solicitudes_ayuda: 'solicitudes',
  personas_desaparecidas: 'desaparecidos',
  zonas_peligrosas: 'zonas peligrosas',
  alertas: 'alertas',
}

const operacion: Record<Operacion, { verbo: string; icono: LucideIcon; clase: string }> = {
  INSERT: { verbo: 'creó un registro en', icono: Plus, clase: 'bg-green-100 text-green-700' },
  UPDATE: { verbo: 'modificó', icono: Pencil, clase: 'bg-blue-100 text-blue-700' },
  DELETE: { verbo: 'eliminó un registro de', icono: Trash2, clase: 'bg-red-100 text-red-700' },
}

const PERIODOS = [7, 14, 30] as const
type Periodo = (typeof PERIODOS)[number]

const formatearFechaCorta = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { day: 'numeric', month: 'short', hour: 'numeric', minute: '2-digit' })

const aFecha = (dia: string) => {
  const [a, m, d] = dia.split('-').map(Number)
  return new Date(a, m - 1, d)
}
const formatearDia = (dia: string) => aFecha(dia).toLocaleDateString('es-CO', { day: 'numeric', month: 'short' })

const saludo = () => {
  const h = new Date().getHours()
  return h < 12 ? 'Buenos días' : h < 19 ? 'Buenas tardes' : 'Buenas noches'
}

// ---------- Animación ----------

const contenedor: Variants = { oculto: {}, visible: { transition: { staggerChildren: 0.05 } } }
const aparecer: Variants = {
  oculto: { opacity: 0, y: 8 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.35, ease: [0.23, 1, 0.32, 1] } },
}

// ---------- Piezas ----------

function Panel({
  titulo,
  subtitulo,
  accion,
  children,
  className = '',
}: {
  titulo: string
  subtitulo?: ReactNode
  accion?: ReactNode
  children: ReactNode
  className?: string
}) {
  return (
    <motion.section variants={aparecer} className={`min-w-0 rounded-[28px] border border-panel-border bg-panel-card p-6 sm:p-7 ${className}`}>
      <div className="flex flex-wrap items-start justify-between gap-x-4 gap-y-2">
        <div className="min-w-0">
          <h2 className="text-lg font-semibold tracking-[-0.02em]">{titulo}</h2>
          {subtitulo && <p className="mt-0.5 text-xs text-panel-text-muted">{subtitulo}</p>}
        </div>
        {accion}
      </div>
      <div className="mt-5">{children}</div>
    </motion.section>
  )
}

function EnlaceVer({ a, texto = 'Ver todo' }: { a: string; texto?: string }) {
  return (
    <Link
      to={a}
      className="group inline-flex items-center gap-1 rounded-full border border-panel-border px-3 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-soft transition hover:border-panel-text-muted/50 hover:text-panel-text"
    >
      {texto}
      <ChevronRight size={12} className="transition-transform group-hover:translate-x-0.5" />
    </Link>
  )
}

// Indicadores de estado: el color solo comunica urgencia (rojo), atención (ámbar) o normalidad (verde).
type Tono = 'alerta' | 'aviso' | 'bien' | 'neutro'
const tonos: Record<Tono, string> = {
  alerta: 'bg-brand shadow-[0_0_0_3px_rgba(232,52,63,0.18)]',
  aviso: 'bg-amber-500 shadow-[0_0_0_3px_rgba(245,158,11,0.18)]',
  bien: 'bg-emerald-500 shadow-[0_0_0_3px_rgba(16,185,129,0.18)]',
  neutro: 'bg-panel-text-muted',
}

interface Kpi {
  titulo: string
  descripcion: string
  valor: number
  icono: LucideIcon
  a: string
  pildora?: { texto: string; tono: Tono }
}

// Tarjeta de cifra: ícono, indicador en mono, número grande y descripción. Lleva a su sección.
// Celda de cifra dentro de la franja: indicador en mono, número grande y descripción. Lleva a su sección.
function TarjetaKpi({ titulo, descripcion, valor, icono: Icono, a, pildora }: Kpi) {
  return (
    <motion.div variants={aparecer} className="h-full bg-panel-card">
      <Link
        to={a}
        className="group relative flex h-full flex-col p-5 transition-colors hover:bg-panel-bg focus-visible:bg-panel-bg focus-visible:outline-none sm:p-6"
      >
        <div className="flex items-center justify-between gap-2">
          <p className="flex min-w-0 items-center gap-2 font-mono text-[10px] uppercase tracking-[0.14em] text-panel-text-muted">
            <span className={`h-1.5 w-1.5 shrink-0 rounded-full ${pildora ? tonos[pildora.tono] : 'bg-panel-text-muted/50'}`} />
            <span className="truncate">{pildora?.texto ?? 'Total'}</span>
          </p>
          <Icono size={15} strokeWidth={1.8} className="shrink-0 text-panel-text-muted transition group-hover:text-panel-text" />
        </div>
        <CountUp to={valor} duration={0.9} trigger="load" className="mt-5 block text-[48px] font-semibold leading-none tracking-[-0.05em]" />
        <p className="mt-3 text-sm font-medium">{titulo}</p>
        <p className="mt-0.5 text-xs text-panel-text-muted">{descripcion}</p>
        <ArrowUpRight
          size={16}
          className="absolute bottom-5 right-5 text-panel-text-muted opacity-0 transition group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-panel-text group-hover:opacity-100"
        />
      </Link>
    </motion.div>
  )
}

function SelectorPeriodo({ valor, onCambiar }: { valor: Periodo; onCambiar: (p: Periodo) => void }) {
  return (
    <div role="group" aria-label="Período" className="inline-flex rounded-full border border-panel-border bg-panel-bg p-0.5 text-xs">
      {PERIODOS.map((p) => (
        <button
          key={p}
          onClick={() => onCambiar(p)}
          aria-pressed={valor === p}
          className={`relative rounded-full px-3 py-1 font-semibold transition-colors ${
            valor === p ? 'text-white dark:text-navy-950' : 'text-panel-text-soft hover:text-panel-text'
          }`}
        >
          {valor === p && (
            <motion.span
              layoutId="periodo-activo"
              transition={{ type: 'spring', stiffness: 420, damping: 36 }}
              className="absolute inset-0 rounded-full bg-navy-950 dark:bg-white"
            />
          )}
          <span className="relative">{p} días</span>
        </button>
      ))}
    </div>
  )
}

function Esqueleto() {
  return (
    <div aria-busy="true" aria-label="Cargando el resumen" className="pt-4">
      <div className="h-4 w-48 animate-pulse rounded-full bg-panel-border" />
      <div className="mt-4 h-12 w-96 max-w-full animate-pulse rounded-2xl bg-panel-border/70" />
      <div className="mt-8 grid grid-cols-2 gap-4 xl:grid-cols-4">
        {[0, 1, 2, 3].map((i) => (
          <div key={i} className="h-40 animate-pulse rounded-3xl border border-panel-border bg-panel-card" />
        ))}
      </div>
      <div className="mt-6 h-80 animate-pulse rounded-3xl border border-panel-border bg-panel-card" />
    </div>
  )
}

// ---------- Página ----------

export default function AdminDashboard() {
  const { usuario } = useAuth()
  const organizacionId = usuario?.organizacion_id ?? ''
  const [datos, setDatos] = useState<DashboardAdmin | null>(null)
  const [nombreOrg, setNombreOrg] = useState('')
  const [error, setError] = useState('')
  const [periodo, setPeriodo] = useState<Periodo>(7)
  const reducir = useReducedMotion()
  const { tema } = useOutletContext<ContextoPanel>()
  const oscuro = tema === 'oscuro'

  useEffect(() => {
    obtenerDashboardAdmin(organizacionId)
      .then(setDatos)
      .catch(() => setError('No se pudo cargar el resumen.'))
    listarOrganizaciones()
      .then((orgs) => setNombreOrg(orgs.find((o) => o.id === organizacionId)?.nombre ?? ''))
      .catch(() => setNombreOrg(''))
  }, [organizacionId])

  if (error) return <p className="text-panel-accent">{error}</p>
  if (!datos) return <Esqueleto />

  const { resumen } = datos
  const actividad = datos.actividad.slice(-periodo)
  const pctPendientes = resumen.reportesTotal ? Math.round((resumen.reportesPendientes / resumen.reportesTotal) * 100) : 0
  const pctCentros = resumen.centrosTotal ? Math.round((resumen.centrosOperativos / resumen.centrosTotal) * 100) : 0
  const primerNombre = usuario?.nombre.split(' ')[0] ?? ''
  const fechaHoy = new Date().toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })
  const hoy = fechaHoy.charAt(0).toUpperCase() + fechaHoy.slice(1)

  // Totales del período elegido y variación del último día frente al anterior (sobre registros reales).
  const totalReportes = actividad.reduce((s, p) => s + p.reportes, 0)
  const totalSolicitudes = actividad.reduce((s, p) => s + p.solicitudes, 0)
  const totalDia = (p?: { reportes: number; solicitudes: number }) => (p ? p.reportes + p.solicitudes : 0)
  const variacion = totalDia(actividad.at(-1)) - totalDia(actividad.at(-2))

  // Las 4 cifras críticas van arriba; el resto, debajo de los gráficos.
  const kpisPrincipales: Kpi[] = [
    {
      titulo: 'Solicitudes abiertas',
      descripcion: 'Pendientes o en atención',
      valor: resumen.solicitudesAbiertas,
      icono: LifeBuoy,
      a: '/admin/solicitudes',
      pildora:
        resumen.solicitudesUrgentes > 0
          ? { texto: `${resumen.solicitudesUrgentes} ${resumen.solicitudesUrgentes === 1 ? 'urgente' : 'urgentes'}`, tono: 'alerta' }
          : { texto: 'Sin urgencias', tono: 'bien' },
    },
    {
      titulo: 'Reportes por revisar',
      descripcion: `De ${resumen.reportesTotal} reportes recibidos`,
      valor: resumen.reportesPendientes,
      icono: FileWarning,
      a: '/admin/reportes',
      pildora: { texto: `${pctPendientes}%`, tono: pctPendientes > 0 ? 'aviso' : 'bien' },
    },
    {
      titulo: 'Alertas activas',
      descripcion: 'Publicadas a la comunidad',
      valor: resumen.alertasActivas,
      icono: Bell,
      a: '/admin/alertas',
    },
    {
      titulo: 'Centros operativos',
      descripcion: `De ${resumen.centrosTotal} centros registrados`,
      valor: resumen.centrosOperativos,
      icono: Building2,
      a: '/admin/centros',
      pildora: { texto: `${pctCentros}%`, tono: 'bien' },
    },
  ]

  const kpisSecundarios: Kpi[] = [
    {
      titulo: 'Zonas peligrosas',
      descripcion: 'Áreas de riesgo activas',
      valor: resumen.zonasActivas,
      icono: TriangleAlert,
      a: '/admin/zonas',
      pildora: resumen.zonasActivas > 0 ? { texto: 'Activas', tono: 'aviso' } : undefined,
    },
    {
      titulo: 'Personas en búsqueda',
      descripcion: 'Casos de desaparición abiertos',
      valor: resumen.desaparecidosBuscando,
      icono: Search,
      a: '/admin/desaparecidos',
    },
    {
      titulo: 'Voluntarios activos',
      descripcion: `De ${resumen.voluntariosTotal} voluntarios de tu organización`,
      valor: resumen.voluntariosActivos,
      icono: HeartHandshake,
      a: '/admin/usuarios',
    },
    {
      titulo: 'Donaciones agotadas',
      descripcion: 'Registros sin existencias',
      valor: resumen.donacionesAgotadas,
      icono: PackageX,
      a: '/admin/donaciones',
      pildora: resumen.donacionesAgotadas > 0 ? { texto: 'Reponer', tono: 'alerta' } : { texto: 'Al día', tono: 'bien' },
    },
  ]

  const segmentos: Segmento[] = estadosReporte.map((e) => ({ ...e, valor: datos.reportesPorEstado[e.clave] }))
  const barrasPrioridad = prioridades.map((p) => ({ ...p, valor: datos.solicitudesPorPrioridad[p.clave] }))

  return (
    <motion.div className="sin-cascada" initial={reducir ? false : 'oculto'} animate="visible" variants={contenedor}>
      {/* ===== Encabezado (mismo lenguaje que la landing) ===== */}
      <motion.div variants={aparecer} className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-brand opacity-60 motion-reduce:hidden" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-brand" />
            </span>
            Centro de mando · {hoy}
          </p>
          <h1 className="mt-4 text-[40px] font-semibold leading-[0.98] tracking-[-0.05em] sm:text-[52px] xl:text-[60px]">
            {saludo()}, {primerNombre}.
            <br />
            <span className={resumen.solicitudesUrgentes > 0 ? 'text-brand' : 'text-panel-text-muted'}>
              {resumen.solicitudesUrgentes > 0
                ? `${resumen.solicitudesUrgentes} ${resumen.solicitudesUrgentes === 1 ? 'solicitud urgente espera' : 'solicitudes urgentes esperan'}.`
                : 'Todo está bajo control.'}
            </span>
          </h1>
          <p className="mt-3 text-[15px] text-panel-text-soft">{nombreOrg || 'Tu organización'}</p>
        </div>
        <div className="flex shrink-0 flex-wrap gap-2">
          <Link to="/admin/alertas?accion=nueva" className={botonCabeceraSecundario}>
            <Bell size={16} /> Publicar alerta
          </Link>
          <Link to="/admin/solicitudes" className={botonCabeceraPrincipal}>
            <LifeBuoy size={16} /> Atender solicitudes
            <ArrowRight size={15} className="transition-transform group-hover:translate-x-0.5" />
          </Link>
        </div>
      </motion.div>

      {/* Aviso si hay solicitudes que nadie ha evaluado */}
      {resumen.solicitudesSinClasificar > 0 && (
        <motion.div variants={aparecer}>
          <Link
            to="/admin/solicitudes"
            className="group mt-6 flex items-center gap-3 rounded-2xl border border-amber-300/60 bg-amber-50 px-4 py-3 text-sm text-amber-900 transition hover:border-amber-400"
          >
            <AlertCircle size={18} className="shrink-0 text-amber-600" />
            <span>
              <strong>
                {resumen.solicitudesSinClasificar}{' '}
                {resumen.solicitudesSinClasificar === 1 ? 'solicitud sin clasificar' : 'solicitudes sin clasificar'}
              </strong>{' '}
              por la IA. Revísalas y asígnales una prioridad manual.
            </span>
            <ChevronRight size={16} className="ml-auto shrink-0 transition-transform group-hover:translate-x-0.5" />
          </Link>
        </motion.div>
      )}

      {/* Cifras críticas */}
      <motion.div variants={contenedor} className="mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-[28px] border border-panel-border bg-panel-border xl:grid-cols-4">
        {kpisPrincipales.map((k) => (
          <TarjetaKpi key={k.titulo} {...k} />
        ))}
      </motion.div>

      {/* Gráficos: lado a lado en PC, uno debajo del otro en pantallas pequeñas */}
      <motion.div variants={contenedor} className="mt-8 grid gap-6 xl:grid-cols-3">
        <Panel
          className="xl:col-span-2"
          titulo="Actividad diaria"
          subtitulo={
            actividad.length > 0
              ? `Reportes y solicitudes del ${formatearDia(actividad[0].fecha)} al ${formatearDia(actividad[actividad.length - 1].fecha)}`
              : 'Sin registros todavía'
          }
          accion={<SelectorPeriodo valor={periodo} onCambiar={setPeriodo} />}
        >
          {actividad.length > 0 ? (
            <>
              <div className="mb-5 flex flex-wrap gap-x-10 gap-y-3">
                <div>
                  <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Reportes</p>
                  <p className="mt-1 text-2xl font-semibold tracking-[-0.03em]">{totalReportes}</p>
                </div>
                <div>
                  <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Solicitudes</p>
                  <p className="mt-1 text-2xl font-semibold tracking-[-0.03em]">{totalSolicitudes}</p>
                </div>
                {actividad.length > 1 && (
                  <div>
                    <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Último día vs. anterior</p>
                    <p
                      className={`mt-1 text-2xl font-semibold tracking-[-0.03em] ${
                        variacion > 0 ? 'text-brand' : variacion < 0 ? 'text-emerald-600' : ''
                      }`}
                    >
                      {variacion > 0 ? '+' : ''}
                      {variacion}
                    </p>
                  </div>
                )}
              </div>
              <GraficoActividad key={periodo} datos={actividad} oscuro={oscuro} />
            </>
          ) : (
            <p className="py-16 text-center text-sm text-panel-text-soft">Aún no hay reportes ni solicitudes.</p>
          )}
        </Panel>

        <Panel titulo="Reportes por estado" subtitulo="Dirigidos a tu organización" accion={<EnlaceVer a="/admin/reportes" />}>
          <GraficoDona segmentos={segmentos} titulo="Reportes por estado" etiquetaTotal="reportes en total" oscuro={oscuro} />
        </Panel>
      </motion.div>

      {/* ===== Otras cifras ===== */}
      <motion.div variants={contenedor} className="mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-[28px] border border-panel-border bg-panel-border xl:grid-cols-4">
        {kpisSecundarios.map((k) => (
          <TarjetaKpi key={k.titulo} {...k} />
        ))}
      </motion.div>

      <motion.div variants={contenedor} className="mt-6 grid gap-6 lg:grid-cols-2 xl:grid-cols-3">
        <Panel
          titulo="Solicitudes por prioridad"
          subtitulo="Abiertas · manual si existe, si no la de la IA"
          accion={<EnlaceVer a="/admin/solicitudes" />}
        >
          {resumen.solicitudesAbiertas > 0 ? (
            <BarrasHorizontales barras={barrasPrioridad} unidad="solicitudes" color={oscuro ? '#7aa5ff' : '#0b1b36'} />
          ) : (
            <p className="py-10 text-center text-sm text-panel-text-soft">No hay solicitudes abiertas.</p>
          )}
        </Panel>

        <Panel titulo="Requieren atención" subtitulo="Solicitudes abiertas más urgentes" accion={<EnlaceVer a="/admin/solicitudes" />}>
          {datos.requierenAtencion.length === 0 ? (
            <p className="py-8 text-center text-sm text-panel-text-soft">Todo al día: no hay solicitudes abiertas.</p>
          ) : (
            <ul className="-my-1 divide-y divide-panel-border">
              {datos.requierenAtencion.map((s) => {
                const p = prioridadEfectiva(s)
                const OrigenIcono = s.origen === 'acelerometro' ? Activity : Smartphone
                return (
                  <li key={s.id} className="flex items-start gap-3 py-3">
                    <span className={`mt-0.5 w-[88px] shrink-0 rounded-full px-2 py-0.5 text-center text-[11px] font-semibold ${colorPrioridad[p]}`}>
                      {prioridades.find((x) => x.clave === p)?.etiqueta}
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm font-medium">{s.descripcion}</p>
                      <p className="mt-0.5 flex flex-wrap items-center gap-x-1.5 text-xs text-panel-text-muted">
                        <span>{s.ubicacion}</span>·<span>{formatearFechaCorta(s.fecha)}</span>·
                        <span className="flex items-center gap-1">
                          <OrigenIcono size={11} />
                          {s.origen === 'acelerometro' ? 'Automática' : 'Manual'}
                        </span>
                        {s.estado === 'en_atencion' && <span className="font-medium text-panel-info">· En atención</span>}
                      </p>
                    </div>
                  </li>
                )
              })}
            </ul>
          )}
        </Panel>

        <Panel
          className="lg:col-span-2 xl:col-span-1"
          titulo="Actividad reciente"
          subtitulo="Últimos cambios registrados en auditoría"
          accion={<EnlaceVer a="/admin/auditoria" />}
        >
          {datos.auditoriaReciente.length === 0 ? (
            <p className="py-8 text-center text-sm text-panel-text-soft">Todavía no hay actividad registrada.</p>
          ) : (
            <ol className="relative space-y-4 before:absolute before:bottom-2 before:left-[13px] before:top-2 before:w-px before:bg-panel-border">
              {datos.auditoriaReciente.map((r) => {
                const { verbo, icono: Icono, clase } = operacion[r.operacion]
                return (
                  <li key={r.id} className="relative flex gap-3">
                    <span className={`relative flex h-7 w-7 shrink-0 items-center justify-center rounded-full ring-4 ring-panel-card ${clase}`}>
                      <Icono size={13} />
                    </span>
                    <div className="min-w-0 pt-0.5 text-sm">
                      <p>
                        <span className="font-semibold">
                          {r.usuarioNombre ?? (
                            <span className="inline-flex items-center gap-1">
                              <Bot size={13} /> Sistema
                            </span>
                          )}
                        </span>{' '}
                        <span className="text-panel-text-soft">
                          {verbo} {etiquetaTabla[r.tabla]}
                        </span>
                      </p>
                      <p className="mt-0.5 truncate text-xs text-panel-text-muted">
                        {formatearFechaCorta(r.creadoEn)}
                        {r.camposModificados?.length ? ` · ${r.camposModificados.join(', ')}` : ''}
                      </p>
                    </div>
                  </li>
                )
              })}
            </ol>
          )}
        </Panel>
      </motion.div>
    </motion.div>
  )
}
