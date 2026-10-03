const funciones = [
  { icono: '🚨', titulo: 'Reportar incidentes', texto: 'Accidentes, incendios, inundaciones y más, con ubicación y evidencias.' },
  { icono: '🆘', titulo: 'Solicitar ayuda', texto: 'Pide asistencia médica, alimentaria, refugio o rescate.' },
  { icono: '🗺️', titulo: 'Mapa en tiempo real', texto: 'Incidentes, alertas y centros de ayuda cerca de ti.' },
  { icono: '🔔', titulo: 'Alertas de tu zona', texto: 'Entérate de lo que ocurre en tu comunidad al momento.' },
  { icono: '🏥', titulo: 'Centros de ayuda', texto: 'Refugios, centros de salud y puntos de acopio por cercanía.' },
  { icono: '🔎', titulo: 'Personas desaparecidas', texto: 'Consulta y colabora en la búsqueda de personas.' },
  { icono: '📖', titulo: 'Guía de emergencia', texto: 'Qué hacer ante sismos, inundaciones, incendios y primeros auxilios.' },
  { icono: '❤️', titulo: 'Donaciones', texto: 'Apoya a las personas afectadas por emergencias.' },
  { icono: '📍', titulo: 'Botón SOS', texto: 'Comparte tu ubicación con organismos y voluntarios cercanos.' },
]

export default function Funciones() {
  return (
    <section id="funciones" className="scroll-mt-20 border-t border-surface-border">
      <div className="mx-auto max-w-6xl px-6 py-24">
        <h2 className="text-center text-3xl font-extrabold sm:text-4xl">Todo lo que necesitas en una emergencia</h2>
        <p className="mx-auto mt-3 max-w-2xl text-center text-ink-soft">
          Herramientas pensadas para actuar rápido y mantener a tu comunidad informada.
        </p>

        <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {funciones.map((f) => (
            <div key={f.titulo} className="rounded-2xl border border-surface-border bg-surface p-6 transition-all duration-300 hover:-translate-y-1 hover:border-primary/60 hover:shadow-lg hover:shadow-primary/5">
              <div className="text-3xl">{f.icono}</div>
              <h3 className="mt-4 text-lg font-bold">{f.titulo}</h3>
              <p className="mt-2 text-sm text-ink-soft">{f.texto}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}