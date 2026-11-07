import { useEffect, useMemo, useState, type FormEvent } from 'react'
import {
  Droplets,
  Wheat,
  Pill,
  Shirt,
  SprayCan,
  BedDouble,
  Package,
  Plus,
  ArrowDownToLine,
  ArrowUpFromLine,
  Building2,
  PackageX,
  Boxes,
  type LucideIcon,
} from 'lucide-react'
import { listarDonaciones, crearDonacion, actualizarCantidad } from '../../services/donaciones.service'
import { listarCentros } from '../../services/centros.service'
import type { Donacion, TipoDonacion } from '../../types/donacion'
import type { Centro } from '../../types/centro'
import Modal from '../../components/panel/Modal'
import TarjetaResumen from '../../components/panel/TarjetaResumen'

const tipos: Record<TipoDonacion, { etiqueta: string; icono: LucideIcon; clase: string; unidad: string }> = {
  agua: { etiqueta: 'Agua', icono: Droplets, clase: 'bg-blue-100 text-blue-600', unidad: 'litros' },
  alimentos: { etiqueta: 'Alimentos', icono: Wheat, clase: 'bg-amber-100 text-amber-700', unidad: 'kg' },
  medicamentos: { etiqueta: 'Medicamentos', icono: Pill, clase: 'bg-violet-100 text-violet-600', unidad: 'cajas' },
  ropa: { etiqueta: 'Ropa', icono: Shirt, clase: 'bg-pink-100 text-pink-600', unidad: 'prendas' },
  higiene: { etiqueta: 'Higiene', icono: SprayCan, clase: 'bg-teal-100 text-teal-700', unidad: 'kits' },
  cobijas: { etiqueta: 'Cobijas', icono: BedDouble, clase: 'bg-orange-100 text-orange-600', unidad: 'unidades' },
  otro: { etiqueta: 'Otro', icono: Package, clase: 'bg-slate-200 text-slate-600', unidad: 'unidades' },
}

const unidadesSugeridas = ['unidades', 'litros', 'kg', 'cajas', 'paquetes', 'kits', 'prendas']

const formatearFecha = (iso: string) =>
  new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' })

const formatearNumero = (n: number) => n.toLocaleString('es-CO')

const campo =
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

interface FormNueva {
  centroId: string
  tipo: TipoDonacion
  cantidad: string
  unidad: string
}

export default function DonacionesPage() {
  const [donaciones, setDonaciones] = useState<Donacion[] | null>(null)
  const [centros, setCentros] = useState<Centro[]>([])
  const [error, setError] = useState('')
  const [centroSel, setCentroSel] = useState<'todos' | string>('todos')
  const [filtroTipo, setFiltroTipo] = useState<'todos' | TipoDonacion>('todos')

  const [nuevaAbierta, setNuevaAbierta] = useState(false)
  const [form, setForm] = useState<FormNueva>({ centroId: '', tipo: 'agua', cantidad: '', unidad: 'litros' })

  const [ajuste, setAjuste] = useState<Donacion | null>(null)
  const [movimiento, setMovimiento] = useState<'entrada' | 'salida'>('entrada')
  const [cantidadAjuste, setCantidadAjuste] = useState('')

  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    Promise.all([listarDonaciones(), listarCentros()])
      .then(([d, c]) => {
        setDonaciones(d)
        setCentros(c)
      })
      .catch(() => setError('No se pudo cargar el inventario de donaciones.'))
  }, [])

  const nombreCentro = (id: string) => centros.find((c) => c.id === id)?.nombre ?? 'Centro desconocido'

  // Solo se listan los centros que tienen al menos un registro, más el total.
  const conteoPorCentro = useMemo(() => {
    const conteo = new Map<string, number>()
    donaciones?.forEach((d) => conteo.set(d.centroId, (conteo.get(d.centroId) ?? 0) + 1))
    return conteo
  }, [donaciones])

  const filtradas = useMemo(
    () =>
      (donaciones ?? [])
        .filter((d) => centroSel === 'todos' || d.centroId === centroSel)
        .filter((d) => filtroTipo === 'todos' || d.tipo === filtroTipo)
        .sort((a, b) => b.actualizadoEn.localeCompare(a.actualizadoEn)),
    [donaciones, centroSel, filtroTipo],
  )

  const resumen = useMemo(
    () => ({
      registros: donaciones?.length ?? 0,
      centros: conteoPorCentro.size,
      agotados: donaciones?.filter((d) => d.cantidad === 0).length ?? 0,
    }),
    [donaciones, conteoPorCentro],
  )

  const reemplazar = (actualizada: Donacion) =>
    setDonaciones((lista) => lista?.map((d) => (d.id === actualizada.id ? actualizada : d)) ?? null)

  const abrirNueva = () => {
    setForm({ centroId: centroSel === 'todos' ? '' : centroSel, tipo: 'agua', cantidad: '', unidad: 'litros' })
    setErrorForm('')
    setNuevaAbierta(true)
  }

  // Si ya hay un registro del mismo tipo y unidad en ese centro, se suma a él en vez de duplicarlo.
  const existente = donaciones?.find(
    (d) =>
      d.centroId === form.centroId &&
      d.tipo === form.tipo &&
      d.unidad.trim().toLowerCase() === form.unidad.trim().toLowerCase(),
  )

  const registrar = async (e: FormEvent) => {
    e.preventDefault()
    const cantidad = Number(form.cantidad)
    if (!form.centroId) return setErrorForm('Elige el centro que recibe la donación.')
    if (!Number.isInteger(cantidad) || cantidad <= 0) return setErrorForm('La cantidad debe ser un número entero mayor que 0.')
    if (!form.unidad.trim()) return setErrorForm('Indica la unidad (litros, kg, cajas…).')

    setGuardando(true)
    setErrorForm('')
    try {
      if (existente) {
        reemplazar(await actualizarCantidad(existente.id, existente.cantidad + cantidad))
      } else {
        const nueva = await crearDonacion({ ...form, cantidad, unidad: form.unidad.trim() })
        setDonaciones((lista) => [nueva, ...(lista ?? [])])
      }
      setNuevaAbierta(false)
    } catch {
      setErrorForm('No se pudo registrar la donación.')
    } finally {
      setGuardando(false)
    }
  }

  const abrirAjuste = (d: Donacion) => {
    setAjuste(d)
    setMovimiento('entrada')
    setCantidadAjuste('')
    setErrorForm('')
  }

  const valorAjuste = Number(cantidadAjuste)
  const ajusteValido = Number.isInteger(valorAjuste) && valorAjuste > 0
  const cantidadResultante = ajuste
    ? ajuste.cantidad + (movimiento === 'entrada' ? 1 : -1) * (ajusteValido ? valorAjuste : 0)
    : 0

  const aplicarAjuste = async (e: FormEvent) => {
    e.preventDefault()
    if (!ajuste) return
    if (!ajusteValido) return setErrorForm('Escribe una cantidad entera mayor que 0.')
    if (cantidadResultante < 0) return setErrorForm(`Solo hay ${formatearNumero(ajuste.cantidad)} ${ajuste.unidad} disponibles.`)

    setGuardando(true)
    setErrorForm('')
    try {
      reemplazar(await actualizarCantidad(ajuste.id, cantidadResultante))
      setAjuste(null)
    } catch {
      setErrorForm('No se pudo actualizar la cantidad.')
    } finally {
      setGuardando(false)
    }
  }

  if (error && !donaciones) return <p className="text-panel-accent">{error}</p>
  if (!donaciones) return <p className="text-panel-text-soft">Cargando…</p>

  const botonCentro = (activo: boolean) =>
    `flex w-full items-center justify-between gap-2 rounded-lg px-3 py-2 text-left text-sm transition ${
      activo ? 'bg-panel-primary font-semibold text-white' : 'text-panel-text-soft hover:bg-panel-bg hover:text-panel-text'
    }`

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-panel-primary">Donaciones</h1>
          <p className="mt-1 text-sm text-panel-text-soft">
            Inventario de lo que hay disponible en cada centro de ayuda.
          </p>
        </div>
        <button
          onClick={abrirNueva}
          className="flex items-center justify-center gap-2 rounded-lg bg-panel-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark active:scale-[0.98]"
        >
          <Plus size={16} /> Registrar donación
        </button>
      </div>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-3">
        <TarjetaResumen titulo="Registros de inventario" valor={resumen.registros} icono={Boxes} color="bg-panel-info" />
        <TarjetaResumen titulo="Centros con donaciones" valor={resumen.centros} icono={Building2} color="bg-panel-success" />
        <TarjetaResumen
          titulo="Agotados"
          valor={resumen.agotados}
          icono={PackageX}
          color={resumen.agotados > 0 ? 'bg-panel-accent' : 'bg-slate-400'}
          pie={resumen.agotados > 0 ? 'Necesitan reposición' : 'Todo con existencias'}
          pieColor={resumen.agotados > 0 ? 'text-panel-accent' : undefined}
        />
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-[260px_minmax(0,1fr)]">
        <nav aria-label="Centros" className="h-fit rounded-2xl border border-panel-border bg-panel-card p-3">
          <p className="px-3 pb-2 pt-1 text-xs uppercase tracking-wide text-panel-text-muted">Centros</p>
          <button onClick={() => setCentroSel('todos')} className={botonCentro(centroSel === 'todos')}>
            Todos los centros
            <span className="tabular-nums">{donaciones.length}</span>
          </button>
          {centros
            .filter((c) => conteoPorCentro.has(c.id))
            .map((c) => (
              <button key={c.id} onClick={() => setCentroSel(c.id)} className={botonCentro(centroSel === c.id)}>
                <span className="truncate">{c.nombre}</span>
                <span className="tabular-nums">{conteoPorCentro.get(c.id)}</span>
              </button>
            ))}
        </nav>

        <section className="min-w-0 rounded-2xl border border-panel-border bg-panel-card">
          <div className="flex flex-col gap-3 px-5 pt-5 sm:flex-row sm:items-center sm:justify-between">
            <h2 className="font-bold">{centroSel === 'todos' ? 'Inventario completo' : nombreCentro(centroSel)}</h2>
            <select
              aria-label="Filtrar por tipo"
              value={filtroTipo}
              onChange={(e) => setFiltroTipo(e.target.value as 'todos' | TipoDonacion)}
              className={`${campo} sm:w-48`}
            >
              <option value="todos">Todos los tipos</option>
              {(Object.keys(tipos) as TipoDonacion[]).map((t) => (
                <option key={t} value={t}>
                  {tipos[t].etiqueta}
                </option>
              ))}
            </select>
          </div>

          <div className="mt-4 max-w-full overflow-x-auto">
            <table className="w-full min-w-[620px] text-left text-sm">
              <thead className="text-xs uppercase text-panel-text-muted">
                <tr>
                  <th className="px-5 py-3">Tipo</th>
                  {centroSel === 'todos' && <th className="px-5 py-3">Centro</th>}
                  <th className="px-5 py-3 text-right">Disponible</th>
                  <th className="px-5 py-3">Actualizado</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody>
                {filtradas.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-5 py-10 text-center text-panel-text-soft">
                      No hay donaciones registradas con esos filtros.
                    </td>
                  </tr>
                )}
                {filtradas.map((d) => {
                  const { etiqueta, icono: Icono, clase } = tipos[d.tipo]
                  return (
                    <tr key={d.id} className="border-t border-panel-border">
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-3">
                          <span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${clase}`}>
                            <Icono size={16} />
                          </span>
                          <span className="font-medium">{etiqueta}</span>
                        </div>
                      </td>
                      {centroSel === 'todos' && (
                        <td className="px-5 py-3 text-panel-text-soft">{nombreCentro(d.centroId)}</td>
                      )}
                      <td className="whitespace-nowrap px-5 py-3 text-right">
                        <span className={`font-bold tabular-nums ${d.cantidad === 0 ? 'text-panel-accent' : ''}`}>
                          {formatearNumero(d.cantidad)}
                        </span>{' '}
                        <span className="text-panel-text-soft">{d.unidad}</span>
                      </td>
                      <td className="whitespace-nowrap px-5 py-3 text-panel-text-soft">{formatearFecha(d.actualizadoEn)}</td>
                      <td className="px-5 py-3 text-right">
                        <button
                          onClick={() => abrirAjuste(d)}
                          className="text-sm font-semibold text-panel-primary hover:underline"
                        >
                          Ajustar
                        </button>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </section>
      </div>

      {nuevaAbierta && (
        <Modal titulo="Registrar donación" onCerrar={() => setNuevaAbierta(false)}>
          <form onSubmit={registrar}>
            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="centro" className="text-sm font-medium">
                  Centro que la recibe
                </label>
                <select
                  id="centro"
                  value={form.centroId}
                  onChange={(e) => setForm({ ...form, centroId: e.target.value })}
                  className={`${campo} mt-1`}
                >
                  <option value="">Elegir centro…</option>
                  {centros
                    .filter((c) => c.estado !== 'inactivo')
                    .map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.nombre}
                      </option>
                    ))}
                </select>
              </div>
              <div>
                <label htmlFor="tipoDonacion" className="text-sm font-medium">
                  Tipo
                </label>
                <select
                  id="tipoDonacion"
                  value={form.tipo}
                  onChange={(e) => {
                    const tipo = e.target.value as TipoDonacion
                    setForm({ ...form, tipo, unidad: tipos[tipo].unidad })
                  }}
                  className={`${campo} mt-1`}
                >
                  {(Object.keys(tipos) as TipoDonacion[]).map((t) => (
                    <option key={t} value={t}>
                      {tipos[t].etiqueta}
                    </option>
                  ))}
                </select>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="cantidad" className="text-sm font-medium">
                    Cantidad
                  </label>
                  <input
                    id="cantidad"
                    type="number"
                    min={1}
                    step={1}
                    inputMode="numeric"
                    value={form.cantidad}
                    onChange={(e) => setForm({ ...form, cantidad: e.target.value })}
                    className={`${campo} mt-1 tabular-nums`}
                  />
                </div>
                <div>
                  <label htmlFor="unidad" className="text-sm font-medium">
                    Unidad
                  </label>
                  <input
                    id="unidad"
                    list="unidades"
                    value={form.unidad}
                    onChange={(e) => setForm({ ...form, unidad: e.target.value })}
                    className={`${campo} mt-1`}
                  />
                  <datalist id="unidades">
                    {unidadesSugeridas.map((u) => (
                      <option key={u} value={u} />
                    ))}
                  </datalist>
                </div>
              </div>
              {existente && (
                <p className="rounded-lg bg-blue-50 px-3 py-2 text-sm text-blue-700">
                  Este centro ya tiene {formatearNumero(existente.cantidad)} {existente.unidad} de{' '}
                  {tipos[existente.tipo].etiqueta.toLowerCase()}. La cantidad se sumará a ese registro.
                </p>
              )}
            </div>

            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setNuevaAbierta(false)}
                className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark active:scale-[0.98] disabled:opacity-60"
              >
                {guardando ? 'Guardando…' : 'Registrar'}
              </button>
            </div>
          </form>
        </Modal>
      )}

      {ajuste && (
        <Modal
          titulo={`Ajustar ${tipos[ajuste.tipo].etiqueta.toLowerCase()}`}
          subtitulo={nombreCentro(ajuste.centroId)}
          onCerrar={() => setAjuste(null)}
        >
          <form onSubmit={aplicarAjuste}>
            <div className="mt-5 grid grid-cols-2 gap-2 rounded-lg border border-panel-border bg-panel-bg p-1 text-sm">
              {(
                [
                  ['entrada', 'Entrada', ArrowDownToLine],
                  ['salida', 'Salida / entrega', ArrowUpFromLine],
                ] as const
              ).map(([valor, etiqueta, Icono]) => (
                <button
                  key={valor}
                  type="button"
                  onClick={() => setMovimiento(valor)}
                  aria-pressed={movimiento === valor}
                  className={`flex items-center justify-center gap-2 rounded-md px-3 py-2 font-medium transition ${
                    movimiento === valor ? 'bg-panel-card text-panel-text shadow-sm' : 'text-panel-text-soft hover:text-panel-text'
                  }`}
                >
                  <Icono size={16} /> {etiqueta}
                </button>
              ))}
            </div>

            <label htmlFor="cantidadAjuste" className="mt-5 block text-sm font-medium">
              Cantidad ({ajuste.unidad})
            </label>
            <input
              id="cantidadAjuste"
              type="number"
              min={1}
              step={1}
              inputMode="numeric"
              autoFocus
              value={cantidadAjuste}
              onChange={(e) => setCantidadAjuste(e.target.value)}
              className={`${campo} mt-1 tabular-nums`}
            />

            <div className="mt-4 flex items-center justify-between rounded-xl bg-panel-bg px-4 py-3 text-sm">
              <span className="text-panel-text-soft">
                Disponible: <span className="font-semibold tabular-nums text-panel-text">{formatearNumero(ajuste.cantidad)}</span>
              </span>
              <span className="text-panel-text-soft">
                Quedará:{' '}
                <span
                  className={`font-bold tabular-nums ${cantidadResultante < 0 ? 'text-panel-accent' : 'text-panel-text'}`}
                >
                  {formatearNumero(cantidadResultante)}
                </span>{' '}
                {ajuste.unidad}
              </span>
            </div>

            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setAjuste(null)}
                className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando || !ajusteValido || cantidadResultante < 0}
                className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark active:scale-[0.98] disabled:opacity-40"
              >
                {guardando ? 'Guardando…' : 'Guardar ajuste'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  )
}
