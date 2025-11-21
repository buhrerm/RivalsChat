import type { RepeatMode, SymmetryMode } from '../lib/converter'
import styles from './ModeToggle.module.css'

type Props = {
  repeatMode: RepeatMode
  symmetryMode: SymmetryMode
  onRepeatChange: (mode: RepeatMode) => void
  onSymmetryChange: (mode: SymmetryMode) => void
}

export function ModeToggle({ repeatMode, symmetryMode, onRepeatChange, onSymmetryChange }: Props) {
  return (
    <div className={styles.container}>
      <div className={styles.group}>
        <label className={styles.label}>Repeat</label>
        <div className={styles.buttons}>
          <button
            className={`${styles.btn} ${repeatMode === 'continuous' ? styles.active : ''}`}
            onClick={() => onRepeatChange('continuous')}
          >
            Continuous
          </button>
          <button
            className={`${styles.btn} ${repeatMode === 'word' ? styles.active : ''}`}
            onClick={() => onRepeatChange('word')}
          >
            Per Word
          </button>
        </div>
      </div>
      <div className={styles.group}>
        <label className={styles.label}>Symmetry</label>
        <div className={styles.buttons}>
          <button
            className={`${styles.btn} ${symmetryMode === 'none' ? styles.active : ''}`}
            onClick={() => onSymmetryChange('none')}
          >
            None
          </button>
          <button
            className={`${styles.btn} ${symmetryMode === 'mirror' ? styles.active : ''}`}
            onClick={() => onSymmetryChange('mirror')}
          >
            Mirror
          </button>
          <button
            className={`${styles.btn} ${symmetryMode === 'full' ? styles.active : ''}`}
            onClick={() => onSymmetryChange('full')}
          >
            Full
          </button>
        </div>
      </div>
    </div>
  )
}
