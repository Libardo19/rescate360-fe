import { useState } from 'react'
import { motion, useReducedMotion } from 'motion/react'

export interface Barra {
  clave: string
  etiqueta: string
  valor: number
}

// Barras horizontales de una sola serie (un solo color): la longitud es el dato.
// El valor va en la punta de cada barra; el tooltip agrega el porcentaje sobre el total.
export default function BarrasHorizontales({
  barras,
  color = '#0f2a5c',
  unidad,
}: {
  barras: Barra[]
  color?: string
  unidad: string
}) {
  const [activa, setActiva] = useState<string | null>(null)
  const reducir = useReducedMotion()
  const max = Math.max(1, ...barras.map((b) => b.valor))
  const total = barras.reduce((s, b) => s + b.valor, 0)

  return (
    <ul className="space-y-3" onMouseLeave={() => setActiva(null)}>
      {barras.map((b, i) => {
        const pct = total ? Math.round((b.valor / total) * 100) : 0
        return (
          <li
            key={b.clave}
            className="grid grid-cols-[96px_minmax(0,1fr)] items-center gap-3 text-sm"
            onMouseEnter={() => setActiva(b.clave)}
          >
            <span className={`truncate ${activa === b.clave ? 'font-semibold text-panel-text' : 'text-panel-text-soft'}`}>
              {b.etiqueta}
            </span>
            <div
              className="relative flex h-5 items-center gap-2"
              tabIndex={0}
              onFocus={() => setActiva(b.clave)}
              onBlur={() => setActiva(null)}
              aria-label={`${b.etiqueta}: ${b.valor} ${unidad} (${pct}%)`}
            >
              {b.valor > 0 && (
                <motion.div
                  className="h-5 rounded-r origin-left"
                  style={{
                    width: `calc(${(b.valor / max) * 100}% - 2rem)`,
                    backgroundColor: color,
                    opacity: activa && activa !== b.clave ? 0.45 : 1,
                  }}
                  initial={{ scaleX: reducir ? 1 : 0 }}
                  animate={{ scaleX: 1 }}
                  transition={{ duration: reducir ? 0 : 0.6, delay: reducir ? 0 : 0.15 + i * 0.05, ease: [0.23, 1, 0.32, 1] }}
                />
              )}
              <span className="text-xs font-semibold tabular-nums text-panel-text">{b.valor}</span>
              {activa === b.clave && b.valor > 0 && (
                <span className="pointer-events-none absolute -top-8 left-0 z-10 whitespace-nowrap rounded-md border border-panel-border bg-panel-card px-2 py-1 text-xs text-panel-text-soft shadow-md">
                  {b.valor} {unidad} · {pct}% del total
                </span>
              )}
            </div>
          </li>
        )
      })}
    </ul>
  )
}
