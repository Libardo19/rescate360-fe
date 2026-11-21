import { useEffect, useRef } from 'react'

// Escudo de RESCATE360 dibujado con puntos (semitono). Tiene "focos de incidente" que laten,
// ondas de pulso, una falla horizontal ocasional y puntos que se apartan del cursor.

interface Punto {
  bx: number // posición base
  by: number
  x: number // posición actual
  y: number
  r: number // radio
  a: number // opacidad base
  cruz: boolean // pertenece a la cruz (va en rojo de marca)
  umbral: number // 0–1 fijo por punto: tramado para colorear solo algunos puntos en los focos
}

// Silueta del escudo y de la cruz en un lienzo de 100 × 116.
const ESCUDO = new Path2D('M50 2C66 10 80 13 96 14L96 52C96 82 76 104 50 114C24 104 4 82 4 52L4 14C20 13 34 10 50 2Z')
const CRUZ = new Path2D('M42 28H58V48H78V64H58V88H42V64H22V48H42Z')

// Focos de incidente (posición relativa dentro del escudo) y su desfase de pulso.
// `tam` escala el radio: un foco principal y dos menores.
const FOCOS = [
  { x: 0.6, y: 0.68, fase: 0, tam: 1.35 },
  { x: 0.28, y: 0.34, fase: 1.4, tam: 0.7 },
  { x: 0.8, y: 0.3, fase: 2.6, tam: 0.6 },
]

// Gradiente iridiscente del foco: azul (borde) → violeta → rojo (centro).
function colorFoco(t: number) {
  const paradas: [number, number[]][] = [
    [0, [62, 123, 250]],
    [0.5, [124, 92, 214]],
    [1, [232, 52, 63]],
  ]
  const i = t < 0.5 ? 0 : 1
  const [t0, c0] = paradas[i]
  const [t1, c1] = paradas[i + 1]
  const k = (t - t0) / (t1 - t0)
  const c = c0.map((v, j) => Math.round(v + (c1[j] - v) * k))
  return `rgb(${c[0]},${c[1]},${c[2]})`
}

export default function EscudoPuntos({ oscuro = false, className = '' }: { oscuro?: boolean; className?: string }) {
  const contenedor = useRef<HTMLDivElement>(null)
  const lienzo = useRef<HTMLCanvasElement>(null)
  const oscuroRef = useRef(oscuro)

  useEffect(() => {
    oscuroRef.current = oscuro
  }, [oscuro])

  useEffect(() => {
    const caja = contenedor.current
    const canvas = lienzo.current
    const ctx = canvas?.getContext('2d')
    if (!caja || !canvas || !ctx) return

    const reducir = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    let puntos: Punto[] = []
    let lado = 0
    let pasoActual = 6
    let escala = 1 // de unidades del escudo (100 × 116) a píxeles
    let origenX = 0
    let origenY = 0
    let raton: { x: number; y: number } | null = null
    let visible = true
    let cuadro = 0
    let falla = { hasta: 0, y0: 0, y1: 0, dx: 0 }
    let proximaFalla = 2500

    // Muestrea la silueta en una grilla para crear los puntos.
    const construir = () => {
      lado = Math.round(caja.clientWidth)
      if (!lado) return
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      canvas.width = lado * dpr
      canvas.height = lado * dpr
      canvas.style.width = `${lado}px`
      canvas.style.height = `${lado}px`
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)

      escala = (lado * 0.74) / 116
      origenX = (lado - 100 * escala) / 2
      origenY = (lado - 116 * escala) / 2

      // Máscaras: escudo nítido, escudo difuminado (halo) y cruz.
      const mascara = (dibujar: (c: CanvasRenderingContext2D) => void, desenfoque = 0) => {
        const m = document.createElement('canvas')
        m.width = lado
        m.height = lado
        const c = m.getContext('2d', { willReadFrequently: true })!
        if (desenfoque) c.filter = `blur(${desenfoque}px)`
        c.translate(origenX, origenY)
        c.scale(escala, escala)
        dibujar(c)
        return c.getImageData(0, 0, lado, lado).data
      }
      const escudo = mascara((c) => c.fill(ESCUDO))
      const halo = mascara((c) => c.fill(ESCUDO), lado * 0.05)
      const cruz = mascara((c) => c.fill(CRUZ))

      const paso = Math.max(4.5, lado / 92)
      pasoActual = paso
      const nuevos: Punto[] = []
      const centroX = lado / 2
      const agregar = (x: number, y: number, r: number, a: number, enCruz = false) =>
        nuevos.push({ bx: x, by: y, x, y, r, a, cruz: enCruz, umbral: Math.random() })

      let fila = 0
      for (let y = paso / 2; y < lado; y += paso * 0.87, fila++) {
        for (let x = (fila % 2 ? paso / 2 : 0) + paso / 2; x < lado; x += paso) {
          const i = (Math.floor(y) * lado + Math.floor(x)) * 4 + 3
          const dentro = escudo[i] > 128
          const enCruz = cruz[i] > 128
          // Profundidad: la máscara difuminada vale menos cerca del borde → puntos más finos (efecto volumen).
          const profundidad = halo[i] / 255
          // Ruido suave (ondas cruzadas) para una textura orgánica, no de pantalla LED.
          const ruido = (Math.sin(x * 0.045) + Math.sin(y * 0.06 + x * 0.021) + Math.sin((x - y) * 0.032)) / 3
          // Luz desde arriba a la izquierda.
          const luz = 1 - Math.hypot(x - lado * 0.25, y - lado * 0.15) / (lado * 1.1)
          const sombra = Math.min(1, Math.max(0, 0.55 - luz * 0.45 + ruido * 0.28 + (Math.random() - 0.5) * 0.18))
          // Disolución: a la derecha del escudo los puntos se desprenden en partículas.
          const disolucion = Math.max(0, (x - centroX - lado * 0.12) / (lado * 0.3))

          if (dentro) {
            if (!enCruz && Math.random() < disolucion * 0.55) {
              // Partícula desprendida: se desplaza hacia la derecha.
              const dx = paso * (1 + Math.random() * 6) * disolucion
              agregar(x + dx, y + (Math.random() - 0.5) * paso * 2, paso * (0.06 + Math.random() * 0.12), 0.25 + Math.random() * 0.4)
              continue
            }
            agregar(
              x,
              y,
              enCruz ? paso * (0.16 + 0.14 * sombra) : paso * (0.1 + 0.3 * sombra * (0.5 + 0.5 * profundidad)),
              enCruz ? 0.75 + 0.25 * sombra : 0.35 + 0.6 * sombra,
              enCruz,
            )
          } else if (halo[i] > 6 && Math.random() < profundidad * (0.4 + disolucion * 0.6)) {
            // Halo: puntos sueltos que se desvanecen alrededor del escudo.
            agregar(x + disolucion * paso * Math.random() * 4, y, paso * (0.05 + Math.random() * 0.07), profundidad * 0.6)
          }
        }
      }
      puntos = nuevos
    }

    const pintar = (t: number) => {
      const oscuroActual = oscuroRef.current
      const tinta = oscuroActual ? '230,236,247' : '11,27,54'
      ctx.clearRect(0, 0, lado, lado)

      // Falla horizontal ocasional (franja que se desplaza un instante).
      if (!reducir && t > proximaFalla) {
        const y0 = lado * (0.2 + Math.random() * 0.6)
        falla = { hasta: t + 160, y0, y1: y0 + lado * (0.02 + Math.random() * 0.04), dx: (Math.random() - 0.5) * lado * 0.05 }
        proximaFalla = t + 2600 + Math.random() * 2400
      }
      const enFalla = t < falla.hasta

      const focos = FOCOS.map((f) => ({
        x: origenX + f.x * 100 * escala,
        y: origenY + f.y * 116 * escala,
        // Intensidad que late suavemente.
        k: reducir ? 0.85 : 0.72 + 0.28 * Math.sin(t / 700 + f.fase),
        radio: lado * 0.15 * f.tam,
      }))

      // Puntos base: un solo trazo para todos los de tinta (rápido); los de color van aparte.
      ctx.beginPath()
      const coloreados: { p: Punto; color: string; alfa: number }[] = []
      for (const p of puntos) {
        let ox = 0
        let oy = 0
        let color: string | null = null
        let alfa = p.a

        if (raton) {
          const dx = p.bx - raton.x
          const dy = p.by - raton.y
          const d = Math.hypot(dx, dy)
          const alcance = lado * 0.14
          if (d < alcance && d > 0.01) {
            const f = (1 - d / alcance) ** 2
            ox += (dx / d) * f * lado * 0.05
            oy += (dy / d) * f * lado * 0.05
            if (f > 0.15) color = 'rgb(232,52,63)'
          }
        }

        if (!p.cruz && !color) {
          for (const f of focos) {
            const d = Math.hypot(p.bx - f.x, p.by - f.y)
            if (d < f.radio) {
              const intensidad = (1 - d / f.radio) * f.k
              // Tramado: solo se colorean los puntos cuyo umbral queda por debajo de la intensidad.
              if (intensidad > p.umbral * 0.95) {
                color = colorFoco(Math.min(1, intensidad * 1.3))
                alfa = Math.min(1, 0.5 + intensidad * 0.6)
                ox += (Math.random() - 0.5) * intensidad
              }
            }
          }
        }

        if (enFalla && p.by > falla.y0 && p.by < falla.y1) {
          ox += falla.dx
          if (!color) color = 'rgb(62,123,250)'
        }

        // Suaviza el movimiento hacia la posición objetivo.
        p.x += (p.bx + ox - p.x) * (reducir ? 1 : 0.18)
        p.y += (p.by + oy - p.y) * (reducir ? 1 : 0.18)

        if (p.cruz) coloreados.push({ p, color: 'rgb(232,52,63)', alfa })
        else if (color) coloreados.push({ p, color, alfa })
        else {
          ctx.moveTo(p.x + p.r, p.y)
          ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
        }
      }
      ctx.fillStyle = `rgba(${tinta},0.78)`
      ctx.fill()

      for (const { p, color, alfa } of coloreados) {
        ctx.globalAlpha = alfa
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(p.x, p.y, Math.max(p.r * 1.15, pasoActual * 0.27), 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.globalAlpha = 1

      // Ondas de pulso desde cada foco.
      if (!reducir) {
        for (const [i, f] of focos.entries()) {
          const ciclo = ((t / 2400 + FOCOS[i].fase / 3) % 1 + 1) % 1
          ctx.beginPath()
          ctx.arc(f.x, f.y, f.radio * (0.3 + ciclo * 1.1), 0, Math.PI * 2)
          ctx.strokeStyle = `rgba(232,52,63,${(1 - ciclo) * 0.35})`
          ctx.lineWidth = 1.2
          ctx.stroke()
        }
      }
    }

    const bucle = (t: number) => {
      if (visible) pintar(t)
      cuadro = requestAnimationFrame(bucle)
    }

    construir()
    if (reducir) pintar(0)
    else cuadro = requestAnimationFrame(bucle)

    const alRedimensionar = new ResizeObserver(() => {
      if (Math.round(caja.clientWidth) !== lado) {
        construir()
        if (reducir) pintar(0)
      }
    })
    alRedimensionar.observe(caja)

    // Solo anima mientras está en pantalla.
    const alVer = new IntersectionObserver(([e]) => {
      visible = e.isIntersecting
    })
    alVer.observe(caja)

    const mover = (e: PointerEvent) => {
      if (e.pointerType !== 'mouse') return
      const r = canvas.getBoundingClientRect()
      raton = { x: e.clientX - r.left, y: e.clientY - r.top }
    }
    const salir = () => {
      raton = null
    }
    canvas.addEventListener('pointermove', mover)
    canvas.addEventListener('pointerleave', salir)

    return () => {
      cancelAnimationFrame(cuadro)
      alRedimensionar.disconnect()
      alVer.disconnect()
      canvas.removeEventListener('pointermove', mover)
      canvas.removeEventListener('pointerleave', salir)
    }
  }, [])

  return (
    <div ref={contenedor} className={`relative aspect-square w-full ${className}`}>
      <canvas ref={lienzo} role="img" aria-label="Escudo de RESCATE360 formado por puntos, con focos de incidentes que laten" />
    </div>
  )
}
