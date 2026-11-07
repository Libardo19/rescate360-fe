import type { LucideIcon } from 'lucide-react'
import CountUp from '../reactbits/CountUp/CountUp'

interface Props {
  titulo: string
  valor: number
  icono: LucideIcon
  color: string // clase de fondo del círculo, ej. 'bg-green-600'
  pie?: string
  pieColor?: string
}

// Tarjeta de resumen del panel. El número sube con CountUp (ReactBits);
// si el usuario prefiere menos movimiento, aparece directamente el valor final.
export default function TarjetaResumen({ titulo, valor, icono: Icono, color, pie, pieColor }: Props) {
  return (
    <div className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5">
      <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-white ${color}`}>
        <Icono size={22} />
      </div>
      <div className="min-w-0">
        <CountUp to={valor} duration={0.8} trigger="load" className="block text-2xl font-extrabold" />
        <p className="text-sm text-panel-text-soft">{titulo}</p>
        {pie && <p className={`text-xs font-medium ${pieColor ?? 'text-panel-text-muted'}`}>{pie}</p>}
      </div>
    </div>
  )
}
