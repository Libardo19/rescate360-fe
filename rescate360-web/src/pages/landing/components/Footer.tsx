import Logo from './Logo'

const links = [
  { href: '#inicio', label: 'Inicio' },
  { href: '#como-funciona', label: '¿Cómo funciona?' },
  { href: '#funciones', label: 'Funciones' },
  { href: '#para-quien', label: 'Para quién es' },
]

export default function Footer() {
  return (
    <footer id="contacto" className="scroll-mt-20 bg-navy-950 text-white">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 px-6 py-6 md:flex-row md:items-center md:justify-between">
        <div className="flex flex-col items-center md:items-start">
          <a href="#inicio" aria-label="RESCATE360, inicio"><Logo className="h-8" /></a>
          <span className="mt-1 text-xs text-white/80">Juntos en la respuesta</span>
        </div>

        <nav className="flex flex-wrap justify-center gap-x-5 gap-y-2 text-xs text-white/85" aria-label="Enlaces del pie de página">
          {links.map((link) => <a className="transition hover:text-white" href={link.href} key={link.href}>{link.label}</a>)}
        </nav>

        <div className="text-center text-xs leading-relaxed text-white/80 md:text-right">
          <p>© 2026 RESCATE360 · Proyecto académico</p>
          <p>En riesgo vital, llama al <a href="tel:123" className="font-bold text-white">123</a></p>
        </div>
      </div>
    </footer>
  )
}
