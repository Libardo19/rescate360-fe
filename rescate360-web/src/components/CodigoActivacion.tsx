import { useState } from 'react'
import { Check, Copy, KeyRound, X } from 'lucide-react'
import type { Invitacion } from '../types/usuarioSistema'

// Muestra el código de activación UNA sola vez: el backend solo guarda su hash.
// La persona lo canjea en la app (o en POST /auth/activar) y pone su contraseña.
export default function CodigoActivacion({ invitacion, onCerrar }: { invitacion: Invitacion; onCerrar: () => void }) {
  const [copiado, setCopiado] = useState(false)
  const { usuario, codigo_activacion, vence_en } = invitacion

  const copiar = async () => {
    await navigator.clipboard.writeText(codigo_activacion)
    setCopiado(true)
    setTimeout(() => setCopiado(false), 2000)
  }

  return (
    <div className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6" onClick={onCerrar}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-codigo"
        className="panel-modal-enter my-auto w-full max-w-md rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <h2 id="titulo-codigo" className="flex items-center gap-2 text-xl font-semibold tracking-[-0.02em]">
            <KeyRound size={20} /> Código de activación
          </h2>
          <button type="button" onClick={onCerrar} aria-label="Cerrar">
            <X size={20} />
          </button>
        </div>

        <p className="mt-3 text-sm text-panel-text-soft">
          Entrégale este código a <strong className="text-panel-text">{usuario.nombre}</strong> ({usuario.email}). Lo usa una
          sola vez para activar su cuenta y poner su contraseña.
        </p>

        <div className="mt-4 flex items-center justify-between gap-3 rounded-xl border-2 border-dashed border-panel-primary/40 bg-panel-bg px-4 py-3">
          <span className="font-mono text-2xl font-bold tracking-[0.2em] text-panel-primary">{codigo_activacion}</span>
          <button
            type="button"
            onClick={copiar}
            className="flex items-center gap-1 rounded-full bg-panel-primary px-3 py-2 text-sm font-semibold text-white hover:bg-panel-primary-dark"
          >
            {copiado ? <Check size={16} /> : <Copy size={16} />} {copiado ? 'Copiado' : 'Copiar'}
          </button>
        </div>

        <p className="mt-3 text-xs text-panel-text-muted">
          Vence el {new Date(vence_en).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })}. No se volverá a
          mostrar: si se pierde, genera uno nuevo desde la lista.
        </p>

        <div className="mt-5 flex justify-end">
          <button type="button" onClick={onCerrar} className="rounded-full bg-panel-primary px-5 py-2 text-sm font-semibold text-white hover:bg-panel-primary-dark">
            Listo
          </button>
        </div>
      </div>
    </div>
  )
}
