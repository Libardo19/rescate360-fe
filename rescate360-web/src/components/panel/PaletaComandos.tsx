import { useEffect, useMemo, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AnimatePresence, motion } from 'motion/react'
import { CornerDownLeft, Search, Plus, BellPlus, UserPlus, PackagePlus, PenTool, type LucideIcon } from 'lucide-react'
import type { ItemMenu } from '../../routes/menus'

interface Comando {
  id: string
  titulo: string
  descripcion?: string
  grupo: string
  icono: LucideIcon
  ruta: string
}

// Acciones rápidas: llevan a la pantalla donde se hace la acción.
const ACCIONES: Comando[] = [
  { id: 'a-alerta', titulo: 'Publicar una alerta', grupo: 'Acciones', icono: BellPlus, ruta: '/admin/alertas?accion=nueva' },
  { id: 'a-centro', titulo: 'Registrar un centro de ayuda', grupo: 'Acciones', icono: Plus, ruta: '/admin/centros?accion=nueva' },
  { id: 'a-zona', titulo: 'Dibujar una zona peligrosa', grupo: 'Acciones', icono: PenTool, ruta: '/admin/zonas?accion=nueva' },
  { id: 'a-donacion', titulo: 'Registrar una donación', grupo: 'Acciones', icono: PackagePlus, ruta: '/admin/donaciones?accion=nueva' },
  { id: 'a-voluntario', titulo: 'Agregar un voluntario', grupo: 'Acciones', icono: UserPlus, ruta: '/admin/usuarios?accion=nueva' },
]

// Normaliza para buscar sin tildes ni mayúsculas.
const normalizar = (t: string) =>
  t
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')

interface Props {
  abierta: boolean
  onCerrar: () => void
  menu: ItemMenu[]
}

// Paleta de comandos (Ctrl/⌘ + K): busca secciones y acciones y navega con el teclado.
export default function PaletaComandos({ abierta, onCerrar, menu }: Props) {
  const navigate = useNavigate()
  const [texto, setTexto] = useState('')
  const [indice, setIndice] = useState(0)
  const lista = useRef<HTMLUListElement>(null)

  const comandos = useMemo<Comando[]>(
    () => [
      ...menu.map((m) => ({
        id: m.ruta,
        titulo: m.etiqueta,
        descripcion: m.descripcion,
        grupo: 'Ir a',
        icono: m.icono,
        ruta: m.ruta,
      })),
      // Solo las acciones cuya sección existe en el menú de este rol.
      ...ACCIONES.filter((a) => menu.some((m) => m.ruta === a.ruta.split('?')[0])),
    ],
    [menu],
  )

  const resultados = useMemo(() => {
    const q = normalizar(texto.trim())
    if (!q) return comandos
    return comandos.filter((c) => normalizar(`${c.titulo} ${c.descripcion ?? ''}`).includes(q))
  }, [comandos, texto])

  const elegir = (c: Comando | undefined) => {
    if (!c) return
    navigate(c.ruta)
    onCerrar()
  }

  // Mantiene visible el elemento seleccionado al moverse con las flechas.
  useEffect(() => {
    lista.current?.querySelector(`[data-indice="${indice}"]`)?.scrollIntoView({ block: 'nearest' })
  }, [indice])

  const alTeclear = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setIndice((i) => Math.min(resultados.length - 1, i + 1))
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setIndice((i) => Math.max(0, i - 1))
    } else if (e.key === 'Enter') {
      e.preventDefault()
      elegir(resultados[indice])
    } else if (e.key === 'Escape') {
      onCerrar()
    }
  }

  return (
    <AnimatePresence onExitComplete={() => setTexto('')}>
      {abierta && (
        <motion.div
          className="fixed inset-0 z-[1200] flex items-start justify-center bg-navy-950/30 px-4 pt-[12vh] backdrop-blur-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          onClick={onCerrar}
        >
          <motion.div
            role="dialog"
            aria-modal="true"
            aria-label="Paleta de comandos"
            initial={{ opacity: 0, y: -10, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -6, scale: 0.98 }}
            transition={{ duration: 0.18, ease: [0.22, 1, 0.36, 1] }}
            className="w-full max-w-xl overflow-hidden rounded-[28px] border border-panel-border bg-panel-card shadow-[0_40px_80px_-30px_rgba(11,27,54,0.55)]"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center gap-3 border-b border-panel-border px-5">
              <Search size={18} className="shrink-0 text-panel-text-muted" />
              <input
                autoFocus
                value={texto}
                onChange={(e) => {
                  setTexto(e.target.value)
                  setIndice(0)
                }}
                onKeyDown={alTeclear}
                placeholder="Busca una sección o una acción…"
                aria-label="Buscar"
                className="h-14 w-full bg-transparent text-[15px] outline-none placeholder:text-panel-text-muted"
              />
              <kbd className="shrink-0 rounded-md border border-panel-border px-1.5 py-0.5 font-mono text-[10px] text-panel-text-muted">ESC</kbd>
            </div>

            <ul ref={lista} className="sin-barra-scroll max-h-[52vh] overflow-y-auto p-2" role="listbox">
              {resultados.length === 0 && (
                <li className="px-4 py-10 text-center text-sm text-panel-text-muted">Nada coincide con “{texto}”.</li>
              )}
              {resultados.map((c, i) => {
                const mostrarGrupo = i === 0 || resultados[i - 1].grupo !== c.grupo
                const Icono = c.icono
                const activo = i === indice
                return (
                  <li key={c.id} role="option" aria-selected={activo}>
                    {mostrarGrupo && (
                      <p className="px-3 pb-1.5 pt-3 font-mono text-[10px] uppercase tracking-[0.16em] text-panel-text-muted">{c.grupo}</p>
                    )}
                    <button
                      data-indice={i}
                      onMouseMove={() => setIndice(i)}
                      onClick={() => elegir(c)}
                      className={`flex w-full items-center gap-3 rounded-2xl px-3 py-2.5 text-left transition-colors ${
                        activo ? 'bg-panel-bg' : ''
                      }`}
                    >
                      <span
                        className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border transition ${
                          activo ? 'border-transparent bg-navy-950 text-white dark:bg-white dark:text-navy-950' : 'border-panel-border text-panel-text-soft'
                        }`}
                      >
                        <Icono size={16} strokeWidth={1.9} />
                      </span>
                      <span className="min-w-0 flex-1">
                        <span className="block truncate text-sm font-medium">{c.titulo}</span>
                        {c.descripcion && <span className="block truncate text-xs text-panel-text-muted">{c.descripcion}</span>}
                      </span>
                      {activo && <CornerDownLeft size={14} className="shrink-0 text-panel-text-muted" />}
                    </button>
                  </li>
                )
              })}
            </ul>

            <div className="flex items-center gap-4 border-t border-panel-border px-5 py-2.5 font-mono text-[10px] uppercase tracking-[0.12em] text-panel-text-muted">
              <span>↑ ↓ moverse</span>
              <span>↵ abrir</span>
              <span className="ml-auto">RESCATE360</span>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
