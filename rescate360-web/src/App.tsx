import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import LandingPage from './pages/landing/LandingPage'
import LoginPage from './pages/login/LoginPage'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
