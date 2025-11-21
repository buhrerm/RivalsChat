import { useState } from 'react'
import styles from './CopyButton.module.css'

type Props = {
  text: string
}

export function CopyButton({ text }: Props) {
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    await navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 1500)
  }

  return (
    <button className={styles.button} onClick={handleCopy} disabled={!text}>
      {copied ? '✓ Copied!' : 'Copy Code'}
    </button>
  )
}
