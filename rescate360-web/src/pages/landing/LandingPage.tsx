import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Funciones from './components/Funciones'
import Footer from './components/Footer'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background text-ink">
      <Navbar />
      <main>
        <Hero />
        <Funciones />
      </main>
      <Footer />
    </div>
  )
}