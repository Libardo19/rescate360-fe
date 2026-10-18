import { useEffect, useMemo, useState, type FormEvent } from 'react'
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
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { listarUsuarios, crearUsuario, actualizarUsuario } from '../../services/usuarios.service'
import type { UsuarioSistema, RolGestionable, EstadoUsuario } from '../../types/usuarioSistema'

const POR_PAGINA = 6

const roles: Record<RolGestionable, string> = {
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
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

type Modal = { modo: 'crear' } | { modo: 'editar'; usuario: UsuarioSistema } | null

export default function UsuariosPage() {
  const { usuario: sesion } = useAuth()
  const [usuarios, setUsuarios] = useState<UsuarioSistema[] | null>(null)
  const [error, setError] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [filtroRol, setFiltroRol] = useState<'todos' | RolGestionable>('todos')
  const [pagina, setPagina] = useState(1)
  const [modal, setModal] = useState<Modal>(null)
  const [form, setForm] = useState({ nombre: '', email: '' })
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  useEffect(() => {
    listarUsuarios()
      .then(setUsuarios)
      .catch(() => setError('No se pudieron cargar los usuarios.'))
  }, [])

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

  const cambiarRol = (valor: 'todos' | RolGestionable) => {
    setFiltroRol(valor)
    setPagina(1)
  }

  const abrirCrear = () => {
    setForm({ nombre: '', email: '' })
    setErrorForm('')
    setModal({ modo: 'crear' })
  }

  const abrirEditar = (u: UsuarioSistema) => {
    setForm({ nombre: u.nombre, email: u.email })
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
        const nuevo = await crearUsuario({ nombre, email })
        setUsuarios((lista) => [...(lista ?? []), nuevo])
      } else {
        const actualizado = await actualizarUsuario(actual.usuario.id, { nombre, email })
        setUsuarios((lista) => lista?.map((u) => (u.id === actualizado.id ? actualizado : u)) ?? null)
      }
      setModal(null)
    } catch {
      setErrorForm('No se pudo guardar el usuario.')
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
    } catch {
      setError('No se pudo cambiar el estado del usuario.')
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
          <h1 className="text-2xl font-extrabold text-panel-primary">Usuarios</h1>
          <p className="mt-1 text-sm text-panel-info">Administra los usuarios del sistema y sus permisos.</p>
        </div>
        <button
          onClick={abrirCrear}
          className="flex items-center justify-center gap-2 rounded-lg bg-panel-info px-4 py-2 text-sm font-semibold text-white transition hover:opacity-90"
        >
          <Plus size={16} /> Nuevo usuario
        </button>
      </div>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ valor, titulo, icono: Icono, color }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-full text-white ${color}`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className="text-2xl font-extrabold">{valor}</p>
            </div>
          </div>
        ))}
      </div>

      <section className="mt-6 rounded-2xl border border-panel-border bg-panel-card">
        <div className="flex flex-col gap-3 px-5 py-4 lg:flex-row lg:items-center lg:justify-between">
          <h2 className="font-bold">Lista de usuarios</h2>
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
              onChange={(e) => cambiarRol(e.target.value as 'todos' | RolGestionable)}
              className={`${campo} sm:w-44`}
            >
              <option value="todos">Todos los roles</option>
              {(Object.keys(roles) as RolGestionable[]).map((r) => (
                <option key={r} value={r}>
                  {roles[r]}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="text-xs uppercase text-panel-text-muted">
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
                const esMiCuenta = u.email === sesion?.email
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
                      {formatearAcceso(u.ultimoAcceso)}
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
          className="fixed inset-0 z-[1000] flex items-center justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setModal(null)}
        >
          <form
            onSubmit={guardar}
            className="w-full max-w-md rounded-2xl bg-panel-card p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-extrabold text-panel-primary">
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
                <label htmlFor="rol" className="text-sm font-medium">
                  Rol
                </label>
                <select id="rol" disabled value={modal.modo === 'crear' ? 'voluntario' : modal.usuario.rol} className={`${campo} mt-1 opacity-70`}>
                  {(Object.keys(roles) as RolGestionable[]).map((r) => (
                    <option key={r} value={r}>
                      {roles[r]}
                    </option>
                  ))}
                </select>
                <p className="mt-1 text-xs text-panel-text-muted">
                  {modal.modo === 'crear'
                    ? 'El nuevo usuario recibirá una invitación y quedará "En espera" hasta activar su cuenta.'
                    : 'Los administradores los crea el super admin, y el rol no se cambia desde aquí.'}
                </p>
              </div>
            </div>

            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}

            <div className="mt-6 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setModal(null)}
                className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft transition hover:bg-panel-bg"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={guardando}
                className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white transition hover:bg-panel-primary-dark disabled:opacity-60"
              >
                {guardando ? 'Guardando…' : modal.modo === 'crear' ? 'Crear e invitar' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}