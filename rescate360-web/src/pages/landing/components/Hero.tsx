import { Download, CirclePlay, ShieldPlus } from 'lucide-react'
import heroBg from '../../../assets/hero-bg.png'
import appHome from '../../../assets/app-home-cutout.png'

export default function Hero() {
  return (
    <section id="inicio" className="relative scroll-mt-20 overflow-hidden text-white">
      <img src={heroBg} alt="" className="absolute inset-0 h-full w-full object-cover" />
      <div className="absolute inset-0 bg-linear-to-r from-navy-950 via-navy-950/85 to-navy-950/30" />

      <div className="relative mx-auto grid min-h-[520px] max-w-6xl items-center gap-5 px-6 pb-10 pt-28 md:min-h-[400px] md:grid-cols-[1.05fr_0.95fr] md:pb-6 md:pt-20">
        <div className="landing-reveal">
          <p className="text-xs font-medium uppercase tracking-widest text-white/70">
            Plataforma de emergencias y coordinación comunitaria
          </p>
          <h1 className="mt-3 text-4xl font-extrabold leading-[0.98] sm:text-5xl lg:text-7xl">
            Juntos somos <span className="block text-brand">más fuertes</span>
          </h1>
          <p className="mt-4 text-base font-medium sm:text-lg md:text-sm lg:text-lg">Coordinación comunitaria ante emergencias.</p>
          <p className="mt-3 max-w-lg text-sm leading-relaxed text-white/80 sm:text-base md:text-xs lg:text-base">
            Reporta, solicita ayuda y mantente informado. RESCATE360 conecta a la comunidad con los
            organismos de respuesta para un apoyo más rápido y efectivo.
          </p>

          <div className="mt-5 flex flex-col gap-3 sm:flex-row md:flex-wrap">
            <a
              href="#descarga"
              className="flex items-center justify-center gap-2 whitespace-nowrap rounded-lg bg-brand px-3 py-2.5 text-xs font-semibold transition hover:bg-brand-dark sm:px-4 lg:px-5 lg:text-sm"
            >
              <Download size={18} /> Descargar app
            </a>
            <a
              href="#como-funciona"
              className="flex items-center justify-center gap-2 whitespace-nowrap rounded-lg border border-white/40 px-3 py-2.5 text-xs font-semibold transition hover:bg-white/10 sm:px-4 lg:px-5 lg:text-sm"
            >
              <CirclePlay size={18} /> Conocer cómo funciona
            </a>
          </div>

          <div className="mt-3 flex flex-wrap gap-2 text-xs">
            <span className="rounded-md border border-white/30 px-3 py-2">Google Play · Próximamente</span>
            <span className="rounded-md border border-white/30 px-3 py-2">App Store · Próximamente</span>
          </div>
        </div>

        <div className="relative flex items-center justify-center md:justify-end">
          <div className="home-phone-3d relative w-40 sm:w-44 lg:w-60 xl:mr-36">
            <img src={appHome} alt="Pantalla de inicio de la app RESCATE360" className="home-phone-image block w-full" />
          </div>
          <div className="absolute -right-2 top-4 hidden w-36 text-right xl:block">
            <ShieldPlus size={40} className="ml-auto" />
            <p className="mt-2 text-lg font-bold leading-snug">Tu comunidad más segura, siempre.</p>
          </div>
        </div>
      </div>
    </section>
  )
}