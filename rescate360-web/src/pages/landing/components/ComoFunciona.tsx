import { ArrowRight, ClipboardList, MapPin, Users } from 'lucide-react'
import bomberos from '../../../assets/bomberos.png'

const pasos = [
  { numero: '01', titulo: 'Reporta', texto: 'Comparte lo que ves y la ubicación.', icono: ClipboardList },
  { numero: '02', titulo: 'Ubicación', texto: 'El sistema identifica la zona y otros detalles.', icono: MapPin },
  { numero: '03', titulo: 'Ayuda', texto: 'Los organismos y la comunidad actúan de inmediato.', icono: Users },
]

export default function ComoFunciona() {
  return (
    <section id="como-funciona" className="relative scroll-mt-20 overflow-hidden text-white">
      <img
        src={bomberos}
        alt=""
        loading="lazy"
        className="absolute inset-0 h-full w-full object-cover object-[center_58%]"
      />
      <div className="absolute inset-0 bg-navy-950/85" />
      <div className="relative mx-auto grid max-w-6xl items-center gap-8 px-6 py-10 md:grid-cols-[0.72fr_1.5fr] md:py-12">
        <div>
          <span className="mb-3 block h-1 w-9 rounded bg-brand" />
          <h2 className="text-2xl font-extrabold sm:text-3xl">¿Cómo funciona?</h2>
          <p className="mt-2 max-w-xs text-xs leading-relaxed text-white/75">
            Es muy fácil. En pocos pasos puedes hacer la diferencia.
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-3 sm:gap-3">
          {pasos.map(({ numero, titulo, texto, icono: Icono }, index) => (
            <div className="landing-reveal relative flex gap-3 sm:flex-col" key={numero} style={{ animationDelay: `${index * 120}ms` }}>
              <div className="flex shrink-0 flex-col items-center gap-2 sm:flex-row">
                <span className="flex h-11 w-11 items-center justify-center rounded-full bg-brand shadow-lg shadow-brand/20 transition duration-300 hover:scale-110">
                  <Icono size={19} />
                </span>
                <span className="text-xs font-bold text-white/70">{numero}</span>
                {index < pasos.length - 1 && <ArrowRight size={16} className="ml-3 hidden text-white/70 sm:block" />}
              </div>
              <div>
                <h3 className="text-sm font-bold">{titulo}</h3>
                <p className="mt-1 max-w-48 text-xs leading-relaxed text-white/80">{texto}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
