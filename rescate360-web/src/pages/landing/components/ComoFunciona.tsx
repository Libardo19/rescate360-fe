import { motion, useReducedMotion } from 'motion/react'
import { Aparecer, EncabezadoSeccion } from './comunes'

const pasos = [
  {
    numero: '01',
    titulo: 'Reporta',
    texto: 'Desde la app: qué pasa, una foto y tu ubicación. Si el teléfono detecta una caída fuerte, puede pedir ayuda por ti.',
  },
  {
    numero: '02',
    titulo: 'Se prioriza',
    texto: 'La IA sugiere la urgencia y la entidad adecuada. Bomberos, Cruz Roja o Defensa Civil lo reciben en su panel.',
  },
  {
    numero: '03',
    titulo: 'Llega la ayuda',
    texto: 'La organización asigna voluntarios y actualiza el estado. Tú ves en todo momento qué está pasando.',
  },
]

export default function ComoFunciona() {
  const reducir = useReducedMotion()
  return (
    <section id="como-funciona" className="scroll-mt-24 px-5 py-20 sm:px-6 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <EncabezadoSeccion
          etiqueta="Cómo funciona"
          titulo={
            <>
              De la alerta a la ayuda,
              <br />
              <span className="text-slate-400 dark:text-white/40">en tres pasos.</span>
            </>
          }
        />

        <div className="relative mt-14">
          {/* Línea de progreso que se dibuja al entrar en pantalla */}
          <div className="absolute left-0 right-0 top-[22px] hidden h-px bg-slate-200 md:block dark:bg-white/10" />
          <motion.div
            className="absolute left-0 right-0 top-[22px] hidden h-px origin-left bg-brand md:block"
            initial={reducir ? false : { scaleX: 0 }}
            whileInView={{ scaleX: 1 }}
            viewport={{ once: true, margin: '-80px' }}
            transition={{ duration: 1.4, ease: [0.22, 1, 0.36, 1] }}
          />

          <ol className="grid gap-10 md:grid-cols-3 md:gap-8">
            {pasos.map((p, i) => (
              <Aparecer key={p.numero} retraso={0.15 + i * 0.18}>
                <li className="relative">
                  <span className="relative z-10 flex h-11 w-11 items-center justify-center rounded-full border border-slate-200 bg-white font-mono text-xs font-medium text-navy-950 dark:border-white/15 dark:bg-navy-950 dark:text-white">
                    {p.numero}
                  </span>
                  <h3 className="mt-6 font-display text-2xl font-semibold tracking-[-0.025em] text-navy-950 dark:text-white">{p.titulo}</h3>
                  <p className="mt-2 max-w-sm text-sm leading-relaxed text-slate-600 dark:text-white/55">{p.texto}</p>
                </li>
              </Aparecer>
            ))}
          </ol>
        </div>
      </div>
    </section>
  )
}
