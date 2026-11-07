import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion, useReducedMotion } from 'motion/react'
import { Eye, EyeOff, ArrowLeft, ArrowRight, Loader2, Moon, Sun, Lock } from 'lucide-react'
import { login } from '../../services/auth.service'
import { useAuth } from '../../context/AuthContext'
import EscudoPuntos from '../landing/components/EscudoPuntos'
import { Etiqueta, useTema } from '../landing/components/comunes'

const campo =
  'h-12 w-full rounded-2xl [@media(max-height:760px)]:h-11 border border-slate-200 bg-white px-4 text-[15px] text-navy-950 outline-none transition placeholder:text-slate-400 focus:border-navy-950 focus:ring-4 focus:ring-navy-950/10 dark:border-white/10 dark:bg-white/[0.04] dark:text-white dark:placeholder:text-white/30 dark:focus:border-white/40 dark:focus:ring-white/10'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [verClave, setVerClave] = useState(false)
  const [recordarme, setRecordarme] = useState(true)
  const [mensaje, setMensaje] = useState('')
  const [esError, setEsError] = useState(false)
  const [cargando, setCargando] = useState(false)
  const navigate = useNavigate()
  const { iniciarSesion } = useAuth()
  const { tema, alternar } = useTema()
  const reducir = useReducedMotion()

  const enviar = async (e: FormEvent) => {
    e.preventDefault()
    setMensaje('')
    setEsError(false)

    if (!email || !password) {
      setEsError(true)
      setMensaje('Ingresa tu correo y tu contraseña.')
      return
    }

    setCargando(true)

    try {
      const { token, usuario } = await login({ email, password })
      iniciarSesion(token, usuario)

      if (usuario.rol === 'administrador') navigate('/admin')
      else if (usuario.rol === 'super_admin') navigate('/superadmin')
      else {
        setEsError(true)
        setMensaje('Tu cuenta es para la app móvil. Descarga la app de RESCATE360.')
      }
    } catch {
      setEsError(true)
      setMensaje('Correo o contraseña incorrectos.')
    } finally {
      setCargando(false)
    }
  }

  const recuperarClave = () => {
    setEsError(false)
    setMensaje('La recuperación de contraseña estará disponible cuando se conecte el servicio de autenticación.')
  }

  const entrar = (retraso: number) => ({
    initial: reducir ? false : { opacity: 0, y: 12, filter: 'blur(6px)' },
    animate: { opacity: 1, y: 0, filter: 'blur(0px)' },
    transition: { duration: 0.6, delay: retraso, ease: [0.22, 1, 0.36, 1] as const },
  })

  return (
    <div
      data-tema={tema}
      className="grid h-dvh overflow-hidden bg-[#f6f7f9] font-display text-navy-950 antialiased transition-colors duration-500 lg:grid-cols-[1.05fr_1fr] dark:bg-[#060c19] dark:text-white"
    >
      {/* Panel de marca (solo pantallas grandes) */}
      <aside className="relative m-3 hidden min-h-0 flex-col justify-between gap-4 overflow-hidden rounded-[32px] bg-navy-950 p-8 text-white lg:flex xl:p-10">
        <div
          aria-hidden="true"
          className="absolute inset-0 opacity-[0.15] [background-image:radial-gradient(rgba(255,255,255,0.6)_1px,transparent_1px)] [background-size:20px_20px] [mask-image:radial-gradient(ellipse_at_center,black,transparent_75%)]"
        />
        <div aria-hidden="true" className="absolute -left-24 -top-24 h-96 w-96 rounded-full bg-panel-info/25 blur-3xl" />
        <div aria-hidden="true" className="absolute -bottom-32 -right-20 h-96 w-96 rounded-full bg-brand/25 blur-3xl" />

        <Link to="/" className="relative flex items-center gap-2.5" aria-label="RESCATE360, ir al inicio">
          <img src="/logoRescate.png" alt="" className="h-9 w-9" />
          <span className="text-2xl font-bold tracking-[-0.04em]">
            RESCATE<span className="text-brand">360</span>
          </span>
        </Link>

        <motion.div
          initial={reducir ? false : { opacity: 0, scale: 0.94 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1.2, ease: [0.22, 1, 0.36, 1] }}
          className="relative mx-auto w-full max-w-[min(400px,44dvh)]"
        >
          <EscudoPuntos oscuro />
        </motion.div>

        <div className="relative">
          <p className="font-mono text-[11px] uppercase tracking-[0.16em] text-white/45">Panel para organizaciones</p>
          <p className="mt-3 max-w-md text-4xl font-semibold leading-[1.02] tracking-[-0.035em] [@media(max-height:720px)]:text-3xl">
            Coordina la respuesta.
            <br />
            <span className="text-white/45">Desde un solo panel.</span>
          </p>
        </div>
      </aside>

      {/* Formulario */}
      <main className="flex h-dvh min-h-0 flex-col overflow-y-auto px-5 py-4 sm:px-10">
        <div className="flex items-center justify-between">
          <Link
            to="/"
            className="inline-flex items-center gap-2 rounded-full px-3 py-2 text-sm font-medium text-slate-600 transition hover:bg-white hover:text-navy-950 dark:text-white/60 dark:hover:bg-white/5 dark:hover:text-white"
          >
            <ArrowLeft size={16} /> Volver al inicio
          </Link>
          <button
            type="button"
            onClick={alternar}
            aria-label={tema === 'claro' ? 'Activar modo oscuro' : 'Activar modo claro'}
            className="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 bg-white/70 text-slate-600 transition hover:text-navy-950 dark:border-white/10 dark:bg-white/5 dark:text-white/70 dark:hover:text-white"
          >
            {tema === 'claro' ? <Moon size={16} /> : <Sun size={16} />}
          </button>
        </div>

        <div className="flex flex-1 items-center justify-center py-4">
          <div className="w-full max-w-sm">
            {/* Marca en móvil */}
            <motion.div {...entrar(0)} className="mb-6 flex items-center gap-2.5 lg:hidden [@media(max-height:700px)]:mb-4">
              <img src="/logoRescate.png" alt="" className="h-9 w-9" />
              <span className="text-2xl font-bold tracking-[-0.04em]">
                RESCATE<span className="text-brand">360</span>
              </span>
            </motion.div>

            <motion.div {...entrar(0.05)}>
              <Etiqueta>Acceso al panel</Etiqueta>
              <h1 className="mt-3 text-4xl font-semibold leading-[1.05] tracking-[-0.035em] [@media(max-height:760px)]:text-3xl">Bienvenido de nuevo.</h1>
              <p className="mt-2 text-[15px] text-slate-600 dark:text-white/55">Ingresa con la cuenta de tu organización.</p>
            </motion.div>

            <motion.form {...entrar(0.15)} onSubmit={enviar} className="mt-7 space-y-4 [@media(max-height:760px)]:mt-5 [@media(max-height:760px)]:space-y-3" noValidate>
              <div>
                <label htmlFor="email" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-white/75">
                  Correo electrónico
                </label>
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value)
                    setMensaje('')
                  }}
                  placeholder="tucorreo@organizacion.org"
                  className={campo}
                />
              </div>

              <div>
                <label htmlFor="password" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-white/75">
                  Contraseña
                </label>
                <div className="relative">
                  <input
                    id="password"
                    type={verClave ? 'text' : 'password'}
                    autoComplete="current-password"
                    required
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value)
                      setMensaje('')
                    }}
                    placeholder="Tu contraseña"
                    className={`${campo} pr-12`}
                  />
                  <button
                    type="button"
                    onClick={() => setVerClave(!verClave)}
                    aria-label={verClave ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                    className="absolute inset-y-0 right-0 flex w-12 items-center justify-center rounded-r-2xl text-slate-500 transition hover:text-navy-950 dark:text-white/50 dark:hover:text-white"
                  >
                    {verClave ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className="flex flex-wrap items-center justify-between gap-2 text-sm">
                <label className="flex cursor-pointer items-center gap-2 text-slate-600 dark:text-white/60">
                  <input
                    type="checkbox"
                    checked={recordarme}
                    onChange={(e) => setRecordarme(e.target.checked)}
                    className="h-4 w-4 rounded accent-navy-950 dark:accent-white"
                  />
                  Recordarme
                </label>
                <button
                  type="button"
                  onClick={recuperarClave}
                  className="font-medium text-brand underline-offset-4 hover:underline"
                >
                  ¿Olvidaste tu contraseña?
                </button>
              </div>

              {mensaje && (
                <motion.p
                  initial={{ opacity: 0, y: -4 }}
                  animate={{ opacity: 1, y: 0 }}
                  role={esError ? 'alert' : 'status'}
                  className={`rounded-2xl px-4 py-3 text-sm leading-relaxed ${
                    esError
                      ? 'bg-red-50 text-red-800 dark:bg-red-500/10 dark:text-red-200'
                      : 'bg-amber-50 text-amber-900 dark:bg-amber-400/10 dark:text-amber-100'
                  }`}
                >
                  {mensaje}
                </motion.p>
              )}

              <button
                type="submit"
                disabled={cargando}
                className="group flex h-12 w-full items-center [@media(max-height:760px)]:h-11 justify-center gap-2 rounded-full bg-navy-950 text-[15px] font-semibold text-white transition hover:bg-navy-800 active:scale-[0.99] disabled:cursor-wait disabled:opacity-80 dark:bg-white dark:text-navy-950 dark:hover:bg-white/90"
              >
                {cargando ? (
                  <>
                    <Loader2 size={18} className="animate-spin" /> Ingresando…
                  </>
                ) : (
                  <>
                    Ingresar
                    <ArrowRight size={16} className="transition-transform group-hover:translate-x-0.5" />
                  </>
                )}
              </button>

              <p className="pt-1 text-center text-sm text-slate-500 dark:text-white/45">
                <Lock size={13} className="mr-1 inline -translate-y-px" />
                ¿Sin cuenta? Pide acceso al administrador de tu organización.
              </p>
            </motion.form>
          </div>
        </div>

        <p className="text-center font-mono text-[11px] uppercase tracking-[0.12em] text-slate-400 dark:text-white/30">
          © 2026 RESCATE360 · Emergencias <a href="tel:123" className="text-brand">123</a>
        </p>
      </main>
    </div>
  )
}
