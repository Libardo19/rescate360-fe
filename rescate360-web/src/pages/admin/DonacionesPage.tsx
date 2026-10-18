import { useEffect, useMemo, useState, type FormEvent } from 'react'
import {
  HandHeart,
  Banknote,
  Hourglass,
  Megaphone,
  Search,
  Plus,
  X,
  Check,
  ShoppingBasket,
  Shirt,
  Pill,
  Droplets,
  type LucideIcon,
} from 'lucide-react'
import {
  listarDonaciones,
  listarCampanas,
  crearCampana,
  finalizarCampana,
  marcarDonacionRecibida,
} from '../../services/donaciones.service'
import type { Donacion, Campana, CategoriaDonacion, EstadoDonacion } from '../../types/donacion'

const categorias: Record<CategoriaDonacion, { etiqueta: string; icono: LucideIcon; clase: string }> = {
  alimentos: { etiqueta: 'Alimentos', icono: ShoppingBasket, clase: 'bg-blue-100 text-blue-600' },
  ropa: { etiqueta: 'Ropa', icono: Shirt, clase: 'bg-violet-100 text-violet-600' },
  medicamentos: { etiqueta: 'Medicamentos', icono: Pill, clase: 'bg-red-100 text-red-600' },
  agua: { etiqueta: 'Agua', icono: Droplets, clase: 'bg-cyan-100 text-cyan-600' },
  dinero: { etiqueta: 'Dinero', icono: Banknote, clase: 'bg-orange-100 text-orange-600' },
}

const estados: Record<EstadoDonacion, { etiqueta: string; clase: string }> = {
  recibida: { etiqueta: 'Recibida', clase: 'bg-green-100 text-green-700' },
  en_proceso: { etiqueta: 'En proceso', clase: 'bg-amber-100 text-amber-700' },
}

const moneda = new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 })
const numero = new Intl.NumberFormat('es-CO')

const formatearFecha = (iso: string) => new Date(iso).toLocaleDateString('es-CO', { dateStyle: 'medium' })

const campo =
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

interface FormCampana {
  titulo: string
  descripcion: string
  categoria: CategoriaDonacion
  meta: string
  unidad: string
  fechaFin: string
}

const formVacio: FormCampana = {
  titulo: '',
  descripcion: '',
  categoria: 'alimentos',
  meta: '',
  unidad: 'kits',
  fechaFin: '',
}

export default function DonacionesPage() {
  const [donaciones, setDonaciones] = useState<Donacion[] | null>(null)
  const [campanas, setCampanas] = useState<Campana[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroCategoria, setFiltroCategoria] = useState<'todas' | CategoriaDonacion>('todas')
  const [modalAbierto, setModalAbierto] = useState(false)
  const [form, setForm] = useState<FormCampana>(formVacio)
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)
  const [ahora] = useState(() => Date.now())

  useEffect(() => {
    Promise.all([listarDonaciones(), listarCampanas()])
      .then(([d, c]) => {
        setDonaciones(d)
        setCampanas(c)
      })
      .catch(() => setError('No se pudieron cargar las donaciones.'))
  }, [])

  const filtradas = useMemo(() => {
    if (!donaciones) return []
    const texto = busqueda.trim().toLowerCase()
    return donaciones
      .filter((d) => {
        const coincideTexto = !texto || d.descripcion.toLowerCase().includes(texto)
        const coincideCategoria = filtroCategoria === 'todas' || d.categoria === filtroCategoria
        return coincideTexto && coincideCategoria
      })
      .sort((a, b) => b.fecha.localeCompare(a.fecha))
  }, [donaciones, busqueda, filtroCategoria])

  const resumen = useMemo(() => {
    const lista = donaciones ?? []
    return {
      recibidas: lista.filter((d) => d.estado === 'recibida').length,
      valor: lista.reduce((suma, d) => suma + (d.monto ?? 0), 0),
      enProceso: lista.filter((d) => d.estado === 'en_proceso').length,
      campanasActivas: (campanas ?? []).filter((c) => c.activa).length,
    }
  }, [donaciones, campanas])

  const campanasActivas = (campanas ?? []).filter((c) => c.activa)

  const publicarCampana = async (e: FormEvent) => {
    e.preventDefault()
    const meta = Number(form.meta)
    if (!form.titulo.trim() || !form.descripcion.trim() || !form.unidad.trim()) {
      setErrorForm('Completa el título, la descripción y la unidad.')
      return
    }
    if (!Number.isFinite(meta) || meta <= 0) {
      setErrorForm('La meta debe ser un número mayor que cero.')
      return
    }
    const fechaFin = `${form.fechaFin}T23:59:59`
    if (!form.fechaFin || new Date(fechaFin).getTime() < ahora) {
      setErrorForm('Elige una fecha de cierre que no haya pasado.')
      return
    }

    setGuardando(true)
    setErrorForm('')
    try {
      const nueva = await crearCampana({
        titulo: form.titulo.trim(),
        descripcion: form.descripcion.trim(),
        categoria: form.categoria,
        meta,
        unidad: form.unidad.trim(),
        fechaFin,
      })
      setCampanas((lista) => [nueva, ...(lista ?? [])])
      setModalAbierto(false)
    } catch {
      setErrorForm('No se pudo crear la campaña.')
    } finally {
      setGuardando(false)
    }
  }

  const terminarCampana = async (c: Campana) => {
    if (!window.confirm(`¿Finalizar la campaña "${c.titulo}"?`)) return
    setError('')
    try {
      const actualizada = await finalizarCampana(c.id)
      setCampanas((lista) => lista?.map((x) => (x.id === actualizada.id ? actualizada : x)) ?? null)
    } catch {
      setError('No se pudo finalizar la campaña.')
    }
  }

  const confirmarRecibida = async (d: Donacion) => {
    setError('')
    try {
      const actualizada = await marcarDonacionRecibida(d.id)
      setDonaciones((lista) => lista?.map((x) => (x.id === actualizada.id ? actualizada : x)) ?? null)
    } catch {
      setError('No se pudo actualizar la donación.')
    }
  }

  if (error && !donaciones) return <p className="text-panel-accent">{error}</p>
  if (!donaciones || !campanas) return <p className="text-panel-text-soft">Cargando…</p>

  const tarjetas = [
    { valor: String(resumen.recibidas), titulo: 'Donaciones recibidas', pie: 'Confirmadas', icono: HandHeart, color: 'bg-green-600', pieColor: 'text-green-600' },
    { valor: moneda.format(resumen.valor), titulo: 'Valor en dinero', pie: 'Aportes registrados', icono: Banknote, color: 'bg-blue-500', pieColor: 'text-blue-600' },
    { valor: String(resumen.enProceso), titulo: 'En proceso', pie: 'Por confirmar', icono: Hourglass, color: 'bg-amber-500', pieColor: 'text-amber-600' },
    { valor: String(resumen.campanasActivas), titulo: 'Campañas activas', pie: 'En curso', icono: Megaphone, color: 'bg-teal-500', pieColor: 'text-teal-600' },
  ]

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Donaciones</h1>
      <p className="mt-1 text-sm text-panel-info">
        Ayuda a quienes más lo necesitan. Con tu donación haces la diferencia.
      </p>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, pie, icono: Icono, color, pieColor }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-full text-white ${color}`}>
              <Icono size={24} />
            </div>
            <div className="min-w-0">
              <p className="truncate text-2xl font-extrabold">{valor}</p>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className={`text-xs font-medium ${pieColor}`}>{pie}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-[minmax(0,3fr)_minmax(0,2fr)]">
        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card">
          <h2 className="px-5 pt-5 font-bold">Listado de donaciones</h2>

          <div className="flex flex-col gap-3 px-5 py-4 sm:flex-row">
            <div className="relative flex-1">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
              <input
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar donaciones"
                className={`${campo} pl-9`}
              />
            </div>
            <select
              value={filtroCategoria}
              onChange={(e) => setFiltroCategoria(e.target.value as 'todas' | CategoriaDonacion)}
              className={`${campo} sm:w-48`}
            >
              <option value="todas">Todas las categorías</option>
              {(Object.keys(categorias) as CategoriaDonacion[]).map((c) => (
                <option key={c} value={c}>
                  {categorias[c].etiqueta}
                </option>
              ))}
            </select>
          </div>

          <div className="max-w-full overflow-x-auto">
            <table className="w-full min-w-[680px] text-left text-sm">
              <thead className="text-xs uppercase text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Fecha</th>
                  <th className="px-5 py-3">Tipo</th>
                  <th className="hidden px-5 py-3 md:table-cell">Descripción</th>
                  <th className="px-5 py-3">Cantidad</th>
                  <th className="px-5 py-3">Estado</th>
                </tr>
              </thead>
              <tbody>
                {filtradas.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay donaciones con esos filtros.
                    </td>
                  </tr>
                )}
                {filtradas.map((d) => {
                  const { icono: Icono, clase, etiqueta } = categorias[d.categoria]
                  return (
                    <tr key={d.id} className="border-t border-panel-border">
                      <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(d.fecha)}</td>
                      <td className="px-5 py-3">
                        <span className="flex items-center gap-2">
                          <span className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${clase}`}>
                            <Icono size={15} />
                          </span>
                          <span className="font-medium">{etiqueta}</span>
                        </span>
                      </td>
                      <td className="hidden px-5 py-3 text-panel-text-soft md:table-cell">{d.descripcion}</td>
                      <td className="px-5 py-3">{d.monto ? moneda.format(d.monto) : d.cantidad}</td>
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-2">
                          <span className={`rounded-full px-3 py-1 text-xs font-medium ${estados[d.estado].clase}`}>
                            {estados[d.estado].etiqueta}
                          </span>
                          {d.estado === 'en_proceso' && (
                            <button
                              onClick={() => confirmarRecibida(d)}
                              title="Marcar como recibida"
                              aria-label="Marcar como recibida"
                              className="rounded p-1.5 text-panel-text-soft hover:bg-panel-bg hover:text-panel-success"
                            >
                              <Check size={16} />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </section>

        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card p-5">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h2 className="font-bold">Campañas de donación</h2>
            <button
              onClick={() => {
                setForm(formVacio)
                setErrorForm('')
                setModalAbierto(true)
              }}
              className="flex shrink-0 items-center gap-1.5 rounded-lg bg-panel-info px-3 py-2 text-sm font-semibold text-white transition hover:opacity-90"
            >
              <Plus size={16} /> Nueva campaña
            </button>
          </div>

          <div className="mt-4 space-y-4">
            {campanasActivas.length === 0 && (
              <p className="rounded-xl border border-dashed border-panel-border px-4 py-10 text-center text-sm text-panel-text-soft">
                No hay campañas activas.
              </p>
            )}
            {campanasActivas.map((c) => {
              const { icono: Icono, clase } = categorias[c.categoria]
              const porcentaje = Math.min(100, Math.round((c.recaudado / c.meta) * 100))
              const dias = Math.ceil((new Date(c.fechaFin).getTime() - ahora) / 86400000)
              return (
                <article key={c.id} className="flex min-w-0 gap-4 rounded-xl border border-panel-border p-4">
                  <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-xl ${clase}`}>
                    <Icono size={26} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="break-words font-bold">{c.titulo}</h3>
                    <p className="break-words text-sm text-panel-text-soft">{c.descripcion}</p>

                    <div className="mt-3 h-2 overflow-hidden rounded-full bg-panel-bg">
                      <div className="h-full rounded-full bg-panel-info" style={{ width: `${porcentaje}%` }} />
                    </div>
                    <div className="mt-1.5 flex flex-wrap items-center justify-between gap-2 text-xs text-panel-text-muted">
                      <span>
                        {porcentaje}% · {numero.format(c.recaudado)} / {numero.format(c.meta)} {c.unidad}
                      </span>
                      <span>{dias > 0 ? `${dias} ${dias === 1 ? 'día restante' : 'días restantes'}` : 'Cierra hoy o ya cerró'}</span>
                    </div>

                    <button
                      onClick={() => terminarCampana(c)}
                      className="mt-2 text-sm font-semibold text-panel-accent hover:underline"
                    >
                      Finalizar campaña
                    </button>
                  </div>
                </article>
              )
            })}
          </div>
        </section>
      </div>

      {modalAbierto && (
        <div
          className="fixed inset-0 z-[1000] flex items-center justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setModalAbierto(false)}
        >
          <form
            onSubmit={publicarCampana}
            className="w-full max-w-lg rounded-2xl bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-extrabold text-panel-primary">Nueva campaña</h2>
              <button type="button" onClick={() => setModalAbierto(false)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="titulo" className="text-sm font-medium">
                  Título
                </label>
                <input
                  id="titulo"
                  value={form.titulo}
                  onChange={(e) => setForm({ ...form, titulo: e.target.value })}
                  placeholder="Ej: Alimentos para familias"
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="descripcion" className="text-sm font-medium">
                  Descripción
                </label>
                <textarea
                  id="descripcion"
                  rows={3}
                  value={form.descripcion}
                  onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
                  placeholder="Qué se necesita y para quién"
                  className={`${campo} mt-1`}
                />
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="categoria" className="text-sm font-medium">
                    Categoría
                  </label>
                  <select
                    id="categoria"
                    value={form.categoria}
                    onChange={(e) => setForm({ ...form, categoria: e.target.value as CategoriaDonacion })}
                    className={`${campo} mt-1`}
                  >
                    {(Object.keys(categorias) as CategoriaDonacion[]).map((c) => (
                      <option key={c} value={c}>
                        {categorias[c].etiqueta}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label htmlFor="fechaFin" className="text-sm font-medium">
                    Fecha de cierre
                  </label>
                  <input
                    id="fechaFin"
                    type="date"
                    value={form.fechaFin}
                    onChange={(e) => setForm({ ...form, fechaFin: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="meta" className="text-sm font-medium">
                    Meta
                  </label>
                  <input
                    id="meta"
                    type="number"
                    min="1"
                    value={form.meta}
                    onChange={(e) => setForm({ ...form, meta: e.target.value })}
                    placeholder="Ej: 500"
                    className={`${campo} mt-1`}
                  />
                </div>
                <div>
                  <label htmlFor="unidad" className="text-sm font-medium">
                    Unidad
                  </label>
                  <input
                    id="unidad"
                    value={form.unidad}
                    onChange={(e) => setForm({ ...form, unidad: e.target.value })}
                    placeholder="kits, prendas, COP…"
                    className={`${campo} mt-1`}
                  />
                </div>
              </div>
            </div>

            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setModalAbierto(false)}
                className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark disabled:opacity-60"
              >
                {guardando ? 'Creando…' : 'Crear campaña'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}