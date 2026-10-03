import Navbar from './components/Navbar'
import Hero from './components/Hero'
import ComoFunciona from './components/ComoFunciona'
import Funciones from './components/Funciones'
import Roles from './components/Roles'
import Descarga from './components/Descarga'
import Footer from './components/Footer'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background text-ink">
      <Navbar />
      <main>
        <Hero />
        <ComoFunciona />
        <Funciones />
        <Roles />
        <Descarga />
      </main>
      <Footer />
    </div>
  )
}