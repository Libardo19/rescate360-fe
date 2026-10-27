import { api, USE_MOCK } from './api'
import type { Persona, DatosPersona, EstadoPersona } from '../types/persona'

// Datos de prueba inventados, SOLO para desarrollo de la interfaz.
let mock: Persona[] = [
  { id: '1', nombre: 'Mariana Ortiz', edad: 21, genero: 'femenino', ultimaUbicacion: 'Terminal de transporte', fechaDesaparicion: '2026-10-03', descripcion: 'Chaqueta negra, jeans azules y tenis blancos. Cabello largo y oscuro.', estado: 'buscando', actualizado: '2026-10-05T08:00:00' },
  { id: '2', nombre: 'Julián Pardo', edad: 32, genero: 'masculino', ultimaUbicacion: 'Barrio El Prado', fechaDesaparicion: '2026-10-02', descripcion: 'Camisa a cuadros, jeans y gorra gris. Lleva una mochila negra.', estado: 'buscando', actualizado: '2026-10-05T09:30:00' },
  { id: '3', nombre: 'Camila Fuentes', edad: 16, genero: 'femenino', ultimaUbicacion: 'Colegio, sector centro', fechaDesaparicion: '2026-10-04', descripcion: 'Uniforme escolar azul, mochila roja. Usa gafas.', estado: 'buscando', actualizado: '2026-10-05T10:10:00' },
  { id: '4', nombre: 'Ernesto Villa', edad: 67, genero: 'masculino', ultimaUbicacion: 'Vereda La Esperanza', fechaDesaparicion: '2026-10-01', descripcion: 'Adulto mayor con sombrero de paja y bastón. Necesita medicación diaria.', estado: 'buscando', actualizado: '2026-10-03T18:00:00' },
  { id: '5', nombre: 'Sofía Barrios', edad: 8, genero: 'femenino', ultimaUbicacion: 'Parque Central', fechaDesaparicion: '2026-09-29', descripcion: 'Vestido amarillo y sandalias. Cabello recogido en dos trenzas.', estado: 'encontrado', actualizado: '2026-09-30T12:00:00' },
  { id: '6', nombre: 'Andrés Cuello', edad: 28, genero: 'masculino', ultimaUbicacion: 'Vía Nacional km 3', fechaDesaparicion: '2026-10-04', descripcion: 'Camiseta blanca y pantalón oscuro. Conducía una moto roja.', estado: 'buscando', actualizado: '2026-10-05T07:45:00' },
  { id: '7', nombre: 'Lucía Montoya', edad: 45, genero: 'femenino', ultimaUbicacion: 'Mercado municipal', fechaDesaparicion: '2026-10-05', descripcion: 'Blusa verde y falda larga. Lleva una bolsa de tela.', estado: 'buscando', actualizado: '2026-10-05T11:00:00' },
]

export async function listarPersonas(): Promise<Persona[]> {
  if (USE_MOCK) return mock.map((p) => ({ ...p }))

  // BACKEND: confirmar la ruta real y la forma de la respuesta.
  return api<Persona[]>('/personas-desaparecidas')
}

export async function registrarPersona(datos: DatosPersona): Promise<Persona> {
  if (USE_MOCK) {
    const nueva: Persona = {
      ...datos,
      id: String(Date.now()),
      estado: 'buscando',
      actualizado: new Date().toISOString(),
    }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  // BACKEND: endpoint para registrar un caso nuevo (si el módulo lo permite al administrador).
  return api<Persona>('/personas-desaparecidas', { method: 'POST', body: JSON.stringify(datos) })
}

export async function actualizarEstadoPersona(id: string, estado: EstadoPersona): Promise<Persona> {
  if (USE_MOCK) {
    mock = mock.map((p) => (p.id === id ? { ...p, estado, actualizado: new Date().toISOString() } : p))
    const persona = mock.find((p) => p.id === id)
    if (!persona) throw new Error('Persona no encontrada')
    return { ...persona }
  }

  // BACKEND: endpoint para actualizar el estado (incluye marcar como encontrada).
  return api<Persona>(`/personas-desaparecidas/${id}/estado`, {
    method: 'PATCH',
    body: JSON.stringify({ estado }),
  })
}