import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Building2, Users, LifeBuoy, FileWarning } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { api, consulta, mensajeDeError, USE_MOCK, type Pagina } from '../../services/api'

interface Totales {
  organizaciones: number
  usuarios: number
  solicitudes: number
  reportes: number
}

// Cuántos hay de cada cosa: basta con pedir una página de 1 y leer `total`
const contar = async (ruta: string) => (await api<Pagina<unknown>>(`${ruta}${consulta({ por_pagina: 1 })}`)).total

export default function SuperAdminDashboard() {
  const { usuario } = useAuth()
  const [totales, setTotales] = useState<Totales | null>(() =>
    USE_MOCK ? { organizaciones: 2, usuarios: 7, solicitudes: 0, reportes: 0 } : null,
  )
  const [error, setError] = useState('')

  useEffect(() => {
    if (USE_MOCK) return
    Promise.all([contar('/organizaciones'), contar('/usuarios'), contar('/solicitudes-ayuda'), contar('/reportes')])
      .then(([organizaciones, usuarios, solicitudes, reportes]) => setTotales({ organizaciones, usuarios, solicitudes, reportes }))
      .catch((e) => setError(mensajeDeError(e, 'No se pudo cargar el resumen.')))
  }, [])

  const tarjetas = [
    { titulo: 'Organizaciones', valor: totales?.organizaciones, icono: Building2, ruta: '/superadmin/organizaciones', color: 'bg-blue-500' },
    { titulo: 'Usuarios', valor: totales?.usuarios, icono: Users, ruta: '/superadmin/usuarios', color: 'bg-green-600' },
    { titulo: 'Solicitudes de ayuda', valor: totales?.solicitudes, icono: LifeBuoy, ruta: '/superadmin/solicitudes', color: 'bg-amber-500' },
    { titulo: 'Reportes', valor: totales?.reportes, icono: FileWarning, ruta: '/superadmin/reportes', color: 'bg-red-500' },
  ]

  return (
    <div>
      <h1 className="text-2xl font-extrabold text-panel-primary">Hola, {usuario?.nombre}</h1>
      <p className="mt-1 text-sm text-panel-info">Vista global de RESCATE360: todas las organizaciones y todos los casos.</p>
      {error && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}

      <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {tarjetas.map(({ titulo, valor, icono: Icono, ruta, color }) => (
          <Link key={titulo} to={ruta} className="flex items-center gap-4 rounded-2xl border border-panel-border bg-panel-card p-5 transition hover:shadow-md">
            <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-full text-white ${color}`}>
              <Icono size={24} />
            </div>
            <div>
              <p className="text-sm text-panel-text-soft">{titulo}</p>
              <p className="text-2xl font-extrabold">{valor ?? '…'}</p>
            </div>
          </Link>
        ))}
      </div>

      <p className="mt-6 rounded-xl bg-amber-50 px-4 py-3 text-sm text-amber-950">
        La IA sugiere automáticamente la organización de las solicitudes y los reportes nuevos. Si un caso queda sin
        organización (porque la IA no respondió o no encontró una adecuada), asígnalo desde
        <strong> Solicitudes</strong> y <strong> Reportes</strong> para que lo vean sus administradores y voluntarios.
      </p>
    </div>
  )
}
