import { Download, CirclePlay, ShieldPlus } from 'lucide-react'
import heroBg from '../../../assets/hero-bg.jpg'
import appHome from '../../../assets/app-home.png'

export default function Hero() {
  return (
    <section id="inicio" className="relative scroll-mt-20 overflow-hidden text-white">
      <img src={heroBg} alt="" className="absolute inset-0 h-full w-full object-cover" />
      <div className="absolute inset-0 bg-linear-to-r from-navy-950 via-navy-950/85 to-navy-950/30" />

      <div className="relative mx-auto grid max-w-6xl items-center gap-12 px-6 pb-24 pt-36 lg:grid-cols-2">
        <div>
          <p className="text-xs font-medium uppercase tracking-widest text-white/70">
            Plataforma de emergencias y coordinación comunitaria
          </p>
          <h1 className="mt-5 text-5xl font-extrabold leading-tight sm:text-7xl">
            Juntos somos <span className="block text-brand">más fuertes</span>
          </h1>
          <p className="mt-6 text-xl font-medium">Coordinación comunitaria ante emergencias.</p>
          <p className="mt-4 max-w-lg text-white/80">
            Reporta, solicita ayuda y mantente informado. RESCATE360 conecta a la comunidad con los
            organismos de respuesta para un apoyo más rápido y efectivo.
          </p>

          <div className="mt-8 flex flex-col gap-4 sm:flex-row">
            <a
              href="#descarga"
              className="flex items-center justify-center gap-2 rounded-lg bg-brand px-6 py-3 font-semibold transition hover:bg-brand-dark"
            >
              <Download size={18} /> Descargar app
            </a>
            <a
              href="#como-funciona"
              className="flex items-center justify-center gap-2 rounded-lg border border-white/40 px-6 py-3 font-semibold transition hover:bg-white/10"
            >
              <CirclePlay size={18} /> Conocer cómo funciona
            </a>
          </div>

          <div className="mt-6 flex gap-3 text-xs">
            <span className="rounded-md border border-white/30 px-3 py-2">Google Play · Próximamente</span>
            <span className="rounded-md border border-white/30 px-3 py-2">App Store · Próximamente</span>
          </div>
        </div>

        <div className="relative flex items-center justify-center lg:justify-end">
          <div className="absolute h-80 w-80 rounded-full border-4 border-white/15 sm:h-[26rem] sm:w-[26rem]" />
          <div className="relative w-56 rotate-6 overflow-hidden rounded-[2rem] border-[6px] border-slate-900 shadow-2xl sm:w-64">
            <img src={appHome} alt="Pantalla de inicio de la app RESCATE360" className="block w-full" />
          </div>
          <div className="absolute -right-2 top-4 hidden w-40 text-right xl:block">
            <ShieldPlus size={40} className="ml-auto" />
            <p className="mt-2 text-lg font-bold leading-snug">Tu comunidad más segura, siempre.</p>
          </div>
        </div>
      </div>
    </section>
  )
}