const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8000'

export const USE_MOCK = import.meta.env.VITE_USE_MOCK !== 'false'

// BACKEND: todas las llamadas reales pasan por aquí.
// Aquí se agrega el token de autenticación a cada petición.
export async function api<T>(ruta: string, opciones: RequestInit = {}): Promise<T> {
  const token = sessionStorage.getItem('token')
  const respuesta = await fetch(`${API_URL}${ruta}`, {
    ...opciones,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...opciones.headers,
    },
  })

  if (!respuesta.ok) {
    throw new Error(`Error ${respuesta.status}`)
  }
  return respuesta.json() as Promise<T>
}