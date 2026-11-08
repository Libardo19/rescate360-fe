import { useEffect, useState, type ReactNode } from 'react'
import { Link, NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { AnimatePresence, motion } from 'motion/react'
import { Bell, ChevronDown, Command, LayoutGrid, LogOut, Moon, Search, Sun } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import { listarOrganizaciones } from '../services/organizaciones.service'
import { useTema, type Tema } from '../pages/landing/components/comunes'
import PaletaComandos from '../components/panel/PaletaComandos'
import type { ItemMenu } from '../routes/menus'

interface Props {
  menu: ItemMenu[]
  titulo: string
}

// Lo que reciben las pantallas del panel por <Outlet context>.
export interface ContextoPanel {
  tema: Tema
}

const vidrio =
  'border border-panel-border/80 bg-panel-card/75 shadow-[0_10px_30px_-14px_rgba(11,27,54,0.25)] backdrop-blur-xl'

// Agrupa por `grupo`, respetando el orden.
function agrupar(items: ItemMenu[]) {
  const grupos: { nombre: string; items: ItemMenu[] }[] = []
  items.forEach((item) => {
    const nombre = item.grupo ?? ''
    const actual = grupos.at(-1)
    if (actual && actual.nombre === nombre) actual.items.push(item)
    else grupos.push({ nombre, items: [item] })
  })
  return grupos
}

const esRutaActiva = (m: ItemMenu, ruta: string) => (m.fin ? ruta === m.ruta : ruta.startsWith(m.ruta))

// Píldora de una sección; la resaltada se desliza entre ellas (layoutId).
function Pildora({ activo, children, grupo = 'barra' }: { activo: boolean; children: ReactNode; grupo?: string }) {
  return (
    <>
      {activo && (
        <motion.span
          layoutId={`seccion-${grupo}`}
          transition={{ type: 'spring', stiffness: 420, damping: 36 }}
          className="absolute inset-0 -z-10 rounded-full bg-navy-950 shadow-[0_8px_18px_-8px_rgba(11,27,54,0.7)] dark:bg-white"
        />
      )}
      {children}
    </>
  )
}

export default function PanelLayout({ menu, titulo }: Props) {
  const [masAbierto, setMasAbierto] = useState(false)
  const [paleta, setPaleta] = useState(false)
  const [menuUsuario, setMenuUsuario] = useState(false)
  const [nombreOrg, setNombreOrg] = useState('')
  const [conScroll, setConScroll] = useState(false)
  const { usuario, cerrarSesion } = useAuth()
  const { tema, alternar } = useTema()
  const navigate = useNavigate()
  const location = useLocation()

  const principales = menu.filter((m) => m.principal)
  const secundarios = menu.filter((m) => !m.principal)
  const secundarioActivo = secundarios.find((m) => esRutaActiva(m, location.pathname))

  useEffect(() => {
    if (!usuario?.organizacion_id) return
    listarOrganizaciones()
      .then((orgs) => setNombreOrg(orgs.find((o) => o.id === usuario.organizacion_id)?.nombre ?? ''))
      .catch(() => setNombreOrg(''))
  }, [usuario?.organizacion_id])

  // Atajo Ctrl/⌘ + K para la paleta de comandos.
  useEffect(() => {
    const alPulsar = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault()
        setPaleta((p) => !p)
      }
      if (e.key === 'Escape') setMasAbierto(false)
    }
    const alBajar = () => setConScroll(window.scrollY > 12)
    window.addEventListener('keydown', alPulsar)
    window.addEventListener('scroll', alBajar, { passive: true })
    return () => {
      window.removeEventListener('keydown', alPulsar)
      window.removeEventListener('scroll', alBajar)
    }
  }, [])

  const salir = () => {
    cerrarSesion()
    navigate('/login')
  }

  const iniciales =
    usuario?.nombre
      .split(' ')
      .map((p) => p[0])
      .slice(0, 2)
      .join('')
      .toUpperCase() ?? ''

  return (
    <div
      data-tema={tema}
      className="panel-raiz relative isolate min-h-screen bg-panel-bg font-display text-panel-text antialiased transition-colors duration-500"
    >
      {/* Fondo: brillos suaves y grilla de puntos (mismo lenguaje que la landing) */}
      <div aria-hidden="true" className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div className="absolute -top-56 left-1/2 h-[620px] w-[1100px] -translate-x-1/2 rounded-full bg-[radial-gradient(closest-side,rgba(62,123,250,0.14),transparent)]" />
        <div className="absolute -right-40 top-1/2 h-[460px] w-[460px] rounded-full bg-[radial-gradient(closest-side,rgba(232,52,63,0.07),transparent)]" />
        <div className="absolute inset-0 opacity-60 [background-image:radial-gradient(rgba(11,27,54,0.07)_1px,transparent_1px)] [background-size:22px_22px] [mask-image:linear-gradient(to_bottom,black,transparent_75%)] dark:[background-image:radial-gradient(rgba(255,255,255,0.06)_1px,transparent_1px)]" />
      </div>

      {/* ===== Barra superior flotante ===== */}
      <header className="fixed inset-x-0 top-0 z-50 px-3 pt-3 sm:px-4 sm:pt-4">
        <div className="mx-auto flex max-w-[1200px] items-center justify-between gap-3">
          {/* Marca + organización */}
          <Link
            to="/admin"
            className={`flex h-12 items-center gap-2.5 rounded-full pl-1.5 pr-4 transition ${vidrio} ${conScroll ? 'bg-panel-card/90' : ''}`}
            aria-label="Inicio del panel"
          >
            <span className="flex h-9 w-9 items-center justify-center rounded-full bg-navy-950 dark:bg-white">
              <img src="/logoRescate.png" alt="" className="h-5 w-5" />
            </span>
            <span className="hidden leading-tight sm:block">
              <span className="block text-sm font-semibold tracking-[-0.02em]">
                RESCATE<span className="text-brand">360</span>
              </span>
              <span className="block max-w-[160px] truncate font-mono text-[9px] uppercase tracking-[0.14em] text-panel-text-muted">
                {nombreOrg || `Panel ${titulo}`}
              </span>
            </span>
          </Link>

          {/* Secciones (pantallas grandes) */}
          <nav aria-label="Secciones del panel" className={`relative hidden items-center gap-0.5 rounded-full p-1 lg:flex ${vidrio}`}>
            {principales.map((m) => (
              <NavLink
                key={m.ruta}
                to={m.ruta}
                end={m.fin}
                className={({ isActive }) =>
                  `relative isolate flex items-center gap-2 rounded-full px-3.5 py-2 text-[13px] font-medium transition-colors ${
                    isActive ? 'text-white dark:text-navy-950' : 'text-panel-text-soft hover:text-panel-text'
                  }`
                }
              >
                {({ isActive }) => (
                  <Pildora activo={isActive}>
                    <m.icono size={15} strokeWidth={2} />
                    {m.corta ?? m.etiqueta}
                  </Pildora>
                )}
              </NavLink>
            ))}

            {/* "Más": muestra el nombre de la sección secundaria activa */}
            <button
              onClick={() => setMasAbierto((a) => !a)}
              aria-expanded={masAbierto}
              aria-haspopup="true"
              className={`relative isolate flex items-center gap-1.5 rounded-full px-3.5 py-2 text-[13px] font-medium transition-colors ${
                secundarioActivo ? 'text-white dark:text-navy-950' : 'text-panel-text-soft hover:text-panel-text'
              }`}
            >
              <Pildora activo={!!secundarioActivo}>
                <LayoutGrid size={15} strokeWidth={2} />
                {secundarioActivo?.etiqueta ?? 'Más'}
                <ChevronDown size={14} className={`transition-transform ${masAbierto ? 'rotate-180' : ''}`} />
              </Pildora>
            </button>

            {/* Mega-menú */}
            <AnimatePresence>
              {masAbierto && (
                <>
                  <div className="fixed inset-0 -z-10" onClick={() => setMasAbierto(false)} />
                  <motion.div
                    initial={{ opacity: 0, y: -8, scale: 0.98 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -6, scale: 0.98 }}
                    transition={{ duration: 0.18, ease: [0.22, 1, 0.36, 1] }}
                    className="absolute right-0 top-[calc(100%+10px)] grid w-[560px] grid-cols-2 gap-1 rounded-[28px] border border-panel-border bg-panel-card p-3 shadow-[0_30px_70px_-30px_rgba(11,27,54,0.5)]"
                  >
                    {agrupar(secundarios).map((g) => (
                      <div key={g.nombre}>
                        <p className="px-3 pb-1.5 pt-2 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">{g.nombre}</p>
                        {g.items.map((m) => {
                          const activo = esRutaActiva(m, location.pathname)
                          return (
                            <Link
                              key={m.ruta}
                              to={m.ruta}
                              onClick={() => setMasAbierto(false)}
                              className={`group flex items-start gap-3 rounded-2xl p-3 transition-colors hover:bg-panel-bg ${activo ? 'bg-panel-bg' : ''}`}
                            >
                              <span
                                className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border transition ${
                                  activo
                                    ? 'border-transparent bg-navy-950 text-white dark:bg-white dark:text-navy-950'
                                    : 'border-panel-border text-panel-text-soft group-hover:text-panel-text'
                                }`}
                              >
                                <m.icono size={16} strokeWidth={1.9} />
                              </span>
                              <span className="min-w-0">
                                <span className="block text-sm font-medium">{m.etiqueta}</span>
                                <span className="block text-xs leading-snug text-panel-text-muted">{m.descripcion}</span>
                              </span>
                            </Link>
                          )
                        })}
                      </div>
                    ))}
                  </motion.div>
                </>
              )}
            </AnimatePresence>
          </nav>

          {/* Acciones */}
          <div className={`flex h-12 items-center gap-1 rounded-full p-1 ${vidrio}`}>
            <button
              onClick={() => setPaleta(true)}
              className="flex h-10 items-center gap-2 rounded-full px-3 text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-text"
              aria-label="Buscar (Ctrl + K)"
            >
              <Search size={16} />
              <kbd className="hidden items-center gap-0.5 rounded-md border border-panel-border px-1.5 py-0.5 font-mono text-[10px] text-panel-text-muted xl:flex">
                <Command size={10} />K
              </kbd>
            </button>
            <button
              onClick={alternar}
              aria-label={tema === 'claro' ? 'Activar modo oscuro' : 'Activar modo claro'}
              className="flex h-10 w-10 items-center justify-center rounded-full text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-text"
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
            <button
              className="relative flex h-10 w-10 items-center justify-center rounded-full text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-text"
              aria-label="Notificaciones"
            >
              <Bell size={16} />
              <span className="absolute right-2.5 top-2.5 h-2 w-2 rounded-full bg-brand ring-2 ring-panel-card" />
            </button>

            <div className="relative">
              {menuUsuario && <div className="fixed inset-0 z-10" onClick={() => setMenuUsuario(false)} />}
              <button
                onClick={() => setMenuUsuario(!menuUsuario)}
                aria-label="Menú de usuario"
                className="relative z-20 flex h-10 w-10 items-center justify-center rounded-full bg-navy-950 text-xs font-bold text-white transition hover:scale-105 dark:bg-white dark:text-navy-950"
              >
                {iniciales}
              </button>
              <AnimatePresence>
                {menuUsuario && (
                  <motion.div
                    initial={{ opacity: 0, y: -6, scale: 0.97 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -6, scale: 0.97 }}
                    transition={{ duration: 0.16 }}
                    className="absolute right-0 top-[calc(100%+10px)] z-20 w-60 overflow-hidden rounded-3xl border border-panel-border bg-panel-card p-2 shadow-[0_30px_60px_-30px_rgba(11,27,54,0.5)]"
                  >
                    <div className="px-3 py-2.5">
                      <p className="truncate text-sm font-semibold">{usuario?.nombre}</p>
                      <p className="truncate text-xs text-panel-text-muted">{usuario?.email}</p>
                      <p className="mt-1.5 font-mono text-[10px] uppercase tracking-[0.14em] text-panel-text-muted">
                        {usuario?.rol.replace('_', ' ')}
                      </p>
                    </div>
                    <button
                      onClick={salir}
                      className="flex w-full items-center gap-2 rounded-2xl px-3 py-2.5 text-sm text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-text"
                    >
                      <LogOut size={15} /> Cerrar sesión
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>
      </header>

      {/* ===== Contenido ===== */}
      <main className="mx-auto max-w-[1200px] px-4 pb-32 pt-24 sm:px-6 sm:pt-28 lg:pb-16">
        {/* La key reinicia la animación de entrada en cada cambio de sección. */}
        <div key={location.pathname} className="panel-page-enter">
          <Outlet context={{ tema } satisfies ContextoPanel} />
        </div>
      </main>

      {/* ===== Dock flotante (móvil y tablet) ===== */}
      <nav
        aria-label="Navegación rápida"
        className={`fixed bottom-4 left-1/2 z-50 flex -translate-x-1/2 items-center gap-1 rounded-full p-1.5 lg:hidden ${vidrio} bg-panel-card/90`}
      >
        {principales.slice(0, 4).map((m) => (
          <NavLink
            key={m.ruta}
            to={m.ruta}
            end={m.fin}
            aria-label={m.etiqueta}
            className={({ isActive }) =>
              `relative isolate flex h-12 w-12 flex-col items-center justify-center rounded-full transition-colors ${
                isActive ? 'text-white dark:text-navy-950' : 'text-panel-text-soft'
              }`
            }
          >
            {({ isActive }) => (
              <Pildora activo={isActive} grupo="dock">
                <m.icono size={19} strokeWidth={1.9} />
              </Pildora>
            )}
          </NavLink>
        ))}
        <span className="mx-1 h-6 w-px bg-panel-border" />
        <button
          onClick={() => setPaleta(true)}
          aria-label="Todas las secciones"
          className={`relative isolate flex h-12 w-12 items-center justify-center rounded-full transition-colors ${
            secundarioActivo || location.pathname.startsWith('/admin/alertas') ? 'text-white dark:text-navy-950' : 'text-panel-text-soft'
          }`}
        >
          <Pildora grupo="dock" activo={!!secundarioActivo || location.pathname.startsWith('/admin/alertas')}>
            <LayoutGrid size={19} strokeWidth={1.9} />
          </Pildora>
        </button>
      </nav>

      <PaletaComandos abierta={paleta} onCerrar={() => setPaleta(false)} menu={menu} />
    </div>
  )
}
