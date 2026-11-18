import { motion, useReducedMotion } from 'motion/react'
import { ArrowRight, Check } from 'lucide-react'
import BlurText from '../../../components/reactbits/BlurText/BlurText'
import EscudoPuntos from './EscudoPuntos'
import type { Tema } from './comunes'

const sellos = [
  'Funciona sin internet',
  'Prioridad asistida por IA',
  'Datos tratados según la Ley 1581',
  'Alertas oficiales en tiempo real',
]

export default function Hero({ tema }: { tema: Tema }) {
  const reducir = useReducedMotion()
  const entrar = (retraso: number) => ({
    initial: reducir ? false : { opacity: 0, y: 14, filter: 'blur(6px)' },
    animate: { opacity: 1, y: 0, filter: 'blur(0px)' },
    transition: { duration: 0.8, delay: retraso, ease: [0.22, 1, 0.36, 1] as const },
  })

  return (
    <section id="inicio" className="relative flex min-h-[100svh] flex-col overflow-hidden pt-24">
      <div className="mx-auto grid w-full max-w-6xl flex-1 items-center gap-6 px-5 sm:px-6 lg:grid-cols-[1.08fr_0.92fr] lg:gap-4">
        <div className="relative z-10 py-6 lg:py-0">
          <motion.p {...entrar(0.05)} className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-slate-500 dark:text-white/50">
            <span className="relative flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-brand opacity-60 motion-reduce:hidden" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-brand" />
            </span>
            Red de respuesta · Valledupar, Cesar
          </motion.p>

          <motion.div {...entrar(0.12)} className="mt-6 flex items-center gap-3">
            <img src="/logoRescate.png" alt="" className="h-11 w-11 sm:h-14 sm:w-14" />
            <span className="font-display text-4xl font-bold tracking-[-0.045em] text-navy-950 sm:text-6xl dark:text-white">
              RESCATE<span className="text-brand">360</span>
            </span>
          </motion.div>

          <h1 className="sr-only">Reporta en segundos. Ayuda en minutos.</h1>
          <div aria-hidden="true" className="mt-6 font-display text-[44px] font-semibold leading-[0.98] tracking-[-0.045em] sm:text-6xl lg:text-[50px] xl:text-[56px]">
            <BlurText
              text="Reporta en segundos."
              trigger="load"
              delay={90}
              stepDuration={0.4}
              className="text-navy-950 dark:text-white"
            />
            <BlurText text="Ayuda en minutos." trigger="load" delay={90} stepDuration={0.4} className="text-brand" />
          </div>

          <motion.p {...entrar(0.55)} className="mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg dark:text-white/60">
            Conecta a la comunidad con bomberos, Cruz Roja, Defensa Civil y voluntarios: reportes con ubicación, solicitudes
            de ayuda priorizadas y alertas oficiales, incluso cuando no hay señal.
          </motion.p>

          <motion.div {...entrar(0.7)} className="mt-8 flex flex-wrap gap-3">
            <a
              href="#descarga"
              className="group inline-flex items-center gap-2 rounded-full bg-brand px-5 py-3 text-sm font-semibold text-white shadow-[0_10px_30px_-10px_rgba(232,52,63,0.7)] transition hover:bg-brand-dark active:scale-[0.98]"
            >
              Descargar la app
              <ArrowRight size={16} className="transition-transform group-hover:translate-x-0.5" />
            </a>
            <a
              href="#como-funciona"
              className="inline-flex items-center gap-2 rounded-full border border-slate-300 bg-white/50 px-5 py-3 text-sm font-semibold text-navy-950 backdrop-blur transition hover:border-slate-400 hover:bg-white active:scale-[0.98] dark:border-white/15 dark:bg-white/5 dark:text-white dark:hover:bg-white/10"
            >
              Ver cómo funciona
            </a>
          </motion.div>
        </div>

        <motion.div
          initial={reducir ? false : { opacity: 0, scale: 0.94 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1.2, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
          className="relative mx-auto w-full max-w-[340px] sm:max-w-[440px] lg:max-w-[560px]"
        >
          <EscudoPuntos oscuro={tema === 'oscuro'} />
          <p className="pointer-events-none absolute bottom-[6%] right-0 font-mono text-[10px] uppercase tracking-[0.18em] text-slate-400 dark:text-white/35">
            Señal · respuesta coordinada
          </p>
        </motion.div>
      </div>

      {/* Sellos */}
      <motion.ul
        {...entrar(0.9)}
        aria-label="Características"
        className="mx-auto flex w-full max-w-6xl flex-wrap justify-center gap-2 px-5 pb-8 pt-6 sm:px-6"
      >
        {sellos.map((s) => (
          <li
            key={s}
            className="inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white/60 px-3 py-1.5 text-xs text-slate-600 backdrop-blur dark:border-white/10 dark:bg-white/5 dark:text-white/65"
          >
            <Check size={13} className="text-emerald-600 dark:text-emerald-400" /> {s}
          </li>
        ))}
      </motion.ul>
    </section>
  )
}
