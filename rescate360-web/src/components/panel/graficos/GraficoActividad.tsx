import { useEffect, useRef, useState } from 'react'
import { motion, useReducedMotion } from 'motion/react'
import type { PuntoActividad } from '../../../types/dashboard'

// Mismos colores que identifican reportes y solicitudes en el mapa operativo.
const SERIES = [
  { clave: 'reportes', etiqueta: 'Reportes', color: '#e5534b' },
  { clave: 'solicitudes', etiqueta: 'Solicitudes', color: '#3e7bfa' },
] as const

const ALTO = 260
const M = { arriba: 12, derecha: 8, abajo: 28, izquierda: 28 }
const MAX_BARRA = 18 // grosor máximo de cada columna
const HUECO = 2 // separación entre las dos columnas de un mismo día

const aFecha = (iso: string) => {
  const [a, m, d] = iso.split('-').map(Number)
  return new Date(a, m - 1, d)
}
const etiquetaCorta = (iso: string, dias: number) =>
  dias <= 7
    ? aFecha(iso).toLocaleDateString('es-CO', { weekday: 'short', day: 'numeric' }).replace('.', '')
    : aFecha(iso).toLocaleDateString('es-CO', { day: 'numeric', month: 'short' }).replace('.', '')
const etiquetaLarga = (iso: string) =>
  aFecha(iso).toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })

// Máximo "redondo" del eje y, con marcas enteras.
function escalaY(max: number) {
  const tope = Math.max(2, Math.ceil(max / 2) * 2)
  const paso = tope <= 4 ? 1 : tope / 4
  const marcas: number[] = []
  for (let v = 0; v <= tope; v += paso) marcas.push(v)
  return { tope, marcas }
}

// Columna con el extremo de datos redondeado (4px) y la base recta sobre el eje.
function columna(x: number, y: number, ancho: number, alto: number) {
  if (alto <= 0) return ''
  const r = Math.min(4, ancho / 2, alto)
  return `M${x},${y + alto} V${y + r} Q${x},${y} ${x + r},${y} H${x + ancho - r} Q${x + ancho},${y} ${x + ancho},${y + r} V${y + alto} Z`
}

// Colores de la "tinta" del gráfico según el fondo (claro o la banda azul marino).
const TINTA = {
  claro: {
    leyenda: 'text-panel-text-soft',
    grilla: '#e3e7ef',
    base: '#cfd5e0',
    eje: 'fill-panel-text-muted',
    ejeActivo: 'fill-panel-text font-semibold',
    franja: '#f4f6fa',
  },
  oscuro: {
    leyenda: 'text-white/70',
    grilla: 'rgba(255,255,255,0.08)',
    base: 'rgba(255,255,255,0.22)',
    eje: 'fill-white/50',
    ejeActivo: 'fill-white font-semibold',
    franja: 'rgba(255,255,255,0.07)',
  },
}

export default function GraficoActividad({ datos, oscuro = false }: { datos: PuntoActividad[]; oscuro?: boolean }) {
  const t = TINTA[oscuro ? 'oscuro' : 'claro']
  const contenedor = useRef<HTMLDivElement>(null)
  const [ancho, setAncho] = useState(0)
  const [activo, setActivo] = useState<number | null>(null)
  const reducir = useReducedMotion()

  useEffect(() => {
    const el = contenedor.current
    if (!el) return
    const observador = new ResizeObserver(([entrada]) => setAncho(entrada.contentRect.width))
    observador.observe(el)
    return () => observador.disconnect()
  }, [])

  const max = Math.max(0, ...datos.flatMap((p) => [p.reportes, p.solicitudes]))
  const { tope, marcas } = escalaY(max)
  const anchoUtil = Math.max(0, ancho - M.izquierda - M.derecha)
  const altoUtil = ALTO - M.arriba - M.abajo
  const banda = datos.length ? anchoUtil / datos.length : 0
  const grosor = Math.max(2, Math.min(MAX_BARRA, (banda * 0.7 - HUECO) / 2))
  const y = (v: number) => M.arriba + altoUtil - (v / tope) * altoUtil
  const centro = (i: number) => M.izquierda + banda * i + banda / 2
  // Se muestra una etiqueta cada tantos días para que no se encimen (~56px por etiqueta), contando desde el último.
  const salto = banda > 0 ? Math.max(1, Math.ceil(56 / banda)) : 1
  const ultimo = datos.length - 1
  const punto = activo !== null ? datos[activo] : null

  return (
    <div>
      <div className={`flex flex-wrap gap-4 text-xs ${t.leyenda}`} aria-hidden="true">
        {SERIES.map((s) => (
          <span key={s.clave} className="flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded-sm" style={{ backgroundColor: s.color }} />
            {s.etiqueta}
          </span>
        ))}
      </div>

      <div ref={contenedor} className="relative mt-3" onMouseLeave={() => setActivo(null)}>
        {ancho > 0 && datos.length > 0 && (
          <svg
            width={ancho}
            height={ALTO}
            role="img"
            aria-label={`Actividad diaria de ${datos.length} días: ${datos.reduce((s, p) => s + p.reportes, 0)} reportes y ${datos.reduce((s, p) => s + p.solicitudes, 0)} solicitudes`}
          >
            {marcas.map((v) => (
              <g key={v}>
                <line x1={M.izquierda} x2={ancho - M.derecha} y1={y(v)} y2={y(v)} stroke={t.grilla} strokeWidth={1} />
                <text x={M.izquierda - 8} y={y(v)} dy="0.32em" textAnchor="end" className={`${t.eje} text-[11px] tabular-nums`}>
                  {v}
                </text>
              </g>
            ))}

            {activo !== null && (
              <rect x={M.izquierda + banda * activo} y={M.arriba} width={banda} height={altoUtil} rx={6} fill={t.franja} />
            )}

            {datos.map((p, i) =>
              SERIES.map((s, j) => {
                const valor = p[s.clave]
                const x = centro(i) - grosor - HUECO / 2 + j * (grosor + HUECO)
                return (
                  <motion.path
                    key={`${p.fecha}-${s.clave}`}
                    d={columna(x, y(valor), grosor, y(0) - y(valor))}
                    fill={s.color}
                    style={{ transformBox: 'fill-box', transformOrigin: 'bottom' }}
                    initial={{ scaleY: reducir ? 1 : 0 }}
                    animate={{ scaleY: 1, opacity: activo === null || activo === i ? 1 : 0.35 }}
                    transition={{
                      scaleY: { duration: reducir ? 0 : 0.55, delay: reducir ? 0 : Math.min(i * 0.02, 0.4), ease: [0.23, 1, 0.32, 1] },
                      opacity: { duration: 0.15 },
                    }}
                  />
                )
              }),
            )}

            <line x1={M.izquierda} x2={ancho - M.derecha} y1={y(0)} y2={y(0)} stroke={t.base} strokeWidth={1} />

            {datos.map(
              (p, i) =>
                (ultimo - i) % salto === 0 && (
                  <text
                    key={p.fecha}
                    x={centro(i)}
                    y={ALTO - 8}
                    textAnchor="middle"
                    className={`text-[11px] ${activo === i ? t.ejeActivo : t.eje}`}
                  >
                    {etiquetaCorta(p.fecha, datos.length)}
                  </text>
                ),
            )}

            {/* Zonas de captura: toda la franja del día, más grande que las columnas. */}
            {datos.map((p, i) => (
              <rect
                key={p.fecha}
                x={M.izquierda + banda * i}
                y={M.arriba}
                width={banda}
                height={altoUtil}
                fill="transparent"
                tabIndex={0}
                onMouseEnter={() => setActivo(i)}
                onFocus={() => setActivo(i)}
                onBlur={() => setActivo(null)}
                aria-label={`${etiquetaLarga(p.fecha)}: ${p.reportes} reportes, ${p.solicitudes} solicitudes`}
                className="outline-none"
              />
            ))}
          </svg>
        )}

        {punto && activo !== null && (
          <div
            className="pointer-events-none absolute top-0 z-10 w-48 rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-xs shadow-lg"
            style={{ left: Math.min(Math.max(centro(activo) - 96, 0), Math.max(ancho - 192, 0)) }}
          >
            <p className="font-semibold capitalize text-panel-text">{etiquetaLarga(punto.fecha)}</p>
            {SERIES.map((s) => (
              <p key={s.clave} className="mt-1 flex items-center justify-between gap-3 text-panel-text-soft">
                <span className="flex items-center gap-1.5">
                  <span className="h-2 w-2 rounded-sm" style={{ backgroundColor: s.color }} />
                  {s.etiqueta}
                </span>
                <span className="font-semibold tabular-nums text-panel-text">{punto[s.clave]}</span>
              </p>
            ))}
          </div>
        )}
      </div>

      <table className="sr-only">
        <caption>Actividad diaria</caption>
        <thead>
          <tr>
            <th>Día</th>
            <th>Reportes</th>
            <th>Solicitudes</th>
          </tr>
        </thead>
        <tbody>
          {datos.map((p) => (
            <tr key={p.fecha}>
              <td>{etiquetaLarga(p.fecha)}</td>
              <td>{p.reportes}</td>
              <td>{p.solicitudes}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
