import { useEffect, useState } from 'react'
import { FileWarning, LifeBuoy, Bell, Building2 } from 'lucide-react'
import { obtenerDashboardAdmin } from '../../services/dashboard.service'
import type { DashboardAdmin } from '../../types/dashboard'

const colorEstado: Record<string, string> = {
  'En revisión': 'bg-amber-100 text-amber-700',
  Confirmado: 'bg-green-100 text-green-700',
  'En proceso': 'bg-blue-100 text-blue-700',
  Pendiente: 'bg-slate-100 text-slate-600',
}

export default function AdminDashboard() {
  const [datos, setDatos] = useState<DashboardAdmin | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    obtenerDashboardAdmin()
      .then(setDatos)
      .catch(() => setError('No se pudo cargar el resumen.'))
  }, [])

  if (error) return <p className="text-panel-accent">{error}</p>
  if (!datos) return <p className="text-panel-text-soft">Cargando…</p>

  const { resumen, recientes } = datos
  const tarjetas = [
    { titulo: 'Reportes pendientes', valor: resumen.reportesPendientes, icono: FileWarning, color: 'bg-red-500' },
    { titulo: 'Solicitudes activas', valor: resumen.solicitudesActivas, icono: LifeBuoy, color: 'bg-blue-500' },
    { titulo: 'Alertas activas', valor: resumen.alertasActivas, icono: Bell, color: 'bg-amber-500' },
    { titulo: 'Centros de ayuda', valor: resumen.centrosRegistrados, icono: Building2, color: 'bg-green-600' },
  ]

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Dashboard</h1>
      <p className="mt-1 text-sm text-panel-text-soft">Resumen operativo de tu organización.</p>

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ titulo, valor, icono: Icono, color }) => (
          <div key={titulo} className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5">
            <div className={`flex h-12 w-12 items-center justify-center rounded-full text-white ${color}`}>
              <Icono size={22} />
            </div>
            <div>
              <p className="text-2xl font-extrabold">{valor}</p>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-8 rounded-2xl border border-panel-border bg-panel-card">
        <h2 className="border-b border-panel-border px-5 py-4 font-bold">Actividad reciente</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="text-xs uppercase text-panel-text-muted">
              <tr>
                <th className="px-5 py-3">Tipo</th>
                <th className="px-5 py-3">Descripción</th>
                <th className="px-5 py-3">Estado</th>
                <th className="px-5 py-3">Cuándo</th>
              </tr>
            </thead>
            <tbody>
              {recientes.map((r) => (
                <tr key={r.id} className="border-t border-panel-border">
                  <td className="px-5 py-3 capitalize">{r.tipo}</td>
                  <td className="px-5 py-3">
                    <p className="font-medium">{r.titulo}</p>
                    <p className="text-xs text-panel-text-muted">{r.detalle}</p>
                  </td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorEstado[r.estado] ?? 'bg-slate-100 text-slate-600'}`}>
                      {r.estado}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-panel-text-soft">{r.hace}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}