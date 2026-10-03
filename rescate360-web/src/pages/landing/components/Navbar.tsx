import { Link } from 'react-router-dom'
import { Download } from 'lucide-react'
import Logo from './Logo'

const links = [
  { href: '#inicio', label: 'Inicio' },
  { href: '#como-funciona', label: '¿Cómo funciona?' },
  { href: '#funciones', label: 'Funciones' },
  { href: '#para-quien', label: 'Para quién es' },
  { href: '#contacto', label: 'Contacto' },
]

export default function Navbar() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 bg-navy-950/60 text-white backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
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

        <div className="flex items-center gap-4">
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
      </div>
    </header>
  )
}