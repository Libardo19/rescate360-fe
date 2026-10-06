import { Construction } from 'lucide-react'

export default function PaginaEnConstruccion({ titulo }: { titulo: string }) {
  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">{titulo}</h1>
      <div className="mt-6 flex flex-col items-center rounded-2xl border border-dashed border-panel-border bg-panel-card px-6 py-20 text-center">
        <Construction size={36} className="text-panel-text-muted" />
        <p className="mt-3 font-semibold">Sección en construcción</p>
        <p className="mt-1 text-sm text-panel-text-soft">Esta pantalla se diseñará próximamente.</p>
      </div>
    </div>
  )
}