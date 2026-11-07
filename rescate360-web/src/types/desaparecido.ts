// Tabla `personas_desaparecidas` (modelo BD v2). No se restringe por organización:
// todos los administradores ven todos los casos.
export type EstadoCaso = 'buscando' | 'encontrado'

export interface PersonaDesaparecida {
  id: string
  nombre: string
  caracteristicas: string
  fotoUrl: string | null
  ultimaUbicacion: { lat: number; lng: number }
  // BACKEND: dirección legible de la última ubicación (geocodificación inversa), si se puede enviar.
  referenciaUbicacion?: string
  estadoCaso: EstadoCaso
  reportadoPor: string // nombre de quien lo reportó
  telefonoContacto?: string // teléfono de quien lo reportó
  creadoEn: string // formato ISO
}
