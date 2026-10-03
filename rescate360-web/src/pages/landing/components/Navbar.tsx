import { Link } from 'react-router-dom'

export default function Navbar() {
  return (
    <header className="sticky top-0 z-50 border-b border-surface-border bg-background/90 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <a href="#inicio" className="text-2xl font-extrabold tracking-wide">
          RESCATE<span className="text-primary">360</span>
        </a>

        <nav className="hidden items-center gap-8 text-sm text-ink-soft md:flex">
          <a href="#como-funciona" className="transition hover:text-ink">Cómo funciona</a>
          <a href="#funciones" className="transition hover:text-ink">Funciones</a>
          <a href="#roles" className="transition hover:text-ink">Roles</a>
          <a href="#descarga" className="transition hover:text-ink">Descargar</a>
        </nav>

        <Link
          to="/login"
          className="rounded-lg border border-surface-border px-4 py-2 text-sm text-ink-soft transition hover:bg-surface hover:text-ink"
        >
          Iniciar sesión
        </Link>
      </div>
    </header>
  )
}