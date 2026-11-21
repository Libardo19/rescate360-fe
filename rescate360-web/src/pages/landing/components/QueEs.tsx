import { useRef } from 'react'
import { motion, useReducedMotion, useScroll, useTransform, type MotionValue } from 'motion/react'
import { Etiqueta } from './comunes'

// Manifiesto: cada palabra se "enciende" a medida que se hace scroll por la sección.
const TEXTO =
  'RESCATE360 une a ciudadanos, voluntarios y organismos de respuesta en un mismo mapa. Cada reporte llega a la organización correcta, con su ubicación y su prioridad, para que la ayuda no se pierda en el camino.'

const DESTACADAS = new Set(['mismo', 'mapa.', 'organización', 'correcta,', 'ayuda'])

function Palabra({ texto, progreso, rango }: { texto: string; progreso: MotionValue<number>; rango: [number, number] }) {
  const opacidad = useTransform(progreso, rango, [0.15, 1])
  const destacada = DESTACADAS.has(texto)
  return (
    <motion.span style={{ opacity: opacidad }} className={destacada ? 'text-brand' : undefined}>
      {texto}{' '}
    </motion.span>
  )
}

export default function QueEs() {
  const ref = useRef<HTMLDivElement>(null)
  const reducir = useReducedMotion()
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 0.85', 'end 0.45'] })
  const palabras = TEXTO.split(' ')

  return (
    <section id="que-es" className="scroll-mt-24 px-5 py-24 sm:px-6 sm:py-32">
      <div ref={ref} className="mx-auto max-w-5xl">
        <Etiqueta>Qué es</Etiqueta>
        <p className="mt-6 font-display text-3xl font-medium leading-[1.15] tracking-[-0.03em] text-navy-950 sm:text-5xl dark:text-white">
          {reducir
            ? TEXTO
            : palabras.map((p, i) => (
                <Palabra
                  key={i}
                  texto={p}
                  progreso={scrollYProgress}
                  rango={[i / palabras.length, Math.min(1, (i + 3) / palabras.length)]}
                />
              ))}
        </p>
      </div>
    </section>
  )
}
