import { COLORS } from '../lib/colors'
import styles from './Preview.module.css'

type Props = {
  converted: string
}

type Segment = { color: string; char: string } | { text: string }

function parseConverted(text: string): Segment[] {
  const segments: Segment[] = []
  let i = 0

  while (i < text.length) {
    if (text[i] === '#' && i + 2 < text.length) {
      const code = text[i + 1]!
      const char = text[i + 2]!
      if (COLORS[code]) {
        segments.push({ color: code, char })
        i += 3
        continue
      }
    }
    segments.push({ text: text[i]! })
    i++
  }

  return segments
}

export function Preview({ converted }: Props) {
  const segments = parseConverted(converted)

  return (
    <div className={styles.container}>
      <label className={styles.label}>Preview</label>
      <div className={styles.preview}>
        {segments.map((seg, i) =>
          'color' in seg ? (
            <span key={i} style={{ color: COLORS[seg.color]?.hex }}>
              {seg.char}
            </span>
          ) : (
            <span key={i}>{seg.text}</span>
          )
        )}
      </div>
      <label className={styles.label}>Code</label>
      <div className={styles.code}>{converted}</div>
    </div>
  )
}
