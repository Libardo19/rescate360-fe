export default function Hero() {
  return (
    <section id="inicio" className="relative scroll-mt-20 overflow-hidden">
      <div className="pointer-events-none absolute left-1/2 top-0 h-96 w-96 -translate-x-1/2 rounded-full bg-primary/20 blur-3xl" />

      <div className="relative mx-auto flex max-w-4xl flex-col items-center px-6 py-28 text-center">
        <span className="rounded-full border border-surface-border bg-surface px-4 py-1 text-xs text-ink-soft">
          Tu comunidad, nuestra prioridad
        </span>

        <h1 className="mt-6 text-4xl font-extrabold leading-tight sm:text-6xl">
          Reporta. Ayuda. Infórmate.{' '}
          <span className="text-primary">Actúa.</span>
        </h1>

        <p className="mt-6 max-w-2xl text-lg text-ink-soft">
          RESCATE360 conecta a ciudadanos, voluntarios y organizaciones para
          responder juntos ante emergencias. Una comunidad más segura, siempre.
        </p>

        <div className="mt-10 flex flex-col gap-4 sm:flex-row">
          <a
            href="#descarga"
            className="rounded-lg bg-primary px-8 py-3 font-semibold transition hover:bg-primary-dark"
          >
            Descargar app
          </a>
          <a
            href="#como-funciona"
            className="rounded-lg border border-surface-border px-8 py-3 font-semibold text-ink-soft transition hover:bg-surface hover:text-ink"
          >
            Ver cómo funciona
          </a>
        </div>

        <p className="mt-8 text-xs text-ink-muted">
          RESCATE360 no sustituye a los organismos oficiales. En caso de riesgo vital: línea 123.
        </p>
      </div>
    </section>
  )
}