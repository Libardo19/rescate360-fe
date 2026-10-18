import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Funciones from './components/Funciones'
import AppShowcase from './components/AppShowcase'
import ComoFunciona from './components/ComoFunciona'
import Roles from './components/Roles'
import Footer from './components/Footer'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-white text-navy-900">
      <Navbar />
      <main>
        <Hero />
        <Funciones />
        <AppShowcase />
        <ComoFunciona />
        <Roles />
      </main>
      <Footer />
    </div>
  )
}