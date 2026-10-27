import { useEffect, useState, type FormEvent } from 'react'
import { Ban, Building2, CircleCheck, KeyRound, Pencil, Plus, ShieldCheck, UserMinus, Users, X } from 'lucide-react'
import {
  actualizarOrganizacion,
  crearOrganizacion,
  invitarAdministrador,
  listarAdministradores,
  listarOrganizaciones,
  revocarAdministrador,
} from '../../services/organizaciones.service'
import { regenerarCodigo } from '../../services/usuarios.service'
import { mensajeDeError } from '../../services/api'
import CodigoActivacion from '../../components/CodigoActivacion'
import { TIPOS_ORGANIZACION, type Organizacion, type TipoOrganizacion } from '../../types/organizacion'
import type { Invitacion, UsuarioSistema } from '../../types/usuarioSistema'

const campo =
  'w-full rounded-lg border border-panel-border bg-panel-card px-3 py-2 text-sm outline-none focus:border-panel-primary focus:ring-2 focus:ring-panel-primary/20'

const estadoUsuario: Record<UsuarioSistema['estado'], { etiqueta: string; clase: string }> = {
  activo: { etiqueta: 'Activo', clase: 'bg-green-100 text-green-700' },
  en_espera: { etiqueta: 'En espera', clase: 'bg-amber-100 text-amber-700' },
  bloqueado: { etiqueta: 'Revocado', clase: 'bg-red-100 text-red-700' },
}

type ModalOrg = { modo: 'crear' } | { modo: 'editar'; org: Organizacion } | null

// Solo el super admin: crea organizaciones, las activa o desactiva y les asigna administradores.
export default function OrganizacionesPage() {
  const [organizaciones, setOrganizaciones] = useState<Organizacion[] | null>(null)
  const [error, setError] = useState('')
  const [modal, setModal] = useState<ModalOrg>(null)
  const [form, setForm] = useState({ nombre: '', tipo: 'cruz_roja' as TipoOrganizacion, telefono_contacto: '' })
  const [errorForm, setErrorForm] = useState('')
  const [guardando, setGuardando] = useState(false)

  const [seleccionada, setSeleccionada] = useState<Organizacion | null>(null)
  const [admins, setAdmins] = useState<UsuarioSistema[] | null>(null)
  const [nuevoAdmin, setNuevoAdmin] = useState({ nombre: '', email: '', telefono: '' })
  const [errorAdmin, setErrorAdmin] = useState('')
  const [invitacion, setInvitacion] = useState<Invitacion | null>(null)

  useEffect(() => {
    listarOrganizaciones()
      .then(setOrganizaciones)
      .catch((e) => setError(mensajeDeError(e, 'No se pudieron cargar las organizaciones.')))
  }, [])

  const elegir = (org: Organizacion) => {
    setSeleccionada(org)
    setAdmins(null)
    setErrorAdmin('')
    listarAdministradores(org.id)
      .then(setAdmins)
      .catch((e) => setErrorAdmin(mensajeDeError(e)))
  }

  const reemplazar = (org: Organizacion) => {
    setOrganizaciones((lista) => lista?.map((o) => (o.id === org.id ? org : o)) ?? null)
    if (seleccionada?.id === org.id) setSeleccionada(org)
  }

  const abrirCrear = () => {
    setForm({ nombre: '', tipo: 'cruz_roja', telefono_contacto: '' })
    setErrorForm('')
    setModal({ modo: 'crear' })
  }

  const abrirEditar = (org: Organizacion) => {
    setForm({ nombre: org.nombre, tipo: org.tipo, telefono_contacto: org.telefono_contacto ?? '' })
    setErrorForm('')
    setModal({ modo: 'editar', org })
  }

  const guardar = async (e: FormEvent) => {
    e.preventDefault()
    if (!modal) return
    const datos = {
      nombre: form.nombre.trim(),
      tipo: form.tipo,
      ...(form.telefono_contacto.trim() ? { telefono_contacto: form.telefono_contacto.trim() } : {}),
    }
    if (datos.nombre.length < 2) return setErrorForm('Escribe el nombre de la organización.')
    setGuardando(true)
    setErrorForm('')
    try {
      if (modal.modo === 'crear') {
        const nueva = await crearOrganizacion(datos)
        setOrganizaciones((lista) => [...(lista ?? []), nueva])
      } else {
        reemplazar(await actualizarOrganizacion(modal.org.id, datos))
      }
      setModal(null)
    } catch (err) {
      setErrorForm(mensajeDeError(err, 'No se pudo guardar la organización.'))
    } finally {
      setGuardando(false)
    }
  }

  const alternarActiva = async (org: Organizacion) => {
    const aviso = org.activa
      ? `¿Desactivar ${org.nombre}? Sus administradores y voluntarios pierden el acceso.`
      : `¿Reactivar ${org.nombre}?`
    if (!window.confirm(aviso)) return
    try {
      reemplazar(await actualizarOrganizacion(org.id, { activa: !org.activa }))
    } catch (err) {
      setError(mensajeDeError(err))
    }
  }

  const invitar = async (e: FormEvent) => {
    e.preventDefault()
    if (!seleccionada) return
    setErrorAdmin('')
    try {
      const nueva = await invitarAdministrador(seleccionada.id, {
        nombre: nuevoAdmin.nombre.trim(),
        email: nuevoAdmin.email.trim().toLowerCase(),
        ...(nuevoAdmin.telefono.trim() ? { telefono: nuevoAdmin.telefono.trim() } : {}),
      })
      setAdmins((lista) => [...(lista ?? []), nueva.usuario])
      setNuevoAdmin({ nombre: '', email: '', telefono: '' })
      setInvitacion(nueva)
    } catch (err) {
      setErrorAdmin(mensajeDeError(err, 'No se pudo invitar al administrador.'))
    }
  }

  const revocar = async (admin: UsuarioSistema) => {
    if (!seleccionada || !window.confirm(`¿Revocar el acceso de ${admin.nombre}?`)) return
    try {
      const actualizado = await revocarAdministrador(seleccionada.id, admin.id)
      setAdmins((lista) => lista?.map((a) => (a.id === actualizado.id ? actualizado : a)) ?? null)
    } catch (err) {
      setErrorAdmin(mensajeDeError(err))
    }
  }

  const nuevoCodigo = async (admin: UsuarioSistema) => {
    try {
      setInvitacion(await regenerarCodigo(admin.id))
    } catch (err) {
      setErrorAdmin(mensajeDeError(err))
    }
  }

  if (error && !organizaciones) return <p className="text-panel-accent">{error}</p>
  if (!organizaciones) return <p className="text-panel-text-soft">Cargando…</p>

  return (
    <div>
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-panel-primary">Organizaciones</h1>
          <p className="mt-1 text-sm text-panel-info">Crea organizaciones y asígnales sus administradores.</p>
        </div>
        <button
          onClick={abrirCrear}
          className="flex items-center justify-center gap-2 rounded-lg bg-panel-info px-4 py-2 text-sm font-semibold text-white transition hover:opacity-90"
        >
          <Plus size={16} /> Nueva organización
        </button>
      </div>

      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-6 xl:grid-cols-[minmax(0,1fr)_minmax(320px,420px)]">
        <section className="overflow-x-auto rounded-2xl border border-panel-border bg-panel-card">
          <table className="w-full text-left text-sm">
            <thead className="text-xs uppercase text-panel-text-muted">
              <tr>
                <th className="px-5 py-3">Organización</th>
                <th className="hidden px-5 py-3 md:table-cell">Tipo</th>
                <th className="hidden px-5 py-3 lg:table-cell">Teléfono</th>
                <th className="px-5 py-3">Estado</th>
                <th className="px-5 py-3 text-right">Acciones</th>
              </tr>
            </thead>
            <tbody>
              {organizaciones.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-5 py-10 text-center text-panel-text-soft">
                    Aún no hay organizaciones. Crea la primera.
                  </td>
                </tr>
              )}
              {organizaciones.map((org) => (
                <tr key={org.id} className={`border-t border-panel-border ${seleccionada?.id === org.id ? 'bg-panel-bg' : ''}`}>
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-3">
                      <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-panel-primary/10 text-panel-primary">
                        <Building2 size={16} />
                      </span>
                      <span className="font-medium">{org.nombre}</span>
                    </div>
                  </td>
                  <td className="hidden px-5 py-3 text-panel-text-soft md:table-cell">{TIPOS_ORGANIZACION[org.tipo]}</td>
                  <td className="hidden px-5 py-3 text-panel-text-soft lg:table-cell">{org.telefono_contacto ?? '—'}</td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${org.activa ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                      {org.activa ? 'Activa' : 'Desactivada'}
                    </span>
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex justify-end gap-1 text-panel-text-soft">
                      <button onClick={() => elegir(org)} title="Administradores" aria-label="Administradores" className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary">
                        <Users size={16} />
                      </button>
                      <button onClick={() => abrirEditar(org)} title="Editar" aria-label="Editar" className="rounded p-2 hover:bg-panel-bg hover:text-panel-primary">
                        <Pencil size={16} />
                      </button>
                      <button
                        onClick={() => alternarActiva(org)}
                        title={org.activa ? 'Desactivar' : 'Reactivar'}
                        aria-label={org.activa ? 'Desactivar' : 'Reactivar'}
                        className="rounded p-2 hover:bg-panel-bg hover:text-panel-accent"
                      >
                        {org.activa ? <Ban size={16} /> : <CircleCheck size={16} />}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>

        <section className="rounded-2xl border border-panel-border bg-panel-card p-5">
          {!seleccionada ? (
            <p className="text-sm text-panel-text-soft">
              Elige una organización (<Users size={14} className="inline" />) para ver y asignar sus administradores.
            </p>
          ) : (
            <>
              <h2 className="flex items-center gap-2 font-bold">
                <ShieldCheck size={18} className="text-panel-primary" /> Administradores de {seleccionada.nombre}
              </h2>
              {!seleccionada.activa && (
                <p className="mt-2 rounded-lg bg-amber-50 px-3 py-2 text-xs text-amber-900">Reactiva la organización para invitar administradores.</p>
              )}
              <ul className="mt-4 space-y-2">
                {admins === null && <li className="text-sm text-panel-text-soft">Cargando…</li>}
                {admins?.length === 0 && <li className="text-sm text-panel-text-soft">Todavía no tiene administradores.</li>}
                {admins?.map((a) => (
                  <li key={a.id} className="flex items-center justify-between gap-2 rounded-lg border border-panel-border px-3 py-2">
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium">{a.nombre}</p>
                      <p className="truncate text-xs text-panel-text-muted">{a.email}</p>
                    </div>
                    <div className="flex shrink-0 items-center gap-1">
                      <span className={`rounded-full px-2 py-0.5 text-xs ${estadoUsuario[a.estado].clase}`}>{estadoUsuario[a.estado].etiqueta}</span>
                      {a.estado === 'en_espera' && (
                        <button onClick={() => nuevoCodigo(a)} title="Código nuevo" aria-label="Código nuevo" className="rounded p-1.5 hover:bg-panel-bg hover:text-panel-primary">
                          <KeyRound size={15} />
                        </button>
                      )}
                      {a.estado !== 'bloqueado' && (
                        <button onClick={() => revocar(a)} title="Revocar acceso" aria-label="Revocar acceso" className="rounded p-1.5 hover:bg-panel-bg hover:text-panel-accent">
                          <UserMinus size={15} />
                        </button>
                      )}
                    </div>
                  </li>
                ))}
              </ul>

              <form onSubmit={invitar} className="mt-5 space-y-2 border-t border-panel-border pt-4">
                <p className="text-sm font-semibold">Invitar administrador</p>
                <input required placeholder="Nombre completo" value={nuevoAdmin.nombre} onChange={(e) => setNuevoAdmin({ ...nuevoAdmin, nombre: e.target.value })} className={campo} />
                <input required type="email" placeholder="Correo" value={nuevoAdmin.email} onChange={(e) => setNuevoAdmin({ ...nuevoAdmin, email: e.target.value })} className={campo} />
                <input type="tel" placeholder="Celular (opcional)" value={nuevoAdmin.telefono} onChange={(e) => setNuevoAdmin({ ...nuevoAdmin, telefono: e.target.value })} className={campo} />
                {errorAdmin && <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorAdmin}</p>}
                <button
                  type="submit"
                  disabled={!seleccionada.activa}
                  className="w-full rounded-lg bg-panel-primary py-2 text-sm font-semibold text-white hover:bg-panel-primary-dark disabled:opacity-50"
                >
                  Invitar y generar código
                </button>
              </form>
            </>
          )}
        </section>
      </div>

      {modal && (
        <div className="fixed inset-0 z-[1000] flex items-center justify-center bg-black/40 p-4" onClick={() => setModal(null)}>
          <form onSubmit={guardar} className="w-full max-w-md rounded-2xl bg-panel-card p-6 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-start justify-between">
              <h2 className="text-xl font-extrabold text-panel-primary">{modal.modo === 'crear' ? 'Nueva organización' : 'Editar organización'}</h2>
              <button type="button" onClick={() => setModal(null)} aria-label="Cerrar">
                <X size={20} />
              </button>
            </div>
            <div className="mt-5 space-y-4">
              <div>
                <label htmlFor="org-nombre" className="text-sm font-medium">Nombre</label>
                <input id="org-nombre" value={form.nombre} onChange={(e) => setForm({ ...form, nombre: e.target.value })} className={`${campo} mt-1`} />
              </div>
              <div>
                <label htmlFor="org-tipo" className="text-sm font-medium">Tipo</label>
                <select id="org-tipo" value={form.tipo} onChange={(e) => setForm({ ...form, tipo: e.target.value as TipoOrganizacion })} className={`${campo} mt-1`}>
                  {(Object.keys(TIPOS_ORGANIZACION) as TipoOrganizacion[]).map((t) => (
                    <option key={t} value={t}>
                      {TIPOS_ORGANIZACION[t]}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="org-telefono" className="text-sm font-medium">
                  Teléfono de contacto <span className="text-panel-text-muted">(opcional)</span>
                </label>
                <input
                  id="org-telefono"
                  type="tel"
                  placeholder="605 570 0000"
                  value={form.telefono_contacto}
                  onChange={(e) => setForm({ ...form, telefono_contacto: e.target.value })}
                  className={`${campo} mt-1`}
                />
              </div>
            </div>
            {errorForm && <p className="mt-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{errorForm}</p>}
            <div className="mt-6 flex justify-end gap-3">
              <button type="button" onClick={() => setModal(null)} className="rounded-lg border border-panel-border px-4 py-2 text-sm text-panel-text-soft hover:bg-panel-bg">
                Cancelar
              </button>
              <button type="submit" disabled={guardando} className="rounded-lg bg-panel-primary px-5 py-2 text-sm font-semibold text-white hover:bg-panel-primary-dark disabled:opacity-60">
                {guardando ? 'Guardando…' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}

      {invitacion && <CodigoActivacion invitacion={invitacion} onCerrar={() => setInvitacion(null)} />}
    </div>
  )
}
