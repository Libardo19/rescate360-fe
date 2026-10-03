export default function Footer() {
  return (
    <footer className="border-t border-surface-border bg-surface/40">
      <div className="mx-auto flex max-w-6xl flex-col gap-4 px-6 py-10 text-center md:flex-row md:items-center md:justify-between md:text-left">
        <div>
          <span className="text-xl font-extrabold tracking-wide">
            RESCATE<span className="text-primary">360</span>
          </span>
          <p className="mt-1 text-xs text-ink-muted">Universidad Popular del Cesar · Ingeniería de Software II</p>
        </div>
        <p className="max-w-md text-xs text-ink-muted">
          RESCATE360 es una herramienta de apoyo comunitario y no sustituye a los organismos oficiales
          de atención de emergencias. En caso de riesgo vital: línea 123.
        </p>
      </div>
    </footer>
  )
}