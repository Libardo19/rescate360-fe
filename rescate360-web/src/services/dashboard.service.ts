import { listarReportes } from './reportes.service'
import { listarSolicitudes } from './solicitudes.service'
import { listarAlertas } from './alertas.service'
import { listarCentros } from './centros.service'
import { listarZonas } from './zonas.service'
import { listarDonaciones } from './donaciones.service'
import { listarDesaparecidos } from './desaparecidos.service'
import { listarAuditoria } from './auditoria.service'
import { listarMiembros } from './usuarios.service'
import { prioridadEfectiva, type PrioridadIA } from '../types/solicitud'
import type { EstadoReporte } from '../types/reporte'
import type { DashboardAdmin, PuntoActividad } from '../types/dashboard'

// Se calculan 30 días; el dashboard deja elegir ver 7, 14 o 30.
const DIAS_ACTIVIDAD = 30

// Orden de urgencia: lo que la IA no clasificó va primero porque nadie lo ha evaluado.
const pesoPrioridad: Record<PrioridadIA, number> = { pendiente: 0, critica: 1, alta: 2, media: 3, baja: 4 }

// Fecha local en formato YYYY-MM-DD (no UTC, para no cambiar de día por la zona horaria).
const diaLocal = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`

// El dashboard se arma con los mismos servicios que usa cada pantalla, así las cifras
// siempre coinciden con lo que el administrador ve en cada módulo.
// BACKEND: cuando exista un endpoint /admin/dashboard con estos agregados, se puede
// reemplazar este cálculo por una sola llamada.
export async function obtenerDashboardAdmin(organizacionId: string): Promise<DashboardAdmin> {
  const [reportes, solicitudes, alertas, centros, zonas, donaciones, desaparecidos, auditoria, miembros] = await Promise.all([
    listarReportes(),
    listarSolicitudes(),
    listarAlertas(),
    listarCentros(),
    listarZonas(),
    listarDonaciones(),
    listarDesaparecidos(),
    listarAuditoria(),
    listarMiembros(organizacionId),
  ])

  const abiertas = solicitudes.filter((s) => s.estado !== 'resuelta')

  const reportesPorEstado: Record<EstadoReporte, number> = {
    pendiente: 0,
    verificado: 0,
    rechazado: 0,
    duplicado: 0,
    no_verificable: 0,
  }
  reportes.forEach((r) => (reportesPorEstado[r.estado] += 1))

  const solicitudesPorPrioridad: Record<PrioridadIA, number> = { critica: 0, alta: 0, media: 0, baja: 0, pendiente: 0 }
  abiertas.forEach((s) => (solicitudesPorPrioridad[prioridadEfectiva(s)] += 1))

  // Actividad diaria: 30 días que terminan en el día del registro más reciente.
  const fechas = [...reportes.map((r) => r.fecha), ...solicitudes.map((s) => s.fecha)]
  const actividad: PuntoActividad[] = []
  if (fechas.length > 0) {
    const ultimo = new Date(fechas.reduce((max, f) => (f > max ? f : max)))
    for (let i = DIAS_ACTIVIDAD - 1; i >= 0; i--) {
      const d = new Date(ultimo.getFullYear(), ultimo.getMonth(), ultimo.getDate() - i)
      actividad.push({ fecha: diaLocal(d), reportes: 0, solicitudes: 0 })
    }
    const indice = new Map(actividad.map((p, i) => [p.fecha, i]))
    reportes.forEach((r) => {
      const i = indice.get(diaLocal(new Date(r.fecha)))
      if (i !== undefined) actividad[i].reportes += 1
    })
    solicitudes.forEach((s) => {
      const i = indice.get(diaLocal(new Date(s.fecha)))
      if (i !== undefined) actividad[i].solicitudes += 1
    })
  }

  const requierenAtencion = [...abiertas]
    .sort((a, b) => {
      const p = pesoPrioridad[prioridadEfectiva(a)] - pesoPrioridad[prioridadEfectiva(b)]
      return p !== 0 ? p : b.fecha.localeCompare(a.fecha)
    })
    .slice(0, 5)

  return {
    resumen: {
      reportesTotal: reportes.length,
      reportesPendientes: reportesPorEstado.pendiente,
      solicitudesAbiertas: abiertas.length,
      solicitudesUrgentes: solicitudesPorPrioridad.critica + solicitudesPorPrioridad.alta,
      solicitudesSinClasificar: solicitudesPorPrioridad.pendiente,
      alertasActivas: alertas.filter((a) => a.activa).length,
      zonasActivas: zonas.filter((z) => z.estado === 'activa').length,
      centrosOperativos: centros.filter((c) => c.estado !== 'inactivo').length,
      centrosTotal: centros.length,
      donacionesAgotadas: donaciones.filter((d) => d.cantidad === 0).length,
      desaparecidosBuscando: desaparecidos.filter((p) => p.estadoCaso === 'buscando').length,
      // Un voluntario sin perfil cuenta como activo (perfiles_voluntario.activo tiene DEFAULT TRUE).
      voluntariosActivos: miembros.filter((m) => m.rol === 'voluntario' && (m.perfil?.activo ?? true)).length,
      voluntariosTotal: miembros.filter((m) => m.rol === 'voluntario').length,
    },
    reportesPorEstado,
    solicitudesPorPrioridad,
    actividad,
    requierenAtencion,
    auditoriaReciente: [...auditoria].sort((a, b) => b.creadoEn.localeCompare(a.creadoEn)).slice(0, 6),
  }
}
