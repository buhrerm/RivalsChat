import { useState } from 'react'
import { COLORS, COLOR_CODES } from '../lib/colors'
import type { CustomPattern } from '../hooks/usePatterns'
import styles from './PatternEditor.module.css'

type Props = {
  initial?: CustomPattern
  onSave: (pattern: CustomPattern) => boolean
  onCancel: () => void
}

export function PatternEditor({ initial, onSave, onCancel }: Props) {
  const [name, setName] = useState(initial?.name ?? '')
  const [colors, setColors] = useState<string[]>(initial?.colors ?? [])
  const [error, setError] = useState('')

  const addColor = (code: string) => {
    setColors((prev) => [...prev, code])
    setError('')
  }

  const removeLastColor = () => {
    setColors((prev) => prev.slice(0, -1))
  }

  const handleSave = () => {
    if (!name.trim()) {
      setError('Name is required')
      return
    }
    if (colors.length === 0) {
      setError('Add at least one color')
      return
    }
    const success = onSave({ name: name.trim(), colors })
    if (!success) {
      setError('Pattern name already exists')
    }
  }

  return (
    <div className={styles.overlay} onClick={onCancel}>
      <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
        <h2 className={styles.title}>{initial ? 'Edit Pattern' : 'New Pattern'}</h2>

        <div className={styles.field}>
          <label className={styles.label}>Name</label>
          <input
            className={styles.input}
            value={name}
            onChange={(e) => {
              setName(e.target.value)
              setError('')
            }}
            placeholder="My Pattern"
            autoFocus
          />
        </div>

        <div className={styles.field}>
          <label className={styles.label}>Colors (click to add)</label>
          <div className={styles.colorGrid}>
            {COLOR_CODES.map((code) => (
              <button
                key={code}
                className={styles.colorBtn}
                style={{ background: COLORS[code]?.hex }}
                onClick={() => addColor(code)}
                title={COLORS[code]?.name}
              />
            ))}
          </div>
        </div>

        <div className={styles.field}>
          <label className={styles.label}>
            Sequence ({colors.length})
            {colors.length > 0 && (
              <button className={styles.undoBtn} onClick={removeLastColor}>
                Undo
              </button>
            )}
          </label>
          <div className={styles.sequence}>
            {colors.length === 0 ? (
              <span className={styles.empty}>Click colors above to build sequence</span>
            ) : (
              colors.map((code, i) => (
                <span
                  key={i}
                  className={styles.swatch}
                  style={{ background: COLORS[code]?.hex }}
                />
              ))
            )}
          </div>
        </div>

        {error && <div className={styles.error}>{error}</div>}

        <div className={styles.actions}>
          <button className={styles.cancelBtn} onClick={onCancel}>
            Cancel
          </button>
          <button className={styles.saveBtn} onClick={handleSave}>
            Save
          </button>
        </div>
      </div>
    </div>
  )
}
