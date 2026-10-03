const pasos = [
  {
    numero: '1',
    titulo: 'Reporta o solicita ayuda',
    texto:
      'Describe lo que ocurre, comparte tu ubicación y adjunta fotos o videos desde la app.',
  },
  {
    numero: '2',
    titulo: 'Se prioriza y se verifica',
    texto:
      'La IA propone una prioridad y la organización verifica el reporte. La decisión del administrador siempre prevalece.',
  },
  {
    numero: '3',
    titulo: 'Se atiende y se hace seguimiento',
    texto:
      'Los voluntarios de la organización acuden, actualizan el estado y mantienen informada a la comunidad.',
  },
]

export default function ComoFunciona() {
  return (
    <section id="como-funciona" className="scroll-mt-20 border-t border-surface-border bg-surface/40">
      <div className="mx-auto max-w-6xl px-6 py-24">
        <h2 className="text-center text-3xl font-extrabold sm:text-4xl">¿Cómo funciona?</h2>
        <p className="mx-auto mt-3 max-w-2xl text-center text-ink-soft">
          De la alerta a la atención, en tres pasos.
        </p>

        <div className="mt-14 grid gap-6 md:grid-cols-3">
          {pasos.map((paso) => (
            <div
              key={paso.numero}
              className="rounded-2xl border border-surface-border bg-surface p-6"
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-lg font-bold">
                {paso.numero}
              </div>
              <h3 className="mt-5 text-lg font-bold">{paso.titulo}</h3>
              <p className="mt-2 text-sm text-ink-soft">{paso.texto}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}