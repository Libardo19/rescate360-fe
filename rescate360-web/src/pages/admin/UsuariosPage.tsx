import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { useSearchParams } from 'react-router-dom'
import {
  Users,
  ShieldCheck,
  Hourglass,
  Ban,
  CircleCheck,
  Search,
  Plus,
  Pencil,
  X,
  ChevronLeft,
  ChevronRight,
  KeyRound,
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { listarUsuarios, crearUsuario, actualizarUsuario, regenerarCodigo } from '../../services/usuarios.service'
import { listarOrganizaciones } from '../../services/organizaciones.service'
import { mensajeDeError } from '../../services/api'
import CodigoActivacion from '../../components/CodigoActivacion'
import type { UsuarioSistema, EstadoUsuario, Invitacion } from '../../types/usuarioSistema'
import type { Rol } from '../../types/auth'
import type { Organizacion } from '../../types/organizacion'

const POR_PAGINA = 6

const roles: Record<Rol, string> = {
  super_admin: 'Super admin',
  administrador: 'Administrador',
  voluntario: 'Voluntario',
  ciudadano: 'Ciudadano',
}

const estados: Record<EstadoUsuario, { etiqueta: string; clase: string }> = {
  activo: { etiqueta: 'Activo', clase: 'bg-green-100 text-green-700' },
  en_espera: { etiqueta: 'En espera', clase: 'bg-amber-100 text-amber-700' },
  bloqueado: { etiqueta: 'Bloqueado', clase: 'bg-red-100 text-red-700' },
}

const iniciales = (nombre: string) =>
  nombre
    .split(' ')
    .map((p) => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

const formatearAcceso = (iso: string | null) =>
  iso ? new Date(iso).toLocaleString('es-CO', { dateStyle: 'medium', timeStyle: 'short' }) : 'Nunca'

const campo =
  'w-full rounded-xl border border-panel-border bg-panel-card px-3.5 py-2.5 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

type Modal = { modo: 'crear' } | { modo: 'editar'; usuario: UsuarioSistema } | null

export default function UsuariosPage() {
  const { usuario: sesion } = useAuth()
  const [usuarios, setUsuarios] = useState<UsuarioSistema[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroRol, setFiltroRol] = useState<'todos' | Rol>('todos')
  const [pagina, setPagina] = useState(1)
    // ?accion=nueva abre el formulario directamente (desde la paleta de comandos o el Inicio).
  const [params, setParams] = useSearchParams()
  const abrirDesdeUrl = params.get('accion') === 'nueva'
  useEffect(() => {
    if (abrirDesdeUrl) setParams({}, { replace: true })
  }, [abrirDesdeUrl, setParams])
  const [modal, setModal] = useState<Modal>(abrirDesdeUrl ? { modo: 'crear' } : null)
  const [form, setForm] = useState({ nombre: '', email: '', telefono: '', organizacion_id: '' })
  const [invitacion, setInvitacion] = useState<Invitacion | null>(null)
  const [organizaciones, setOrganizaciones] = useState<Organizacion[]>([])
  const esSuperAdmin = sesion?.rol === 'super_admin'
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarUsuarios()
      .then(setUsuarios)
      .catch((e) => setError(mensajeDeError(e, 'No se pudieron cargar los usuarios.')))
  }, [])

  // El super admin elige a qué organización entra el voluntario que invita
  useEffect(() => {
    if (esSuperAdmin) listarOrganizaciones().then((lista) => setOrganizaciones(lista.filter((o) => o.activa))).catch(() => {})
  }, [esSuperAdmin])

  const filtrados = useMemo(() => {
    if (!usuarios) return []
    const texto = busqueda.trim().toLowerCase()
    return usuarios.filter((u) => {
      const coincideTexto =
        !texto ||
        u.nombre.toLowerCase().includes(texto) ||
        u.email.toLowerCase().includes(texto) ||
        roles[u.rol].toLowerCase().includes(texto)
      const coincideRol = filtroRol === 'todos' || u.rol === filtroRol
      return coincideTexto && coincideRol
    })
  }, [usuarios, busqueda, filtroRol])

  const resumen = useMemo(() => {
    const lista = usuarios ?? []
    return {
      total: lista.length,
      activos: lista.filter((u) => u.estado === 'activo').length,
      enEspera: lista.filter((u) => u.estado === 'en_espera').length,
      bloqueados: lista.filter((u) => u.estado === 'bloqueado').length,
    }
  }, [usuarios])

  const totalPaginas = Math.max(1, Math.ceil(filtrados.length / POR_PAGINA))
  const paginaActual = Math.min(pagina, totalPaginas)
  const inicio = (paginaActual - 1) * POR_PAGINA
  const visibles = filtrados.slice(inicio, inicio + POR_PAGINA)

  const cambiarBusqueda = (valor: string) => {
    setBusqueda(valor)
    setPagina(1)
  }

  const cambiarRol = (valor: 'todos' | Rol) => {
    setFiltroRol(valor)
    setPagina(1)
  }

  const abrirCrear = () => {
    setForm({ nombre: '', email: '', telefono: '', organizacion_id: organizaciones[0]?.id ?? '' })
    setErrorForm('')
    setModal({ modo: 'crear' })
  }

  const abrirEditar = (u: UsuarioSistema) => {
    setForm({ nombre: u.nombre, email: u.email, telefono: u.telefono ?? '', organizacion_id: u.organizacion_id ?? '' })
    setErrorForm('')
    setModal({ modo: 'editar', usuario: u })
  }

  const guardar = async (e: FormEvent) => {
    e.preventDefault()
    const actual = modal
    if (!actual) return

    const nombre = form.nombre.trim()
    const email = form.email.trim().toLowerCase()
    if (!nombre || !email) {
      setErrorForm('Completa el nombre y el correo.')
      return
    }
    if (!/^\S+@\S+\.\S+$/.test(email)) {
      setErrorForm('El correo no tiene un formato válido.')
      return
    }
    if (actual.modo === 'crear' && esSuperAdmin && !form.organizacion_id) {
      setErrorForm('Elige la organización del voluntario.')
      return
    }
    const telefono = form.telefono.trim() || undefined
    const duplicado = usuarios?.some(
      (u) => u.email === email && (actual.modo === 'crear' || u.id !== actual.usuario.id),
    )
    if (duplicado) {
      setErrorForm('Ya existe un usuario con ese correo.')
      return
    }

    setGuardando(true)
    setErrorForm('')
    try {
      if (actual.modo === 'crear') {
        const nueva = await crearUsuario({
          nombre,
          email,
          telefono,
          ...(esSuperAdmin ? { organizacion_id: form.organizacion_id } : {}),
        })
        setUsuarios((lista) => [...(lista ?? []), nueva.usuario])
        setInvitacion(nueva)
      } else {
        const actualizado = await actualizarUsuario(actual.usuario.id, { nombre, email, ...(telefono ? { telefono } : {}) })
        setUsuarios((lista) => lista?.map((u) => (u.id === actualizado.id ? actualizado : u)) ?? null)
      }
      setModal(null)
    } catch (e) {
      setErrorForm(mensajeDeError(e, 'No se pudo guardar el usuario.'))
    } finally {
      setGuardando(false)
    }
  }

  const alternarBloqueo = async (u: UsuarioSistema) => {
    const nuevo: EstadoUsuario = u.estado === 'bloqueado' ? 'activo' : 'bloqueado'
    const verbo = nuevo === 'bloqueado' ? 'bloquear' : 'desbloquear'
    if (!window.confirm(`¿Seguro que quieres ${verbo} a ${u.nombre}?`)) return
    setError('')
    try {
      const actualizado = await actualizarUsuario(u.id, { estado: nuevo })
      setUsuarios((lista) => lista?.map((x) => (x.id === actualizado.id ? actualizado : x)) ?? null)
    } catch (e) {
      setError(mensajeDeError(e, 'No se pudo cambiar el estado del usuario.'))
    }
  }

  const nuevoCodigo = async (u: UsuarioSistema) => {
    if (!window.confirm(`¿Generar un código nuevo para ${u.nombre}? El anterior deja de servir.`)) return
    setError('')
    try {
      setInvitacion(await regenerarCodigo(u.id))
    } catch (e) {
      setError(mensajeDeError(e, 'No se pudo generar el código.'))
    }
  }

  if (error && !usuarios) return <p className="text-panel-accent">{error}</p>
  if (!usuarios) return <p className="text-panel-text-soft">Cargando…</p>

  const tarjetas = [
    { valor: resumen.total, titulo: 'Total usuarios', icono: Users, color: 'bg-blue-500' },
    { valor: resumen.activos, titulo: 'Activos', icono: ShieldCheck, color: 'bg-green-600' },
    { valor: resumen.enEspera, titulo: 'En espera', icono: Hourglass, color: 'bg-amber-500' },
    { valor: resumen.bloqueados, titulo: 'Bloqueados', icono: Ban, color: 'bg-red-500' },
  ]

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="flex items-center gap-2 font-mono text-[11px] font-medium uppercase tracking-[0.16em] text-panel-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-brand" />
            Administración
          </p>
          <h1 className="mt-3 break-words text-[34px] font-semibold leading-[1] tracking-[-0.045em] sm:text-[52px] sm:tracking-[-0.05em]">Usuarios</h1>
          <p className="mt-3 max-w-2xl text-[15px] leading-relaxed text-panel-text-soft">Administra los usuarios del sistema y sus permisos.</p>
        </div>
        <button
          onClick={abrirCrear}
          className="flex items-center justify-center gap-2 rounded-full bg-navy-950 px-5 py-2.5 text-sm font-semibold text-white shadow-[0_12px_28px_-12px_rgba(11,27,54,0.8)] transition hover:bg-navy-800 active:scale-[0.98] dark:bg-white dark:text-navy-950"
        >
          <Plus size={16} /> Nuevo usuario
        </button>
      </div>

      {error && <p className="mt-3 rounded-2xl bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, icono: Icono }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-3xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border border-panel-border text-panel-text-soft`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className="text-2xl font-extrabold">{valor}</p>
            </div>
          </div>
        ))}
      </div>

      <section className="mt-6 rounded-3xl border border-panel-border bg-panel-card">
        <div className="flex flex-col gap-3 px-5 py-4 lg:flex-row lg:items-center lg:justify-between">
          <h2 className="text-lg font-semibold tracking-[-0.02em]">Lista de usuarios</h2>
          <div className="flex flex-col gap-3 sm:flex-row">
            <div className="relative">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-panel-text-muted" />
              <input
                value={busqueda}
                onChange={(e) => cambiarBusqueda(e.target.value)}
                placeholder="Buscar por nombre, email o rol"
                className={`${campo} pl-9 sm:w-72`}
              />
            </div>
            <select
              value={filtroRol}
              onChange={(e) => cambiarRol(e.target.value as 'todos' | Rol)}
              className={`${campo} sm:w-44`}
            >
              <option value="todos">Todos los roles</option>
              {(Object.keys(roles) as Rol[]).map((r) => (
                <option key={r} value={r}>
                  {roles[r]}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
              <tr>
                <th className="px-5 py-3">ID</th>
                <th className="px-5 py-3">Nombre</th>
                <th className="hidden px-5 py-3 lg:table-cell">Email</th>
                <th className="px-5 py-3">Rol</th>
                <th className="px-5 py-3">Estado</th>
                <th className="hidden px-5 py-3 md:table-cell">Último acceso</th>
                <th className="px-5 py-3 text-right">Acciones</th>
              </tr>
            </thead>
            <tbody>
              {visibles.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-5 py-10 text-center text-panel-text-soft">
                    No hay usuarios con esos filtros.
                  </td>
                </tr>
              )}
              {visibles.map((u) => {
                const esMiCuenta = u.id === sesion?.id
                return (
                  <tr key={u.id} className="border-t border-panel-border">
                    <td className="whitespace-nowrap px-5 py-3 text-panel-text-muted">{u.codigo}</td>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-3">
                        <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-panel-primary/10 text-xs font-bold text-panel-primary">
                          {iniciales(u.nombre)}
                        </span>
                        <span className="font-medium">{u.nombre}</span>
                      </div>
                    </td>
                    <td className="hidden px-5 py-3 text-panel-text-soft lg:table-cell">{u.email}</td>
                    <td className="px-5 py-3 text-panel-text-soft">{roles[u.rol]}</td>
                    <td className="px-5 py-3">
                      <span className={`rounded-full px-3 py-1 text-xs font-medium ${estados[u.estado].clase}`}>
                        {estados[u.estado].etiqueta}
                      </span>
                    </td>
                    <td className="hidden whitespace-nowrap px-5 py-3 text-panel-text-soft md:table-cell">
                      {formatearAcceso(u.ultimo_acceso)}
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex justify-end gap-1 text-panel-text-soft">
                        <button
                          onClick={() => abrirEditar(u)}
                          title="Ver y editar"
                          aria-label="Ver y editar"
                          className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                        >
                          <Pencil size={16} />
                        </button>
                        {u.estado === 'en_espera' && (
                          <button
                            onClick={() => nuevoCodigo(u)}
                            title="Generar código de activación nuevo"
                            aria-label="Generar código de activación nuevo"
                            className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary"
                          >
                            <KeyRound size={16} />
                          </button>
                        )}
                        <button
                          onClick={() => alternarBloqueo(u)}
                          disabled={esMiCuenta}
                          title={esMiCuenta ? 'No puedes bloquear tu propia cuenta' : u.estado === 'bloqueado' ? 'Desbloquear' : 'Bloquear'}
                          aria-label={u.estado === 'bloqueado' ? 'Desbloquear' : 'Bloquear'}
                          className="rounded p-2 hover:bg-panel-bg hover:text-panel-accent disabled:cursor-not-allowed disabled:opacity-30"
                        >
                          {u.estado === 'bloqueado' ? <CircleCheck size={16} /> : <Ban size={16} />}
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>

        <div className="flex flex-col items-center justify-between gap-3 border-t border-panel-border px-5 py-4 text-xs text-panel-text-muted sm:flex-row">
          <div className="flex items-center gap-1">
            <button
              onClick={() => setPagina(paginaActual - 1)}
              disabled={paginaActual === 1}
              aria-label="Página anterior"
              className="rounded p-1.5 hover:bg-panel-bg disabled:opacity-30"
            >
              <ChevronLeft size={16} />
            </button>
            {Array.from({ length: totalPaginas }, (_, i) => i + 1).map((n) => (
              <button
                key={n}
                onClick={() => setPagina(n)}
                className={`h-7 min-w-7 rounded px-2 font-medium ${
                  n === paginaActual ? 'bg-panel-info text-white' : 'text-panel-text-soft hover:bg-panel-bg'
                }`}
              >
                {n}
              </button>
            ))}
            <button
              onClick={() => setPagina(paginaActual + 1)}
              disabled={paginaActual === totalPaginas}
              aria-label="Página siguiente"
              className="rounded p-1.5 hover:bg-panel-bg disabled:opacity-30"
            >
              <ChevronRight size={16} />
            </button>
          </div>
          <p>
            {filtrados.length === 0
              ? 'Sin resultados'
              : `Mostrando ${inicio + 1} - ${inicio + visibles.length} de ${filtrados.length} usuarios`}
          </p>
        </div>
      </section>

      {modal && (
        <div
          className="panel-enfoque fixed inset-0 z-[1100] flex items-start justify-center overflow-y-auto bg-navy-950/35 p-4 backdrop-blur-md sm:p-6"
          onClick={() => setModal(null)}
        >
          <form
            onSubmit={guardar}
            className="panel-modal-enter my-auto w-full max-w-md rounded-[28px] border border-panel-border bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-semibold tracking-[-0.02em]">
                {modal.modo === 'crear' ? 'Nuevo voluntario' : 'Detalles del usuario'}
              </h2>
              <button type="button" onClick={() => setModal(null)} aria-label="Cerrar">
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
              <div>
                <label htmlFor="email" className="text-sm font-medium">
                  Correo electrónico
                </label>
                <input
                  id="email"
                  type="email"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              <div>
                <label htmlFor="telefono" className="text-sm font-medium">
                  Celular <span className="text-panel-text-muted">(opcional)</span>
                </label>
                <input
                  id="telefono"
                  type="tel"
                  placeholder="300 123 4567"
                  value={form.telefono}
                  onChange={(e) => setForm({ ...form, telefono: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
              {modal.modo === 'crear' && esSuperAdmin && (
                <div>
                  <label htmlFor="organizacion" className="text-sm font-medium">
                    Organización
                  </label>
                  <select
                    id="organizacion"
                    value={form.organizacion_id}
                    onChange={(e) => setForm({ ...form, organizacion_id: e.target.value })}
                    className={`${campo} mt-1`}
                  >
                    {organizaciones.length === 0 && <option value="">Primero crea una organización</option>}
                    {organizaciones.map((o) => (
                      <option key={o.id} value={o.id}>
                        {o.nombre}
                      </option>
                    ))}
                  </select>
                </div>
              )}
              <div>
                <label htmlFor="rol" className="text-sm font-medium">
                  Rol
                </label>
                <select id="rol" disabled value={modal.modo === 'crear' ? 'voluntario' : modal.usuario.rol} className={`${campo} mt-1 opacity-70`}>
                  {(Object.keys(roles) as Rol[]).map((r) => (
                    <option key={r} value={r}>
                      {roles[r]}
                    </option>
                  ))}
                </select>
                <p className="mt-1 text-xs text-panel-text-muted">
                  {modal.modo === 'crear'
                    ? 'Al crearlo verás un código de activación para entregarle. Queda "En espera" hasta que active su cuenta en la app.'
                    : 'Los administradores los crea el super admin, y el rol no se cambia desde aquí.'}
                </p>
              </div>
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
                {guardando ? 'Guardando…' : modal.modo === 'crear' ? 'Crear e invitar' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}

      {invitacion && <CodigoActivacion invitacion={invitacion} onCerrar={() => setInvitacion(null)} />}
    </div>
  )
}