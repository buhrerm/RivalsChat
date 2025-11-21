import { useState } from 'react'
import styles from './TextInput.module.css'

type Props = {
  value: string
  onChange: (value: string) => void
  onCopy: () => void
}

export function TextInput({ value, onChange, onCopy }: Props) {
  const [copied, setCopied] = useState(false)

  const handleCopy = () => {
    onCopy()
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleCopy()
    }
  }

  return (
    <div className={styles.container}>
      <div className={styles.labelRow}>
        <label className={styles.label}>Enter Text</label>
        <button
          className={styles.copyBtn}
          onClick={handleCopy}
          disabled={!value}
          title="Copy (Enter)"
        >
          {copied ? '✓' : '⎘'}
        </button>
      </div>
      <input
        type="text"
        className={styles.input}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Type your text here..."
        autoFocus
      />
    </div>
  )
}
