import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { useSearchParams } from 'react-router-dom'
import { Search, UserPlus, Users, ShieldCheck, HeartHandshake, Power, Mail, Phone } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import {
  listarMiembros,
  buscarUsuarioPorCorreo,
  asignarVoluntario,
  cambiarActivoVoluntario,
} from '../../services/usuarios.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import type { MiembroOrganizacion, UsuarioEncontrado } from '../../types/usuarioAdmin'
import Modal from '../../components/panel/Modal'
import CabeceraPanel, { botonCabeceraPrincipal } from '../../components/panel/CabeceraPanel'

type FiltroRol = 'todos' | 'voluntario' | 'administrador'

const formatearFecha = (iso: string) => new Date(iso).toLocaleDateString('es-CO', { dateStyle: 'medium' })

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

// Un voluntario sin perfil se considera activo (perfiles_voluntario.activo tiene DEFAULT TRUE).
const estaActivo = (m: MiembroOrganizacion) => m.perfil?.activo ?? true

const iniciales = (nombre: string) =>
  nombre
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0])
    .join('')
    .toUpperCase()

export default function UsuariosPage() {
  const { usuario } = useAuth()
  const organizacionId = usuario?.organizacion_id ?? ''

  const [miembros, setMiembros] = useState<MiembroOrganizacion[] | null>(null)
  const [nombreOrg, setNombreOrg] = useState('')
  const [error, setError] = useState('')
  const [aviso, setAviso] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroRol, setFiltroRol] = useState<FiltroRol>('todos')

  // Modal "Agregar voluntario"
    // ?accion=nueva abre el formulario directamente (desde la paleta de comandos o el Inicio).
  const [params, setParams] = useSearchParams()
  const abrirDesdeUrl = params.get('accion') === 'nueva'
  useEffect(() => {
    if (abrirDesdeUrl) setParams({}, { replace: true })
  }, [abrirDesdeUrl, setParams])
  const [modalAbierto, setModalAbierto] = useState(abrirDesdeUrl)
  const [correo, setCorreo] = useState('')
  const [encontrado, setEncontrado] = useState<UsuarioEncontrado | null>(null)
  const [noExiste, setNoExiste] = useState(false)
  const [disponibilidad, setDisponibilidad] = useState('')
  const [certificaciones, setCertificaciones] = useState('')
  const [errorForm, setErrorForm] = useState('')
  const [ocupado, setOcupado] = useState(false)

  useEffect(() => {
    listarMiembros(organizacionId)
      .then(setMiembros)
      .catch(() => setError('No se pudieron cargar los usuarios.'))
    listarOrganizaciones()
      .then((orgs) => setNombreOrg(orgs.find((o) => o.id === organizacionId)?.nombre ?? ''))
      .catch(() => setNombreOrg(''))
  }, [organizacionId])

  const filtrados = useMemo(() => {
    const texto = busqueda.trim().toLowerCase()
    return (miembros ?? [])
      .filter((m) => filtroRol === 'todos' || m.rol === filtroRol)
      .filter((m) => !texto || m.nombre.toLowerCase().includes(texto) || m.correo.toLowerCase().includes(texto))
      .sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'))
  }, [miembros, busqueda, filtroRol])

  const resumen = useMemo(() => {
    const voluntarios = (miembros ?? []).filter((m) => m.rol === 'voluntario')
    return {
      voluntariosActivos: voluntarios.filter(estaActivo).length,
      voluntarios: voluntarios.length,
      administradores: (miembros ?? []).length - voluntarios.length,
    }
  }, [miembros])

  const abrirModal = () => {
    setCorreo('')
    setEncontrado(null)
    setNoExiste(false)
    setDisponibilidad('')
    setCertificaciones('')
    setErrorForm('')
    setModalAbierto(true)
  }

  const buscar = async (e: FormEvent) => {
    e.preventDefault()
    if (!/^\S+@\S+\.\S+$/.test(correo.trim())) {
      setErrorForm('Escribe un correo válido.')
      return
    }
    setOcupado(true)
    setErrorForm('')
    setEncontrado(null)
    setNoExiste(false)
    try {
      const u = await buscarUsuarioPorCorreo(correo)
      if (u) setEncontrado(u)
      else setNoExiste(true)
    } catch {
      setErrorForm('No se pudo hacer la búsqueda.')
    } finally {
      setOcupado(false)
    }
  }

  const confirmarAsignacion = async () => {
    if (!encontrado) return
    setOcupado(true)
    setErrorForm('')
    const perfil =
      disponibilidad.trim() || certificaciones.trim()
        ? { disponibilidad: disponibilidad.trim() || null, certificaciones: certificaciones.trim() || null }
        : null
    try {
      const nuevo = await asignarVoluntario(organizacionId, encontrado, perfil)
      setMiembros((lista) => [nuevo, ...(lista ?? [])])
      setModalAbierto(false)
      setAviso(`${nuevo.nombre} ahora es voluntario(a) de tu organización.`)
    } catch {
      setErrorForm('No se pudo asignar el rol. Es posible que el usuario ya no sea ciudadano.')
    } finally {
      setOcupado(false)
    }
  }

  const alternarActivo = async (m: MiembroOrganizacion) => {
    const activar = !estaActivo(m)
    const pregunta = activar
      ? `¿Reactivar a ${m.nombre}? Podrá recibir asignaciones de nuevo.`
      : `¿Desactivar a ${m.nombre}? No se le asignarán nuevas emergencias.${
          m.asignacionesActivas > 0 ? ` Tiene ${m.asignacionesActivas} asignación(es) activa(s).` : ''
        }`
    if (!window.confirm(pregunta)) return
    setError('')
    try {
      const actualizado = await cambiarActivoVoluntario(m.id, activar)
      setMiembros((lista) => lista?.map((x) => (x.id === actualizado.id ? actualizado : x)) ?? null)
    } catch {
      setError('No se pudo cambiar el estado del voluntario.')
    }
  }

  if (error && !miembros) return <p className="text-panel-accent">{error}</p>
  if (!miembros) return <p className="text-panel-text-soft">Cargando…</p>

  // Mensaje según el resultado de la búsqueda por correo.
  const yaEsMiembro = encontrado && miembros.some((m) => m.id === encontrado.id)
  const motivoNoAsignable = !encontrado
    ? ''
    : yaEsMiembro
      ? 'Este usuario ya pertenece a tu organización.'
      : encontrado.rol !== 'ciudadano'
        ? 'Este usuario ya está afiliado a otra organización o tiene un rol administrativo. Solo se pueden reclutar ciudadanos.'
        : ''

  return (
    <div>
      <CabeceraPanel
        seccion="Administración"
        titulo="Usuarios"
        descripcion={`Voluntarios y administradores de ${nombreOrg || 'tu organización'}.`}
        acciones={
          <button onClick={abrirModal} className={botonCabeceraPrincipal}>
            <UserPlus size={16} /> Agregar voluntario
          </button>
        }
        estadisticas={[
          {
            titulo: 'Voluntarios activos',
            valor: resumen.voluntariosActivos,
            icono: HeartHandshake,
            pie: `De ${resumen.voluntarios} voluntarios`,
          },
          { titulo: 'Administradores', valor: resumen.administradores, icono: ShieldCheck, pie: 'Gestionan el panel' },
          { titulo: 'Miembros en total', valor: miembros.length, icono: Users, pie: 'En tu organización' },
        ]}
      />

      {error && <p className="mb-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
      {aviso && (
        <p className="mb-3 flex items-center justify-between gap-3 rounded-2xl bg-green-50 px-3 py-2 text-sm text-green-700">
          {aviso}
          <button onClick={() => setAviso('')} className="text-xs font-semibold hover:underline">
            Cerrar
          </button>
        </p>
      )}

      <div className="flex flex-col gap-3 sm:flex-row">
        <div className="relative flex-1">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
          <input
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            placeholder="Buscar por nombre o correo"
            className={`${campo} pl-9`}
          />
        </div>
        <div className="inline-flex w-fit rounded-lg border border-panel-border bg-panel-card p-1 text-sm">
          {(
            [
              ['todos', 'Todos'],
              ['voluntario', 'Voluntarios'],
              ['administrador', 'Administradores'],
            ] as const
          ).map(([valor, etiqueta]) => (
            <button
              key={valor}
              onClick={() => setFiltroRol(valor)}
              className={`rounded-full px-3 py-1.5 font-medium transition ${
                filtroRol === valor ? 'bg-panel-primary text-white' : 'text-panel-text-soft hover:text-panel-text'
              }`}
            >
              {etiqueta}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-4 max-w-full overflow-x-auto rounded-3xl border border-panel-border bg-panel-card">
        <table className="w-full min-w-[820px] text-left text-sm">
          <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
            <tr>
              <th className="px-5 py-3">Usuario</th>
              <th className="px-5 py-3">Rol</th>
              <th className="px-5 py-3">Disponibilidad</th>
              <th className="px-5 py-3 text-right">Asignaciones</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3" />
            </tr>
          </thead>
          <tbody>
            {filtrados.length === 0 && (
              <tr>
                <td colSpan={6} className="px-5 py-10 text-center text-panel-text-soft">
                  No hay usuarios con esos filtros.
                </td>
              </tr>
            )}
            {filtrados.map((m) => {
              const voluntario = m.rol === 'voluntario'
              const activo = estaActivo(m)
              const soyYo = m.id === usuario?.id
              return (
                <tr key={m.id} className="border-t border-panel-border">
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-3">
                      <span
                        aria-hidden="true"
                        className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-panel-bg text-xs font-bold text-panel-primary"
                      >
                        {iniciales(m.nombre)}
                      </span>
                      <div className="min-w-0">
                        <p className="font-medium">
                          {m.nombre}
                          {soyYo && <span className="ml-1 text-xs font-normal text-panel-text-muted">(tú)</span>}
                        </p>
                        <p className="flex flex-wrap gap-x-3 text-xs text-panel-text-muted">
                          <span className="flex items-center gap-1">
                            <Mail size={11} /> {m.correo}
                          </span>
                          {m.telefono && (
                            <span className="flex items-center gap-1">
                              <Phone size={11} /> {m.telefono}
                            </span>
                          )}
                        </p>
                      </div>
                    </div>
                  </td>
                  <td className="px-5 py-3">
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-medium ${
                        voluntario ? 'bg-blue-100 text-blue-700' : 'bg-navy-800 text-white'
                      }`}
                    >
                      {voluntario ? 'Voluntario' : 'Administrador'}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">
                    {voluntario ? (
                      <>
                        <p>{m.perfil?.disponibilidad ?? '—'}</p>
                        {m.perfil?.certificaciones && (
                          <p className="max-w-[220px] truncate text-xs text-panel-text-muted" title={m.perfil.certificaciones}>
                            {m.perfil.certificaciones}
                          </p>
                        )}
                      </>
                    ) : (
                      '—'
                    )}
                  </td>
                  <td className="px-5 py-3 text-right tabular-nums">{voluntario ? m.asignacionesActivas : '—'}</td>
                  <td className="px-5 py-3">
                    {voluntario ? (
                      <span
                        className={`rounded-full px-3 py-1 text-xs font-medium ${
                          activo ? 'bg-green-100 text-green-700' : 'bg-slate-200 text-slate-600'
                        }`}
                      >
                        {activo ? 'Activo' : 'Inactivo'}
                      </span>
                    ) : (
                      <span className="text-xs text-panel-text-muted">Desde {formatearFecha(m.creadoEn)}</span>
                    )}
                  </td>
                  <td className="px-5 py-3 text-right">
                    {voluntario && (
                      <button
                        onClick={() => alternarActivo(m)}
                        title={activo ? 'Desactivar voluntario' : 'Reactivar voluntario'}
                        aria-label={activo ? `Desactivar a ${m.nombre}` : `Reactivar a ${m.nombre}`}
                        className="rounded p-2 text-panel-text-soft transition hover:bg-panel-bg hover:text-panel-accent"
                      >
                        <Power size={16} />
                      </button>
                    )}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      <p className="mt-3 text-xs text-panel-text-muted">
        Los administradores solo los puede crear o cambiar el super administrador.
      </p>

      {modalAbierto && (
        <Modal titulo="Agregar voluntario" subtitulo="Busca a un ciudadano registrado en la app por su correo." onCerrar={() => setModalAbierto(false)}>
          <form onSubmit={buscar} className="mt-5 flex gap-2">
            <label htmlFor="correo" className="sr-only">
              Correo del ciudadano
            </label>
            <input
              id="correo"
              type="email"
              autoFocus
              value={correo}
              onChange={(e) => {
                setCorreo(e.target.value)
                setEncontrado(null)
                setNoExiste(false)
              }}
              placeholder="correo@ejemplo.com"
              className={campo}
            />
            <button
              type="submit"
              disabled={ocupado || !correo.trim()}
              className="shrink-0 rounded-lg border border-panel-primary px-4 py-2 text-sm font-semibold text-panel-primary transition hover:bg-panel-bg disabled:opacity-40"
            >
              Buscar
            </button>
          </form>

          {noExiste && (
            <p className="mt-4 rounded-lg bg-panel-bg px-3 py-2 text-sm text-panel-text-soft">
              No hay ningún usuario con ese correo. La persona debe registrarse primero en la app.
            </p>
          )}

          {encontrado && (
            <div className="mt-4 rounded-xl border border-panel-border p-4">
              <p className="font-semibold">{encontrado.nombre}</p>
              <p className="text-sm text-panel-text-soft">{encontrado.correo}</p>

              {motivoNoAsignable ? (
                <p className="mt-3 rounded-lg bg-amber-50 px-3 py-2 text-sm text-amber-800">{motivoNoAsignable}</p>
              ) : (
                <div className="mt-4 space-y-4">
                  <p className="text-xs uppercase tracking-wide text-panel-text-muted">Perfil de voluntario (opcional)</p>
                  <div>
                    <label htmlFor="disponibilidad" className="text-sm font-medium">
                      Disponibilidad
                    </label>
                    <input
                      id="disponibilidad"
                      value={disponibilidad}
                      onChange={(e) => setDisponibilidad(e.target.value)}
                      placeholder="Ej: Fines de semana, noches"
                      className={`${campo} mt-1`}
                    />
                  </div>
                  <div>
                    <label htmlFor="certificaciones" className="text-sm font-medium">
                      Certificaciones
                    </label>
                    <textarea
                      id="certificaciones"
                      rows={2}
                      value={certificaciones}
                      onChange={(e) => setCertificaciones(e.target.value)}
                      placeholder="Ej: Primeros auxilios, rescate en alturas"
                      className={`${campo} mt-1`}
                    />
                  </div>
                </div>
              )}
            </div>
          )}

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
              type="button"
              onClick={confirmarAsignacion}
              disabled={ocupado || !encontrado || !!motivoNoAsignable}
              className="rounded-full bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark active:scale-[0.98] disabled:opacity-40"
            >
              {ocupado && encontrado ? 'Asignando…' : 'Hacer voluntario'}
            </button>
          </div>
        </Modal>
      )}
    </div>
  )
}
