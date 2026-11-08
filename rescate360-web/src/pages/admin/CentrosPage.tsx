import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { useSearchParams } from 'react-router-dom'
import { MapContainer, TileLayer, CircleMarker, Popup, useMap } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import {
  House,
  Users,
  Utensils,
  HeartPulse,
  Package,
  Search,
  Plus,
  Pencil,
  Power,
  MapPin,
  X,
  type LucideIcon,
} from 'lucide-react'
import { listarCentros, crearCentro, actualizarCentro } from '../../services/centros.service'
import CabeceraPanel, { botonCabeceraPrincipal } from '../../components/panel/CabeceraPanel'
import type { Centro, DatosCentro, EstadoCentro, TipoCentro } from '../../types/centro'

const CENTRO_MAPA: [number, number] = [10.4631, -73.2532]

const tipos: Record<TipoCentro, { etiqueta: string; icono: LucideIcon; clase: string; color: string }> = {
  albergue: { etiqueta: 'Albergue', icono: House, clase: 'bg-blue-100 text-blue-600', color: '#3e7bfa' },
  comedor: { etiqueta: 'Comedor', icono: Utensils, clase: 'bg-orange-100 text-orange-600', color: '#f59e0b' },
  puesto_medico: { etiqueta: 'Puesto médico', icono: HeartPulse, clase: 'bg-violet-100 text-violet-600', color: '#7c5cd6' },
  centro_acopio: { etiqueta: 'Centro de acopio', icono: Package, clase: 'bg-red-100 text-red-600', color: '#e5534b' },
}

const estados: Record<EstadoCentro, { etiqueta: string; clase: string }> = {
  activo: { etiqueta: 'Activo', clase: 'bg-green-100 text-green-700' },
  en_operacion: { etiqueta: 'En operación', clase: 'bg-amber-100 text-amber-700' },
  inactivo: { etiqueta: 'Inactivo', clase: 'bg-slate-200 text-slate-600' },
}

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

interface FormCentro {
  nombre: string
  tipo: TipoCentro
  ubicacion: string
  estado: EstadoCentro
  lat: string
  lng: string
}

const formVacio: FormCentro = {
  nombre: '',
  tipo: 'albergue',
  ubicacion: '',
  estado: 'activo',
  lat: String(CENTRO_MAPA[0]),
  lng: String(CENTRO_MAPA[1]),
}

type Modal = { modo: 'crear' } | { modo: 'editar'; centro: Centro } | null

// Mueve el mapa hacia el centro seleccionado.
function VolarA({ centro }: { centro: Centro | null }) {
  const map = useMap()
  useEffect(() => {
    if (centro) map.flyTo([centro.lat, centro.lng], 15)
  }, [centro, map])
  return null
}

export default function CentrosPage() {
  const [centros, setCentros] = useState<Centro[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroTipo, setFiltroTipo] = useState<'todos' | TipoCentro>('todos')
  const [enfocado, setEnfocado] = useState<Centro | null>(null)
    // ?accion=nueva abre el formulario directamente (desde la paleta de comandos o el Inicio).
  const [params, setParams] = useSearchParams()
  const abrirDesdeUrl = params.get('accion') === 'nueva'
  useEffect(() => {
    if (abrirDesdeUrl) setParams({}, { replace: true })
  }, [abrirDesdeUrl, setParams])
  const [modal, setModal] = useState<Modal>(abrirDesdeUrl ? { modo: 'crear' } : null)
  const [form, setForm] = useState<FormCentro>(formVacio)
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarCentros()
      .then(setCentros)
      .catch(() => setError('No se pudieron cargar los centros.'))
  }, [])

  const filtrados = useMemo(() => {
    if (!centros) return []
    const texto = busqueda.trim().toLowerCase()
    return centros.filter((c) => {
      const coincideTexto =
        !texto ||
        c.nombre.toLowerCase().includes(texto) ||
        c.ubicacion.toLowerCase().includes(texto) ||
        tipos[c.tipo].etiqueta.toLowerCase().includes(texto)
      const coincideTipo = filtroTipo === 'todos' || c.tipo === filtroTipo
      return coincideTexto && coincideTipo
    })
  }, [centros, busqueda, filtroTipo])

  const resumen = useMemo(() => {
    const disponibles = (centros ?? []).filter((c) => c.estado !== 'inactivo')
    const cuenta = (t: TipoCentro) => disponibles.filter((c) => c.tipo === t).length
    return {
      activos: disponibles.length,
      albergues: cuenta('albergue'),
      comedores: cuenta('comedor'),
      medicos: cuenta('puesto_medico'),
    }
  }, [centros])

  const abrirCrear = () => {
    setForm(formVacio)
    setErrorForm('')
    setModal({ modo: 'crear' })
  }

  const abrirEditar = (c: Centro) => {
    setForm({
      nombre: c.nombre,
      tipo: c.tipo,
      ubicacion: c.ubicacion,
      estado: c.estado,
      lat: String(c.lat),
      lng: String(c.lng),
    })
    setErrorForm('')
    setModal({ modo: 'editar', centro: c })
  }

  const guardar = async (e: FormEvent) => {
    e.preventDefault()
    const actual = modal
    if (!actual) return

    const lat = Number(form.lat)
    const lng = Number(form.lng)
    if (!form.nombre.trim() || !form.ubicacion.trim()) {
      setErrorForm('Completa el nombre y la ubicación.')
      return
    }
    if (!Number.isFinite(lat) || !Number.isFinite(lng) || Math.abs(lat) > 90 || Math.abs(lng) > 180) {
      setErrorForm('La latitud o la longitud no son válidas.')
      return
    }

    const datos: DatosCentro = {
      nombre: form.nombre.trim(),
      tipo: form.tipo,
      ubicacion: form.ubicacion.trim(),
      estado: form.estado,
      lat,
      lng,
    }

    setGuardando(true)
    setErrorForm('')
    try {
      if (actual.modo === 'crear') {
        const nuevo = await crearCentro(datos)
        setCentros((lista) => [nuevo, ...(lista ?? [])])
        setEnfocado(nuevo)
      } else {
        const actualizado = await actualizarCentro(actual.centro.id, datos)
        setCentros((lista) => lista?.map((c) => (c.id === actualizado.id ? actualizado : c)) ?? null)
        setEnfocado(actualizado)
      }
      setModal(null)
    } catch {
      setErrorForm('No se pudo guardar el centro.')
    } finally {
      setGuardando(false)
    }
  }

  const alternarEstado = async (c: Centro) => {
    const nuevo: EstadoCentro = c.estado === 'inactivo' ? 'activo' : 'inactivo'
    const verbo = nuevo === 'inactivo' ? 'desactivar' : 'activar'
    if (!window.confirm(`¿Seguro que quieres ${verbo} "${c.nombre}"?`)) return
    setError('')
    try {
      const actualizado = await actualizarCentro(c.id, { estado: nuevo })
      setCentros((lista) => lista?.map((x) => (x.id === actualizado.id ? actualizado : x)) ?? null)
    } catch {
      setError('No se pudo cambiar el estado del centro.')
    }
  }

  if (error && !centros) return <p className="text-panel-accent">{error}</p>
  if (!centros) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <CabeceraPanel
        seccion="Recursos"
        titulo="Centros de ayuda"
        descripcion="Albergues, comedores, puestos médicos y centros de acopio que ven los ciudadanos en la app."
        acciones={
          <button onClick={abrirCrear} className={botonCabeceraPrincipal}>
            <Plus size={16} /> Nuevo centro
          </button>
        }
        estadisticas={[
          { titulo: 'Centros activos', valor: resumen.activos, icono: House, pie: `De ${centros.length} registrados` },
          { titulo: 'Albergues', valor: resumen.albergues, icono: Users, pie: 'Disponibles' },
          { titulo: 'Comedores', valor: resumen.comedores, icono: Utensils, pie: 'Disponibles' },
          { titulo: 'Puestos médicos', valor: resumen.medicos, icono: HeartPulse, pie: 'Disponibles' },
        ]}
      />

      {error && <p className="mb-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="grid gap-6 2xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
        <section className="min-w-0 rounded-3xl border border-panel-border bg-panel-card">
          <h2 className="px-5 pt-5 text-lg font-semibold tracking-[-0.02em]">Lista de centros de ayuda</h2>

          <div className="flex flex-col gap-3 px-5 py-4 sm:flex-row">
            <div className="relative flex-1">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
              <input
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar por nombre, ubicación o tipo"
                className={`${campo} pl-9`}
              />
            </div>
            <select
              value={filtroTipo}
              onChange={(e) => setFiltroTipo(e.target.value as 'todos' | TipoCentro)}
              className={`${campo} sm:w-48`}
            >
              <option value="todos">Todos los tipos</option>
              {(Object.keys(tipos) as TipoCentro[]).map((t) => (
                <option key={t} value={t}>
                  {tipos[t].etiqueta}
                </option>
              ))}
            </select>
          </div>

          <div className="max-w-full overflow-x-auto">
            <table className="w-full min-w-[560px] text-left text-sm md:min-w-[700px]">
              <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Nombre</th>
                  <th className="px-5 py-3">Tipo</th>
                  <th className="hidden px-5 py-3 md:table-cell">Ubicación</th>
                  <th className="px-5 py-3">Estado</th>
                  <th className="px-5 py-3 text-right">Acciones</th>
                </tr>
              </thead>
              <tbody>
                {filtrados.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay centros con esos filtros.
                    </td>
                  </tr>
                )}
                {filtrados.map((c) => {
                  const { icono: Icono, clase, etiqueta } = tipos[c.tipo]
                  return (
                    <tr key={c.id} className="border-t border-panel-border">
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-3">
                          <span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${clase}`}>
                            <Icono size={16} />
                          </span>
                          <span className="font-medium">{c.nombre}</span>
                        </div>
                      </td>
                      <td className="px-5 py-3 text-panel-text-soft">{etiqueta}</td>
                      <td className="hidden px-5 py-3 text-panel-text-soft md:table-cell">{c.ubicacion}</td>
                      <td className="px-5 py-3">
                        <span className={`rounded-full px-3 py-1 text-xs font-medium ${estados[c.estado].clase}`}>
                          {estados[c.estado].etiqueta}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <div className="flex justify-end gap-1 text-panel-text-soft">
                          <button
                            onClick={() => setEnfocado(c)}
                            title="Ver en el mapa"
                            aria-label="Ver en el mapa"
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                          >
                            <MapPin size={16} />
                          </button>
                          <button
                            onClick={() => abrirEditar(c)}
                            title="Ver detalles y editar"
                            aria-label="Ver detalles y editar"
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                          >
                            <Pencil size={16} />
                          </button>
                          <button
                            onClick={() => alternarEstado(c)}
                            title={c.estado === 'inactivo' ? 'Activar' : 'Desactivar'}
                            aria-label={c.estado === 'inactivo' ? 'Activar' : 'Desactivar'}
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-accent"
                          >
                            <Power size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </section>

        <section className="min-w-0 rounded-3xl border border-panel-border bg-panel-card p-5">
          <h2 className="text-lg font-semibold tracking-[-0.02em]">Ubicación en el mapa</h2>
          <div className="relative z-0 mt-4 overflow-hidden rounded-xl border border-panel-border">
            <MapContainer center={CENTRO_MAPA} zoom={13} scrollWheelZoom className="h-[420px] w-full">
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <VolarA centro={enfocado} />
              {filtrados.map((c) => (
                <CircleMarker
                  key={c.id}
                  center={[c.lat, c.lng]}
                  radius={enfocado?.id === c.id ? 13 : 10}
                  pathOptions={{
                    color: '#ffffff',
                    weight: 2,
                    fillColor: tipos[c.tipo].color,
                    fillOpacity: c.estado === 'inactivo' ? 0.4 : 0.95,
                  }}
                >
                  <Popup>
                    <p className="font-bold">{c.nombre}</p>
                    <p>
                      {tipos[c.tipo].etiqueta} · {c.ubicacion}
                    </p>
                    <button
                      onClick={() => abrirEditar(c)}
                      className="mt-2 rounded bg-panel-primary px-3 py-1 text-xs font-semibold text-white"
                    >
                      Ver detalles
                    </button>
                  </Popup>
                </CircleMarker>
              ))}
            </MapContainer>
          </div>
        </section>
      </div>

      {modal && (
        <div
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setModal(null)}
        >
          <form
            onSubmit={guardar}
            className="panel-modal-enter my-auto w-full max-w-lg rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-semibold tracking-[-0.02em]">
                {modal.modo === 'crear' ? 'Nuevo centro de ayuda' : 'Detalles del centro'}
              </h2>
              <button type="button" onClick={() => setModal(null)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="nombre" className="text-sm font-medium">
                  Nombre
                </label>
                <input
                  id="nombre"
                  autoFocus
                  value={form.nombre}
                  onChange={(e) => setForm({ ...form, nombre: e.target.value })}
                  placeholder="Ej: Colegio San José"
                  className={`${campo} mt-1`}
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="tipo" className="text-sm font-medium">
                    Tipo
                  </label>
                  <select
                    id="tipo"
                    value={form.tipo}
                    onChange={(e) => setForm({ ...form, tipo: e.target.value as TipoCentro })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(tipos) as TipoCentro[]).map((t) => (
                      <option key={t} value={t}>
                        {tipos[t].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label htmlFor="estado" className="text-sm font-medium">
                    Estado
                  </label>
                  <select
                    id="estado"
                    value={form.estado}
                    onChange={(e) => setForm({ ...form, estado: e.target.value as EstadoCentro })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(estados) as EstadoCentro[]).map((s) => (
                      <option key={s} value={s}>
                        {estados[s].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label htmlFor="ubicacion" className="text-sm font-medium">
                  Ubicación
                </label>
                <input
                  id="ubicacion"
                  value={form.ubicacion}
                  onChange={(e) => setForm({ ...form, ubicacion: e.target.value })}
                  placeholder="Ej: Cra. 9 #14-30"
                  className={`${campo} mt-1`}
                />
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="lat" className="text-sm font-medium">
                    Latitud
                  </label>
                  <input
                    id="lat"
                    type="number"
                    step="any"
                    value={form.lat}
                    onChange={(e) => setForm({ ...form, lat: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="lng" className="text-sm font-medium">
                    Longitud
                  </label>
                  <input
                    id="lng"
                    type="number"
                    step="any"
                    value={form.lng}
                    onChange={(e) => setForm({ ...form, lng: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
              </div>
              <p className="text-xs text-panel-text-muted">
                Más adelante se podrá elegir el punto tocando el mapa.
              </p>
            </div>

            {errorForm && <p className="mt-4 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setModal(null)}
                className="rounded-full border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-full bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark disabled:opacity-60"
              >
                {guardando ? 'Guardando…' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}