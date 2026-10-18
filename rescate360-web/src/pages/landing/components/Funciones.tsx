import { TriangleAlert, HandHelping, Map, Bell, BookOpen, ShieldCheck } from 'lucide-react'

const funciones = [
  { icono: TriangleAlert, color: 'bg-red-500', titulo: 'Reporta incidentes', texto: 'Informa emergencias de forma rápida y sencilla.' },
  { icono: HandHelping, color: 'bg-blue-500', titulo: 'Solicita ayuda', texto: 'Conecta con los organismos de respuesta y la comunidad.' },
  { icono: Map, color: 'bg-green-600', titulo: 'Encuentra lo cercano', texto: 'Ubica centros de ayuda, hospitales y más.' },
  { icono: Bell, color: 'bg-amber-500', titulo: 'Recibe alertas', texto: 'Mantente al día con la información oficial.' },
  { icono: BookOpen, color: 'bg-violet-500', titulo: 'Guías de emergencia', texto: 'Infórmate y prepárate ante cualquier situación.' },
  { icono: ShieldCheck, color: 'bg-teal-500', titulo: 'Funciona sin internet', texto: 'Reporta y consulta incluso sin conexión.' },
]

export default function Funciones() {
  return (
    <section id="funciones" className="scroll-mt-20 bg-white text-slate-900">
      <div className="mx-auto max-w-6xl px-6 py-12 sm:py-14">
        <div className="mx-auto h-1 w-10 rounded bg-brand" />
        <h2 className="mt-4 text-center text-3xl font-extrabold text-navy-900">
          ¿Qué puedes hacer con RESCATE360?
        </h2>
        <p className="mt-2 text-center text-sm text-slate-500">Todo lo que necesitas en un solo lugar.</p>

        <div className="mt-9 grid grid-cols-2 gap-y-8 md:grid-cols-6">
          {funciones.map(({ icono: Icono, color, titulo, texto }, index) => (
            <div
              key={titulo}
              className={`landing-reveal flex flex-col items-center px-3 text-center ${index % 6 !== 5 ? 'md:border-r md:border-slate-200' : ''}`}
              style={{ animationDelay: `${index * 90}ms` }}
            >
              <div className={`flex h-12 w-12 items-center justify-center rounded-full text-white shadow-sm transition duration-300 hover:scale-110 sm:h-14 sm:w-14 ${color}`}>
                <Icono size={23} />
              </div>
              <h3 className="mt-3 text-xs font-bold text-navy-900 sm:text-sm">{titulo}</h3>
              <p className="mt-1 text-xs leading-relaxed text-slate-600">{texto}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}