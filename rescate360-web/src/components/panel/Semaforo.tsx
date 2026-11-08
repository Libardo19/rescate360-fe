import { textoEspera, nivelEspera, type NivelEspera } from '../../utils/espera'

const estilos: Record<NivelEspera, { caja: string; punto: string; etiqueta: string }> = {
  ok: {
    caja: 'border-emerald-500/25 text-emerald-700 dark:text-emerald-300',
    punto: 'bg-emerald-500',
    etiqueta: 'A tiempo',
  },
  atencion: {
    caja: 'border-amber-500/35 bg-amber-500/[0.07] text-amber-700 dark:text-amber-300',
    punto: 'bg-amber-500',
    etiqueta: 'Más de 15 min',
  },
  critico: {
    caja: 'border-brand/40 bg-brand/[0.07] text-brand',
    punto: 'bg-brand',
    etiqueta: 'Más de 30 min',
  },
}

// Píldora del semáforo de espera: punto que late en rojo cuando ya pasaron 30 min sin atención.
export default function Semaforo({ minutos, compacto = false }: { minutos: number; compacto?: boolean }) {
  const nivel = nivelEspera(minutos)
  const e = estilos[nivel]
  return (
    <span
      title={`${e.etiqueta} sin atención`}
      className={`inline-flex items-center gap-1.5 whitespace-nowrap rounded-full border px-2.5 py-1 font-mono text-[11px] tabular-nums ${e.caja}`}
    >
      <span className="relative flex h-1.5 w-1.5">
        {nivel === 'critico' && (
          <span className={`absolute inline-flex h-full w-full animate-ping rounded-full ${e.punto} opacity-75 motion-reduce:hidden`} />
        )}
        <span className={`relative inline-flex h-1.5 w-1.5 rounded-full ${e.punto}`} />
      </span>
      {compacto ? textoEspera(minutos) : `Espera ${textoEspera(minutos)}`}
      <span className="sr-only">. {e.etiqueta} sin atención.</span>
    </span>
  )
}
