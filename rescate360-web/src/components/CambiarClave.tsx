import { useState, type FormEvent } from 'react'
import { X } from 'lucide-react'
import { api, mensajeDeError } from '../services/api'

const campo =
  'mt-1 w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

// PATCH /usuarios/me/password: pide la contraseña actual
export default function CambiarClave({ onCerrar }: { onCerrar: () => void }) {
  const [actual, setActual] = useState('')
  const [nueva, setNueva] = useState('')
  const [confirmacion, setConfirmacion] = useState('')
  const [error, setError] = useState('')
  const [listo, setListo] = useState(false)
  const [guardando, setGuardando] = useState(false)

  const guardar = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    if (nueva.length < 8) return setError('La contraseña nueva debe tener al menos 8 caracteres.')
    if (nueva !== confirmacion) return setError('Las contraseñas no coinciden.')
    setGuardando(true)
    try {
      await api<void>('/usuarios/me/password', {
        method: 'PATCH',
        body: JSON.stringify({ password_actual: actual, password_nueva: nueva }),
      })
      setListo(true)
    } catch (err) {
      setError(mensajeDeError(err, 'No se pudo cambiar la contraseña.'))
    } finally {
      setGuardando(false)
    }
  }

  return (
    <div className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6" onClick={onCerrar}>
      <form
        onSubmit={guardar}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-clave"
        className="panel-modal-enter my-auto w-full max-w-sm rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <h2 id="titulo-clave" className="text-xl font-semibold tracking-[-0.02em]">
            Cambiar contraseña
          </h2>
          <button type="button" onClick={onCerrar} aria-label="Cerrar">
            <X size={20} />
          </button>
        </div>

        {listo ? (
          <>
            <p className="mt-4 rounded-2xl bg-green-50 px-3 py-2 text-sm text-green-800">Tu contraseña cambió.</p>
            <button type="button" onClick={onCerrar} className="mt-5 w-full rounded-full bg-panel-primary py-2 text-sm font-semibold text-white">
              Listo
            </button>
          </>
        ) : (
          <>
            <div className="mt-4 space-y-3">
              <label className="block text-sm font-medium">
                Contraseña actual
                <input type="password" autoComplete="current-password" required value={actual} onChange={(e) => setActual(e.target.value)} className={campo} />
              </label>
              <label className="block text-sm font-medium">
                Contraseña nueva
                <input type="password" autoComplete="new-password" required value={nueva} onChange={(e) => setNueva(e.target.value)} className={campo} />
              </label>
              <label className="block text-sm font-medium">
                Repite la contraseña nueva
                <input
                  type="password"
                  autoComplete="new-password"
                  required
                  value={confirmacion}
                  onChange={(e) => setConfirmacion(e.target.value)}
                  className={campo}
                />
              </label>
            </div>
            {error && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
            <button
              type="submit"
              disabled={guardando}
              className="mt-5 w-full rounded-full bg-panel-primary py-2 text-sm font-semibold text-white hover:bg-panel-primary-dark disabled:opacity-60"
            >
              {guardando ? 'Guardando…' : 'Cambiar contraseña'}
            </button>
          </>
        )}
      </form>
    </div>
  )
}
