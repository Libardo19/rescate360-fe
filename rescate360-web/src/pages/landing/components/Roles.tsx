import { Link } from 'react-router-dom'

const roles = [
  {
    nombre: 'Ciudadano',
    plataforma: 'App móvil',
    texto: 'Reporta incidentes, solicita ayuda y consulta mapa, alertas y guía de emergencia.',
    web: false,
  },
  {
    nombre: 'Voluntario',
    plataforma: 'App móvil',
    texto: 'Pertenece a una organización y hace seguimiento de solicitudes y reportes.',
    web: false,
  },
  {
    nombre: 'Administrador',
    plataforma: 'Plataforma web',
    texto: 'Gestiona su organización: verifica reportes, prioriza solicitudes y administra centros y alertas.',
    web: true,
  },
  {
    nombre: 'Super admin',
    plataforma: 'Plataforma web',
    texto: 'Administra organizaciones y administradores, con visión global de la plataforma.',
    web: true,
  },
]

export default function Roles() {
  return (
    <section id="roles" className="scroll-mt-20 border-t border-surface-border bg-surface/40">
      <div className="mx-auto max-w-6xl px-6 py-24">
        <h2 className="text-center text-3xl font-extrabold sm:text-4xl">Una plataforma, cada quien con su rol</h2>
        <p className="mx-auto mt-3 max-w-2xl text-center text-ink-soft">
          La comunidad usa la app móvil y las organizaciones gestionan desde la web.
        </p>

        <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {roles.map((r) => (
            <div key={r.nombre} className="flex flex-col rounded-2xl border border-surface-border bg-surface p-6">
              <span className="w-fit rounded-full bg-surface-elevated px-3 py-1 text-xs text-ink-soft">{r.plataforma}</span>
              <h3 className="mt-4 text-lg font-bold">{r.nombre}</h3>
              <p className="mt-2 flex-1 text-sm text-ink-soft">{r.texto}</p>
              {r.web && (
                <Link to="/login" className="mt-5 text-sm font-semibold text-primary hover:underline">
                  Iniciar sesión →
                </Link>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}