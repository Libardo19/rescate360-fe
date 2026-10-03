export default function Descarga() {
  return (
    <section id="descarga" className="scroll-mt-20 border-t border-surface-border">
      <div className="mx-auto max-w-3xl px-6 py-24 text-center">
        <h2 className="text-3xl font-extrabold sm:text-4xl">Lleva RESCATE360 contigo</h2>
        <p className="mx-auto mt-3 max-w-xl text-ink-soft">
          Descarga la app para reportar, pedir ayuda y recibir alertas desde tu celular.
        </p>

        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <button disabled className="w-56 cursor-not-allowed rounded-lg border border-surface-border bg-surface px-6 py-3 text-ink-soft">
            Google Play
            <span className="block text-xs text-ink-muted">Próximamente</span>
          </button>
          <button disabled className="w-56 cursor-not-allowed rounded-lg border border-surface-border bg-surface px-6 py-3 text-ink-soft">
            App Store
            <span className="block text-xs text-ink-muted">Próximamente</span>
          </button>
        </div>
      </div>
    </section>
  )
}