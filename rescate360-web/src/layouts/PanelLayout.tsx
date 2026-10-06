import { useState } from 'react'
import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { LogOut, Menu, X } from 'lucide-react'
import Logo from '../pages/landing/components/Logo'
import { useAuth } from '../context/AuthContext'
import type { ItemMenu } from '../routes/menus'

interface Props {
  menu: ItemMenu[]
  titulo: string
}

export default function PanelLayout({ menu, titulo }: Props) {
  const [abierto, setAbierto] = useState(false)
  const { usuario, cerrarSesion } = useAuth()
  const navigate = useNavigate()

  const salir = () => {
    cerrarSesion()
    navigate('/login')
  }

  return (
    <div className="flex min-h-screen bg-panel-bg text-panel-text">
      {abierto && (
        <div className="fixed inset-0 z-30 bg-black/40 lg:hidden" onClick={() => setAbierto(false)} />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-40 flex w-64 flex-col bg-panel-primary text-white transition-transform lg:static lg:translate-x-0 ${
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
                    ? 'bg-white/15 font-semibold text-white'
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
        <header className="flex items-center justify-between border-b border-panel-border bg-panel-card px-4 py-3 sm:px-6">
          <button className="lg:hidden" onClick={() => setAbierto(true)} aria-label="Abrir menú">
            <Menu size={22} />
          </button>
          <div className="ml-auto flex items-center gap-4">
            <div className="text-right text-sm leading-tight">
              <p className="font-semibold">{usuario?.nombre}</p>
              <p className="text-xs capitalize text-panel-text-muted">{usuario?.rol.replace('_', ' ')}</p>
            </div>
            <button
              onClick={salir}
              className="flex items-center gap-2 rounded-lg border border-panel-border px-3 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
            >
              <LogOut size={16} /> <span className="hidden sm:inline">Cerrar sesión</span>
            </button>
          </div>
        </header>

        <main className="flex-1 p-4 sm:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}