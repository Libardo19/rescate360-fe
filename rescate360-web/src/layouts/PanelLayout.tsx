import { useState } from 'react'
import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { Bell, ChevronDown, KeyRound, LogOut, Menu, Search, X } from 'lucide-react'
import Logo from '../pages/landing/components/Logo'
import { useAuth } from '../context/AuthContext'
import type { ItemMenu } from '../routes/menus'
import CambiarClave from '../components/CambiarClave'

interface Props {
  menu: ItemMenu[]
  titulo: string
}

export default function PanelLayout({ menu, titulo }: Props) {
  const [abierto, setAbierto] = useState(false)
  const [menuUsuario, setMenuUsuario] = useState(false)
  const [cambiandoClave, setCambiandoClave] = useState(false)
  const { usuario, cerrarSesion } = useAuth()
  const navigate = useNavigate()

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
    <div className="flex min-h-screen bg-panel-bg text-panel-text">
      {abierto && (
        <div className="fixed inset-0 z-30 bg-black/40 lg:hidden" onClick={() => setAbierto(false)} />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-40 flex w-64 flex-col bg-navy-900 text-white transition-transform lg:sticky lg:top-0 lg:bottom-auto lg:h-dvh lg:self-start lg:translate-x-0 ${
          abierto ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex items-center justify-between px-5 py-5">
          <Logo />
          <button className="lg:hidden" onClick={() => setAbierto(false)} aria-label="Cerrar menú">
            <X size={20} />
          </button>
        </div>
        <p className="px-5 text-xs uppercase tracking-widest text-white/50">{titulo}</p>

        <nav className="mt-3 flex-1 space-y-1 overflow-y-auto px-3 pb-4">
          {menu.map(({ ruta, etiqueta, icono: Icono, fin }) => (
            <NavLink
              key={ruta}
              to={ruta}
              end={fin}
              onClick={() => setAbierto(false)}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition ${
                  isActive
                    ? 'bg-blue-700 font-semibold text-white'
                    : 'text-white/70 hover:bg-white/10 hover:text-white'
                }`
              }
            >
              <Icono size={18} /> {etiqueta}
            </NavLink>
          ))}
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-20 flex items-center gap-4 border-b border-panel-border bg-panel-card px-4 py-3 sm:px-6">
          <button className="lg:hidden" onClick={() => setAbierto(true)} aria-label="Abrir menú">
            <Menu size={22} />
          </button>

          {/* Buscador global: solo interfaz por ahora. */}
          {/* BACKEND: conectar la búsqueda global cuando exista el endpoint. */}
          <div className="relative hidden max-w-md flex-1 sm:block">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
            <input
              placeholder="Buscar..."
              className="w-full rounded-lg border border-panel-border bg-panel-bg py-2 pl-9 pr-3 text-sm outline-none focus:border-panel-primary"
            />
          </div>

          <div className="ml-auto flex items-center gap-4">
            <button className="relative text-panel-text-soft hover:text-panel-text" aria-label="Notificaciones">
              <Bell size={20} />
              <span className="absolute -right-0.5 -top-0.5 h-2 w-2 rounded-full bg-panel-accent" />
            </button>

            {menuUsuario && <div className="fixed inset-0 z-10" onClick={() => setMenuUsuario(false)} />}
            <div className="relative z-20">
              <button onClick={() => setMenuUsuario(!menuUsuario)} className="flex items-center gap-3">
                <span className="flex h-9 w-9 items-center justify-center rounded-full bg-panel-primary text-sm font-bold text-white">
                  {iniciales}
                </span>
                <span className="hidden text-left text-sm leading-tight sm:block">
                  <span className="block font-semibold">{usuario?.nombre}</span>
                  <span className="block text-xs capitalize text-panel-text-muted">
                    {usuario?.rol.replace('_', ' ')}
                  </span>
                </span>
                <ChevronDown size={16} className="text-panel-text-muted" />
              </button>

              {menuUsuario && (
                <div className="absolute right-0 mt-2 w-52 rounded-lg border border-panel-border bg-panel-card py-1 shadow-lg">
                  <button
                    onClick={() => {
                      setMenuUsuario(false)
                      setCambiandoClave(true)
                    }}
                    className="flex w-full items-center gap-2 px-4 py-2 text-sm text-panel-text-soft hover:bg-panel-bg"
                  >
                    <KeyRound size={16} /> Cambiar contraseña
                  </button>
                  <button
                    onClick={salir}
                    className="flex w-full items-center gap-2 px-4 py-2 text-sm text-panel-text-soft hover:bg-panel-bg"
                  >
                    <LogOut size={16} /> Cerrar sesión
                  </button>
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="min-w-0 flex-1 p-4 sm:p-6">
          <Outlet />
        </main>
      </div>
      {cambiandoClave && <CambiarClave onCerrar={() => setCambiandoClave(false)} />}
    </div>
  )
}