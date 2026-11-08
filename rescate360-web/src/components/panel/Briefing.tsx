import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { motion, useReducedMotion } from 'motion/react'
import { ArrowRight, Sparkles } from 'lucide-react'
import { prioridadEfectiva, type PrioridadIA } from '../../types/solicitud'
import type { DashboardAdmin } from '../../types/dashboard'
import { minutosDesde, UMBRAL_CRITICO_MIN } from '../../utils/espera'
import Semaforo from './Semaforo'

const peso: Record<PrioridadIA, number> = { critica: 0, alta: 1, pendiente: 2, media: 3, baja: 4 }
const nombrePrioridad: Record<PrioridadIA, string> = {
  critica: 'crítica',
  alta: 'alta',
  media: 'media',
  baja: 'baja',
  pendiente: 'sin clasificar',
}

const plural = (n: number, uno: string, varios: string) => `${n} ${n === 1 ? uno : varios}`
const B = ({ children }: { children: ReactNode }) => <strong className="font-semibold text-panel-text">{children}</strong>

// Resumen del día escrito a partir de los datos (reglas). Cuando el backend exponga la IA,
// el texto puede venir de allí; la recomendación sigue la misma lógica que el semáforo.
export default function Briefing({ datos, ahora }: { datos: DashboardAdmin; ahora: number }) {
  const reducir = useReducedMotion()
  const { resumen, pendientes } = datos
  const demoradas = pendientes.filter((s) => minutosDesde(s.fecha, ahora) >= UMBRAL_CRITICO_MIN)

  // La más urgente: prioridad primero; a igual prioridad, la que más lleva esperando.
  const primera = [...pendientes].sort((a, b) => {
    const p = peso[prioridadEfectiva(a)] - peso[prioridadEfectiva(b)]
    return p !== 0 ? p : a.fecha.localeCompare(b.fecha)
  })[0]

  const frases: ReactNode[] = []
  if (resumen.solicitudesUrgentes > 0) {
    frases.push(
      <>
        Hay <B>{plural(resumen.solicitudesUrgentes, 'solicitud urgente', 'solicitudes urgentes')}</B> abiertas
        {demoradas.length > 0 ? (
          <>
            {' '}y <B>{plural(demoradas.length, 'lleva', 'llevan')} más de 30 min</B> sin atención.
          </>
        ) : (
          '.'
        )}
      </>,
    )
  } else {
    frases.push(<>No hay solicitudes urgentes abiertas.</>)
  }
  if (resumen.solicitudesSinClasificar > 0) {
    frases.push(
      <>
        <B>{plural(resumen.solicitudesSinClasificar, 'solicitud no tiene', 'solicitudes no tienen')}</B> clasificación de la
        IA y {resumen.solicitudesSinClasificar === 1 ? 'necesita' : 'necesitan'} tu prioridad manual.
      </>,
    )
  }
  if (resumen.reportesPendientes > 0) {
    frases.push(
      <>
        <B>{plural(resumen.reportesPendientes, 'reporte espera', 'reportes esperan')}</B> verificación.
      </>,
    )
  }
  if (resumen.donacionesAgotadas > 0) {
    frases.push(
      <>
        <B>{plural(resumen.donacionesAgotadas, 'insumo está agotado', 'insumos están agotados')}</B> en los centros de ayuda.
      </>,
    )
  }

  const entrar = (i: number) => ({
    initial: reducir ? false : { opacity: 0, y: 6, filter: 'blur(4px)' },
    animate: { opacity: 1, y: 0, filter: 'blur(0px)' },
    transition: { duration: 0.5, delay: 0.15 + i * 0.12, ease: [0.22, 1, 0.36, 1] as const },
  })

  const hora = new Date(ahora).toLocaleTimeString('es-CO', { hour: 'numeric', minute: '2-digit' })

  return (
    <section
      aria-label="Briefing del día"
      className="relative overflow-hidden rounded-[28px] border border-panel-border bg-panel-card p-6 sm:p-7"
    >
      {/* Brillo sutil que recuerda a la IA */}
      <div aria-hidden="true" className="pointer-events-none absolute -right-20 -top-24 h-64 w-64 rounded-full bg-[radial-gradient(closest-side,rgba(124,92,214,0.14),transparent)]" />

      <div className="relative grid gap-6 lg:grid-cols-[minmax(0,1fr)_340px] lg:items-center">
        <div>
          <p className="flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="flex h-6 w-6 items-center justify-center rounded-full bg-linear-to-br from-panel-info to-violet-500 text-white">
              <Sparkles size={12} />
            </span>
            Briefing · {hora}
          </p>
          <div className="mt-4 space-y-1.5 text-[17px] leading-relaxed text-panel-text-soft sm:text-lg">
            {frases.map((f, i) => (
              <motion.p key={i} {...entrar(i)}>
                {f}
              </motion.p>
            ))}
          </div>
        </div>

        {/* Recomendación */}
        <motion.div {...entrar(frases.length)} className="rounded-3xl border border-panel-border bg-panel-bg p-5">
          <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">Recomendación</p>
          {primera ? (
            <>
              <p className="mt-2 text-sm leading-relaxed text-panel-text-soft">
                Empieza por{' '}
                <B>
                  “{primera.descripcion.length > 70 ? `${primera.descripcion.slice(0, 70).trimEnd()}…` : primera.descripcion}”
                </B>{' '}
                ({nombrePrioridad[prioridadEfectiva(primera)]}, {primera.ubicacion}).
              </p>
              <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
                <Semaforo minutos={minutosDesde(primera.fecha, ahora)} />
                <Link
                  to="/admin/solicitudes"
                  className="group inline-flex items-center gap-1.5 rounded-full bg-navy-950 px-4 py-2 text-sm font-semibold text-white transition hover:bg-navy-800 dark:bg-white dark:text-navy-950"
                >
                  Atender ahora
                  <ArrowRight size={14} className="transition-transform group-hover:translate-x-0.5" />
                </Link>
              </div>
            </>
          ) : (
            <p className="mt-2 text-sm text-panel-text-soft">
              Nadie está esperando atención. {resumen.reportesPendientes > 0 ? 'Aprovecha para verificar los reportes pendientes.' : 'Todo al día.'}
            </p>
          )}
        </motion.div>
      </div>

      <p className="relative mt-5 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted/80">
        Generado con reglas a partir de tus datos · se actualiza solo
      </p>
    </section>
  )
}
