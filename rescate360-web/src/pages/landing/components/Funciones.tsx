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
      <div className="mx-auto max-w-6xl px-6 py-20">
        <div className="mx-auto h-1 w-10 rounded bg-brand" />
        <h2 className="mt-4 text-center text-3xl font-extrabold text-navy-900">
          ¿Qué puedes hacer con RESCATE360?
        </h2>
        <p className="mt-2 text-center text-slate-500">Todo lo que necesitas en un solo lugar.</p>

        <div className="mt-14 grid grid-cols-2 gap-x-6 gap-y-10 md:grid-cols-3 lg:grid-cols-6">
          {funciones.map(({ icono: Icono, color, titulo, texto }) => (
            <div key={titulo} className="flex flex-col items-center text-center">
              <div className={`flex h-16 w-16 items-center justify-center rounded-full text-white ${color}`}>
                <Icono size={28} />
              </div>
              <h3 className="mt-4 font-bold text-navy-900">{titulo}</h3>
              <p className="mt-1 text-sm text-slate-500">{texto}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}