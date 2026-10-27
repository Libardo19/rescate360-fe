export type EstadoPersona = 'en_busqueda' | 'en_proceso' | 'encontrada'
export type Genero = 'femenino' | 'masculino' | 'otro'

export interface Persona {
  id: string
  nombre: string
  edad: number
  genero: Genero
  ultimaUbicacion: string
  fechaDesaparicion: string // formato AAAA-MM-DD
  descripcion: string
  estado: EstadoPersona
  actualizado: string // formato ISO, última novedad del caso
}

export type DatosPersona = Pick<
  Persona,
  'nombre' | 'edad' | 'genero' | 'ultimaUbicacion' | 'fechaDesaparicion' | 'descripcion'
>