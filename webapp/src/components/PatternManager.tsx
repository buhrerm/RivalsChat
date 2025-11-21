import { useRef } from 'react'
import { COLORS } from '../lib/colors'
import type { CustomPattern } from '../hooks/usePatterns'
import styles from './PatternManager.module.css'

type Props = {
  patterns: Record<string, string[]>
  patternNames: string[]
  customPatterns: CustomPattern[]
  isBuiltin: (name: string) => boolean
  onEdit: (pattern: CustomPattern) => void
  onDelete: (name: string) => void
  onNew: () => void
  onExport: () => string
  onImport: (json: string) => boolean
  onClose: () => void
}

export function PatternManager({
  patterns,
  patternNames,
  isBuiltin,
  onEdit,
  onDelete,
  onNew,
  onExport,
  onImport,
  onClose,
}: Props) {
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleExport = () => {
    const json = onExport()
    const blob = new Blob([json], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'rivals-patterns.json'
    a.click()
    URL.revokeObjectURL(url)
  }

  const handleImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        onImport(reader.result)
      }
    }
    reader.readAsText(file)
    e.target.value = ''
  }

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
        <div className={styles.header}>
          <h2 className={styles.title}>Manage Patterns</h2>
          <button className={styles.closeBtn} onClick={onClose}>
            ✕
          </button>
        </div>

        <div className={styles.actions}>
          <button className={styles.actionBtn} onClick={onNew}>
            + New Pattern
          </button>
          <button className={styles.actionBtn} onClick={handleExport}>
            Export
          </button>
          <button className={styles.actionBtn} onClick={() => fileInputRef.current?.click()}>
            Import
          </button>
          <input
            ref={fileInputRef}
            type="file"
            accept=".json"
            onChange={handleImport}
            style={{ display: 'none' }}
          />
        </div>

        <div className={styles.list}>
          {patternNames.map((name) => {
            const colors = patterns[name] ?? []
            const builtin = isBuiltin(name)
            return (
              <div key={name} className={styles.item}>
                <div className={styles.info}>
                  <span className={styles.name}>{name}</span>
                  <span className={styles.tag}>{builtin ? 'Built-in' : 'Custom'}</span>
                </div>
                <div className={styles.swatches}>
                  {colors.slice(0, 8).map((code, i) => (
                    <span
                      key={i}
                      className={styles.swatch}
                      style={{ background: COLORS[code]?.hex }}
                    />
                  ))}
                  {colors.length > 8 && <span className={styles.more}>+{colors.length - 8}</span>}
                </div>
                {!builtin && (
                  <div className={styles.itemActions}>
                    <button
                      className={styles.editBtn}
                      onClick={() => onEdit({ name, colors })}
                    >
                      Edit
                    </button>
                    <button className={styles.deleteBtn} onClick={() => onDelete(name)}>
                      Delete
                    </button>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
