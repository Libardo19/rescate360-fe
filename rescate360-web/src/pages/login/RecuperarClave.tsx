import { useState, type FormEvent } from 'react'
import { X } from 'lucide-react'
import { pedirCodigoRecuperacion, restablecerContrasena } from '../../services/auth.service'
import { mensajeDeError } from '../../services/api'
import type { CanalRecuperacion, LoginResponse } from '../../types/auth'

const campo =
  'mt-1 min-h-10 w-full rounded-lg border border-slate-400 px-3 py-2 text-base text-slate-900 outline-none placeholder:text-slate-500 focus:border-navy-800 focus:ring-2 focus:ring-navy-800/30'

interface Props {
  emailInicial: string
  onCerrar: () => void
  // Contraseña cambiada: el backend ya devuelve la sesión abierta
  onListo: (sesion: LoginResponse) => void
}

// Dos pasos: 1) correo + por dónde quiere el código (SMS o correo); 2) código + contraseña nueva.
export default function RecuperarClave({ emailInicial, onCerrar, onListo }: Props) {
  const [paso, setPaso] = useState<1 | 2>(1)
  const [email, setEmail] = useState(emailInicial)
  const [canal, setCanal] = useState<CanalRecuperacion>('sms')
  const [codigo, setCodigo] = useState('')
  const [clave, setClave] = useState('')
  const [confirmacion, setConfirmacion] = useState('')
  const [aviso, setAviso] = useState('')
  const [error, setError] = useState('')
  const [enviando, setEnviando] = useState(false)

  const pedirCodigo = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    setEnviando(true)
    try {
      setAviso(await pedirCodigoRecuperacion(email.trim().toLowerCase(), canal))
      setPaso(2)
    } catch (err) {
      setError(mensajeDeError(err))
    } finally {
      setEnviando(false)
    }
  }

  const cambiarClave = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    if (clave.length < 8) return setError('La contraseña debe tener al menos 8 caracteres.')
    if (clave !== confirmacion) return setError('Las contraseñas no coinciden.')
    setEnviando(true)
    try {
      onListo(await restablecerContrasena(email.trim().toLowerCase(), codigo, clave))
    } catch (err) {
      setError(mensajeDeError(err))
    } finally {
      setEnviando(false)
    }
  }

  return (
    <div className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6" onClick={onCerrar}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="titulo-recuperar"
        className="w-full max-w-md rounded-2xl bg-white p-6 text-slate-900 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <h2 id="titulo-recuperar" className="text-xl font-extrabold text-navy-900">
            Recuperar contraseña
          </h2>
          <button type="button" onClick={onCerrar} aria-label="Cerrar">
            <X size={20} />
          </button>
        </div>

        {paso === 1 ? (
          <form onSubmit={pedirCodigo} className="mt-4 space-y-4">
            <div>
              <label htmlFor="rec-email" className="text-sm font-medium text-slate-700">
                Correo de tu cuenta
              </label>
              <input id="rec-email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} className={campo} />
            </div>
            <fieldset>
              <legend className="text-sm font-medium text-slate-700">¿Dónde quieres recibir el código?</legend>
              <div className="mt-2 grid grid-cols-2 gap-2">
                {(
                  [
                    ['sms', 'SMS a mi celular'],
                    ['correo', 'Correo electrónico'],
                  ] as const
                ).map(([valor, etiqueta]) => (
                  <label
                    key={valor}
                    className={`flex cursor-pointer items-center gap-2 rounded-lg border px-3 py-2 text-sm ${
                      canal === valor ? 'border-navy-800 bg-navy-900/5 font-semibold' : 'border-slate-300'
                    }`}
                  >
                    <input type="radio" name="canal" value={valor} checked={canal === valor} onChange={() => setCanal(valor)} className="accent-navy-900" />
                    {etiqueta}
                  </label>
                ))}
              </div>
            </fieldset>
            {error && <p role="alert" className="rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-800">{error}</p>}
            <button type="submit" disabled={enviando} className="min-h-11 w-full rounded-lg bg-navy-900 font-semibold text-white hover:bg-navy-800 disabled:opacity-60">
              {enviando ? 'Enviando…' : 'Enviar código'}
            </button>
          </form>
        ) : (
          <form onSubmit={cambiarClave} className="mt-4 space-y-4">
            <p role="status" className="rounded-lg bg-amber-50 px-3 py-2 text-sm text-amber-950">
              {aviso} El código vence en 15 minutos.
            </p>
            <div>
              <label htmlFor="rec-codigo" className="text-sm font-medium text-slate-700">
                Código
              </label>
              <input
                id="rec-codigo"
                required
                autoComplete="one-time-code"
                placeholder="XXXX-XXXX"
                value={codigo}
                onChange={(e) => setCodigo(e.target.value.toUpperCase())}
                className={`${campo} font-mono tracking-widest`}
              />
            </div>
            <div>
              <label htmlFor="rec-clave" className="text-sm font-medium text-slate-700">
                Contraseña nueva
              </label>
              <input id="rec-clave" type="password" autoComplete="new-password" required value={clave} onChange={(e) => setClave(e.target.value)} className={campo} />
            </div>
            <div>
              <label htmlFor="rec-confirmacion" className="text-sm font-medium text-slate-700">
                Repite la contraseña
              </label>
              <input
                id="rec-confirmacion"
                type="password"
                autoComplete="new-password"
                required
                value={confirmacion}
                onChange={(e) => setConfirmacion(e.target.value)}
                className={campo}
              />
            </div>
            {error && <p role="alert" className="rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-800">{error}</p>}
            <div className="flex gap-2">
              <button type="button" onClick={() => setPaso(1)} className="min-h-11 flex-1 rounded-lg border border-slate-300 text-sm">
                Pedir otro código
              </button>
              <button type="submit" disabled={enviando} className="min-h-11 flex-1 rounded-lg bg-navy-900 font-semibold text-white hover:bg-navy-800 disabled:opacity-60">
                {enviando ? 'Guardando…' : 'Cambiar contraseña'}
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  )
}
