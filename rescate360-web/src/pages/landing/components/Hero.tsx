import { useState } from 'react'
import type { ReactNode } from 'react'

type PhoneTab = 'Inicio' | 'Mapa' | 'Reportes' | 'Más'
type IconName = 'alert' | 'arrow' | 'bell' | 'chevron' | 'map' | 'phone' | 'report' | 'shield' | 'users'

const iconPaths: Record<IconName, ReactNode> = {
  alert: <><path d="M10.3 3.9 2.5 17.4A1.8 1.8 0 0 0 4 20h16a1.8 1.8 0 0 0 1.5-2.6L13.7 3.9a2 2 0 0 0-3.4 0Z" /><path d="M12 9v4m0 3h.01" /></>,
  arrow: <><path d="M5 12h14m-7-7 7 7-7 7" /></>,
  bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9m-8 12a2 2 0 0 0 4 0" /></>,
  chevron: <><path d="m9 18 6-6-6-6" /></>,
  map: <><path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3zM9 3v15m6-12v15" /></>,
  phone: <><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.4 19.4 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 2 .7 2.9a2 2 0 0 1-.5 2.1L8 8.9a16 16 0 0 0 6 6l1.2-1.3a2 2 0 0 1 2.1-.5c.9.3 1.9.6 2.9.7a2 2 0 0 1 1.8 2.1Z" /></>,
  report: <><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" /><path d="M14 2v6h6m-11 5h6m-6 4h6" /></>,
  shield: <><path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11" /><path d="m9 12 2 2 4-4" /></>,
  users: <><path d="M16 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2m16 0v-2a4 4 0 0 0-3-3.9M14 3.1a4 4 0 0 1 0 7.8" /><circle cx="10" cy="7" r="4" /></>,
}

function Icon({ name, size = 19 }: { name: IconName; size?: number }) {
  return (
    <svg aria-hidden="true" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      {iconPaths[name]}
    </svg>
  )
}

const tabs: { name: PhoneTab; icon: IconName }[] = [
  { name: 'Inicio', icon: 'shield' },
  { name: 'Mapa', icon: 'map' },
  { name: 'Reportes', icon: 'report' },
  { name: 'Más', icon: 'users' },
]

function PhonePreview() {
  const [activeTab, setActiveTab] = useState<PhoneTab>('Inicio')

  return (
    <div className="phone-stage" aria-label="Vista previa interactiva de la aplicación">
      <div className="phone-orbit phone-orbit-one" />
      <div className="phone-orbit phone-orbit-two" />
      <div className="phone-float-badge">
        <span><Icon name="shield" size={17} /></span>
        <div><b>Tu comunidad conectada</b><small>Ayuda más cerca de ti</small></div>
      </div>
      <div className="phone-float-pin" aria-hidden="true"><Icon name="map" size={18} /></div>

      <div className="phone-frame">
        <div className="phone-screen">
          <div className="phone-status"><span>9:41</span><span className="phone-notch" /><span>●●● <b>100%</b></span></div>
          <div className="phone-appbar">
            <span className="phone-brand-mark"><Icon name="shield" size={16} /></span>
            <span className="phone-brand">RESCATE<span>360</span></span>
            <button className="phone-bell" type="button" aria-label="Notificaciones"><Icon name="bell" size={17} /></button>
          </div>

          <div className="phone-content" key={activeTab}>
            {activeTab === 'Inicio' && (
              <>
                <span className="phone-eyebrow">CENTRO DE RESPUESTA</span>
                <h2>Hola, Oscar</h2>
                <p className="phone-subtitle">Estamos aquí para ayudarte.</p>
                <div className="phone-sos-card">
                  <span className="phone-action-icon"><Icon name="alert" /></span>
                  <span><b>Solicitar ayuda</b><small>Cuéntanos qué sucede</small></span>
                  <Icon name="chevron" size={16} />
                </div>
                <div className="phone-shortcuts">
                  <div><span className="shortcut-icon blue"><Icon name="map" size={18} /></span><b>Mapa de<br />emergencia</b></div>
                  <div><span className="shortcut-icon green"><Icon name="report" size={18} /></span><b>Reportar un<br />incidente</b></div>
                </div>
                <div className="phone-section-heading"><b>Alertas recientes</b><span>Ver todas</span></div>
                <div className="phone-alert-row"><span className="alert-dot" /><span><b>Riesgo de deslizamiento</b><small>Zona Norte · Hace 12 min</small></span></div>
                <div className="phone-alert-row"><span className="alert-dot blue-dot" /><span><b>Centro de ayuda disponible</b><small>Refugio Central · Abierto 24/7</small></span></div>
              </>
            )}
            {activeTab === 'Mapa' && (
              <>
                <span className="phone-eyebrow">CERCA DE TI</span>
                <h2>Mapa de emergencia</h2>
                <p className="phone-subtitle">Consulta reportes y centros de ayuda.</p>
                <div className="phone-map">
                  <span className="map-road road-one" /><span className="map-road road-two" /><span className="map-road road-three" />
                  <span className="map-pin pin-one"><Icon name="alert" size={13} /></span>
                  <span className="map-pin pin-two"><Icon name="shield" size={13} /></span>
                  <span className="map-pin pin-three"><Icon name="alert" size={13} /></span>
                  <span className="map-you" />
                </div>
                <div className="phone-place"><span className="place-marker"><Icon name="map" size={16} /></span><span><b>Refugio Central</b><small>Abierto 24/7 · A 1,2 km</small></span></div>
                <div className="phone-place"><span className="place-marker coral-marker"><Icon name="alert" size={16} /></span><span><b>Reporte cercano</b><small>Riesgo de deslizamiento</small></span></div>
              </>
            )}
            {activeTab === 'Reportes' && (
              <>
                <span className="phone-eyebrow">SEGUIMIENTO</span>
                <h2>Mis reportes</h2>
                <p className="phone-subtitle">Estado de tus reportes recientes.</p>
                <div className="phone-report"><span className="report-status resolved"><Icon name="shield" size={16} /></span><span><b>Árbol caído en vía</b><small>Verificado · Hace 2 h</small></span><span className="report-check">✓</span></div>
                <div className="phone-report"><span className="report-status review"><Icon name="alert" size={16} /></span><span><b>Inundación en barrio</b><small>En revisión · Prioridad alta</small></span></div>
                <div className="phone-report"><span className="report-status pending"><Icon name="report" size={16} /></span><span><b>Falla de alumbrado</b><small>En cola · Se enviará al tener señal</small></span></div>
                <div className="phone-tip"><Icon name="bell" size={16} /><span>Te avisaremos cuando cambie el estado de un reporte.</span></div>
              </>
            )}
            {activeTab === 'Más' && (
              <>
                <span className="phone-eyebrow">TU COMUNIDAD</span>
                <h2>¿Cómo podemos ayudar?</h2>
                <p className="phone-subtitle">Encuentra recursos útiles para ti.</p>
                <div className="phone-menu-item"><span className="shortcut-icon blue"><Icon name="users" size={18} /></span><span><b>Centros de ayuda</b><small>Refugios y puntos de apoyo</small></span><Icon name="chevron" size={15} /></div>
                <div className="phone-menu-item"><span className="shortcut-icon green"><Icon name="shield" size={18} /></span><span><b>Guías de emergencia</b><small>Prepárate y actúa con calma</small></span><Icon name="chevron" size={15} /></div>
                <div className="phone-menu-item"><span className="shortcut-icon amber"><Icon name="bell" size={18} /></span><span><b>Alertas de mi zona</b><small>Información importante</small></span><Icon name="chevron" size={15} /></div>
                <div className="phone-offline"><span className="online-indicator" /><span><b>Modo sin conexión</b><small>Tus reportes se envían al volver la señal</small></span></div>
              </>
            )}
          </div>

          <nav className="phone-tabs" aria-label="Pestañas de la vista previa">
            {tabs.map((tab) => (
              <button
                className={activeTab === tab.name ? 'active' : ''}
                key={tab.name}
                type="button"
                aria-pressed={activeTab === tab.name}
                onClick={() => setActiveTab(tab.name)}
              >
                <Icon name={tab.icon} size={17} /><span>{tab.name}</span>
              </button>
            ))}
          </nav>
          <div className="phone-home-indicator" />
        </div>
      </div>
    </div>
  )
}

export default function Hero() {
  return (
    <section id="inicio" className="hero-section relative scroll-mt-20 overflow-hidden">
      <div className="hero-grid">
        <div className="hero-copy">
          <span className="hero-kicker hero-reveal hero-reveal-one"><span className="kicker-pulse" /> TU COMUNIDAD, NUESTRA PRIORIDAD</span>
          <h1 className="hero-reveal hero-reveal-two">Reporta. Ayuda.<br />Infórmate. <span>Actúa.</span></h1>
          <p className="hero-lead hero-reveal hero-reveal-three">Juntos respondemos mejor ante una emergencia.</p>
          <p className="hero-description hero-reveal hero-reveal-four">
            RESCATE360 conecta a ciudadanos, voluntarios y organizaciones para responder juntos. Reporta, pide ayuda y encuentra recursos cercanos, incluso cuando se cae la señal.
          </p>
          <div className="hero-buttons hero-reveal hero-reveal-five">
            <a href="#descarga" className="button button-primary">Descargar app <Icon name="arrow" size={17} /></a>
            <a href="#como-funciona" className="button button-secondary">Cómo funciona</a>
          </div>
          <a className="emergency-call hero-reveal hero-reveal-six" href="tel:123">
            <span className="call-icon"><Icon name="phone" size={17} /></span>
            <span>En riesgo vital, llama al <b>123</b></span>
            <Icon name="arrow" size={15} />
          </a>
        </div>
        <PhonePreview />
      </div>
      <div className="hero-bottom">
        <span><span className="bottom-line" /> TECNOLOGÍA AL SERVICIO DE LA COMUNIDAD</span>
        <a href="#como-funciona">Conoce cómo funciona <span className="scroll-arrow">↓</span></a>
      </div>
    </section>
  )
}
