import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Download, Menu, X } from 'lucide-react'
import Logo from './Logo'

const links = [
  { href: '#inicio', label: 'Inicio' },
  { href: '#como-funciona', label: '¿Cómo funciona?' },
  { href: '#funciones', label: 'Funciones' },
  { href: '#para-quien', label: 'Para quién es' },
  { href: '#contacto', label: 'Contacto' },
]

export default function Navbar() {
  const [menuAbierto, setMenuAbierto] = useState(false)

  return (
    <header className="fixed inset-x-0 top-0 z-50 bg-navy-950/60 text-white backdrop-blur">
      <div className="relative mx-auto flex max-w-6xl items-center justify-between px-4 py-3 sm:px-6 sm:py-4">
        <a href="#inicio">
          <Logo />
        </a>

        <nav className="hidden items-center gap-8 text-sm md:flex">
          {links.map((l) => (
            <a key={l.href} href={l.href} className="text-white/80 transition hover:text-white">
              {l.label}
            </a>
          ))}
        </nav>

        <div className="hidden items-center gap-4 md:flex">
          <Link to="/login" className="hidden text-sm text-white/80 transition hover:text-white sm:block">
            Iniciar sesión
          </Link>
          <a
            href="#descarga"
            className="flex items-center gap-2 rounded-lg bg-white px-4 py-2 text-sm font-semibold text-navy-900 transition hover:bg-slate-200"
          >
            <Download size={16} />
            <span className="hidden sm:inline">Descargar app</span>
          </a>
        </div>

        <button
          type="button"
          className="flex h-11 w-11 items-center justify-center rounded-lg text-white transition hover:bg-white/10 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white md:hidden"
          aria-label={menuAbierto ? 'Cerrar menú' : 'Abrir menú'}
          aria-expanded={menuAbierto}
          aria-controls="mobile-navigation"
          onClick={() => setMenuAbierto((abierto) => !abierto)}
        >
          {menuAbierto ? <X size={24} /> : <Menu size={24} />}
        </button>

        {menuAbierto && (
          <nav
            id="mobile-navigation"
            aria-label="Navegación móvil"
            className="absolute inset-x-0 top-full grid gap-1 rounded-b-xl border-t border-white/10 bg-navy-950/95 p-3 shadow-xl backdrop-blur md:hidden"
          >
            {links.map((l) => (
              <a
                key={l.href}
                href={l.href}
                onClick={() => setMenuAbierto(false)}
                className="rounded-lg px-3 py-3 text-sm text-white/90 transition hover:bg-white/10 hover:text-white"
              >
                {l.label}
              </a>
            ))}
            <Link
              to="/login"
              onClick={() => setMenuAbierto(false)}
              className="rounded-lg px-3 py-3 text-sm text-white/90 transition hover:bg-white/10 hover:text-white"
            >
              Iniciar sesión
            </Link>
            <a
              href="#descarga"
              onClick={() => setMenuAbierto(false)}
              className="mt-1 flex items-center justify-center gap-2 rounded-lg bg-white px-4 py-3 text-sm font-semibold text-navy-900 transition hover:bg-slate-200"
            >
              <Download size={16} /> Descargar app
            </a>
          </nav>
        )}
      </div>
    </header>
  )
}