const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8000'

export const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

const CLAVE_ACCESS = 'access_token'
const CLAVE_REFRESH = 'refresh_token'

// Respuesta paginada del backend: {items, total, pagina, por_pagina}
export interface Pagina<T> {
  items: T[]
  total: number
  pagina: number
  por_pagina: number
}

// Error del contrato: {detalle, codigo} y, en los 422, la lista de campos con problema
export class ApiError extends Error {
  readonly status: number
  readonly codigo: string
  readonly errores: { campo: string; mensaje: string }[]

  constructor(status: number, detalle: string, codigo: string, errores: { campo: string; mensaje: string }[] = []) {
    super(detalle)
    this.status = status
    this.codigo = codigo
    this.errores = errores
  }
}

// Mensaje listo para mostrar: el del backend o uno genérico
export const mensajeDeError = (e: unknown, porDefecto = 'Ocurrió un error. Intenta de nuevo.') => {
  if (e instanceof ApiError) {
    const primero = e.errores[0]
    return primero ? `${e.message}: ${primero.campo} — ${primero.mensaje}` : e.message
  }
  return porDefecto
}

export const urlArchivo = (ruta: string) => (ruta.startsWith('http') ? ruta : `${API_URL}${ruta}`)

export function guardarTokens(access: string, refresh: string) {
  sessionStorage.setItem(CLAVE_ACCESS, access)
  sessionStorage.setItem(CLAVE_REFRESH, refresh)
}

export function borrarTokens() {
  sessionStorage.removeItem(CLAVE_ACCESS)
  sessionStorage.removeItem(CLAVE_REFRESH)
}

// Si el refresh también falla, la app cierra la sesión (lo registra AuthContext)
let alExpirarSesion: () => void = () => {}
export const registrarAlExpirarSesion = (fn: () => void) => {
  alExpirarSesion = fn
}

// Una sola renovación a la vez: si llegan varios 401 juntos, todos esperan la misma
let renovando: Promise<boolean> | null = null

async function renovarToken(): Promise<boolean> {
  const refresh = sessionStorage.getItem(CLAVE_REFRESH)
  if (!refresh) return false
  renovando ??= fetch(`${API_URL}/auth/refresh-token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: refresh }),
  })
    .then(async (r) => {
      if (!r.ok) return false
      const sesion = await r.json()
      guardarTokens(sesion.access_token, sesion.refresh_token)
      return true
    })
    .catch(() => false)
    .finally(() => {
      renovando = null
    })
  return renovando
}

async function leerError(respuesta: Response): Promise<ApiError> {
  try {
    const cuerpo = await respuesta.json()
    return new ApiError(respuesta.status, cuerpo.detalle ?? `Error ${respuesta.status}`, cuerpo.codigo ?? 'ERROR', cuerpo.errores)
  } catch {
    return new ApiError(respuesta.status, `Error ${respuesta.status}`, 'ERROR')
  }
}

// Todas las llamadas reales pasan por aquí: agrega el token, renueva la sesión ante un 401
// y convierte los errores del backend en ApiError.
export async function api<T>(ruta: string, opciones: RequestInit = {}, reintento = true): Promise<T> {
  const token = sessionStorage.getItem(CLAVE_ACCESS)
  const esFormulario = opciones.body instanceof FormData
  const respuesta = await fetch(`${API_URL}${ruta}`, {
    ...opciones,
    headers: {
      ...(esFormulario ? {} : { 'Content-Type': 'application/json' }),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...opciones.headers,
    },
  })

  if (respuesta.status === 401 && token && reintento) {
    if (await renovarToken()) return api<T>(ruta, opciones, false)
    borrarTokens()
    alExpirarSesion()
  }
  if (!respuesta.ok) throw await leerError(respuesta)
  if (respuesta.status === 204) return undefined as T
  return respuesta.json() as Promise<T>
}

// Arma "?a=1&b=2" ignorando los valores vacíos
export const consulta = (params: Record<string, string | number | boolean | null | undefined>) => {
  const p = new URLSearchParams()
  for (const [clave, valor] of Object.entries(params)) {
    if (valor !== undefined && valor !== null && valor !== '') p.set(clave, String(valor))
  }
  const texto = p.toString()
  return texto ? `?${texto}` : ''
}
