import { Building2, Download, HeartHandshake, ShieldCheck, Users } from 'lucide-react'
import { Link } from 'react-router-dom'
import heroBg from '../../../assets/hero-bg.png'

const roles = [
  { icono: Users, titulo: 'Ciudadanos', texto: 'Reportan, solicitan y reciben información.' },
  { icono: HeartHandshake, titulo: 'Voluntarios', texto: 'Apoyan y dan seguimiento a las solicitudes.' },
  { icono: Building2, titulo: 'Organizaciones', texto: 'Gestionan su operación y recursos.' },
  { icono: ShieldCheck, titulo: 'Administradores', texto: 'Coordinan y supervisan la información.', acceso: true },
]

export default function Roles() {
  return (
    <section id="para-quien" className="relative scroll-mt-20 overflow-hidden bg-[#f0f6fc] text-navy-900">
      <div className="absolute inset-x-0 top-0 h-64 md:inset-y-0 md:right-auto md:h-auto md:w-[42%]">
        <img src={heroBg} alt="" loading="lazy" className="h-full w-full object-cover object-left brightness-110" />
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-[#f0f6fc]/10 to-[#f0f6fc]" />
      </div>
      <div className="relative mx-auto grid max-w-6xl items-center gap-6 px-6 pb-8 pt-64 md:min-h-[360px] md:grid-cols-[0.85fr_1.15fr] md:gap-5 md:py-10 lg:min-h-[300px] lg:grid-cols-[0.85fr_1.05fr_1.1fr] lg:gap-6">
        <div aria-hidden="true" className="hidden md:block" />
        <div className="max-w-sm text-navy-900 md:col-start-2 lg:col-auto">
          <span className="mb-3 block h-1 w-9 rounded bg-brand" />
          <h2 className="text-2xl font-extrabold leading-tight sm:text-3xl">
            Más que una app,<br />una comunidad unida.
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-navy-900/75">
            RESCATE360 es tecnología al servicio de las personas. Cuando nos informamos, nos apoyamos y actuamos juntos, estamos más seguros.
          </p>
          <div id="descarga" className="mt-4 flex flex-wrap gap-2">
            <span className="inline-flex items-center gap-2 rounded-full bg-navy-900 px-4 py-2 text-xs font-semibold text-white">
              <Download size={14} /> App móvil
            </span>
            <span className="inline-flex items-center rounded-full border border-navy-900/25 px-3 py-2 text-xs text-navy-900">
              Próximamente
            </span>
          </div>
        </div>

        <div className="grid gap-1 rounded-xl bg-white/90 p-4 shadow-xl shadow-navy-900/5 sm:grid-cols-2 md:col-start-2 md:grid-cols-1 lg:col-auto">
          {roles.map(({ icono: Icono, titulo, texto, acceso }) => (
            <div className="flex items-center gap-3 rounded-lg p-2.5 transition hover:bg-slate-50" key={titulo}>
              <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-navy-900 text-white">
                <Icono size={17} />
              </span>
              <span className="min-w-0 flex-1">
                <b className="block text-xs text-navy-900">{titulo}</b>
                <span className="mt-0.5 block text-xs leading-relaxed text-slate-600">{texto}</span>
              </span>
              {acceso && (
                <Link to="/login" className="min-h-11 shrink-0 self-center text-xs font-semibold text-brand-dark underline-offset-4 hover:underline focus-visible:outline-2 focus-visible:outline-brand-dark">
                  Ingresar
                </Link>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
