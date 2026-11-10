import { useState, type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { motion, useReducedMotion, type Variants } from 'motion/react'
import {
  FileWarning,
  LifeBuoy,
  Bell,
  Building2,
  Search,
  HeartHandshake,
  ArrowRight,
  ArrowUpRight,
  ChevronRight,
  Sparkles,
  type LucideIcon,
} from 'lucide-react'
import { obtenerDashboardAdmin } from '../../services/dashboard.service'
import type { DashboardAdmin } from '../../types/dashboard'
import { useConsultaPeriodica } from '../../hooks/useConsultaPeriodica'
import { useAuth } from '../../context/AuthContext'
import CountUp from '../../components/reactbits/CountUp/CountUp'
import { botonCabeceraPrincipal, botonCabeceraSecundario } from '../../components/panel/CabeceraPanel'

// El backend manda el estado tal cual (de reportes o de solicitudes)
const estados: Record<string, { etiqueta: string; color: string }> = {
  pendiente: { etiqueta: 'Pendiente', color: 'bg-amber-100 text-amber-700' },
  verificado: { etiqueta: 'Verificado', color: 'bg-green-100 text-green-700' },
  en_proceso: { etiqueta: 'En proceso', color: 'bg-blue-100 text-blue-700' },
  atendido: { etiqueta: 'Atendido', color: 'bg-blue-100 text-blue-700' },
  atendida: { etiqueta: 'Atendida', color: 'bg-green-100 text-green-700' },
  rechazado: { etiqueta: 'Rechazado', color: 'bg-red-100 text-red-700' },
  cancelada: { etiqueta: 'Cancelada', color: 'bg-slate-200 text-slate-600' },
  duplicado: { etiqueta: 'Duplicado', color: 'bg-slate-200 text-slate-600' },
  no_verificable: { etiqueta: 'No verificable', color: 'bg-slate-200 text-slate-600' },
}

const saludo = () => {
  const h = new Date().getHours()
  return h < 12 ? 'Buenos días' : h < 19 ? 'Buenas tardes' : 'Buenas noches'
}

const plural = (n: number, uno: string, varios: string) => `${n} ${n === 1 ? uno : varios}`
const B = ({ children }: { children: ReactNode }) => <strong className="font-semibold text-panel-text">{children}</strong>

const contenedor: Variants = { oculto: {}, visible: { transition: { staggerChildren: 0.08 } } }
const aparecer: Variants = {
  oculto: { opacity: 0, y: 22 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] } },
}

interface Cifra {
  titulo: string
  valor: number
  icono: LucideIcon
  a: string
  pie: string
  alerta?: boolean // punto rojo cuando hay algo que atender
}

export default function AdminDashboard() {
  const { usuario } = useAuth()
  const [datos, setDatos] = useState<DashboardAdmin | null>(null)
  const [error, setError] = useState('')
  const reducir = useReducedMotion()
  const alBajar = {
    initial: reducir ? false : ('oculto' as const),
    whileInView: 'visible' as const,
    viewport: { once: true, margin: '0px 0px -8% 0px' },
  }

  // Los conteos y la actividad se refrescan solos, como las listas
  useConsultaPeriodica(() => {
    obtenerDashboardAdmin()
      .then((d) => {
        setDatos(d)
        setError('')
      })
      .catch(() => setError('No se pudo cargar el resumen.'))
  })

  if (error && !datos) return <p className="pt-4 text-panel-accent">{error}</p>
  if (!datos) return <p className="pt-4 text-panel-text-soft">Cargando…</p>

  const { resumen, recientes } = datos
  const primerNombre = usuario?.nombre.split(' ')[0] ?? ''
  const fecha = new Date().toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })
  const hoy = fecha.charAt(0).toUpperCase() + fecha.slice(1)
  const hora = new Date().toLocaleTimeString('es-CO', { hour: 'numeric', minute: '2-digit' })

  const cifras: Cifra[] = [
    { titulo: 'Solicitudes activas', valor: resumen.solicitudesActivas, icono: LifeBuoy, a: '/admin/solicitudes', pie: 'Esperando o en atención', alerta: resumen.solicitudesActivas > 0 },
    { titulo: 'Reportes pendientes', valor: resumen.reportesPendientes, icono: FileWarning, a: '/admin/reportes', pie: 'Sin verificar', alerta: resumen.reportesPendientes > 0 },
    { titulo: 'Alertas activas', valor: resumen.alertasActivas, icono: Bell, a: '/admin/alertas', pie: 'Publicadas a la comunidad' },
    { titulo: 'Centros de ayuda', valor: resumen.centrosRegistrados, icono: Building2, a: '/admin/centros', pie: 'Registrados' },
  ]
  if (resumen.personasBuscando !== undefined)
    cifras.push({ titulo: 'Personas en búsqueda', valor: resumen.personasBuscando, icono: Search, a: '/admin/desaparecidos', pie: 'Casos abiertos', alerta: resumen.personasBuscando > 0 })
  if (resumen.voluntariosActivos !== undefined)
    cifras.push({ titulo: 'Voluntarios activos', valor: resumen.voluntariosActivos, icono: HeartHandshake, a: '/admin/usuarios', pie: 'De tu organización' })

  // Briefing: resumen escrito a partir de los datos reales del backend.
  const frases: ReactNode[] = []
  if (resumen.solicitudesActivas > 0)
    frases.push(<>Hay <B>{plural(resumen.solicitudesActivas, 'solicitud activa', 'solicitudes activas')}</B> esperando o en atención.</>)
  else frases.push(<>No hay solicitudes de ayuda activas.</>)
  if (resumen.reportesPendientes > 0)
    frases.push(<><B>{plural(resumen.reportesPendientes, 'reporte espera', 'reportes esperan')}</B> verificación.</>)
  if (resumen.personasBuscando)
    frases.push(<><B>{plural(resumen.personasBuscando, 'persona sigue', 'personas siguen')}</B> en búsqueda.</>)
  const recomendacion =
    resumen.solicitudesActivas > 0
      ? { texto: 'Empieza por las solicitudes: son personas pidiendo ayuda ahora.', a: '/admin/solicitudes', boton: 'Atender solicitudes' }
      : resumen.reportesPendientes > 0
        ? { texto: 'Aprovecha para verificar los reportes pendientes.', a: '/admin/reportes', boton: 'Revisar reportes' }
        : { texto: 'Todo al día. Revisa el mapa para ver la situación general.', a: '/admin/mapa', boton: 'Abrir el mapa' }

  return (
    <div className="sin-cascada">
      {/* Encabezado */}
      <motion.div variants={aparecer} {...alBajar} className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-brand opacity-60 motion-reduce:hidden" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-brand" />
            </span>
            Centro de mando · {hoy}
          </p>
          <h1 className="mt-4 text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em] xl:text-[60px]">
            {saludo()}, {primerNombre}.
            <br />
            <span className={resumen.solicitudesActivas > 0 ? 'text-brand' : 'text-panel-text-muted'}>
              {resumen.solicitudesActivas > 0
                ? `${plural(resumen.solicitudesActivas, 'solicitud espera', 'solicitudes esperan')}.`
                : 'Todo está bajo control.'}
            </span>
          </h1>
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

      {error && <p className="mt-4 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      {/* Briefing del día */}
      <motion.section
        variants={aparecer}
        {...alBajar}
        aria-label="Briefing del día"
        className="relative mt-8 overflow-hidden rounded-[28px] border border-panel-border bg-panel-card p-6 sm:p-7"
      >
        <div aria-hidden="true" className="pointer-events-none absolute -right-20 -top-24 h-64 w-64 rounded-full bg-[radial-gradient(closest-side,rgba(124,92,214,0.14),transparent)]" />
        <div className="relative grid gap-6 lg:grid-cols-[minmax(0,1fr)_320px] lg:items-center">
          <div>
            <p className="flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">
              <span className="flex h-6 w-6 items-center justify-center rounded-full bg-linear-to-br from-panel-info to-violet-500 text-white">
                <Sparkles size={12} />
              </span>
              Briefing · {hora}
            </p>
            <div className="mt-4 space-y-1.5 text-[17px] leading-relaxed text-panel-text-soft sm:text-lg">
              {frases.map((f, i) => (
                <p key={i}>{f}</p>
              ))}
            </div>
          </div>
          <div className="rounded-3xl border border-panel-border bg-panel-bg p-5">
            <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">Recomendación</p>
            <p className="mt-2 text-sm leading-relaxed text-panel-text-soft">{recomendacion.texto}</p>
            <Link
              to={recomendacion.a}
              className="group mt-4 inline-flex items-center gap-1.5 rounded-full bg-navy-950 px-4 py-2 text-sm font-semibold text-white transition hover:bg-navy-800 dark:bg-white dark:text-navy-950"
            >
              {recomendacion.boton}
              <ArrowRight size={14} className="transition-transform group-hover:translate-x-0.5" />
            </Link>
          </div>
        </div>
        <p className="relative mt-5 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted/80">
          Generado a partir de tus datos · se actualiza solo
        </p>
      </motion.section>

      {/* Cifras: franja única con divisores */}
      <motion.div
        variants={contenedor}
        {...alBajar}
        className={`mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-[28px] border border-panel-border bg-panel-border ${
          cifras.length > 4 ? 'lg:grid-cols-3' : 'xl:grid-cols-4'
        }`}
      >
        {cifras.map(({ titulo, valor, icono: Icono, a, pie, alerta }) => (
          <motion.div key={titulo} variants={aparecer} className="h-full bg-panel-card">
            <Link to={a} className="group relative flex h-full flex-col p-5 transition-colors hover:bg-panel-bg sm:p-6">
              <div className="flex items-center justify-between gap-2">
                <p className="flex min-w-0 items-center gap-2 font-mono text-[10px] uppercase tracking-[0.14em] text-panel-text-muted">
                  <span
                    className={`h-1.5 w-1.5 shrink-0 rounded-full ${
                      alerta ? 'bg-brand shadow-[0_0_0_3px_rgba(232,52,63,0.18)]' : 'bg-panel-text-muted/50'
                    }`}
                  />
                  <span className="truncate">{titulo}</span>
                </p>
                <Icono size={15} strokeWidth={1.8} className="shrink-0 text-panel-text-muted transition group-hover:text-panel-text" />
              </div>
              <CountUp to={valor} duration={0.9} trigger="load" className="mt-5 block text-[48px] font-semibold leading-none tracking-[-0.05em]" />
              <p className="mt-3 text-xs text-panel-text-muted">{pie}</p>
              <ArrowUpRight
                size={16}
                className="absolute bottom-5 right-5 text-panel-text-muted opacity-0 transition group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-panel-text group-hover:opacity-100"
              />
            </Link>
          </motion.div>
        ))}
      </motion.div>

      {/* Actividad reciente */}
      <motion.section variants={aparecer} {...alBajar} className="mt-8 rounded-[28px] border border-panel-border bg-panel-card p-6 sm:p-7">
        <div className="flex flex-wrap items-start justify-between gap-2">
          <div>
            <h2 className="text-lg font-semibold tracking-[-0.02em]">Actividad reciente</h2>
            <p className="mt-0.5 text-xs text-panel-text-muted">Últimos reportes y solicitudes · se actualiza solo</p>
          </div>
          <Link
            to="/admin/solicitudes"
            className="group inline-flex items-center gap-1 rounded-full border border-panel-border px-3 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-soft transition hover:text-panel-text"
          >
            Ver solicitudes <ChevronRight size={12} className="transition-transform group-hover:translate-x-0.5" />
          </Link>
        </div>

        {recientes.length === 0 ? (
          <p className="py-10 text-center text-sm text-panel-text-soft">Todavía no hay actividad.</p>
        ) : (
          <ol className="mt-5 divide-y divide-panel-border">
            {recientes.map((r) => {
              const Icono = r.tipo === 'solicitud' ? LifeBuoy : FileWarning
              const estado = estados[r.estado]
              return (
                <li key={`${r.tipo}-${r.id}`}>
                  <Link
                    to={r.tipo === 'solicitud' ? '/admin/solicitudes' : '/admin/reportes'}
                    className="group -mx-3 flex items-center gap-4 rounded-2xl px-3 py-3.5 transition-colors hover:bg-panel-bg"
                  >
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-panel-border text-panel-text-soft">
                      <Icono size={17} strokeWidth={1.8} />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate text-sm font-medium">{r.titulo}</span>
                      <span className="block truncate text-xs text-panel-text-muted">
                        <span className="capitalize">{r.tipo}</span> · {r.detalle}
                      </span>
                    </span>
                    <span className="hidden shrink-0 sm:block">
                      <span className={`whitespace-nowrap rounded-full px-3 py-1 text-xs font-medium ${estado?.color ?? 'bg-slate-100 text-slate-600'}`}>
                        {estado?.etiqueta ?? r.estado}
                      </span>
                    </span>
                    <span className="w-20 shrink-0 text-right font-mono text-[11px] text-panel-text-muted">{r.hace}</span>
                  </Link>
                </li>
              )
            })}
          </ol>
        )}
      </motion.section>
    </div>
  )
}
