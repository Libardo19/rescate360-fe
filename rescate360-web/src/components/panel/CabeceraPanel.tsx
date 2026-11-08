import type { ReactNode } from 'react'
import type { LucideIcon } from 'lucide-react'
import CountUp from '../reactbits/CountUp/CountUp'

export type TonoEstadistica = 'alerta' | 'aviso' | 'bien' | 'neutro'

export interface Estadistica {
  titulo: string
  valor: number
  icono: LucideIcon
  pie?: string // texto pequeño debajo del número
  tono?: TonoEstadistica // solo cuando el color comunica algo (urgente, atención, al día)
}

const puntos: Record<TonoEstadistica, string> = {
  alerta: 'bg-brand shadow-[0_0_0_3px_rgba(232,52,63,0.18)]',
  aviso: 'bg-amber-500 shadow-[0_0_0_3px_rgba(245,158,11,0.18)]',
  bien: 'bg-emerald-500 shadow-[0_0_0_3px_rgba(16,185,129,0.18)]',
  neutro: 'bg-panel-text-muted/50',
}

// Botones de la cabecera.
export const botonCabeceraPrincipal =
  'group inline-flex items-center justify-center gap-2 rounded-full bg-navy-950 px-5 py-3 text-sm font-semibold text-white shadow-[0_12px_28px_-12px_rgba(11,27,54,0.8)] transition hover:bg-navy-800 active:scale-[0.98] disabled:opacity-60 dark:bg-white dark:text-navy-950 dark:hover:bg-white/90'
export const botonCabeceraSecundario =
  'inline-flex items-center justify-center gap-2 rounded-full border border-panel-border bg-panel-card/70 px-5 py-3 text-sm font-semibold text-panel-text backdrop-blur transition hover:border-panel-text-muted/50 active:scale-[0.98]'

interface Props {
  seccion: string // texto pequeño sobre el título, ej. "Operación"
  titulo: string
  descripcion?: ReactNode
  acciones?: ReactNode
  estadisticas?: Estadistica[]
  children?: ReactNode
}

// Franja de cifras: un solo bloque con divisores finos (gap-px sobre el color del borde).
export function FranjaCifras({ estadisticas }: { estadisticas: Estadistica[] }) {
  const columnas = estadisticas.length >= 4 ? 'lg:grid-cols-4' : estadisticas.length === 3 ? 'sm:grid-cols-3' : 'sm:grid-cols-2'
  const impar = estadisticas.length % 2 === 1
  return (
    <div
      className={`panel-stats grid grid-cols-2 gap-px overflow-hidden rounded-[28px] border border-panel-border bg-panel-border ${columnas} ${
        impar ? '[&>*:last-child]:col-span-2 sm:[&>*:last-child]:col-span-1' : ''
      }`}
    >
      {estadisticas.map(({ titulo, valor, icono: Icono, pie, tono = 'neutro' }) => (
        <div key={titulo} className="group relative bg-panel-card p-5 transition-colors hover:bg-panel-bg sm:p-6">
          <div className="flex items-center justify-between gap-2">
            <p className="flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.14em] text-panel-text-muted">
              <span className={`h-1.5 w-1.5 rounded-full ${puntos[tono]}`} />
              {titulo}
            </p>
            <Icono size={15} strokeWidth={1.8} className="text-panel-text-muted transition group-hover:text-panel-text" />
          </div>
          <CountUp to={valor} duration={0.8} trigger="load" className="mt-4 block text-[44px] font-semibold leading-none tracking-[-0.05em]" />
          {pie && <p className="mt-2 text-xs text-panel-text-muted">{pie}</p>}
        </div>
      ))}
    </div>
  )
}

// Cabecera de cada sección: etiqueta mono, título editorial grande, acciones y franja de cifras.
export default function CabeceraPanel({ seccion, titulo, descripcion, acciones, estadisticas, children }: Props) {
  return (
    <section className="mb-8">
      <div className="flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between">
        <div className="min-w-0">
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-brand" />
            {seccion}
          </p>
          <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[56px] sm:tracking-[-0.05em]">{titulo}</h1>
          {descripcion && <p className="mt-3 max-w-xl text-[15px] leading-relaxed text-panel-text-soft">{descripcion}</p>}
        </div>
        {acciones && <div className="flex shrink-0 flex-wrap gap-2">{acciones}</div>}
      </div>

      {estadisticas && estadisticas.length > 0 && (
        <div className="mt-8">
          <FranjaCifras estadisticas={estadisticas} />
        </div>
      )}

      {children}
    </section>
  )
}
