import { useEffect, useState, type ReactNode } from 'react'
import { motion, useReducedMotion } from 'motion/react'

export type Tema = 'claro' | 'oscuro'

const CLAVE_TEMA = 'rescate360-tema'

// Tema de la landing: lo que el visitante eligió antes, o el de su sistema.
// eslint-disable-next-line react-refresh/only-export-components
export function useTema() {
  const [tema, setTema] = useState<Tema>(() => {
    try {
      const guardado = localStorage.getItem(CLAVE_TEMA)
      if (guardado === 'claro' || guardado === 'oscuro') return guardado
    } catch {
      /* almacenamiento no disponible */
    }
    return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'oscuro' : 'claro'
  })

  useEffect(() => {
    try {
      localStorage.setItem(CLAVE_TEMA, tema)
    } catch {
      /* almacenamiento no disponible */
    }
  }, [tema])

  return { tema, alternar: () => setTema((t) => (t === 'claro' ? 'oscuro' : 'claro')) }
}

// Etiqueta técnica en mono, con un punto rojo de marca: • CAPACIDADES
export function Etiqueta({ children }: { children: ReactNode }) {
  return (
    <p className="font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-slate-500 dark:text-white/50">
      <span className="mr-2 inline-block h-1.5 w-1.5 -translate-y-px rounded-full bg-brand align-middle" />
      {children}
    </p>
  )
}

// Aparece suavemente al entrar en pantalla.
export function Aparecer({
  children,
  retraso = 0,
  className = '',
}: {
  children: ReactNode
  retraso?: number
  className?: string
}) {
  const reducir = useReducedMotion()
  return (
    <motion.div
      className={className}
      initial={reducir ? false : { opacity: 0, y: 18, filter: 'blur(6px)' }}
      whileInView={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
      viewport={{ once: true, margin: '-60px' }}
      transition={{ duration: 0.7, delay: retraso, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  )
}

// Encabezado de sección: etiqueta mono + título grande + texto opcional.
export function EncabezadoSeccion({
  etiqueta,
  titulo,
  texto,
  centrado = false,
}: {
  etiqueta: string
  titulo: ReactNode
  texto?: ReactNode
  centrado?: boolean
}) {
  return (
    <Aparecer className={centrado ? 'mx-auto max-w-2xl text-center' : 'max-w-2xl'}>
      <Etiqueta>{etiqueta}</Etiqueta>
      <h2 className="mt-4 font-display text-4xl font-semibold leading-[1.02] tracking-[-0.035em] text-navy-950 sm:text-5xl dark:text-white">
        {titulo}
      </h2>
      {texto && <p className="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg dark:text-white/60">{texto}</p>}
    </Aparecer>
  )
}
