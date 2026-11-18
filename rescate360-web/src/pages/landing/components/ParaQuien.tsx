import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { Aparecer, EncabezadoSeccion } from './comunes'

const roles = [
  {
    nombre: 'Ciudadanos',
    donde: 'App móvil',
    texto: 'Reportan incidentes, piden ayuda, reciben alertas y encuentran centros de ayuda cercanos.',
  },
  {
    nombre: 'Voluntarios',
    donde: 'App móvil',
    texto: 'Se unen a una organización, reciben asignaciones y apoyan en terreno.',
  },
  {
    nombre: 'Organizaciones',
    donde: 'Panel web',
    texto: 'Bomberos, Cruz Roja, Defensa Civil y ONG atienden solo lo que les corresponde.',
  },
  {
    nombre: 'Administradores',
    donde: 'Panel web',
    texto: 'Verifican reportes, priorizan solicitudes, publican alertas y auditan cada cambio.',
    acceso: true,
  },
]

export default function ParaQuien() {
  return (
    <section id="para-quien" className="scroll-mt-24 px-5 py-20 sm:px-6 sm:py-28">
      <div className="mx-auto grid max-w-6xl gap-12 lg:grid-cols-[0.8fr_1.2fr]">
        <div className="lg:sticky lg:top-28 lg:self-start">
          <EncabezadoSeccion
            etiqueta="Para quién"
            titulo={
              <>
                Una red,
                <br />
                <span className="text-slate-400 dark:text-white/40">cuatro roles.</span>
              </>
            }
            texto="Cada persona ve lo que necesita. Cada organización gestiona solo lo suyo."
          />
        </div>

        <ul className="divide-y divide-slate-200 border-y border-slate-200 dark:divide-white/10 dark:border-white/10">
          {roles.map((r, i) => (
            <Aparecer key={r.nombre} retraso={i * 0.08}>
              <li className="group grid gap-2 py-7 sm:grid-cols-[180px_1fr_auto] sm:items-baseline sm:gap-6">
                <h3 className="font-display text-2xl font-semibold tracking-[-0.025em] text-navy-950 transition group-hover:translate-x-1 dark:text-white">
                  {r.nombre}
                </h3>
                <p className="text-sm leading-relaxed text-slate-600 dark:text-white/55">{r.texto}</p>
                {r.acceso ? (
                  <Link
                    to="/login"
                    className="inline-flex items-center gap-1 justify-self-start rounded-full bg-navy-950 px-3 py-1 font-mono text-[11px] uppercase tracking-[0.12em] text-white transition hover:bg-brand sm:justify-self-end dark:bg-white dark:text-navy-950 dark:hover:bg-brand dark:hover:text-white"
                  >
                    Ingresar <ArrowUpRight size={12} />
                  </Link>
                ) : (
                  <span className="justify-self-start font-mono text-[11px] uppercase tracking-[0.12em] text-slate-400 sm:justify-self-end dark:text-white/40">
                    {r.donde}
                  </span>
                )}
              </li>
            </Aparecer>
          ))}
        </ul>
      </div>
    </section>
  )
}
