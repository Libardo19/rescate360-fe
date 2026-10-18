import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'

export default function SuperAdminDashboard() {
  const { usuario, cerrarSesion } = useAuth()
  const navigate = useNavigate()

  const salir = () => {
    cerrarSesion()
    navigate('/login')
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-panel-bg text-panel-text">
      <h1 className="text-3xl font-extrabold text-panel-primary">Panel Super Admin</h1>
      <p className="text-panel-text-soft">Hola, {usuario?.nombre}</p>
      <button
        onClick={salir}
        className="rounded-lg bg-panel-primary px-5 py-2 font-semibold text-white transition hover:bg-panel-primary-dark"
      >
        Cerrar sesión
      </button>
    </div>
  )
}