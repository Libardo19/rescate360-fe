import { useEffect, useMemo, useRef, useState } from 'react'
import { MapContainer, TileLayer, CircleMarker, Circle, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { RefreshCw } from 'lucide-react'
import { obtenerMapa } from '../../services/mapa.service'
import { mensajeDeError } from '../../services/api'
import type { PuntoMapa, TipoPunto } from '../../types/mapa'

const CENTRO_INICIAL: [number, number] = [10.4631, -73.2532]
// Cada cuánto se pregunta al backend qué cambió (polling con `desde`)
const INTERVALO_MS = 15_000

const config: Record<TipoPunto, { etiqueta: string; color: string }> = {
  reporte: { etiqueta: 'Reportes', color: '#e5534b' },
  solicitud: { etiqueta: 'Solicitudes', color: '#3e7bfa' },
  centro: { etiqueta: 'Centros de ayuda', color: '#2fa96b' },
  zona: { etiqueta: 'Zonas peligrosas', color: '#f5a524' },
  alerta: { etiqueta: 'Alertas', color: '#9333ea' },
}

const tipos = Object.keys(config) as TipoPunto[]

const horaCorta = (iso: string) => new Date(iso).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit', second: '2-digit' })

export default function MapaPage() {
  // Los puntos se guardan por id: cada consulta de polling reemplaza los que cambiaron
  const [puntos, setPuntos] = useState<Map<string, PuntoMapa> | null>(null)
  const [error, setError] = useState('')
  const [ultima, setUltima] = useState('')
  const desde = useRef<string | undefined>(undefined)
  const [visibles, setVisibles] = useState<Record<TipoPunto, boolean>>({
    reporte: true,
    solicitud: true,
    centro: true,
    zona: true,
    alerta: true,
  })

  useEffect(() => {
    let vivo = true

    const actualizar = async () => {
      // Con la pestaña oculta no se consulta: ahorra peticiones
      if (document.hidden && desde.current) return
      try {
        const respuesta = await obtenerMapa(desde.current)
        if (!vivo) return
        desde.current = respuesta.generado_en
        setUltima(respuesta.generado_en)
        setError('')
        setPuntos((anteriores) => {
          const siguientes = new Map(anteriores ?? [])
          for (const p of respuesta.puntos) {
            if (p.activo) siguientes.set(p.id, p)
            else siguientes.delete(p.id) // se cerró: sale del mapa
          }
          return siguientes
        })
      } catch (e) {
        if (vivo) setError(mensajeDeError(e, 'No se pudo cargar el mapa.'))
      }
    }

    actualizar()
    const intervalo = setInterval(actualizar, INTERVALO_MS)
    return () => {
      vivo = false
      clearInterval(intervalo)
    }
  }, [])

  const lista = useMemo(() => [...(puntos?.values() ?? [])], [puntos])

  const cantidades = useMemo(() => {
    const total: Record<TipoPunto, number> = { reporte: 0, solicitud: 0, centro: 0, zona: 0, alerta: 0 }
    lista.forEach((p) => {
      total[p.capa] += 1
    })
    return total
  }, [lista])

  if (error && !puntos) return <p className="text-panel-accent">{error}</p>
  if (!puntos) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-panel-primary">Mapa operativo</h1>
          <p className="mt-1 text-sm text-panel-text-soft">
            Reportes, solicitudes y centros de ayuda en vivo. Pulsa un punto para ver sus datos.
          </p>
        </div>
        <p className="flex items-center gap-1 text-xs text-panel-text-muted" role="status">
          <RefreshCw size={12} /> Se actualiza cada 15 s{ultima && ` · última: ${horaCorta(ultima)}`}
        </p>
      </div>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-5 flex flex-wrap gap-2">
        {tipos.map((tipo) => (
          <button
            key={tipo}
            onClick={() => setVisibles((v) => ({ ...v, [tipo]: !v[tipo] }))}
            className={`flex items-center gap-2 rounded-full border px-4 py-2 text-sm transition ${
              visibles[tipo]
                ? 'border-panel-primary bg-panel-card font-semibold text-panel-text'
                : 'border-panel-border bg-panel-bg text-panel-text-muted'
            }`}
          >
            <span
              className="h-3 w-3 rounded-full"
              style={{ backgroundColor: visibles[tipo] ? config[tipo].color : '#cbd5e1' }}
            />
            {config[tipo].etiqueta} ({cantidades[tipo]})
          </button>
        ))}
      </div>

      <div className="relative z-0 mt-4 overflow-hidden rounded-2xl border border-panel-border">
        <MapContainer center={CENTRO_INICIAL} zoom={13} scrollWheelZoom className="h-[65vh] w-full">
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {lista
            .filter((p) => visibles[p.capa])
            .map((p) => {
              const estilo = { color: '#ffffff', weight: 2, fillColor: config[p.capa].color, fillOpacity: p.aproximada ? 0.55 : 0.95 }
              const popup = (
                <Popup>
                  <p className="font-bold">{p.titulo}</p>
                  <p>{p.detalle}</p>
                  <p className="mt-1 text-xs">
                    {config[p.capa].etiqueta.slice(0, -1)} · {p.estado.replace('_', ' ')}
                    {p.prioridad && ` · prioridad ${p.prioridad}`}
                  </p>
                  {p.aproximada && <p className="text-xs italic">Ubicación aproximada (otra organización)</p>}
                </Popup>
              )
              // Zonas y alertas se dibujan como círculo de radio real
              return p.radio_m ? (
                <Circle key={p.id} center={[p.lat, p.lng]} radius={p.radio_m} pathOptions={{ ...estilo, color: config[p.capa].color, fillOpacity: 0.2 }}>
                  {popup}
                </Circle>
              ) : (
                <CircleMarker key={p.id} center={[p.lat, p.lng]} radius={p.prioridad === 'critica' ? 13 : 10} pathOptions={estilo}>
                  {popup}
                </CircleMarker>
              )
            })}
        </MapContainer>
      </div>
    </div>
  )
}
