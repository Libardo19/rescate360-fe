import { useEffect, useMemo, useState, type FormEvent } from 'react'
import {
  UserSearch,
  UserCheck,
  Clock,
  BellOff,
  Search,
  Plus,
  X,
  Share2,
  Check,
  MapPin,
  CalendarDays,
} from 'lucide-react'
import { listarPersonas, registrarPersona, actualizarEstadoPersona } from '../../services/personas.service'
import type { Persona, EstadoPersona, Genero } from '../../types/persona'

const estados: Record<EstadoPersona, { etiqueta: string; clase: string }> = {
  buscando: { etiqueta: 'En búsqueda', clase: 'bg-red-100 text-red-700' },
  encontrado: { etiqueta: 'Encontrada', clase: 'bg-green-100 text-green-700' },
}

const generos: Record<Genero, string> = { femenino: 'Femenino', masculino: 'Masculino', otro: 'Otro' }

const orden: Record<EstadoPersona, number> = { buscando: 0, encontrado: 1 }

const iniciales = (nombre: string) =>
  nombre
    .split(' ')
    .map((p) => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

const formatearFecha = (valor: string) =>
  new Date(valor.length === 10 ? `${valor}T00:00:00` : valor).toLocaleDateString('es-CO', { dateStyle: 'long' })

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

interface FormPersona {
  nombre: string
  edad: string
  genero: Genero
  ultimaUbicacion: string
  fechaDesaparicion: string
  descripcion: string
}

const formVacio: FormPersona = {
  nombre: '',
  edad: '',
  genero: 'femenino',
  ultimaUbicacion: '',
  fechaDesaparicion: '',
  descripcion: '',
}

export default function DesaparecidosPage() {
  const [personas, setPersonas] = useState<Persona[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroEstado, setFiltroEstado] = useState<'todos' | EstadoPersona>('todos')
  const [filtroGenero, setFiltroGenero] = useState<'todos' | Genero>('todos')
  const [seleccionId, setSeleccionId] = useState<string | null>(null)
  const [modalAbierto, setModalAbierto] = useState(false)
  const [form, setForm] = useState<FormPersona>(formVacio)
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)
  const [copiado, setCopiado] = useState(false)
  const [ahora] = useState(() => Date.now())

  useEffect(() => {
    listarPersonas()
      .then(setPersonas)
      .catch(() => setError('No se pudieron cargar los casos.'))
  }, [])

  const filtradas = useMemo(() => {
    if (!personas) return []
    const texto = busqueda.trim().toLowerCase()
    return personas
      .filter((p) => {
        const coincideTexto =
          !texto || p.nombre.toLowerCase().includes(texto) || p.ultimaUbicacion.toLowerCase().includes(texto)
        const coincideEstado = filtroEstado === 'todos' || p.estado === filtroEstado
        const coincideGenero = filtroGenero === 'todos' || p.genero === filtroGenero
        return coincideTexto && coincideEstado && coincideGenero
      })
      .sort((a, b) => orden[a.estado] - orden[b.estado] || b.fechaDesaparicion.localeCompare(a.fechaDesaparicion))
  }, [personas, busqueda, filtroEstado, filtroGenero])

  const resumen = useMemo(() => {
    const lista = personas ?? []
    const dia = 24 * 60 * 60 * 1000
    return {
      enBusqueda: lista.filter((p) => p.estado === 'buscando').length,
      encontradas: lista.filter((p) => p.estado === 'encontrado').length,
      nuevas: lista.filter((p) => p.estado === 'buscando' && ahora - new Date(p.actualizado).getTime() <= dia).length,
      sinNovedades: lista.filter((p) => p.estado !== 'encontrado' && ahora - new Date(p.actualizado).getTime() > dia)
        .length,
    }
  }, [personas, ahora])

  const seleccionada = personas?.find((p) => p.id === seleccionId) ?? filtradas[0] ?? null

  const cambiarEstado = async (estado: EstadoPersona) => {
    if (!seleccionada || estado === seleccionada.estado) return
    setError('')
    try {
      const actualizada = await actualizarEstadoPersona(seleccionada.id, estado)
      setPersonas((lista) => lista?.map((p) => (p.id === actualizada.id ? actualizada : p)) ?? null)
    } catch {
      setError('No se pudo actualizar el estado.')
    }
  }

  const compartir = async () => {
    if (!seleccionada) return
    const texto = [
      `SE BUSCA: ${seleccionada.nombre}, ${seleccionada.edad} años.`,
      `Última ubicación: ${seleccionada.ultimaUbicacion}.`,
      `Desapareció el ${formatearFecha(seleccionada.fechaDesaparicion)}.`,
      `Descripción: ${seleccionada.descripcion}`,
      'Si tienes información, comunícate con RESCATE360.',
    ].join('\n')
    try {
      await navigator.clipboard.writeText(texto)
      setCopiado(true)
      setTimeout(() => setCopiado(false), 2000)
    } catch {
      setError('No se pudo copiar el texto.')
    }
  }

  const registrar = async (e: FormEvent) => {
    e.preventDefault()
    const edad = Number(form.edad)
    if (!form.nombre.trim() || !form.ultimaUbicacion.trim() || !form.descripcion.trim()) {
      setErrorForm('Completa el nombre, la última ubicación y la descripción.')
      return
    }
    if (!Number.isInteger(edad) || edad < 0 || edad > 120) {
      setErrorForm('La edad debe ser un número entero entre 0 y 120.')
      return
    }
    if (!form.fechaDesaparicion || new Date(`${form.fechaDesaparicion}T00:00:00`).getTime() > ahora) {
      setErrorForm('Elige una fecha de desaparición que no sea futura.')
      return
    }

    setGuardando(true)
    setErrorForm('')
    try {
      const nueva = await registrarPersona({
        nombre: form.nombre.trim(),
        edad,
        genero: form.genero,
        ultimaUbicacion: form.ultimaUbicacion.trim(),
        fechaDesaparicion: form.fechaDesaparicion,
        descripcion: form.descripcion.trim(),
      })
      setPersonas((lista) => [nueva, ...(lista ?? [])])
      setSeleccionId(nueva.id)
      setModalAbierto(false)
    } catch {
      setErrorForm('No se pudo registrar el caso.')
    } finally {
      setGuardando(false)
    }
  }

  if (error && !personas) return <p className="text-panel-accent">{error}</p>
  if (!personas) return <p className="text-panel-text-soft">Cargando…</p>

  const tarjetas = [
    { valor: resumen.enBusqueda, titulo: 'Personas reportadas', pie: 'En búsqueda', icono: UserSearch, color: 'bg-red-500', pieColor: 'text-red-600' },
    { valor: resumen.encontradas, titulo: 'Encontradas', pie: 'Sanas y a salvo', icono: UserCheck, color: 'bg-blue-500', pieColor: 'text-blue-600' },
    { valor: resumen.nuevas, titulo: 'Con novedades', pie: 'Últimas 24 h', icono: Clock, color: 'bg-amber-500', pieColor: 'text-amber-600' },
    { valor: resumen.sinNovedades, titulo: 'Sin novedades', pie: 'Más de 24 h sin cambios', icono: BellOff, color: 'bg-violet-500', pieColor: 'text-violet-600' },
  ]

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-brand" />
            Recursos
          </p>
          <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Personas desaparecidas</h1>
          <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">
            Ayúdanos a encontrarlas. Comparte esta información y mantente atento a las actualizaciones.
          </p>
        </div>
        <button
          onClick={() => {
            setForm(formVacio)
            setErrorForm('')
            setModalAbierto(true)
          }}
          className="flex items-center justify-center gap-2 rounded-full bg-panel-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark"
        >
          <Plus size={16} /> Registrar caso
        </button>
      </div>

      {error && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, pie, icono: Icono, pieColor }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-3xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border border-panel-border text-panel-text-soft`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-2xl font-extrabold">{valor}</p>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className={`text-xs font-medium ${pieColor}`}>{pie}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-[3fr_2fr]">
        <section className="rounded-3xl border border-panel-border bg-panel-card">
          <h2 className="px-5 pt-5 text-lg font-semibold tracking-[-0.02em]">Lista de personas desaparecidas</h2>

          <div className="flex flex-col gap-3 px-5 py-4 lg:flex-row">
            <div className="relative flex-1">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
              <input
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar por nombre o ubicación"
                className={`${campo} pl-9`}
              />
            </div>
            <select
              value={filtroEstado}
              onChange={(e) => setFiltroEstado(e.target.value as 'todos' | EstadoPersona)}
              className={`${campo} lg:w-44`}
            >
              <option value="todos">Todos los estados</option>
              {(Object.keys(estados) as EstadoPersona[]).map((s) => (
                <option key={s} value={s}>
                  {estados[s].etiqueta}
                </option>
              ))}
            </select>
            <select
              value={filtroGenero}
              onChange={(e) => setFiltroGenero(e.target.value as 'todos' | Genero)}
              className={`${campo} lg:w-40`}
            >
              <option value="todos">Todos los géneros</option>
              {(Object.keys(generos) as Genero[]).map((g) => (
                <option key={g} value={g}>
                  {generos[g]}
                </option>
              ))}
            </select>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Nombre</th>
                  <th className="px-5 py-3">Edad</th>
                  <th className="hidden px-5 py-3 md:table-cell">Última ubicación</th>
                  <th className="px-5 py-3">Estado</th>
                </tr>
              </thead>
              <tbody>
                {filtradas.length === 0 && (
                  <tr>
                    <td colSpan={4} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay casos con esos filtros.
                    </td>
                  </tr>
                )}
                {filtradas.map((p) => (
                  <tr
                    key={p.id}
                    onClick={() => setSeleccionId(p.id)}
                    className={`cursor-pointer border-t border-panel-border transition hover:bg-panel-bg ${
                      seleccionada?.id === p.id ? 'bg-blue-50' : ''
                    }`}
                  >
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-3">
                        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-panel-primary/10 text-xs font-bold text-panel-primary">
                          {iniciales(p.nombre)}
                        </span>
                        <span className="font-medium">{p.nombre}</span>
                      </div>
                    </td>
                    <td className="px-5 py-3 text-panel-text-soft">{p.edad}</td>
                    <td className="hidden px-5 py-3 text-panel-text-soft md:table-cell">{p.ultimaUbicacion}</td>
                    <td className="px-5 py-3">
                      <span className={`rounded-full px-3 py-1 text-xs font-medium ${estados[p.estado].clase}`}>
                        {estados[p.estado].etiqueta}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="h-fit rounded-3xl border border-panel-border bg-panel-card p-5">
          {!seleccionada ? (
            <p className="py-10 text-center text-sm text-panel-text-soft">Selecciona un caso para ver su detalle.</p>
          ) : (
            <>
              <div className="flex items-center gap-4">
                <span className="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-panel-primary/10 text-xl font-bold text-panel-primary">
                  {iniciales(seleccionada.nombre)}
                </span>
                <div>
                  <h2 className="text-lg font-extrabold">{seleccionada.nombre}</h2>
                  <p className="text-sm text-panel-text-soft">
                    {seleccionada.edad} años · {generos[seleccionada.genero]}
                  </p>
                  <span
                    className={`mt-1 inline-block rounded-full px-3 py-1 text-xs font-medium ${estados[seleccionada.estado].clase}`}
                  >
                    {estados[seleccionada.estado].etiqueta}
                  </span>
                </div>
              </div>

              <dl className="mt-5 space-y-3 text-sm">
                <div className="flex gap-3">
                  <MapPin size={16} className="mt-0.5 shrink-0 text-panel-text-muted" />
                  <div>
                    <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Última ubicación</dt>
                    <dd>{seleccionada.ultimaUbicacion}</dd>
                  </div>
                </div>
                <div className="flex gap-3">
                  <CalendarDays size={16} className="mt-0.5 shrink-0 text-panel-text-muted" />
                  <div>
                    <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Fecha de desaparición</dt>
                    <dd>{formatearFecha(seleccionada.fechaDesaparicion)}</dd>
                  </div>
                </div>
                <div>
                  <dt className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">Descripción</dt>
                  <dd className="mt-1">{seleccionada.descripcion}</dd>
                </div>
              </dl>

              <div className="mt-5">
                <label htmlFor="estado" className="text-sm font-semibold">
                  Actualizar estado
                </label>
                <select
                  id="estado"
                  value={seleccionada.estado}
                  onChange={(e) => cambiarEstado(e.target.value as EstadoPersona)}
                  className={`${campo} mt-2`}
                >
                  {(Object.keys(estados) as EstadoPersona[]).map((s) => (
                    <option key={s} value={s}>
                      {estados[s].etiqueta}
                    </option>
                  ))}
                </select>
              </div>

              <button
                onClick={compartir}
                className="mt-4 flex w-full items-center justify-center gap-2 rounded-full border border-panel-border px-4 py-2 text-sm font-semibold text-panel-text-soft transition hover:bg-panel-bg"
              >
                {copiado ? <Check size={16} className="text-panel-success" /> : <Share2 size={16} />}
                {copiado ? 'Texto copiado' : 'Compartir'}
              </button>
            </>
          )}
        </section>
      </div>

      {modalAbierto && (
        <div
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setModalAbierto(false)}
        >
          <form
            onSubmit={registrar}
            className="max-h-[calc(100dvh-2rem)] w-full max-w-lg overflow-y-auto rounded-2xl bg-panel-card p-6 shadow-2xl sm:max-h-[calc(100dvh-3rem)]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-semibold tracking-[-0.02em]">Registrar caso</h2>
              <button type="button" onClick={() => setModalAbierto(false)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="nombre" className="text-sm font-medium">
                  Nombre completo
                </label>
                <input
                  id="nombre"
                  value={form.nombre}
                  onChange={(e) => setForm({ ...form, nombre: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="edad" className="text-sm font-medium">
                    Edad
                  </label>
                  <input
                    id="edad"
                    type="number"
                    min="0"
                    max="120"
                    value={form.edad}
                    onChange={(e) => setForm({ ...form, edad: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="genero" className="text-sm font-medium">
                    Género
                  </label>
                  <select
                    id="genero"
                    value={form.genero}
                    onChange={(e) => setForm({ ...form, genero: e.target.value as Genero })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(generos) as Genero[]).map((g) => (
                      <option key={g} value={g}>
                        {generos[g]}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label htmlFor="ubicacion" className="text-sm font-medium">
                  Última ubicación conocida
                </label>
                <input
                  id="ubicacion"
                  value={form.ultimaUbicacion}
                  onChange={(e) => setForm({ ...form, ultimaUbicacion: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="fecha" className="text-sm font-medium">
                  Fecha de desaparición
                </label>
                <input
                  id="fecha"
                  type="date"
                  value={form.fechaDesaparicion}
                  onChange={(e) => setForm({ ...form, fechaDesaparicion: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="descripcion" className="text-sm font-medium">
                  Descripción (ropa, señas particulares)
                </label>
                <textarea
                  id="descripcion"
                  rows={3}
                  value={form.descripcion}
                  onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
            </div>

            {errorForm && <p className="mt-4 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setModalAbierto(false)}
                className="rounded-full border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-full bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark disabled:opacity-60"
              >
                {guardando ? 'Registrando…' : 'Registrar'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}