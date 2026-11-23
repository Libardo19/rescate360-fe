// Color y tamaño de un sismo según su magnitud: los comparten la página de Sismos y el mapa
export const colorMagnitud = (m: number) => (m >= 6 ? '#b91c1c' : m >= 4.5 ? '#ea580c' : m >= 2.5 ? '#f59e0b' : '#a3a3a3')

export const radioMagnitud = (m: number) => Math.max(4, Math.min(22, 3 + m * 2.6))
