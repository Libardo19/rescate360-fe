const enlaces = [
  { href: '#que-es', label: 'Qué es' },
  { href: '#capacidades', label: 'Capacidades' },
  { href: '#como-funciona', label: 'Cómo funciona' },
  { href: '#para-quien', label: 'Para quién' },
]

export default function Footer() {
  return (
    <footer id="contacto" className="px-5 pb-10 pt-6 sm:px-6">
      <div className="mx-auto max-w-6xl border-t border-slate-200 pt-8 dark:border-white/10">
        <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <a href="#inicio" className="flex items-center gap-2" aria-label="RESCATE360, inicio">
              <img src="/logoRescate.png" alt="" className="h-7 w-7" />
              <span className="font-display text-xl font-bold tracking-[-0.04em] text-navy-950 dark:text-white">
                RESCATE<span className="text-brand">360</span>
              </span>
            </a>
            <p className="mt-2 max-w-xs text-sm text-slate-500 dark:text-white/50">Juntos en la respuesta.</p>
          </div>

          <nav aria-label="Enlaces del pie de página" className="flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-600 dark:text-white/60">
            {enlaces.map((e) => (
              <a key={e.href} href={e.href} className="transition hover:text-navy-950 dark:hover:text-white">
                {e.label}
              </a>
            ))}
          </nav>
        </div>

        <div className="mt-8 flex flex-col gap-2 font-mono text-[11px] uppercase tracking-[0.12em] text-slate-400 sm:flex-row sm:justify-between dark:text-white/35">
          <p>© 2026 RESCATE360 · Proyecto académico · Universidad Popular del Cesar</p>
          <p>
            Emergencias: <a href="tel:123" className="text-brand">123</a>
          </p>
        </div>
      </div>
    </footer>
  )
}
