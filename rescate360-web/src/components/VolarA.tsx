import { useEffect } from 'react'
import { useMap } from 'react-leaflet'

export default function VolarA({ lat, lng, zoom = 15 }: { lat?: number; lng?: number; zoom?: number }) {
  const map = useMap()

  useEffect(() => {
    if (lat !== undefined && lng !== undefined) map.flyTo([lat, lng], zoom)
  }, [lat, lng, zoom, map])

  return null
}