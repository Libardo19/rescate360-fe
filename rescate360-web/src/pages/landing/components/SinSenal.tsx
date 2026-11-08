import { useState } from 'react'
import { AnimatePresence, motion, useReducedMotion } from 'motion/react'
import { Cloud, LayoutDashboard, RadioTower, Smartphone, Wifi, WifiOff, type LucideIcon } from 'lucide-react'
import { Aparecer, EncabezadoSeccion } from './comunes'

type Modo = 'con' | 'sin'

interface Nodo {
  id: string
  x: number // coordenadas en un lienzo de 640 × 280
  y: number
  icono: LucideIcon
  titulo: string
  detalle: string
  tono: 'tu' | 'red' | 'vecino' | 'destino'
}

const NODOS: Record<Modo, Nodo[]> = {
  con: [
    { id: 'tu', x: 70, y: 150, icono: Smartphone, titulo: 'Tu teléfono', detalle: 'Reporte + ubicación', tono: 'tu' },
    { id: 'nube', x: 320, y: 70, icono: Cloud, titulo: 'RESCATE360', detalle: 'Prioriza con IA', tono: 'red' },
    { id: 'panel', x: 570, y: 150, icono: LayoutDashboard, titulo: 'Bomberos', detalle: 'Panel de la organización', tono: 'destino' },
  ],
  sin: [
    { id: 'tu', x: 70, y: 150, icono: Smartphone, titulo: 'Tu teléfono', detalle: 'Guardado en cola', tono: 'tu' },
    { id: 'torre', x: 320, y: 50, icono: RadioTower, titulo: 'SMS', detalle: 'Red celular básica', tono: 'red' },
    { id: 'v1', x: 230, y: 235, icono: Smartphone, titulo: 'Vecino', detalle: 'Sin señal, reenvía', tono: 'vecino' },
    { id: 'v2', x: 420, y: 235, icono: Smartphone, titulo: 'Vecino', detalle: 'Con señal', tono: 'vecino' },
    { id: 'panel', x: 570, y: 150, icono: LayoutDashboard, titulo: 'Bomberos', detalle: 'Llega igual', tono: 'destino' },
  ],
}

// Rutas que recorren los "paquetes". La primera es la principal; en modo sin señal hay dos caminos.
const RUTAS: Record<Modo, { d: string; color: string; punteada?: boolean; duracion: number }[]> = {
  con: [{ d: 'M70 150 Q 190 60 320 70 Q 450 80 570 150', color: '#3e7bfa', duracion: 2.4 }],
  sin: [
    { d: 'M70 150 Q 180 40 320 50 Q 460 60 570 150', color: '#f59e0b', punteada: true, duracion: 3.2 },
    { d: 'M70 150 Q 130 230 230 235 L 420 235 Q 520 230 570 150', color: '#e8343f', duracion: 3.8 },
  ],
}

const PASOS: Record<Modo, { metodo: string; texto: string }[]> = {
  con: [
    { metodo: 'online', texto: 'Hay conexión: el reporte sale de inmediato.' },
    { metodo: 'ia', texto: 'La IA sugiere la prioridad y la organización.' },
    { metodo: 'panel', texto: 'Bomberos lo recibe en su panel en segundos.' },
  ],
  sin: [
    { metodo: 'local', texto: 'Sin internet: el reporte se guarda en el teléfono.' },
    { metodo: 'sms', texto: 'Se envía un resumen por SMS, que funciona con poca señal.' },
    { metodo: 'mesh', texto: 'En paralelo salta de teléfono en teléfono cercano.' },
    { metodo: 'sync', texto: 'El primero con señal lo entrega; no se duplica al sincronizar.' },
  ],
}

const estiloNodo: Record<Nodo['tono'], string> = {
  tu: 'bg-navy-950 text-white dark:bg-white dark:text-navy-950',
  red: 'bg-white text-navy-950 border border-slate-200 dark:bg-white/10 dark:text-white dark:border-white/15',
  vecino: 'bg-white text-slate-600 border border-dashed border-slate-300 dark:bg-white/5 dark:text-white/70 dark:border-white/20',
  destino: 'bg-brand text-white shadow-[0_10px_30px_-10px_rgba(232,52,63,0.8)]',
}

const pct = (v: number, total: number) => `${(v / total) * 100}%`

export default function SinSenal() {
  const [modo, setModo] = useState<Modo>('sin')
  const reducir = useReducedMotion()

  return (
    <section id="sin-senal" className="scroll-mt-24 px-5 py-20 sm:px-6 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="flex flex-col gap-8 lg:flex-row lg:items-end lg:justify-between">
          <EncabezadoSeccion
            etiqueta="Sin señal"
            titulo={
              <>
                Cuando se cae la red,
                <br />
                <span className="text-slate-400 dark:text-white/40">el reporte igual llega.</span>
              </>
            }
            texto="En una emergencia lo primero que falla es internet. Prueba cómo viaja un reporte en cada caso."
          />

          {/* Interruptor */}
          <Aparecer retraso={0.1}>
            <div role="radiogroup" aria-label="Estado de la conexión" className="inline-flex rounded-full border border-slate-200 bg-white/70 p-1 backdrop-blur dark:border-white/10 dark:bg-white/5">
              {(
                [
                  ['con', 'Con señal', Wifi],
                  ['sin', 'Sin señal', WifiOff],
                ] as const
              ).map(([valor, etiqueta, Icono]) => (
                <button
                  key={valor}
                  role="radio"
                  aria-checked={modo === valor}
                  onClick={() => setModo(valor)}
                  className={`relative isolate flex items-center gap-2 rounded-full px-5 py-2.5 text-sm font-semibold transition-colors ${
                    modo === valor ? 'text-white dark:text-navy-950' : 'text-slate-600 hover:text-navy-950 dark:text-white/60 dark:hover:text-white'
                  }`}
                >
                  {modo === valor && (
                    <motion.span
                      layoutId="modo-senal"
                      transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                      className={`absolute inset-0 -z-10 rounded-full ${valor === 'sin' ? 'bg-brand' : 'bg-navy-950 dark:bg-white'}`}
                    />
                  )}
                  <Icono size={16} />
                  {etiqueta}
                </button>
              ))}
            </div>
          </Aparecer>
        </div>

        <Aparecer retraso={0.15} className="mt-10">
          <div className="grid overflow-hidden rounded-[32px] border border-slate-200/80 bg-white/70 backdrop-blur lg:grid-cols-[1.45fr_1fr] dark:border-white/10 dark:bg-white/[0.04]">
            {/* Diagrama */}
            <div className="relative border-b border-slate-200/80 p-4 sm:p-8 lg:border-b-0 lg:border-r dark:border-white/10">
              <div
                aria-hidden="true"
                className="absolute inset-0 opacity-60 [background-image:radial-gradient(rgba(11,27,54,0.09)_1px,transparent_1px)] [background-size:16px_16px] dark:[background-image:radial-gradient(rgba(255,255,255,0.08)_1px,transparent_1px)]"
              />
              <div className="relative aspect-[640/280] w-full">
                <svg viewBox="0 0 640 280" className="absolute inset-0 h-full w-full" aria-hidden="true">
                  <AnimatePresence mode="wait">
                    <motion.g key={modo} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.3 }}>
                      {RUTAS[modo].map((r, i) => (
                        <g key={i}>
                          <path id={`ruta-${modo}-${i}`} d={r.d} fill="none" stroke={r.color} strokeOpacity={0.25} strokeWidth={2} strokeDasharray={r.punteada ? '6 6' : undefined} />
                          <motion.path
                            d={r.d}
                            fill="none"
                            stroke={r.color}
                            strokeWidth={2}
                            strokeLinecap="round"
                            strokeDasharray={r.punteada ? '6 6' : undefined}
                            initial={{ pathLength: reducir ? 1 : 0 }}
                            animate={{ pathLength: 1 }}
                            transition={{ duration: 1.1, delay: 0.2 + i * 0.3, ease: [0.22, 1, 0.36, 1] }}
                          />
                          {/* Paquete que viaja por la ruta */}
                          {!reducir && (
                            <circle r={6} fill={r.color} stroke="white" strokeWidth={2}>
                              <animateMotion dur={`${r.duracion}s`} begin={`${0.6 + i * 0.5}s`} repeatCount="indefinite" keyPoints="0;1" keyTimes="0;1" calcMode="linear">
                                <mpath href={`#ruta-${modo}-${i}`} />
                              </animateMotion>
                            </circle>
                          )}
                        </g>
                      ))}
                    </motion.g>
                  </AnimatePresence>
                </svg>

                <AnimatePresence>
                  {NODOS[modo].map((n, i) => (
                    <motion.div
                      key={`${modo}-${n.id}`}
                      initial={reducir ? false : { opacity: 0, scale: 0.6 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 0.6 }}
                      transition={{ duration: 0.35, delay: i * 0.06, ease: [0.22, 1, 0.36, 1] }}
                      className="absolute flex -translate-x-1/2 -translate-y-1/2 flex-col items-center text-center"
                      style={{ left: pct(n.x, 640), top: pct(n.y, 280) }}
                    >
                      <span className={`relative flex h-11 w-11 items-center justify-center rounded-2xl sm:h-14 sm:w-14 ${estiloNodo[n.tono]}`}>
                        {n.tono === 'destino' && (
                          <span className="absolute inset-0 animate-ping rounded-2xl bg-brand/40 motion-reduce:hidden" style={{ animationDuration: '2.4s' }} />
                        )}
                        <n.icono size={20} strokeWidth={1.8} className="relative" />
                        {n.id === 'tu' && modo === 'sin' && (
                          <span className="absolute -right-1.5 -top-1.5 flex h-5 w-5 items-center justify-center rounded-full border-2 border-white bg-brand text-white dark:border-[#060c19]">
                            <WifiOff size={10} />
                          </span>
                        )}
                      </span>
                      <span className="mt-1.5 rounded-lg bg-[#f6f7f9]/90 px-1.5 py-0.5 leading-tight backdrop-blur-sm dark:bg-[#0b1220]/90">
                        <span className="block whitespace-nowrap text-[11px] font-semibold text-navy-950 sm:text-xs dark:text-white">{n.titulo}</span>
                        <span className="hidden whitespace-nowrap text-[11px] text-slate-500 sm:block dark:text-white/50">{n.detalle}</span>
                      </span>
                    </motion.div>
                  ))}
                </AnimatePresence>
              </div>
            </div>

            {/* Registro paso a paso */}
            <div className="p-6 sm:p-8">
              <p className="font-mono text-[11px] uppercase tracking-[0.16em] text-slate-500 dark:text-white/50">
                Registro del envío · {modo === 'con' ? 'online' : 'modo sin conexión'}
              </p>
              <AnimatePresence mode="wait">
                <motion.ol key={modo} className="mt-5 space-y-4" initial="oculto" animate="visible" exit="oculto">
                  {PASOS[modo].map((p, i) => (
                    <motion.li
                      key={p.metodo}
                      variants={{
                        oculto: { opacity: 0, x: -8 },
                        visible: { opacity: 1, x: 0, transition: { delay: reducir ? 0 : 0.25 + i * 0.35, duration: 0.4 } },
                      }}
                      className="flex gap-3"
                    >
                      <span
                        className={`mt-0.5 shrink-0 rounded-md px-1.5 py-0.5 font-mono text-[10px] uppercase tracking-[0.1em] ${
                          modo === 'sin' ? 'bg-brand/10 text-brand' : 'bg-panel-info/10 text-panel-info'
                        }`}
                      >
                        {p.metodo}
                      </span>
                      <span className="text-sm leading-relaxed text-slate-600 dark:text-white/65">{p.texto}</span>
                    </motion.li>
                  ))}
                </motion.ol>
              </AnimatePresence>
              <p className="mt-6 border-t border-slate-200 pt-4 text-xs leading-relaxed text-slate-500 dark:border-white/10 dark:text-white/45">
                {modo === 'sin'
                  ? 'Cada reporte lleva un identificador único: si llega por varios caminos, el sistema lo registra una sola vez.'
                  : 'Desactiva la señal para ver qué pasa cuando la red se cae.'}
              </p>
            </div>
          </div>
        </Aparecer>
      </div>
    </section>
  )
}
