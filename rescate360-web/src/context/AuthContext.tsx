import { createContext, useContext, useState, type ReactNode } from 'react'
import type { Usuario } from '../types/auth'

interface AuthState {
  usuario: Usuario | null
  iniciarSesion: (token: string, usuario: Usuario) => void
  cerrarSesion: () => void
}

const AuthContext = createContext<AuthState | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(() => {
    const guardado = sessionStorage.getItem('usuario')
    return guardado ? (JSON.parse(guardado) as Usuario) : null
  })

  const iniciarSesion = (token: string, u: Usuario) => {
    sessionStorage.setItem('token', token)
    sessionStorage.setItem('usuario', JSON.stringify(u))
    setUsuario(u)
  }

  const cerrarSesion = () => {
    sessionStorage.removeItem('token')
    sessionStorage.removeItem('usuario')
    setUsuario(null)
  }

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