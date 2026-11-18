import type { ReactNode } from 'react'
import { Sparkles, MapPinned, BellRing, WifiOff, Search, BookOpen, Camera, type LucideIcon } from 'lucide-react'
import appReportar from '../../../assets/app-reportar.png'
import mapaClaro from '../../../assets/mapa-valledupar-claro.jpg'
import mapaOscuro from '../../../assets/mapa-valledupar-oscuro.jpg'
import { Aparecer, EncabezadoSeccion } from './comunes'

function Tarjeta({
  icono: Icono,
  titulo,
  texto,
  children,
  className = '',
  retraso = 0,
}: {
  icono: LucideIcon
  titulo: string
  texto: string
  children?: ReactNode
  className?: string
  retraso?: number
}) {
  return (
    <Aparecer retraso={retraso} className={className}>
      <article className="group relative flex h-full flex-col overflow-hidden rounded-[28px] border border-slate-200/80 bg-white/70 p-6 backdrop-blur transition duration-300 hover:-translate-y-1 hover:border-slate-300 hover:shadow-[0_24px_50px_-28px_rgba(11,27,54,0.35)] dark:border-white/10 dark:bg-white/[0.04] dark:hover:border-white/20">
        <span className="flex h-10 w-10 items-center justify-center rounded-2xl border border-slate-200 bg-white text-navy-950 transition group-hover:border-brand/30 group-hover:text-brand dark:border-white/10 dark:bg-white/5 dark:text-white">
          <Icono size={18} strokeWidth={1.8} />
        </span>
        <h3 className="mt-5 font-display text-xl font-semibold tracking-[-0.02em] text-navy-950 dark:text-white">{titulo}</h3>
        <p className="mt-1.5 text-sm leading-relaxed text-slate-600 dark:text-white/55">{texto}</p>
        {children}
      </article>
    </Aparecer>
  )
}

// Captura de la app (la imagen ya incluye el marco del teléfono).
function Pantalla({ src, alt, className = '' }: { src: string; alt: string; className?: string }) {
  return <img src={src} alt={alt} loading="lazy" className={`block drop-shadow-2xl ${className}`} />
}

// Imagen de un mapa real de Valledupar (OpenStreetMap), con lo que muestra la app encima:
// un incidente que late, centros de ayuda y una zona de riesgo. Versión clara y oscura.
function Marcador({ x, y, color, pulso = false, icono }: { x: string; y: string; color: string; pulso?: boolean; icono?: string }) {
  return (
    <span className="absolute flex h-6 w-6 -translate-x-1/2 -translate-y-1/2 items-center justify-center" style={{ left: x, top: y }}>
      {pulso && <span className={`absolute inline-flex h-full w-full animate-ping rounded-full ${color} opacity-50 motion-reduce:hidden`} />}
      <span className={`relative flex h-6 w-6 items-center justify-center rounded-full border-2 border-white text-[10px] font-bold text-white shadow-lg ${color} dark:border-[#0d1729]`}>
        {icono}
      </span>
    </span>
  )
}

function MapaReal() {
  return (
    <div className="relative mt-5 aspect-[1000/475] w-full overflow-hidden rounded-2xl border border-slate-200 dark:border-white/10">
      <img src={mapaClaro} alt="Mapa del centro de Valledupar" loading="lazy" className="absolute inset-0 h-full w-full object-cover dark:hidden" />
      <img src={mapaOscuro} alt="Mapa del centro de Valledupar" loading="lazy" className="absolute inset-0 hidden h-full w-full object-cover dark:block" />

      {/* Zona de riesgo */}
      <span aria-hidden="true" className="absolute left-[74%] top-[30%] h-[34%] w-[16%] -translate-x-1/2 -translate-y-1/2 rotate-12 rounded-[45%] border-2 border-dashed border-amber-500 bg-amber-400/20" />

      <div aria-hidden="true">
        <Marcador x="41%" y="47%" color="bg-brand" pulso icono="!" />
        <Marcador x="18%" y="25%" color="bg-panel-info" icono="+" />
        <Marcador x="62%" y="72%" color="bg-panel-info" icono="+" />
        <Marcador x="28%" y="78%" color="bg-emerald-500" icono="✓" />
      </div>

      {/* Leyenda */}
      <div aria-hidden="true" className="absolute left-2 top-2 flex flex-wrap gap-1.5 font-mono text-[9px] uppercase tracking-[0.12em]">
        {[
          ['bg-brand', 'Incidente'],
          ['bg-panel-info', 'Centro de ayuda'],
          ['bg-amber-500', 'Zona de riesgo'],
        ].map(([c, t]) => (
          <span key={t} className="inline-flex items-center gap-1 rounded-full bg-white/90 px-2 py-0.5 text-slate-600 shadow-sm backdrop-blur dark:bg-[#0b1426]/90 dark:text-white/70">
            <span className={`h-1.5 w-1.5 rounded-full ${c}`} />
            {t}
          </span>
        ))}
      </div>

      {/* Atribución obligatoria de OpenStreetMap */}
      <a
        href="https://www.openstreetmap.org/copyright"
        target="_blank"
        rel="noreferrer"
        className="absolute bottom-1 right-1.5 rounded bg-white/80 px-1.5 py-0.5 text-[9px] text-slate-500 hover:text-navy-950 dark:bg-[#0b1426]/80 dark:text-white/50 dark:hover:text-white"
      >
        © OpenStreetMap
      </a>
    </div>
  )
}

export default function Capacidades() {
  return (
    <section id="capacidades" className="scroll-mt-24 px-5 py-20 sm:px-6 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <EncabezadoSeccion
          etiqueta="Capacidades"
          titulo={
            <>
              Todo lo necesario
              <br />
              <span className="text-slate-400 dark:text-white/40">cuando cada minuto cuenta.</span>
            </>
          }
        />

        <div className="mt-12 grid gap-4 md:grid-cols-6">
          {/* Reportar: tarjeta grande con la pantalla real */}
          <Tarjeta
            icono={Camera}
            titulo="Reporta un incidente"
            texto="Foto, descripción y ubicación automática. El reporte llega a la organización que debe atenderlo."
            className="md:col-span-3 md:row-span-2"
          >
            {/* Teléfono centrado y completo dentro de la tarjeta */}
            <div className="relative mt-6 flex flex-1 items-center justify-center py-2">
              <div className="absolute inset-x-10 inset-y-8 rounded-full bg-brand/15 blur-3xl dark:bg-brand/20" />
              <Pantalla
                src={appReportar}
                alt="Pantalla de la app para reportar un incidente"
                className="relative max-h-[420px] w-auto max-w-[200px] transition duration-500 group-hover:-translate-y-1.5 sm:max-w-[210px]"
              />
            </div>
          </Tarjeta>

          {/* Solicitar ayuda con prioridad IA */}
          <Tarjeta
            icono={Sparkles}
            titulo="Ayuda priorizada"
            texto="La IA sugiere la urgencia de cada solicitud; un operador la confirma o la corrige."
            className="md:col-span-3"
            retraso={0.08}
          >
            <div className="mt-5 flex flex-wrap gap-2" aria-hidden="true">
              {[
                ['Crítica', 'bg-brand text-white'],
                ['Alta', 'bg-red-100 text-red-700 dark:bg-red-500/15 dark:text-red-300'],
                ['Media', 'bg-amber-100 text-amber-800 dark:bg-amber-500/15 dark:text-amber-300'],
                ['Baja', 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-300'],
              ].map(([t, c]) => (
                <span key={t} className={`rounded-full px-3 py-1 text-xs font-semibold ${c}`}>
                  {t}
                </span>
              ))}
              <span className="rounded-full border border-dashed border-slate-300 px-3 py-1 font-mono text-[11px] text-slate-500 dark:border-white/20 dark:text-white/50">
                IA · 91% confianza
              </span>
            </div>
          </Tarjeta>

          {/* Mapa */}
          <Tarjeta
            icono={MapPinned}
            titulo="Mapa en vivo"
            texto="Centros de ayuda, zonas de riesgo y puntos de atención cerca de ti."
            className="md:col-span-3"
            retraso={0.12}
          >
            <MapaReal />
          </Tarjeta>

          <Tarjeta
            icono={WifiOff}
            titulo="Sin señal, igual llega"
            texto="Si no hay internet, el reporte se guarda y sale por SMS o de teléfono a teléfono."
            className="md:col-span-2"
            retraso={0.05}
          >
            <div className="mt-5 flex items-center gap-2 font-mono text-[11px] text-slate-500 dark:text-white/50" aria-hidden="true">
              {['LOCAL', 'SMS', 'MESH'].map((m, i) => (
                <span key={m} className="flex items-center gap-2">
                  <span className="rounded-md border border-slate-200 px-2 py-1 dark:border-white/10">{m}</span>
                  {i < 2 && <span className="h-px w-4 bg-slate-300 dark:bg-white/20" />}
                </span>
              ))}
            </div>
          </Tarjeta>

          <Tarjeta
            icono={BellRing}
            titulo="Alertas oficiales"
            texto="Avisos de inundación, deslizamientos o seguridad publicados por las autoridades."
            className="md:col-span-2"
            retraso={0.1}
          />

          <Tarjeta
            icono={Search}
            titulo="Personas desaparecidas"
            texto="Casos visibles para todas las organizaciones, con última ubicación conocida."
            className="md:col-span-2"
            retraso={0.15}
          />

          <Tarjeta
            icono={BookOpen}
            titulo="Guías de emergencia"
            texto="Qué hacer antes, durante y después de una emergencia: primeros auxilios, evacuación y más."
            className="md:col-span-6"
            retraso={0.05}
          />
        </div>
      </div>
    </section>
  )
}
