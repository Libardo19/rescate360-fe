import { ArrowRight, CheckCircle2 } from 'lucide-react'
import appAlerts from '../../../assets/app-alertas.png'
import appMap from '../../../assets/app-mapa.png'
import appReport from '../../../assets/app-reportar.png'

const benefits = [
  'Reportes en tiempo real',
  'Ubicación precisa',
  'Comunicación directa',
  'Información confiable',
]

const screens = [
  { src: appReport, alt: 'Pantalla para reportar un incidente', className: 'showcase-phone showcase-phone-report' },
  { src: appMap, alt: 'Mapa de emergencias y centros de ayuda', className: 'showcase-phone showcase-phone-map' },
  { src: appAlerts, alt: 'Pantalla de alertas de emergencia', className: 'showcase-phone showcase-phone-alerts' },
]

export default function AppShowcase() {
  return (
    <section className="overflow-hidden bg-[#f0f6fc] text-navy-900">
      <div className="mx-auto grid max-w-6xl items-center gap-8 px-6 py-14 md:grid-cols-[0.8fr_1.2fr] md:py-16">
        <div className="landing-reveal">
          <span className="mb-3 block h-1 w-9 rounded bg-brand" />
          <h2 className="max-w-md text-3xl font-extrabold leading-tight sm:text-4xl">
            Una app,<br />muchas soluciones
          </h2>
          <p className="mt-4 max-w-md text-sm leading-relaxed text-navy-900/75">
            RESCATE360 está diseñada para que cualquier persona pueda actuar, recibir ayuda y mantenerse informada, en cualquier momento y lugar.
          </p>
          <ul className="mt-5 space-y-2.5">
            {benefits.map((benefit) => (
              <li key={benefit} className="flex items-center gap-2.5 text-xs text-navy-900/80">
                <CheckCircle2 size={16} className="shrink-0 fill-navy-900 text-white" />
                {benefit}
              </li>
            ))}
          </ul>
          <a
            href="#funciones"
            className="mt-6 inline-flex items-center gap-3 rounded-full border border-navy-900 px-5 py-2.5 text-xs font-semibold transition hover:bg-navy-900 hover:text-white"
          >
            Conocer todas las funciones <ArrowRight size={15} />
          </a>
        </div>

        <div className="showcase-phones" aria-label="Vistas de las funciones de la aplicación">
          {screens.map((screen) => (
            <div className={screen.className} key={screen.src}>
              <img src={screen.src} alt={screen.alt} loading="lazy" />
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
