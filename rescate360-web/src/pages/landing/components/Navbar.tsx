import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { AnimatePresence, motion } from 'motion/react'
import { ArrowRight, Menu, Moon, Sun, X } from 'lucide-react'
import type { Tema } from './comunes'

const enlaces = [
  { href: '#que-es', label: 'Qué es' },
  { href: '#capacidades', label: 'Capacidades' },
  { href: '#sin-senal', label: 'Sin señal' },
  { href: '#como-funciona', label: 'Cómo funciona' },
  { href: '#para-quien', label: 'Para quién' },
  { href: '#descarga', label: 'Descarga' },
]

const vidrio =
  'border border-white/70 bg-white/60 shadow-[0_8px_30px_-12px_rgba(11,27,54,0.18)] backdrop-blur-xl dark:border-white/10 dark:bg-[#0b1426]/75 dark:shadow-none'

export default function Navbar({ tema, alternar }: { tema: Tema; alternar: () => void }) {
  const [abierto, setAbierto] = useState(false)
  const [conScroll, setConScroll] = useState(false)
  const [activa, setActiva] = useState<string | null>(null)

  useEffect(() => {
    const alBajar = () => {
      setConScroll(window.scrollY > 24)
      // Arriba del todo (hero) no se resalta ninguna sección.
      if (window.scrollY < window.innerHeight * 0.5) setActiva(null)
    }
    alBajar()
    window.addEventListener('scroll', alBajar, { passive: true })
    return () => window.removeEventListener('scroll', alBajar)
  }, [])

  // Sección visible: la que cruza la franja central de la pantalla.
  useEffect(() => {
    const observador = new IntersectionObserver(
      (entradas) => {
        entradas.forEach((e) => {
          if (e.isIntersecting) setActiva(`#${e.target.id}`)
        })
      },
      { rootMargin: '-45% 0px -50% 0px' },
    )
    enlaces.forEach((e) => {
      const el = document.querySelector(e.href)
      if (el) observador.observe(el)
    })
    return () => observador.disconnect()
  }, [])

  return (
    <motion.header
      initial={{ y: -24, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
      className="fixed inset-x-0 top-0 z-50 px-4 pt-4"
    >
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-3">
        {/* Marca */}
        <a
          href="#inicio"
          aria-label="RESCATE360, inicio"
          className={`flex h-11 w-11 items-center justify-center rounded-full transition ${vidrio} ${conScroll ? 'bg-white/80' : ''}`}
        >
          <img src="/logoRescate.png" alt="" className="h-6 w-6" />
        </a>

        {/* Enlaces (escritorio) */}
        <nav aria-label="Secciones" className={`hidden items-center gap-1 rounded-full p-1 md:flex ${vidrio}`}>
          {enlaces.map((e) => {
            const esActiva = activa === e.href
            return (
              <a
                key={e.href}
                href={e.href}
                aria-current={esActiva ? 'location' : undefined}
                className={`relative rounded-full px-3.5 py-1.5 text-[13px] font-medium transition-colors ${
                  esActiva
                    ? 'text-white dark:text-navy-950'
                    : 'text-slate-600 hover:text-navy-950 dark:text-white/65 dark:hover:text-white'
                }`}
              >
                {/* Píldora que se desliza hasta la sección en pantalla */}
                {esActiva && (
                  <motion.span
                    layoutId="seccion-activa"
                    transition={{ type: 'spring', stiffness: 380, damping: 32 }}
                    className="absolute inset-0 -z-10 rounded-full bg-navy-950 shadow-[0_6px_16px_-6px_rgba(11,27,54,0.6)] dark:bg-white"
                  />
                )}
                <span className="relative">{e.label}</span>
              </a>
            )
          })}
        </nav>

        {/* Acciones */}
        <div className={`flex items-center gap-1 rounded-full p-1 ${vidrio}`}>
          <button
            type="button"
            onClick={alternar}
            aria-label={tema === 'claro' ? 'Activar modo oscuro' : 'Activar modo claro'}
            className="flex h-9 w-9 items-center justify-center rounded-full text-slate-600 transition hover:bg-white hover:text-navy-950 dark:text-white/70 dark:hover:bg-white/10 dark:hover:text-white"
          >
            <AnimatePresence mode="wait" initial={false}>
              <motion.span
                key={tema}
                initial={{ rotate: -90, opacity: 0, scale: 0.6 }}
                animate={{ rotate: 0, opacity: 1, scale: 1 }}
                exit={{ rotate: 90, opacity: 0, scale: 0.6 }}
                transition={{ duration: 0.2 }}
              >
                {tema === 'claro' ? <Moon size={16} /> : <Sun size={16} />}
              </motion.span>
            </AnimatePresence>
          </button>
          <Link
            to="/login"
            className="group hidden items-center gap-1.5 rounded-full bg-navy-950 px-4 py-2 text-[13px] font-semibold text-white transition hover:bg-navy-800 sm:flex dark:bg-white dark:text-navy-950 dark:hover:bg-white/90"
          >
            Ingresar
            <ArrowRight size={14} className="transition-transform group-hover:translate-x-0.5" />
          </Link>
          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-full text-slate-700 transition hover:bg-white md:hidden dark:text-white dark:hover:bg-white/10"
            aria-label={abierto ? 'Cerrar menú' : 'Abrir menú'}
            aria-expanded={abierto}
            aria-controls="menu-movil"
            onClick={() => setAbierto((a) => !a)}
          >
            {abierto ? <X size={18} /> : <Menu size={18} />}
          </button>
        </div>
      </div>

      {/* Menú móvil */}
      <AnimatePresence>
        {abierto && (
          <motion.nav
            id="menu-movil"
            aria-label="Navegación móvil"
            initial={{ opacity: 0, y: -8, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -8, scale: 0.98 }}
            transition={{ duration: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className={`mx-auto mt-2 grid max-w-6xl gap-1 rounded-3xl p-2 md:hidden ${vidrio} bg-white/90 dark:bg-navy-950/90`}
          >
            {enlaces.map((e) => (
              <a
                key={e.href}
                href={e.href}
                onClick={() => setAbierto(false)}
                aria-current={activa === e.href ? 'location' : undefined}
                className={`rounded-2xl px-4 py-3 text-sm font-medium transition ${
                  activa === e.href
                    ? 'bg-navy-950 text-white dark:bg-white dark:text-navy-950'
                    : 'text-slate-700 hover:bg-slate-100 dark:text-white/80 dark:hover:bg-white/10'
                }`}
              >
                {e.label}
              </a>
            ))}
            <Link
              to="/login"
              onClick={() => setAbierto(false)}
              className="mt-1 flex items-center justify-center gap-2 rounded-2xl bg-navy-950 px-4 py-3 text-sm font-semibold text-white dark:bg-white dark:text-navy-950"
            >
              Ingresar al panel <ArrowRight size={14} />
            </Link>
          </motion.nav>
        )}
      </AnimatePresence>
    </motion.header>
  )
}
