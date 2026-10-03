import type { ReactNode } from 'react'

type IconName =
  | 'activity'
  | 'alert'
  | 'arrow'
  | 'bell'
  | 'book'
  | 'building'
  | 'check'
  | 'chevron'
  | 'cloud'
  | 'download'
  | 'location'
  | 'map'
  | 'menu'
  | 'phone'
  | 'report'
  | 'shield'
  | 'users'

const iconPaths: Record<IconName, ReactNode> = {
  activity: <><path d="M3 12h4l3-8 4 16 3-8h4" /></>,
  alert: <><path d="M10.3 3.9 2.5 17.4A1.8 1.8 0 0 0 4 20h16a1.8 1.8 0 0 0 1.5-2.6L13.7 3.9a2 2 0 0 0-3.4 0Z" /><path d="M12 9v4m0 3h.01" /></>,
  arrow: <><path d="M5 12h14m-7-7 7 7-7 7" /></>,
  bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9m-8 12a2 2 0 0 0 4 0" /></>,
  book: <><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H20v16H6.5A2.5 2.5 0 0 0 4 21z" /><path d="M4 5.5v15M8 7h8m-8 4h8" /></>,
  building: <><path d="M3 21h18M5 21V7l7-4 7 4v14M9 21v-5h6v5M8 9h.01M16 9h.01M8 12h.01M16 12h.01" /></>,
  check: <><path d="m5 12 4 4L19 6" /></>,
  chevron: <><path d="m9 18 6-6-6-6" /></>,
  cloud: <><path d="M20 16.2A4.5 4.5 0 0 0 18 7.5a6 6 0 0 0-11.7 1.7A4 4 0 0 0 7 17h12" /><path d="m3 3 18 18" /></>,
  download: <><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4m4-5 5 5 5-5m-5 5V3" /></>,
  location: <><path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z" /><circle cx="12" cy="10" r="2.5" /></>,
  map: <><path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3zM9 3v15m6-12v15" /></>,
  menu: <><path d="M4 6h16M4 12h16M4 18h16" /></>,
  phone: <><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.4 19.4 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 2 .7 2.9a2 2 0 0 1-.5 2.1L8 8.9a16 16 0 0 0 6 6l1.2-1.3a2 2 0 0 1 2.1-.5c.9.3 1.9.6 2.9.7a2 2 0 0 1 1.8 2.1Z" /></>,
  report: <><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" /><path d="M14 2v6h6m-11 5h6m-6 4h6" /></>,
  shield: <><path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11" /><path d="m9 12 2 2 4-4" /></>,
  users: <><path d="M16 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2m16 0v-2a4 4 0 0 0-3-3.9M14 3.1a4 4 0 0 1 0 7.8" /><circle cx="10" cy="7" r="4" /></>,
}

function Icon({ name, size = 22 }: { name: IconName; size?: number }) {
  return (
    <svg
      aria-hidden="true"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {iconPaths[name]}
    </svg>
  )
}

const features: {
  icon: IconName
  tone: string
  title: string
  description: string
  tag?: string
}[] = [
  {
    icon: 'report',
    tone: 'coral',
    title: 'Reportar un incidente',
    description: 'Describe lo que sucede y comparte tu ubicación aproximada.',
  },
  {
    icon: 'alert',
    tone: 'coral',
    title: 'Solicitar ayuda',
    description: 'Pide asistencia. Una persona revisa la prioridad sugerida.',
  },
  {
    icon: 'map',
    tone: 'blue',
    title: 'Ver emergencias cercanas',
    description: 'Consulta centros de ayuda y puntos de interés en el mapa.',
  },
  {
    icon: 'bell',
    tone: 'yellow',
    title: 'Recibir alertas',
    description: 'Entérate de las alertas publicadas para tu zona.',
  },
  {
    icon: 'book',
    tone: 'green',
    title: 'Guías de emergencia',
    description: 'Orientación para actuar antes, durante y después.',
    tag: 'Próximamente',
  },
  {
    icon: 'cloud',
    tone: 'blue',
    title: 'Reportar sin conexión',
    description: 'El reporte se guarda y se envía cuando vuelva la señal.',
  },
]

function AppPreview() {
  return (
    <div className="preview-wrap" aria-label="Vista previa de la aplicación Rescate 360">
      <div className="preview-glow" />
      <div className="preview-card">
        <div className="preview-topbar">
          <span className="preview-brand"><span className="brand-mark"><Icon name="activity" size={15} /></span> RESCATE<span>360</span></span>
          <span className="online-dot">En línea</span>
        </div>
        <div className="preview-greeting">
          <span className="eyebrow">CENTRO DE RESPUESTA</span>
          <h2>Hola, estamos<br />aquí para ayudarte.</h2>
          <p>¿Qué necesitas hoy?</p>
        </div>
        <div className="preview-actions">
          <div className="preview-action primary-action">
            <span className="action-icon"><Icon name="alert" /></span>
            <span><b>Solicitar ayuda</b><small>Cuéntanos qué sucede</small></span>
            <Icon name="chevron" size={17} />
          </div>
          <div className="preview-action">
            <span className="action-icon blue-action"><Icon name="map" /></span>
            <span><b>Mapa de emergencia</b><small>Centros y alertas cercanas</small></span>
            <Icon name="chevron" size={17} />
          </div>
          <div className="preview-action">
            <span className="action-icon green-action"><Icon name="report" /></span>
            <span><b>Reportar incidente</b><small>Ayuda a tu comunidad</small></span>
            <Icon name="chevron" size={17} />
          </div>
        </div>
        <div className="preview-alert">
          <span className="alert-symbol"><Icon name="bell" size={17} /></span>
          <span><b>Alertas de tu zona</b><small>Mantente informado en tiempo real</small></span>
          <span className="alert-count">2</span>
        </div>
        <div className="preview-nav">
          <span className="selected"><Icon name="activity" size={17} />Inicio</span>
          <span><Icon name="map" size={17} />Mapa</span>
          <span><Icon name="report" size={17} />Reportes</span>
          <span><Icon name="users" size={17} />Ayuda</span>
        </div>
      </div>
      <div className="float-note"><span><Icon name="shield" size={18} /></span><div><b>Una comunidad más preparada</b><small>La ayuda empieza con estar conectados</small></div></div>
      <div className="float-pin"><Icon name="location" size={17} /></div>
    </div>
  )
}

function App() {
  return (
    <>
      <header className="site-header">
        <a className="brand" href="#inicio" aria-label="Rescate 360, inicio">
          <span className="brand-mark"><Icon name="activity" size={19} /></span>
          <span>RESCATE<span className="brand-accent">360</span></span>
        </a>
        <nav className="desktop-nav" aria-label="Navegación principal">
          <a href="#funciones">Funciones</a>
          <a href="#como-funciona">Cómo funciona</a>
          <a href="#comunidad">Comunidad</a>
        </nav>
        <a className="header-cta" href="#funciones">Explorar la plataforma <Icon name="arrow" size={16} /></a>
      </header>

      <main>
        <section className="hero-section" id="inicio">
          <div className="hero-grid">
            <div className="hero-copy">
              <div className="hero-kicker"><span className="kicker-pulse" /> RESPUESTA COMUNITARIA, MÁS CERCA</div>
              <h1>Juntos somos<br /><span>más fuertes.</span></h1>
              <p className="hero-lead">Coordinación comunitaria ante emergencias.</p>
              <p className="hero-description">Reporta un incidente, pide ayuda y encuentra centros cercanos. RESCATE360 conecta a las personas para responder mejor, incluso cuando se cae la señal.</p>
              <div className="hero-buttons">
                <a className="button button-primary" href="#funciones">Conoce la plataforma <Icon name="arrow" size={18} /></a>
                <a className="button button-secondary" href="#como-funciona"><span className="play-mark">▶</span> Cómo funciona</a>
              </div>
              <a className="emergency-call" href="tel:123">
                <span className="call-icon"><Icon name="phone" size={19} /></span>
                <span>En riesgo vital, llama al <b>123</b></span>
                <Icon name="arrow" size={15} />
              </a>
            </div>
            <AppPreview />
          </div>
          <div className="hero-bottom">
            <span><span className="bottom-line" /> TECNOLOGÍA AL SERVICIO DE LA COMUNIDAD</span>
            <a href="#funciones">Desliza para conocer más <span className="scroll-arrow">↓</span></a>
          </div>
        </section>

        <section className="section features-section" id="funciones">
          <div className="section-heading">
            <span className="section-label">HERRAMIENTAS PARA ACTUAR</span>
            <h2>Una respuesta más coordinada<br /><span>empieza por estar conectados.</span></h2>
            <p>Todo lo que necesitas para informar, orientarte y ayudar a tu comunidad en un solo lugar.</p>
          </div>
          <div className="feature-grid">
            {features.map((feature, index) => (
              <article className="feature-card" key={feature.title}>
                <div className={`feature-icon ${feature.tone}`}><Icon name={feature.icon} /></div>
                {feature.tag && <span className="feature-tag">{feature.tag}</span>}
                <span className="feature-index">0{index + 1}</span>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
                <span className="card-arrow"><Icon name="arrow" size={17} /></span>
              </article>
            ))}
          </div>
        </section>

        <section className="steps-section" id="como-funciona">
          <div className="section steps-inner">
            <div className="steps-heading">
              <span className="section-label">CLARO, HUMANO Y COORDINADO</span>
              <h2>Un reporte.<br /><span>Tres pasos.</span></h2>
              <p>De tu aviso a la atención, con una persona siempre al final del proceso.</p>
            </div>
            <div className="steps-list">
              <article className="step-item">
                <span className="step-number">01</span>
                <div><h3>Reportas</h3><p>Describes lo que sucede y compartes tu ubicación aproximada.</p></div>
                <span className="step-icon"><Icon name="report" /></span>
              </article>
              <article className="step-item">
                <span className="step-number">02</span>
                <div><h3>Se prioriza</h3><p>La tecnología ayuda a orientar. Una persona revisa cada situación.</p></div>
                <span className="step-icon"><Icon name="activity" /></span>
              </article>
              <article className="step-item">
                <span className="step-number">03</span>
                <div><h3>Se coordina la atención</h3><p>La organización correspondiente recibe y gestiona la solicitud.</p></div>
                <span className="step-icon"><Icon name="check" /></span>
              </article>
            </div>
          </div>
        </section>

        <section className="section community-section" id="comunidad">
          <div className="section-heading">
            <span className="section-label">UNA RED, MUCHAS FORMAS DE AYUDAR</span>
            <h2>La respuesta la<br /><span>construimos entre todos.</span></h2>
          </div>
          <div className="audience-grid">
            <article className="audience-card citizen-card">
              <span className="audience-icon"><Icon name="users" size={26} /></span>
              <span className="audience-label">PARA LA COMUNIDAD</span>
              <h3>Ciudadanos y voluntarios</h3>
              <p>Reporta, solicita ayuda y consulta información de emergencia para ti y quienes te rodean.</p>
              <a href="#funciones">Conoce las herramientas <Icon name="arrow" size={17} /></a>
              <div className="audience-decoration"><Icon name="activity" size={92} /></div>
            </article>
            <article className="audience-card organization-card">
              <span className="audience-icon"><Icon name="building" size={26} /></span>
              <span className="audience-label">PARA QUIENES COORDINAN</span>
              <h3>Organizaciones</h3>
              <p>Coordina la respuesta desde herramientas para gestionar reportes, solicitudes, mapas y alertas.</p>
              <a href="#como-funciona">Conoce cómo funciona <Icon name="arrow" size={17} /></a>
              <div className="audience-decoration"><Icon name="map" size={92} /></div>
            </article>
          </div>
        </section>

        <section className="safety-section">
          <div className="section safety-inner">
            <div className="safety-title">
              <span className="safety-icon"><Icon name="shield" size={23} /></span>
              <div><span className="section-label">CONFIANZA Y RESPONSABILIDAD</span><h2>Hecha para apoyar,<br />con las personas primero.</h2></div>
            </div>
            <div className="safety-points">
              <div><Icon name="phone" size={18} /><p><b>Emergencia vital</b><span>La app no reemplaza la línea 123 ni a las autoridades.</span></p></div>
              <div><Icon name="shield" size={18} /><p><b>Tu información importa</b><span>La ubicación compartida con otros se muestra de forma aproximada.</span></p></div>
              <div><Icon name="users" size={18} /><p><b>La decisión es humana</b><span>La tecnología orienta; las personas revisan y coordinan.</span></p></div>
            </div>
          </div>
        </section>

        <section className="final-cta">
          <div className="cta-orb cta-orb-one" /><div className="cta-orb cta-orb-two" />
          <div className="cta-content">
            <span className="section-label">MÁS CERCA, MÁS PREPARADOS</span>
            <h2>Cuando nos conectamos,<br /><span>podemos responder mejor.</span></h2>
            <p>Conoce cómo RESCATE360 puede ayudar a tu comunidad.</p>
            <a className="button button-light" href="#funciones">Explorar funciones <Icon name="arrow" size={18} /></a>
            <a className="cta-emergency" href="tel:123"><Icon name="phone" size={16} /> Si hay riesgo vital, llama al 123</a>
          </div>
        </section>
      </main>

      <footer className="site-footer">
        <div className="footer-main">
          <a className="brand" href="#inicio" aria-label="Rescate 360, inicio">
            <span className="brand-mark"><Icon name="activity" size={19} /></span>
            <span>RESCATE<span className="brand-accent">360</span></span>
          </a>
          <p>Juntos en la respuesta.</p>
          <div className="footer-note"><span>UNIVERSIDAD POPULAR DEL CESAR</span><span>Ingeniería de Software II</span></div>
        </div>
        <div className="footer-bottom">
          <span>© 2026 RESCATE360 · Proyecto académico</span>
          <a href="#inicio">Volver arriba <Icon name="arrow" size={15} /></a>
          <span>En una emergencia, llama al <a href="tel:123">123</a></span>
        </div>
      </footer>
    </>
  )
}

export default App
