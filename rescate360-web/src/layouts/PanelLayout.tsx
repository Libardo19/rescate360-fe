import { useEffect, useState } from 'react'
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { motion } from 'motion/react'
import { Bell, ChevronDown, LogOut, Menu, Moon, Search, ShieldCheck, Sun, X } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import { listarOrganizaciones } from '../services/organizaciones.service'
import { useTema, type Tema } from '../pages/landing/components/comunes'
import type { ItemMenu } from '../routes/menus'

interface Props {
  menu: ItemMenu[]
  titulo: string
}

// Lo que reciben las pantallas del panel por <Outlet context>.
export interface ContextoPanel {
  tema: Tema
}

// Agrupa el menú por `grupo`, respetando el orden en que aparecen.
function agrupar(menu: ItemMenu[]) {
  const grupos: { nombre: string; items: ItemMenu[] }[] = []
  menu.forEach((item) => {
    const nombre = item.grupo ?? ''
    const actual = grupos.at(-1)
    if (actual && actual.nombre === nombre) actual.items.push(item)
    else grupos.push({ nombre, items: [item] })
  })
  return grupos
}

export default function PanelLayout({ menu, titulo }: Props) {
  const [abierto, setAbierto] = useState(false)
  const [menuUsuario, setMenuUsuario] = useState(false)
  const [nombreOrg, setNombreOrg] = useState('')
  const { usuario, cerrarSesion } = useAuth()
  const { tema, alternar } = useTema()
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    if (!usuario?.organizacion_id) return
    listarOrganizaciones()
      .then((orgs) => setNombreOrg(orgs.find((o) => o.id === usuario.organizacion_id)?.nombre ?? ''))
      .catch(() => setNombreOrg(''))
  }, [usuario?.organizacion_id])

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

  // Sección actual para la ruta de navegación de la barra superior.
  const actual = [...menu].reverse().find((m) => (m.fin ? location.pathname === m.ruta : location.pathname.startsWith(m.ruta)))

  return (
    <div
      data-tema={tema}
      className="panel-raiz relative isolate flex min-h-screen bg-panel-bg font-display text-panel-text antialiased transition-colors duration-500"
    >
      {/* Fondo: brillos suaves y grilla de puntos (mismo lenguaje que la landing) */}
      <div aria-hidden="true" className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div className="absolute -top-48 left-1/2 h-[560px] w-[1000px] -translate-x-1/3 rounded-full bg-[radial-gradient(closest-side,rgba(62,123,250,0.13),transparent)]" />
        <div className="absolute -right-40 top-1/3 h-[420px] w-[420px] rounded-full bg-[radial-gradient(closest-side,rgba(232,52,63,0.07),transparent)]" />
        <div className="absolute inset-0 opacity-60 [background-image:radial-gradient(rgba(11,27,54,0.07)_1px,transparent_1px)] [background-size:22px_22px] [mask-image:linear-gradient(to_bottom,black,transparent_70%)] dark:[background-image:radial-gradient(rgba(255,255,255,0.06)_1px,transparent_1px)]" />
      </div>

      {abierto && <div className="fixed inset-0 z-40 bg-navy-950/40 backdrop-blur-sm lg:hidden" onClick={() => setAbierto(false)} />}

      {/* Menú lateral: tarjeta flotante fija en PC, desplegable en móvil */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-[272px] p-3 transition-transform duration-300 ease-out lg:sticky lg:top-0 lg:z-auto lg:h-screen lg:translate-x-0 ${
          abierto ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex h-full flex-col rounded-[28px] border border-panel-border bg-panel-card/85 shadow-[0_20px_50px_-30px_rgba(11,27,54,0.35)] backdrop-blur-xl">
          <div className="flex items-center justify-between px-5 pb-3 pt-5">
            <NavLink to="/" className="flex items-center gap-2" aria-label="RESCATE360, ir a la página principal">
              <img src="/logoRescate.png" alt="" className="h-8 w-8" />
              <span className="text-xl font-bold tracking-[-0.04em]">
                RESCATE<span className="text-brand">360</span>
              </span>
            </NavLink>
            <button
              className="rounded-full p-1.5 text-panel-text-soft transition hover:bg-panel-bg lg:hidden"
              onClick={() => setAbierto(false)}
              aria-label="Cerrar menú"
            >
              <X size={18} />
            </button>
          </div>

          <p className="mx-5 flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 shadow-[0_0_0_3px_rgba(16,185,129,0.18)]" />
            Panel {titulo}
          </p>

          <nav aria-label="Secciones del panel" className="sin-barra-scroll mt-2 flex-1 overflow-y-auto overscroll-contain px-3 pb-3">
            {agrupar(menu).map((grupo) => (
              <div key={grupo.nombre} className="mt-5 first:mt-3">
                {grupo.nombre && (
                  <p className="mb-1.5 px-3 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">{grupo.nombre}</p>
                )}
                <div className="space-y-0.5">
                  {grupo.items.map(({ ruta, etiqueta, icono: Icono, fin }) => (
                    <NavLink
                      key={ruta}
                      to={ruta}
                      end={fin}
                      onClick={() => setAbierto(false)}
                      className={({ isActive }) =>
                        `group relative flex items-center gap-3 rounded-full px-3.5 py-2.5 text-sm outline-none transition-colors focus-visible:ring-2 focus-visible:ring-panel-primary/30 ${
                          isActive ? 'font-semibold text-white dark:text-navy-950' : 'text-panel-text-soft hover:bg-panel-bg hover:text-panel-text'
                        }`
                      }
                    >
                      {({ isActive }) => (
                        <>
                          {isActive && (
                            <motion.span
                              layoutId="menu-activo"
                              transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                              className="absolute inset-0 rounded-full bg-navy-950 shadow-[0_8px_20px_-10px_rgba(11,27,54,0.7)] dark:bg-white"
                            />
                          )}
                          <Icono size={17} strokeWidth={1.9} className="relative shrink-0" />
                          <span className="relative truncate">{etiqueta}</span>
                        </>
                      )}
                    </NavLink>
                  ))}
                </div>
              </div>
            ))}
          </nav>

          {/* Organización del usuario */}
          <div className="m-3 flex items-center gap-3 rounded-2xl border border-panel-border bg-panel-bg/70 p-3">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-brand text-white shadow-[0_8px_18px_-8px_rgba(232,52,63,0.8)]">
              <ShieldCheck size={17} />
            </span>
            <div className="min-w-0">
              <p className="truncate text-sm font-semibold">{nombreOrg || 'RESCATE360'}</p>
              <p className="truncate font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Organización</p>
            </div>
          </div>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        {/* Barra superior */}
        <header className="sticky top-0 z-30 flex items-center gap-3 bg-panel-bg/70 px-4 py-3 backdrop-blur-xl sm:px-6 lg:pl-3">
          <button
            className="flex h-10 w-10 items-center justify-center rounded-full border border-panel-border bg-panel-card text-panel-text-soft lg:hidden"
            onClick={() => setAbierto(true)}
            aria-label="Abrir menú"
          >
            <Menu size={18} />
          </button>

          <p className="hidden font-mono text-[11px] uppercase tracking-[0.16em] text-panel-text-muted md:block">
            Panel <span className="mx-1 text-panel-border">/</span>
            <span className="text-panel-text">{actual?.etiqueta ?? 'Inicio'}</span>
          </p>

          {/* Buscador global: solo interfaz por ahora. */}
          {/* BACKEND: conectar la búsqueda global cuando exista el endpoint. */}
          <div className="relative ml-auto hidden w-full max-w-xs sm:block">
            <Search size={15} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-panel-text-muted" />
            <input
              placeholder="Buscar…"
              className="h-10 w-full rounded-full border border-panel-border bg-panel-card pl-9 pr-3 text-sm outline-none transition placeholder:text-panel-text-muted focus:border-panel-primary focus:ring-4 focus:ring-panel-primary/10"
            />
          </div>

          <div className="ml-auto flex items-center gap-2 sm:ml-0">
            <button
              onClick={alternar}
              aria-label={tema === 'claro' ? 'Activar modo oscuro' : 'Activar modo claro'}
              className="flex h-10 w-10 items-center justify-center rounded-full border border-panel-border bg-panel-card text-panel-text-soft transition hover:text-panel-text"
            >
              {tema === 'claro' ? <Moon size={16} /> : <Sun size={16} />}
            </button>
            <button
              className="relative flex h-10 w-10 items-center justify-center rounded-full border border-panel-border bg-panel-card text-panel-text-soft transition hover:text-panel-text"
              aria-label="Notificaciones"
            >
              <Bell size={16} />
              <span className="absolute right-2.5 top-2.5 h-2 w-2 rounded-full bg-brand ring-2 ring-panel-card" />
            </button>

            {menuUsuario && <div className="fixed inset-0 z-10" onClick={() => setMenuUsuario(false)} />}
            <div className="relative z-20">
              <button
                onClick={() => setMenuUsuario(!menuUsuario)}
                className="flex h-10 items-center gap-2.5 rounded-full border border-panel-border bg-panel-card py-1 pl-1 pr-3 transition hover:border-panel-text-muted/40"
              >
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-navy-950 text-xs font-bold text-white dark:bg-white dark:text-navy-950">
                  {iniciales}
                </span>
                <span className="hidden text-left text-sm leading-tight md:block">
                  <span className="block font-semibold">{usuario?.nombre}</span>
                </span>
                <ChevronDown size={15} className="text-panel-text-muted" />
              </button>

              {menuUsuario && (
                <div className="panel-modal-enter absolute right-0 mt-2 w-52 overflow-hidden rounded-2xl border border-panel-border bg-panel-card py-1 shadow-xl">
                  <p className="border-b border-panel-border px-4 py-2.5 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
                    {usuario?.rol.replace('_', ' ')}
                  </p>
                  <button onClick={salir} className="flex w-full items-center gap-2 px-4 py-2.5 text-sm text-panel-text-soft hover:bg-panel-bg hover:text-panel-text">
                    <LogOut size={15} /> Cerrar sesión
                  </button>
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="min-w-0 flex-1 px-4 pb-10 pt-2 sm:px-6 lg:pl-3">
          {/* La key reinicia la animación de entrada en cada cambio de sección. */}
          <div key={location.pathname} className="panel-page-enter">
            <Outlet context={{ tema } satisfies ContextoPanel} />
          </div>
        </main>
      </div>
    </div>
  )
}
