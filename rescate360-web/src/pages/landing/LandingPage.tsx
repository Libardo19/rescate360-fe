import { Link } from 'react-router-dom'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background text-ink">
      <header className="flex items-center justify-between border-b border-surface-border px-6 py-4">
        <span className="text-2xl font-extrabold tracking-wide">
          RESCATE<span className="text-primary">360</span>
        </span>
        <Link
          to="/login"
          className="rounded-lg border border-surface-border px-4 py-2 text-sm text-ink-soft transition hover:bg-surface hover:text-ink"
        >
          Iniciar sesión
        </Link>
      </header>

      <main className="flex flex-col items-center justify-center px-6 py-32 text-center">
        <h1 className="text-5xl font-extrabold">Juntos en la respuesta</h1>
        <p className="mt-4 max-w-xl text-ink-soft">
          Plataforma de apoyo y coordinación comunitaria ante emergencias.
        </p>
        <button className="mt-8 rounded-lg bg-primary px-6 py-3 font-semibold transition hover:bg-primary-dark">
          Descargar app
        </button>
        <p className="mt-6 text-xs text-ink-muted">
          RESCATE360 no sustituye a los organismos oficiales. En caso de riesgo vital: línea 123.
        </p>
      </main>
    </div>
  )
}