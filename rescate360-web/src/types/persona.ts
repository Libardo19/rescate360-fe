// Contrato del backend (app/schemas/personas_desaparecidas_schema.py)
export type EstadoPersona = 'buscando' | 'encontrado'
export type Genero = 'femenino' | 'masculino' | 'otro'

export interface PersonaApi {
  id: string
  nombre: string
  edad: number | null
  sexo: string | null
  estatura: string | null
  fecha_vista: string | null
  lugar: string | null
  descripcion: string
  senas_particulares: string | null
  vestimenta: string | null
  estado: EstadoPersona
  es_menor: boolean
  foto_url: string | null
  foto_oculta: boolean
  ubicacion: { lat: number; lng: number } | null
  contacto_nombre: string | null
  contacto_telefono: string | null
  es_mia: boolean
  puede_gestionar: boolean
  aviso?: string | null
  encontrado_en?: string | null
  creado_en: string
  actualizado_en: string
}

// Lo que usa la pantalla de DesaparecidosPage
export interface Persona {
  id: string
  nombre: string
  edad: number
  genero: Genero
  ultimaUbicacion: string
  fechaDesaparicion: string
  descripcion: string
  estado: EstadoPersona
  actualizado: string
  fotoUrl?: string | null
  contactoNombre?: string | null
  contactoTelefono?: string | null
}

export type DatosPersona = Omit<Persona, 'id' | 'estado' | 'actualizado'>
