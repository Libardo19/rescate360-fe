import { Phone } from 'lucide-react'
import appHome from '../../../assets/app-home.png'
import appAlertas from '../../../assets/app-alertas.png'
import { Aparecer, Etiqueta } from './comunes'

// Insignia de tienda (deshabilitada hasta que la app esté publicada).
function Tienda({ nombre }: { nombre: string }) {
  return (
    <span className="inline-flex flex-col rounded-2xl border border-white/15 bg-white/5 px-5 py-2.5 leading-tight">
      <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-white/45">Próximamente en</span>
      <span className="text-sm font-semibold text-white">{nombre}</span>
    </span>
  )
}

export default function Descarga() {
  return (
    <section id="descarga" className="scroll-mt-24 px-5 py-16 sm:px-6 sm:py-24">
      <Aparecer className="mx-auto max-w-6xl">
        <div className="relative isolate overflow-hidden rounded-[36px] bg-navy-950 px-6 py-14 text-white sm:px-12 sm:py-16 dark:border dark:border-white/10">
          {/* Grilla de puntos y brillos */}
          <div
            aria-hidden="true"
            className="absolute inset-0 -z-10 opacity-[0.18] [background-image:radial-gradient(rgba(255,255,255,0.6)_1px,transparent_1px)] [background-size:18px_18px] [mask-image:radial-gradient(ellipse_at_70%_50%,black,transparent_70%)]"
          />
          <div aria-hidden="true" className="absolute -right-24 -top-24 -z-10 h-80 w-80 rounded-full bg-brand/30 blur-3xl" />
          <div aria-hidden="true" className="absolute -bottom-32 left-1/3 -z-10 h-80 w-80 rounded-full bg-panel-info/25 blur-3xl" />

          <div className="grid items-center gap-12 lg:grid-cols-[1.1fr_0.9fr]">
            <div>
              <Etiqueta>Descarga</Etiqueta>
              <h2 className="mt-4 font-display text-4xl font-semibold leading-[1.02] tracking-[-0.035em] sm:text-6xl">
                Lleva la ayuda
                <br />
                <span className="text-white/45">en tu bolsillo.</span>
              </h2>
              <p className="mt-5 max-w-md text-white/60">
                La app para ciudadanos y voluntarios estará disponible para Android y iOS.
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <Tienda nombre="Google Play" />
                <Tienda nombre="App Store" />
              </div>
              <a
                href="tel:123"
                className="mt-8 inline-flex items-center gap-2 rounded-full border border-white/15 px-4 py-2 text-sm text-white/80 transition hover:border-brand hover:text-white"
              >
                <Phone size={14} className="text-brand" />
                En riesgo vital, llama al <b className="text-white">123</b>
              </a>
            </div>

            <div className="relative mx-auto flex h-[340px] w-full max-w-sm items-center justify-center sm:h-[420px]" aria-hidden="true">
              <img
                src={appAlertas}
                alt=""
                loading="lazy"
                className="absolute left-2 top-8 w-40 rotate-[-8deg] opacity-80 drop-shadow-2xl sm:w-48"
              />
              <img
                src={appHome}
                alt=""
                loading="lazy"
                className="relative w-44 translate-x-10 rotate-[4deg] drop-shadow-2xl sm:w-52"
              />
            </div>
          </div>
        </div>
      </Aparecer>
    </section>
  )
}
