import type { ReactNode } from 'react'
import type { LucideIcon } from 'lucide-react'
import CountUp from '../reactbits/CountUp/CountUp'

export type TonoEstadistica = 'alerta' | 'aviso' | 'bien' | 'neutro'

export interface Estadistica {
  titulo: string
  valor: number
  icono: LucideIcon
  pie?: string // texto pequeño debajo del título
  tono?: TonoEstadistica // solo cuando el color comunica algo (urgente, atención, al día)
}

const tonos: Record<TonoEstadistica, { punto: string; texto: string }> = {
  alerta: { punto: 'bg-brand shadow-[0_0_0_3px_rgba(232,52,63,0.18)]', texto: 'Urgente' },
  aviso: { punto: 'bg-amber-500 shadow-[0_0_0_3px_rgba(245,158,11,0.18)]', texto: 'Revisar' },
  bien: { punto: 'bg-emerald-500 shadow-[0_0_0_3px_rgba(16,185,129,0.18)]', texto: 'Al día' },
  neutro: { punto: '', texto: '' },
}

// Botones de la cabecera.
export const botonCabeceraPrincipal =
  'group inline-flex items-center justify-center gap-2 rounded-full bg-navy-950 px-4 py-2.5 text-sm font-semibold text-white shadow-[0_10px_24px_-12px_rgba(11,27,54,0.8)] transition hover:bg-navy-800 active:scale-[0.98] disabled:opacity-60 dark:bg-white dark:text-navy-950 dark:hover:bg-white/90'
export const botonCabeceraSecundario =
  'inline-flex items-center justify-center gap-2 rounded-full border border-panel-border bg-panel-card px-4 py-2.5 text-sm font-semibold text-panel-text transition hover:border-panel-text-muted/50 active:scale-[0.98]'


interface Props {
  seccion: string // texto pequeño sobre el título, ej. "Operación"
  titulo: string
  descripcion?: ReactNode
  acciones?: ReactNode
  estadisticas?: Estadistica[]
  children?: ReactNode
}

// Cabecera de cada sección del panel: etiqueta mono, título grande, acciones y cifras en tarjetas limpias.
export default function CabeceraPanel({ seccion, titulo, descripcion, acciones, estadisticas, children }: Props) {
  const columnas =
    estadisticas && estadisticas.length >= 4
      ? 'xl:grid-cols-4'
      : estadisticas?.length === 3
        ? // En móvil la tercera cifra ocupa toda la fila para no quedar sola a media anchura.
          'sm:grid-cols-3 [&>*:last-child]:col-span-2 sm:[&>*:last-child]:col-span-1'
        : 'sm:grid-cols-2'

  return (
    <section className="mb-6">
      <div className="flex flex-col gap-4 pt-4 sm:flex-row sm:items-end sm:justify-between">
        <div className="min-w-0">
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-brand" />
            {seccion}
          </p>
          <h1 className="mt-3 text-[34px] font-semibold leading-[1.02] tracking-[-0.04em] sm:text-[42px]">{titulo}</h1>
          {descripcion && <p className="mt-2 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">{descripcion}</p>}
        </div>
        {acciones && <div className="flex shrink-0 flex-wrap gap-2">{acciones}</div>}
      </div>

      {estadisticas && estadisticas.length > 0 && (
        <div className={`panel-stats mt-6 grid grid-cols-2 gap-3 sm:gap-4 ${columnas}`}>
          {estadisticas.map(({ titulo: t, valor, icono: Icono, pie, tono = 'neutro' }) => (
            <div
              key={t}
              className="group rounded-3xl border border-panel-border bg-panel-card p-5 transition duration-300 hover:-translate-y-0.5 hover:shadow-[0_18px_40px_-26px_rgba(11,27,54,0.45)]"
            >
              <div className="flex items-start justify-between gap-2">
                <span className="flex h-9 w-9 items-center justify-center rounded-xl border border-panel-border text-panel-text-soft transition group-hover:text-panel-text">
                  <Icono size={16} strokeWidth={1.9} />
                </span>
                {tono !== 'neutro' && (
                  <span className="flex items-center gap-1.5 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
                    <span className={`h-1.5 w-1.5 rounded-full ${tonos[tono].punto}`} />
                    {tonos[tono].texto}
                  </span>
                )}
              </div>
              <CountUp to={valor} duration={0.8} trigger="load" className="mt-4 block text-[32px] font-semibold leading-none tracking-[-0.04em]" />
              <p className="mt-2 text-sm font-medium">{t}</p>
              {pie && <p className="mt-0.5 text-xs text-panel-text-muted">{pie}</p>}
            </div>
          ))}
        </div>
      )}

      {children}
    </section>
  )
}
