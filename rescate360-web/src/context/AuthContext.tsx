import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import type { LoginResponse, Usuario } from '../types/auth'
import { borrarTokens, guardarTokens, registrarAlExpirarSesion } from '../services/api'

interface AuthState {
  usuario: Usuario | null
  iniciarSesion: (sesion: LoginResponse) => void
  cerrarSesion: () => void
}

const AuthContext = createContext<AuthState | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(() => {
    const guardado = sessionStorage.getItem('usuario')
    return guardado ? (JSON.parse(guardado) as Usuario) : null
  })

  const iniciarSesion = ({ access_token, refresh_token, usuario: u }: LoginResponse) => {
    guardarTokens(access_token, refresh_token)
    sessionStorage.setItem('usuario', JSON.stringify(u))
    setUsuario(u)
  }

  const cerrarSesion = () => {
    borrarTokens()
    sessionStorage.removeItem('usuario')
    setUsuario(null)
  }

  // Si el token vence y no se puede renovar, api.ts avisa y la sesión se cierra
  // (ProtectedRoute lleva al login).
  useEffect(() => {
    registrarAlExpirarSesion(() => {
      sessionStorage.removeItem('usuario')
      setUsuario(null)
    })
  }, [])

  return (
    <AuthContext.Provider value={{ usuario, iniciarSesion, cerrarSesion }}>
      {children}
    </AuthContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de AuthProvider')
  return ctx
}
