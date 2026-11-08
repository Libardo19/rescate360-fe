// SOLO para los datos de prueba: las fechas de los mocks se escribieron alrededor de esta hora.
// Se desplazan para que el registro más reciente quede "hace unos minutos" respecto al momento actual,
// manteniendo la distancia entre registros. Así el semáforo de espera y el briefing muestran casos realistas.
const BASE = new Date('2026-10-05T10:30:00').getTime()
const DESFASE = Date.now() - BASE

export const desplazar = (iso: string) => new Date(new Date(iso).getTime() + DESFASE).toISOString()

export function desplazarFechas<T>(lista: T[], campo: keyof T): T[] {
  return lista.map((x) => ({ ...x, [campo]: desplazar(x[campo] as unknown as string) }))
}
