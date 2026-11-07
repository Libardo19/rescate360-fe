import { useEffect, useMemo, useState } from 'react'
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { FileWarning, LifeBuoy, Building2 } from 'lucide-react'
import { listarPuntosMapa } from '../../services/mapa.service'
import CabeceraPanel from '../../components/panel/CabeceraPanel'
import type { PuntoMapa, TipoPunto } from '../../types/mapa'

const CENTRO_INICIAL: [number, number] = [10.4631, -73.2532]

const config: Record<TipoPunto, { etiqueta: string; color: string }> = {
  reporte: { etiqueta: 'Reportes', color: '#e5534b' },
  solicitud: { etiqueta: 'Solicitudes', color: '#3e7bfa' },
  centro: { etiqueta: 'Centros de ayuda', color: '#2fa96b' },
}

const tipos = Object.keys(config) as TipoPunto[]

export default function MapaPage() {
  const [puntos, setPuntos] = useState<PuntoMapa[] | null>(null)
  const [error, setError] = useState('')
  const [visibles, setVisibles] = useState<Record<TipoPunto, boolean>>({
    reporte: true,
    solicitud: true,
    centro: true,
  })

  useEffect(() => {
    listarPuntosMapa()
      .then(setPuntos)
      .catch(() => setError('No se pudo cargar el mapa.'))
  }, [])

  const cantidades = useMemo(() => {
    const total: Record<TipoPunto, number> = { reporte: 0, solicitud: 0, centro: 0 }
    puntos?.forEach((p) => {
      total[p.tipo] += 1
    })
    return total
  }, [puntos])

  if (error) return <p className="text-panel-accent">{error}</p>
  if (!puntos) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <CabeceraPanel
        seccion="Operación"
        titulo="Mapa operativo"
        descripcion="Ubicación de reportes, solicitudes y centros de ayuda. Pulsa un punto para ver sus datos."
        estadisticas={[
          { titulo: 'Reportes', valor: cantidades.reporte, icono: FileWarning, pie: 'Puntos en el mapa' },
          { titulo: 'Solicitudes', valor: cantidades.solicitud, icono: LifeBuoy, pie: 'Puntos en el mapa' },
          { titulo: 'Centros de ayuda', valor: cantidades.centro, icono: Building2, pie: 'Puntos en el mapa' },
        ]}
      />

      <div className="flex flex-wrap gap-2">
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
          {puntos
            .filter((p) => visibles[p.tipo])
            .map((p) => (
              <CircleMarker
                key={p.id}
                center={[p.lat, p.lng]}
                radius={10}
                pathOptions={{
                  color: '#ffffff',
                  weight: 2,
                  fillColor: config[p.tipo].color,
                  fillOpacity: 0.95,
                }}
              >
                <Popup>
                  <p className="font-bold">{p.titulo}</p>
                  <p>{p.detalle}</p>
                  <p className="mt-1 text-xs">
                    {config[p.tipo].etiqueta.slice(0, -1)} · {p.estado}
                  </p>
                </Popup>
              </CircleMarker>
            ))}
        </MapContainer>
      </div>
    </div>
  )
}