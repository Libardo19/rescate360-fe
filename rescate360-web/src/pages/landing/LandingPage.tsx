import Navbar from './components/Navbar'
import Hero from './components/Hero'
import QueEs from './components/QueEs'
import Capacidades from './components/Capacidades'
import ComoFunciona from './components/ComoFunciona'
import ParaQuien from './components/ParaQuien'
import Descarga from './components/Descarga'
import Footer from './components/Footer'
import { useTema } from './components/comunes'

export default function LandingPage() {
  const { tema, alternar } = useTema()

  return (
    <div
      data-tema={tema}
      className="relative isolate min-h-screen overflow-x-clip bg-[#f6f7f9] font-display text-navy-950 antialiased transition-colors duration-500 selection:bg-brand/20 dark:bg-[#060c19] dark:text-white"
    >
      {/* Fondo: brillos suaves arriba y una grilla de puntos que se desvanece */}
      <div aria-hidden="true" className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[1100px] overflow-hidden">
        <div className="absolute -top-40 left-1/2 h-[620px] w-[1100px] -translate-x-1/2 rounded-full bg-[radial-gradient(closest-side,rgba(62,123,250,0.18),transparent)] dark:bg-[radial-gradient(closest-side,rgba(62,123,250,0.22),transparent)]" />
        <div className="absolute right-[-10%] top-40 h-[480px] w-[480px] rounded-full bg-[radial-gradient(closest-side,rgba(232,52,63,0.10),transparent)]" />
        <div className="absolute inset-0 opacity-50 [background-image:radial-gradient(rgba(11,27,54,0.08)_1px,transparent_1px)] [background-size:22px_22px] [mask-image:linear-gradient(to_bottom,black,transparent_80%)] dark:[background-image:radial-gradient(rgba(255,255,255,0.07)_1px,transparent_1px)]" />
      </div>

      <Navbar tema={tema} alternar={alternar} />
      <main>
        <Hero tema={tema} />
        <QueEs />
        <Capacidades />
        <ComoFunciona />
        <ParaQuien />
        <Descarga />
      </main>
      <Footer />
    </div>
  )
}
