import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Persona, PersonaApi, DatosPersona, EstadoPersona, Genero } from '../types/persona'

export const aPersona = (p: PersonaApi): Persona => ({
  id: p.id,
  nombre: p.nombre,
  edad: p.edad ?? 0,
  genero: (p.sexo as Genero) ?? 'otro',
  ultimaUbicacion: p.lugar ?? 'Sin ubicación registrada',
  fechaDesaparicion: p.fecha_vista ? String(p.fecha_vista) : p.creado_en.slice(0, 10),
  descripcion: p.descripcion,
  estado: p.estado,
  actualizado: p.actualizado_en ?? p.creado_en,
  fotoUrl: p.foto_url,
  contactoNombre: p.contacto_nombre,
  contactoTelefono: p.contacto_telefono,
})

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
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

  const pagina = await api<Pagina<PersonaApi>>(`/personas-desaparecidas${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aPersona)
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

  // El backend exige multipart/form-data en POST /personas-desaparecidas
  const formData = new FormData()
  formData.append('nombre', datos.nombre)
  formData.append('edad', String(datos.edad))
  formData.append('sexo', datos.genero)
  formData.append('fecha_vista', datos.fechaDesaparicion)
  formData.append('lugar', datos.ultimaUbicacion)
  formData.append('descripcion', datos.descripcion)
  formData.append('contacto_nombre', 'Administración')
  formData.append('contacto_telefono', '+573001234567')

  const respuesta = await api<PersonaApi>('/personas-desaparecidas', {
    method: 'POST',
    body: formData,
  })
  return aPersona(respuesta)
}

export async function actualizarEstadoPersona(id: string, estado: EstadoPersona): Promise<Persona> {
  if (USE_MOCK) {
    mock = mock.map((p) => (p.id === id ? { ...p, estado, actualizado: new Date().toISOString() } : p))
    const persona = mock.find((p) => p.id === id)
    if (!persona) throw new Error('Persona no encontrada')
    return { ...persona }
  }

  const respuesta = await api<PersonaApi>(`/personas-desaparecidas/${id}/estado`, {
    method: 'PATCH',
    body: JSON.stringify({ estado }),
  })
  return aPersona(respuesta)
}
