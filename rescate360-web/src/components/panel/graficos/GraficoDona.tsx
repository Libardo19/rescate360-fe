import { useState } from 'react'
import { motion, useReducedMotion } from 'motion/react'

export interface Segmento {
  clave: string
  etiqueta: string
  valor: number
  color: string
}

const TAM = 168
const GROSOR = 18
const R = (TAM - GROSOR) / 2
const CIRC = 2 * Math.PI * R
const HUECO = 2 // separación en px entre segmentos (color de la superficie)

// Dona para ver de un vistazo cómo se reparte un total (≤ 6 partes).
// El centro muestra el total, o el segmento bajo el cursor. Debajo, la tabla hace de leyenda.
export default function GraficoDona({
  segmentos,
  titulo,
  etiquetaTotal,
  oscuro = false,
}: {
  segmentos: Segmento[]
  titulo: string
  etiquetaTotal: string
  oscuro?: boolean
}) {
  const [activo, setActivo] = useState<string | null>(null)
  const reducir = useReducedMotion()
  const total = segmentos.reduce((s, x) => s + x.valor, 0)
  const pct = (v: number) => (total ? Math.round((v / total) * 100) : 0)
  const visibles = segmentos.filter((s) => s.valor > 0)
  const seleccionado = segmentos.find((s) => s.clave === activo)

  // Cada arco empieza donde terminan los anteriores; se le resta el hueco al final.
  const arcos = visibles.map((s, i) => {
    const inicio = (visibles.slice(0, i).reduce((suma, x) => suma + x.valor, 0) / total) * CIRC
    const largo = (s.valor / total) * CIRC
    return { ...s, inicio, largo: Math.max(0, largo - (visibles.length > 1 ? HUECO : 0)) }
  })

  return (
    <div>
      <div className="relative mx-auto" style={{ width: TAM, height: TAM }}>
        <svg width={TAM} height={TAM} role="img" aria-label={`${titulo}: ${segmentos.map((s) => `${s.etiqueta} ${s.valor}`).join(', ')}`}>
          <circle cx={TAM / 2} cy={TAM / 2} r={R} fill="none" stroke={oscuro ? "rgba(255,255,255,0.08)" : "#eef1f6"} strokeWidth={GROSOR} />
          <g transform={`rotate(-90 ${TAM / 2} ${TAM / 2})`} onMouseLeave={() => setActivo(null)}>
            {arcos.map((a, i) => (
              <motion.circle
                key={a.clave}
                cx={TAM / 2}
                cy={TAM / 2}
                r={R}
                fill="none"
                stroke={a.color}
                strokeWidth={activo === a.clave ? GROSOR + 4 : GROSOR}
                strokeDashoffset={-a.inicio}
                initial={{ strokeDasharray: `0 ${CIRC}` }}
                animate={{
                  strokeDasharray: `${a.largo} ${CIRC}`,
                  opacity: activo && activo !== a.clave ? 0.35 : 1,
                }}
                transition={{
                  strokeDasharray: { duration: reducir ? 0 : 0.7, delay: reducir ? 0 : 0.1 + i * 0.08, ease: [0.23, 1, 0.32, 1] },
                  opacity: { duration: 0.15 },
                }}
                onMouseEnter={() => setActivo(a.clave)}
                className="cursor-pointer transition-[stroke-width] duration-150"
              />
            ))}
          </g>
        </svg>
        <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center text-center">
          <span className={`text-3xl font-extrabold ${oscuro ? "text-white" : "text-panel-text"}`}>{seleccionado ? seleccionado.valor : total}</span>
          <span className={`max-w-[100px] text-xs leading-tight ${oscuro ? "text-white/60" : "text-panel-text-muted"}`}>
            {seleccionado ? `${seleccionado.etiqueta} · ${pct(seleccionado.valor)}%` : etiquetaTotal}
          </span>
        </div>
      </div>

      {/* Leyenda + vista de tabla: nombre, cantidad y porcentaje de cada parte. */}
      <table className="mt-5 w-full text-sm">
        <caption className="sr-only">{titulo}</caption>
        <thead className="sr-only">
          <tr>
            <th>Estado</th>
            <th>Cantidad</th>
            <th>Porcentaje</th>
          </tr>
        </thead>
        <tbody>
          {segmentos.map((s) => (
            <tr
              key={s.clave}
              tabIndex={s.valor > 0 ? 0 : -1}
              onMouseEnter={() => s.valor > 0 && setActivo(s.clave)}
              onMouseLeave={() => setActivo(null)}
              onFocus={() => s.valor > 0 && setActivo(s.clave)}
              onBlur={() => setActivo(null)}
              className={`border-b outline-none transition-colors last:border-0 ${oscuro ? "border-white/10" : "border-panel-border"} ${
                activo === s.clave ? (oscuro ? 'bg-white/5' : 'bg-panel-bg') : ''
              } ${s.valor === 0 ? 'opacity-50' : ''}`}
            >
              <td className="py-1.5 pl-1">
                <span className={`flex items-center gap-2 ${oscuro ? "text-white/75" : "text-panel-text-soft"}`}>
                  <span className="h-2.5 w-2.5 shrink-0 rounded-sm" style={{ backgroundColor: s.color }} />
                  {s.etiqueta}
                </span>
              </td>
              <td className={`py-1.5 text-right font-semibold tabular-nums ${oscuro ? "text-white" : "text-panel-text"}`}>{s.valor}</td>
              <td className={`w-12 py-1.5 pr-1 text-right text-xs tabular-nums ${oscuro ? "text-white/50" : "text-panel-text-muted"}`}>{pct(s.valor)}%</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
