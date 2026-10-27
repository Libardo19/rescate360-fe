import { useState, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { Eye, EyeOff, ArrowLeft } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { login } from '../../services/auth.service'
import { ApiError, borrarTokens } from '../../services/api'
import { useAuth } from '../../context/AuthContext'
import fondoLogin from '../../assets/fondoLogin.png'
import RecuperarClave from './RecuperarClave'
import type { LoginResponse } from '../../types/auth'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [verClave, setVerClave] = useState(false)
  const [recordarme, setRecordarme] = useState(true)
  const [mensaje, setMensaje] = useState('')
  const [esError, setEsError] = useState(false)
  const [cargando, setCargando] = useState(false)
  const [recuperando, setRecuperando] = useState(false)
  const navigate = useNavigate()
  const { iniciarSesion } = useAuth()

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
      const sesion = await login({ email, password })
      const { rol } = sesion.usuario

      if (rol === 'administrador' || rol === 'super_admin') {
        iniciarSesion(sesion)
        navigate(rol === 'administrador' ? '/admin' : '/superadmin')
      } else {
        // Ciudadanos y voluntarios usan la app: no se guarda la sesión en el panel
        borrarTokens()
        setEsError(true)
        setMensaje('Tu cuenta es para la app móvil. Descarga la app de RESCATE360.')
      }
    } catch (error) {
      setEsError(true)
      // El backend explica el motivo: credenciales, cuenta bloqueada, sin activar u organización inactiva
      setMensaje(error instanceof ApiError ? error.message : 'No se pudo conectar con el servidor. Intenta de nuevo.')
    } finally {
      setCargando(false)
    }
  }

  const recuperarClave = () => {
    setMensaje('')
    setRecuperando(true)
  }

  // Tras cambiar la contraseña el backend ya devuelve la sesión: entra directo si es del panel
  const claveRecuperada = (sesion: LoginResponse) => {
    setRecuperando(false)
    const { rol } = sesion.usuario
    if (rol === 'administrador' || rol === 'super_admin') {
      iniciarSesion(sesion)
      navigate(rol === 'administrador' ? '/admin' : '/superadmin')
    } else {
      borrarTokens()
      setEsError(false)
      setMensaje('Tu contraseña cambió. Ingresa con ella en la app de RESCATE360.')
    }
  }

  return (
    <main
      className="relative isolate grid min-h-dvh place-items-center overflow-y-auto bg-cover bg-center px-4 py-5 sm:px-6 sm:py-8"
      style={{ backgroundImage: `url(${fondoLogin})` }}
    >
      <div className="absolute inset-0 -z-10 bg-gradient-to-r from-white/25 via-white/10 to-navy-950/35" />
      <div className="login-content-enter mx-auto grid w-full max-w-4xl items-center gap-5 sm:gap-8 lg:grid-cols-[minmax(0,1fr)_minmax(400px,440px)] lg:gap-8">
        <section className="flex flex-col items-center text-center">
          <img src="/logoRescate.png" alt="" className="h-20 w-auto drop-shadow-sm sm:h-24" />
          <h2 className="mt-3 text-3xl font-extrabold tracking-wide text-navy-900 sm:text-4xl">
            RESCATE<span className="text-brand">360</span>
          </h2>
          <p className="mt-2 text-base font-semibold text-navy-800 sm:text-lg">
            Juntos somos más fuertes
          </p>
        </section>

        <section className="w-full">
          <div className="rounded-2xl bg-white/95 p-6 text-slate-900 shadow-2xl shadow-navy-950/25 backdrop-blur-sm sm:p-7">
            <Link to="/" className="mb-3 inline-flex min-h-9 items-center gap-2 text-sm text-navy-800 underline-offset-4 transition hover:text-brand-dark hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-800">
              <ArrowLeft size={16} /> Volver al inicio
            </Link>

            <h1 className="text-[clamp(1.4rem,4vw,1.75rem)] font-extrabold leading-tight text-navy-900">Iniciar sesión</h1>
            <p className="mt-1 text-sm leading-relaxed text-slate-600">Acceso para administradores y organizaciones.</p>

            <form onSubmit={enviar} className="mt-4 space-y-3">
              <div>
                <label htmlFor="email" className="text-sm font-medium text-slate-700">
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
                  placeholder="tucorreo@ejemplo.com"
                  className="mt-1 min-h-10 w-full rounded-lg border border-slate-400 px-3 py-2 text-base text-slate-900 outline-none placeholder:text-slate-500 focus:border-navy-800 focus:ring-2 focus:ring-navy-800/30"
                />
              </div>

              <div>
                <label htmlFor="password" className="text-sm font-medium text-slate-700">
                  Contraseña
                </label>
                <div className="relative mt-1">
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
                    placeholder="Ingresa tu contraseña"
                    className="min-h-10 w-full rounded-lg border border-slate-400 px-3 py-2 pr-12 text-base text-slate-900 outline-none placeholder:text-slate-500 focus:border-navy-800 focus:ring-2 focus:ring-navy-800/30"
                  />
                  <button
                    type="button"
                    onClick={() => setVerClave(!verClave)}
                    aria-label={verClave ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                    className="absolute inset-y-0 right-0 px-3 text-slate-600 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-navy-800"
                  >
                    {verClave ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className="flex flex-wrap items-center justify-between gap-2 text-sm">
                <label className="flex items-center gap-2 text-slate-600">
                  <input
                    type="checkbox"
                    checked={recordarme}
                    onChange={(e) => setRecordarme(e.target.checked)}
                    className="h-4 w-4 accent-navy-900"
                  />
                  Recordarme
                </label>
                <button type="button" onClick={recuperarClave} className="font-medium text-brand underline-offset-4 hover:underline focus-visible:outline-2 focus-visible:outline-brand">
                  ¿Olvidaste tu contraseña?
                </button>
              </div>

              {mensaje && (
                <p
                  role={esError ? 'alert' : 'status'}
                  className={`rounded-lg px-3 py-2 text-sm leading-relaxed ${
                    esError ? 'bg-red-50 text-red-800' : 'bg-amber-50 text-amber-950'
                  }`}
                >
                  {mensaje}
                </p>
              )}

              <button
                type="submit"
                disabled={cargando}
                className="min-h-11 w-full rounded-lg bg-navy-900 py-2.5 font-semibold text-white transition hover:bg-navy-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-navy-900 disabled:opacity-60"
              >
                {cargando ? 'Ingresando…' : 'Iniciar sesión'}
              </button>
              <p className="pt-1 text-center text-sm text-slate-600">
                ¿No tienes cuenta?{' '}
                <a
                  href="#contacto-administrador"
                  className="font-semibold text-brand-dark underline-offset-4 hover:underline focus-visible:outline-2 focus-visible:outline-brand-dark"
                >
                  Contacta al administrador
                </a>
              </p>
            </form>
          </div>
        </section>
      </div>
      {recuperando && (
        <RecuperarClave emailInicial={email} onCerrar={() => setRecuperando(false)} onListo={claveRecuperada} />
      )}
    </main>
  )
}