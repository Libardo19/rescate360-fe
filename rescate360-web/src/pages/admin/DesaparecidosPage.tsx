import { useEffect, useMemo, useState } from 'react'
import { MapContainer, TileLayer, CircleMarker } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import { Search, MapPin, Clock, Phone, UserCheck, RotateCcw, Info } from 'lucide-react'
import { listarDesaparecidos, cambiarEstadoCaso } from '../../services/desaparecidos.service'
import type { EstadoCaso, PersonaDesaparecida } from '../../types/desaparecido'
import Modal from '../../components/panel/Modal'

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

// "hace 3 h", "hace 2 días"… para ver de un vistazo cuánto lleva abierto el caso.
function haceCuanto(iso: string) {
  const minutos = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60000))
  if (minutos < 60) return `hace ${minutos} min`
  const horas = Math.round(minutos / 60)
  if (horas < 24) return `hace ${horas} h`
  const dias = Math.round(horas / 24)
  return `hace ${dias} ${dias === 1 ? 'día' : 'días'}`
}

const iniciales = (nombre: string) =>
  nombre
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0])
    .join('')
    .toUpperCase()

function Foto({ persona, tamano }: { persona: PersonaDesaparecida; tamano: 'sm' | 'lg' }) {
  const clase = tamano === 'lg' ? 'h-24 w-24 text-2xl' : 'h-16 w-16 text-lg'
  if (persona.fotoUrl) {
    return <img src={persona.fotoUrl} alt={`Foto de ${persona.nombre}`} className={`${clase} shrink-0 rounded-2xl object-cover`} />
  }
  return (
    <span
      aria-hidden="true"
      className={`${clase} flex shrink-0 items-center justify-center rounded-2xl bg-navy-800 font-bold text-white`}
    >
      {iniciales(persona.nombre)}
    </span>
  )
}

export default function DesaparecidosPage() {
  const [personas, setPersonas] = useState<PersonaDesaparecida[] | null>(null)
  const [error, setError] = useState('')
  const [pestana, setPestana] = useState<EstadoCaso>('buscando')
  const [busqueda, setBusqueda] = useState('')
  const [seleccionada, setSeleccionada] = useState<PersonaDesaparecida | null>(null)
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarDesaparecidos()
      .then(setPersonas)
      .catch(() => setError('No se pudieron cargar los casos.'))
  }, [])

  const conteo = useMemo(
    () => ({
      buscando: personas?.filter((p) => p.estadoCaso === 'buscando').length ?? 0,
      encontrado: personas?.filter((p) => p.estadoCaso === 'encontrado').length ?? 0,
    }),
    [personas],
  )

  const visibles = useMemo(() => {
    const texto = busqueda.trim().toLowerCase()
    return (personas ?? [])
      .filter((p) => p.estadoCaso === pestana)
      .filter(
        (p) =>
          !texto ||
          p.nombre.toLowerCase().includes(texto) ||
          p.caracteristicas.toLowerCase().includes(texto) ||
          (p.referenciaUbicacion ?? '').toLowerCase().includes(texto),
      )
      // Los casos más recientes primero: las primeras horas son las más importantes.
      .sort((a, b) => b.creadoEn.localeCompare(a.creadoEn))
  }, [personas, pestana, busqueda])

  const cambiarEstado = async (estado: EstadoCaso) => {
    if (!seleccionada) return
    const pregunta =
      estado === 'encontrado'
        ? `¿Confirmas que ${seleccionada.nombre} fue encontrado(a)? El caso dejará de mostrarse como activo.`
        : `¿Reabrir la búsqueda de ${seleccionada.nombre}?`
    if (!window.confirm(pregunta)) return
    setGuardando(true)
    setError('')
    try {
      const actualizada = await cambiarEstadoCaso(seleccionada.id, estado)
      setPersonas((lista) => lista?.map((p) => (p.id === actualizada.id ? actualizada : p)) ?? null)
      setSeleccionada(null)
    } catch {
      setError('No se pudo actualizar el caso.')
    } finally {
      setGuardando(false)
    }
  }

  if (error && !personas) return <p className="text-panel-accent">{error}</p>
  if (!personas) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Personas desaparecidas</h1>
      <p className="mt-1 text-sm text-panel-text-soft">
        Casos reportados por la comunidad. Son visibles para todas las organizaciones.
      </p>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="inline-flex w-fit rounded-lg border border-panel-border bg-panel-card p-1 text-sm">
          {(['buscando', 'encontrado'] as const).map((p) => (
            <button
              key={p}
              onClick={() => setPestana(p)}
              className={`rounded-md px-4 py-1.5 font-medium transition ${
                pestana === p ? 'bg-panel-primary text-white' : 'text-panel-text-soft hover:text-panel-text'
              }`}
            >
              {p === 'buscando' ? `En búsqueda (${conteo.buscando})` : `Encontrados (${conteo.encontrado})`}
            </button>
          ))}
        </div>
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
          <input
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            placeholder="Buscar por nombre, características o lugar"
            className="w-full rounded-lg border border-panel-border bg-panel-card py-2 pl-9 pr-3 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20"
          />
        </div>
      </div>

      <div className="mt-5 grid gap-4 md:grid-cols-2 2xl:grid-cols-3">
        {visibles.length === 0 && (
          <p className="rounded-2xl border border-dashed border-panel-border bg-panel-card px-6 py-12 text-center text-panel-text-soft md:col-span-2 2xl:col-span-3">
            {busqueda
              ? 'Ningún caso coincide con la búsqueda.'
              : pestana === 'buscando'
                ? 'No hay casos de búsqueda activos.'
                : 'Todavía no hay casos cerrados.'}
          </p>
        )}
        {visibles.map((p) => (
          <button
            key={p.id}
            onClick={() => setSeleccionada(p)}
            className="flex gap-4 rounded-2xl border border-panel-border bg-panel-card p-5 text-left transition hover:border-panel-primary/40 hover:shadow-md active:scale-[0.99]"
          >
            <Foto persona={p} tamano="sm" />
            <div className="min-w-0 flex-1">
              <div className="flex items-start justify-between gap-2">
                <h2 className="font-bold leading-tight">{p.nombre}</h2>
                {p.estadoCaso === 'buscando' ? (
                  <span className="shrink-0 rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-700">
                    En búsqueda
                  </span>
                ) : (
                  <span className="shrink-0 rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-700">
                    Encontrado
                  </span>
                )}
              </div>
              <p className="mt-1 line-clamp-2 text-sm text-panel-text-soft">{p.caracteristicas}</p>
              <p className="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-xs text-panel-text-muted">
                <span className="flex items-center gap-1">
                  <Clock size={12} /> Reportado {haceCuanto(p.creadoEn)}
                </span>
                {p.referenciaUbicacion && (
                  <span className="flex items-center gap-1">
                    <MapPin size={12} /> {p.referenciaUbicacion}
                  </span>
                )}
              </p>
            </div>
          </button>
        ))}
      </div>

      {seleccionada && (
        <Modal titulo={seleccionada.nombre} subtitulo={`Reportado el ${formatearFecha(seleccionada.creadoEn)}`} onCerrar={() => setSeleccionada(null)} ancho="lg">
          <div className="mt-5 flex flex-col gap-5 sm:flex-row">
            <Foto persona={seleccionada} tamano="lg" />
            <dl className="min-w-0 flex-1 space-y-3 text-sm">
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Características</dt>
                <dd>{seleccionada.caracteristicas}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Reportado por</dt>
                <dd className="flex flex-wrap items-center gap-x-2">
                  {seleccionada.reportadoPor}
                  {seleccionada.telefonoContacto && (
                    <a
                      href={`tel:${seleccionada.telefonoContacto.replace(/\s/g, '')}`}
                      className="flex items-center gap-1 font-medium text-panel-primary hover:underline"
                    >
                      <Phone size={12} /> {seleccionada.telefonoContacto}
                    </a>
                  )}
                </dd>
              </div>
              <div>
                <dt className="text-xs uppercase text-panel-text-muted">Última ubicación conocida</dt>
                <dd>
                  {seleccionada.referenciaUbicacion ?? 'Sin referencia'}{' '}
                  <span className="text-xs tabular-nums text-panel-text-muted">
                    ({seleccionada.ultimaUbicacion.lat.toFixed(4)}, {seleccionada.ultimaUbicacion.lng.toFixed(4)})
                  </span>
                </dd>
              </div>
            </dl>
          </div>

          <div className="relative z-0 mt-5 overflow-hidden rounded-xl border border-panel-border">
            <MapContainer
              center={[seleccionada.ultimaUbicacion.lat, seleccionada.ultimaUbicacion.lng]}
              zoom={15}
              scrollWheelZoom={false}
              className="h-56 w-full"
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <CircleMarker
                center={[seleccionada.ultimaUbicacion.lat, seleccionada.ultimaUbicacion.lng]}
                radius={11}
                pathOptions={{ color: '#ffffff', weight: 3, fillColor: '#e5534b', fillOpacity: 0.95 }}
              />
            </MapContainer>
          </div>

          <p className="mt-4 flex gap-2 rounded-lg bg-panel-bg px-3 py-2 text-xs text-panel-text-soft">
            <Info size={14} className="mt-0.5 shrink-0" />
            Si hay indicios de desaparición forzada, el caso debe remitirse a la Fiscalía y a la Comisión de Búsqueda
            de Personas Desaparecidas.
          </p>

          <div className="mt-5 flex justify-end">
            {seleccionada.estadoCaso === 'buscando' ? (
              <button
                disabled={guardando}
                onClick={() => cambiarEstado('encontrado')}
                className="flex items-center gap-2 rounded-lg bg-panel-success px-5 py-2 text-sm font-semibold text-white transition hover:opacity-90 active:scale-[0.98] disabled:opacity-50"
              >
                <UserCheck size={16} /> Marcar como encontrado
              </button>
            ) : (
              <button
                disabled={guardando}
                onClick={() => cambiarEstado('buscando')}
                className="flex items-center gap-2 rounded-lg border border-panel-border px-5 py-2 text-sm font-semibold text-panel-text-soft transition hover:bg-panel-bg disabled:opacity-50"
              >
                <RotateCcw size={16} /> Reabrir búsqueda
              </button>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
