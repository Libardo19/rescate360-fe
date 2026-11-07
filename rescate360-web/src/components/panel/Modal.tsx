import { useEffect, useId, useRef, type ReactNode } from 'react'
import { X } from 'lucide-react'

interface Props {
  titulo: string
  subtitulo?: ReactNode
  onCerrar: () => void
  children: ReactNode
  ancho?: 'md' | 'lg' | 'xl'
}

const anchos = { md: 'max-w-lg', lg: 'max-w-2xl', xl: 'max-w-4xl' }

// Ventana modal del panel: se cierra con Esc o pulsando fuera, y enfoca el diálogo al abrir.
export default function Modal({ titulo, subtitulo, onCerrar, children, ancho = 'md' }: Props) {
  const idTitulo = useId()
  const ref = useRef<HTMLDivElement>(null)
  const cerrarRef = useRef(onCerrar)

  useEffect(() => {
    cerrarRef.current = onCerrar
  })

  // Solo al montar: enfocar el diálogo (si nada dentro pidió el foco) y escuchar Esc.
  useEffect(() => {
    if (!ref.current?.contains(document.activeElement)) ref.current?.focus()
    const alPulsar = (e: KeyboardEvent) => {
      if (e.key === 'Escape') cerrarRef.current()
    }
    window.addEventListener('keydown', alPulsar)
    return () => window.removeEventListener('keydown', alPulsar)
  }, [])

  return (
    <div
      className="panel-overlay-enter fixed inset-0 z-[1100] flex items-center justify-center overflow-y-auto bg-black/40 p-4"
      onClick={onCerrar}
    >
      <div
        ref={ref}
        role="dialog"
        aria-modal="true"
        aria-labelledby={idTitulo}
        tabIndex={-1}
        className={`panel-modal-enter w-full ${anchos[ancho]} rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl outline-none`}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <h2 id={idTitulo} className="text-xl font-semibold tracking-[-0.02em]">
              {titulo}
            </h2>
            {subtitulo && <div className="mt-1 text-xs text-panel-text-muted">{subtitulo}</div>}
          </div>
          <button
            type="button"
            onClick={onCerrar}
            aria-label="Cerrar"
            className="rounded p-1 text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-text"
          >
            <X size={20} />
          </button>
        </div>
        {children}
      </div>
    </div>
  )
}
