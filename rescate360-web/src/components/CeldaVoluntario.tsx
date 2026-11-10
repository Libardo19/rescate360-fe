import type { Atencion } from '../types/solicitud'

const hora = (iso: string) => new Date(iso).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' })

// Columna "Voluntario" de solicitudes y reportes: quién lo tomó y si ya lo finalizó
export default function CeldaVoluntario({ atencion }: { atencion: Atencion | null }) {
  if (!atencion) return <span className="text-panel-text-muted">Sin asignar</span>
  return (
    <div>
      <p className="font-medium">{atencion.voluntario}</p>
      <p className={`text-[11px] ${atencion.finalizada ? 'text-green-700' : 'text-blue-700'}`}>
        {atencion.finalizada
          ? `Finalizó${atencion.hasta ? ` ${hora(atencion.hasta)}` : ''}`
          : `En atención desde ${hora(atencion.desde)}`}
      </p>
    </div>
  )
}
