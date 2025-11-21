import { COLORS } from '../lib/colors'
import styles from './PatternSelector.module.css'

type Props = {
  patterns: Record<string, string[]>
  patternNames: string[]
  selected: string
  onSelect: (name: string) => void
}

export function PatternSelector({ patterns, patternNames, selected, onSelect }: Props) {
  return (
    <div className={styles.container}>
      <label className={styles.label}>Pattern</label>
      <div className={styles.grid}>
        {patternNames.map((name) => (
          <button
            key={name}
            className={`${styles.button} ${selected === name ? styles.selected : ''}`}
            onClick={() => onSelect(name)}
          >
            <span className={styles.name}>{name}</span>
            <div className={styles.swatches}>
              {(patterns[name] ?? []).slice(0, 6).map((code, i) => (
                <span
                  key={i}
                  className={styles.swatch}
                  style={{ background: COLORS[code]?.hex }}
                />
              ))}
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}
