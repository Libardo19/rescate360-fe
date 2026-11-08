import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Plus, X, Waves, Mountain, ShieldAlert, CloudRain, TriangleAlert, BellRing, History, type LucideIcon } from 'lucide-react'
import CabeceraPanel, { botonCabeceraPrincipal } from '../../components/panel/CabeceraPanel'
import { listarAlertas, crearAlerta, finalizarAlerta } from '../../services/alertas.service'
import type { Alerta, NuevaAlerta, TipoAlerta } from '../../types/alerta'

const config: Record<TipoAlerta, { etiqueta: string; icono: LucideIcon; color: string }> = {
  inundacion: { etiqueta: 'Inundación', icono: Waves, color: 'bg-blue-100 text-blue-600' },
  deslizamiento: { etiqueta: 'Deslizamiento', icono: Mountain, color: 'bg-amber-100 text-amber-600' },
  seguridad: { etiqueta: 'Seguridad', icono: ShieldAlert, color: 'bg-red-100 text-red-600' },
  clima: { etiqueta: 'Clima', icono: CloudRain, color: 'bg-slate-200 text-slate-600' },
  otro: { etiqueta: 'Otro', icono: TriangleAlert, color: 'bg-violet-100 text-violet-600' },
}

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

const formularioVacio: NuevaAlerta = { tipo: 'inundacion', titulo: '', descripcion: '', zona: '' }

export default function AlertasPage() {
  const [alertas, setAlertas] = useState<Alerta[] | null>(null)
  const [error, setError] = useState('')
  const [pestana, setPestana] = useState<'activas' | 'historial'>('activas')
    // ?accion=nueva abre el formulario directamente (desde la paleta de comandos o el Inicio).
  const [params, setParams] = useSearchParams()
  const abrirDesdeUrl = params.get('accion') === 'nueva'
  useEffect(() => {
    if (abrirDesdeUrl) setParams({}, { replace: true })
  }, [abrirDesdeUrl, setParams])
  const [modalAbierto, setModalAbierto] = useState(abrirDesdeUrl)
  const [form, setForm] = useState<NuevaAlerta>(formularioVacio)
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarAlertas()
      .then(setAlertas)
      .catch(() => setError('No se pudieron cargar las alertas.'))
  }, [])

  const visibles = useMemo(() => {
    if (!alertas) return []
    return alertas
      .filter((a) => (pestana === 'activas' ? a.activa : !a.activa))
      .sort((a, b) => b.fecha.localeCompare(a.fecha))
  }, [alertas, pestana])

  const cantidadActivas = alertas?.filter((a) => a.activa).length ?? 0

  const abrirModal = () => {
    setForm(formularioVacio)
    setErrorForm('')
    setModalAbierto(true)
  }

  const publicar = async (e: FormEvent) => {
    e.preventDefault()
    if (!form.titulo.trim() || !form.zona.trim() || !form.descripcion.trim()) {
      setErrorForm('Completa el título, la zona y la descripción.')
      return
    }
    setGuardando(true)
    setErrorForm('')
    try {
      const nueva = await crearAlerta({
        ...form,
        titulo: form.titulo.trim(),
        zona: form.zona.trim(),
        descripcion: form.descripcion.trim(),
      })
      setAlertas((lista) => [nueva, ...(lista ?? [])])
      setPestana('activas')
      setModalAbierto(false)
    } catch {
      setErrorForm('No se pudo publicar la alerta.')
    } finally {
      setGuardando(false)
    }
  }

  const finalizar = async (alerta: Alerta) => {
    if (!window.confirm(`¿Finalizar la alerta "${alerta.titulo}"? Pasará al historial.`)) return
    setError('')
    try {
      const actualizada = await finalizarAlerta(alerta.id)
      setAlertas((lista) => lista?.map((a) => (a.id === actualizada.id ? actualizada : a)) ?? null)
    } catch {
      setError('No se pudo finalizar la alerta.')
    }
  }

  if (error && !alertas) return <p className="text-panel-accent">{error}</p>
  if (!alertas) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <CabeceraPanel
        seccion="Operación"
        titulo="Alertas"
        descripcion="Publica y gestiona las alertas que reciben los ciudadanos en la app."
        acciones={
          <button onClick={abrirModal} className={botonCabeceraPrincipal}>
            <Plus size={16} /> Nueva alerta
          </button>
        }
        estadisticas={[
          {
            titulo: 'Activas',
            valor: cantidadActivas,
            icono: BellRing,
            pie: 'Visibles para la comunidad',
            tono: cantidadActivas > 0 ? 'aviso' : 'neutro',
          },
          { titulo: 'En historial', valor: alertas.length - cantidadActivas, icono: History, pie: 'Alertas finalizadas' },
        ]}
      />

      {error && <p className="mb-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="inline-flex rounded-full border border-panel-border bg-panel-card p-1 text-sm">
        {(['activas', 'historial'] as const).map((p) => (
          <button
            key={p}
            onClick={() => setPestana(p)}
            className={`rounded-full px-4 py-1.5 font-medium capitalize transition ${
              pestana === p ? 'bg-panel-primary text-white' : 'text-panel-text-soft hover:text-panel-text'
            }`}
          >
            {p}
            {p === 'activas' && ` (${cantidadActivas})`}
          </button>
        ))}
      </div>

      <div className="mt-5 grid gap-4 lg:grid-cols-2">
        {visibles.length === 0 && (
          <p className="rounded-2xl border border-dashed border-panel-border bg-panel-card px-6 py-12 text-center text-panel-text-soft lg:col-span-2">
            {pestana === 'activas' ? 'No hay alertas activas.' : 'Todavía no hay alertas en el historial.'}
          </p>
        )}
        {visibles.map((a) => {
          const { etiqueta, icono: Icono, color } = config[a.tipo]
          return (
            <article key={a.id} className="flex gap-4 rounded-3xl border border-panel-border bg-panel-card p-5">
              <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-full ${color}`}>
                <Icono size={22} />
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <h2 className="text-lg font-semibold tracking-[-0.02em]">{a.titulo}</h2>
                  <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${color}`}>{etiqueta}</span>
                </div>
                <p className="mt-1 text-sm text-panel-text-soft">{a.descripcion}</p>
                <p className="mt-2 text-xs text-panel-text-muted">
                  {a.zona} · {formatearFecha(a.fecha)}
                </p>
                {a.activa && (
                  <button
                    onClick={() => finalizar(a)}
                    className="mt-3 text-sm font-semibold text-panel-accent hover:underline"
                  >
                    Finalizar alerta
                  </button>
                )}
              </div>
            </article>
          )
        })}
      </div>

      {modalAbierto && (
        <div
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setModalAbierto(false)}
        >
          <form
            onSubmit={publicar}
            className="panel-modal-enter my-auto w-full max-w-lg rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-semibold tracking-[-0.02em]">Nueva alerta</h2>
              <button type="button" onClick={() => setModalAbierto(false)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="tipo" className="text-sm font-medium">
                  Tipo de alerta
                </label>
                <select
                  id="tipo"
                  value={form.tipo}
                  onChange={(e) => setForm({ ...form, tipo: e.target.value as TipoAlerta })}
                  className={`${campo} mt-1`}
                >
                  {(Object.keys(config) as TipoAlerta[]).map((t) => (
                    <option key={t} value={t}>
                      {config[t].etiqueta}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="titulo" className="text-sm font-medium">
                  Título
                </label>
                <input
                  id="titulo"
                  autoFocus
                  value={form.titulo}
                  onChange={(e) => setForm({ ...form, titulo: e.target.value })}
                  placeholder="Ej: Alerta de inundación"
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="zona" className="text-sm font-medium">
                  Zona afectada
                </label>
                <input
                  id="zona"
                  value={form.zona}
                  onChange={(e) => setForm({ ...form, zona: e.target.value })}
                  placeholder="Ej: Barrio El Prado"
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="descripcion" className="text-sm font-medium">
                  Descripción
                </label>
                <textarea
                  id="descripcion"
                  rows={4}
                  value={form.descripcion}
                  onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
                  placeholder="Qué ocurre y qué debe hacer la comunidad"
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
                {guardando ? 'Publicando…' : 'Publicar alerta'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}