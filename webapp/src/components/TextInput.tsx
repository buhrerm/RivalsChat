import styles from './TextInput.module.css'

type Props = {
  value: string
  onChange: (value: string) => void
}

export function TextInput({ value, onChange }: Props) {
  return (
    <div className={styles.container}>
      <label className={styles.label}>Enter Text</label>
      <textarea
        className={styles.textarea}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Type your text here..."
        autoFocus
      />
    </div>
  )
}
