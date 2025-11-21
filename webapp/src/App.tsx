import { useEffect, useState } from 'react'
import { useConverter } from './hooks/useConverter'
import { TextInput } from './components/TextInput'
import { PatternSelector } from './components/PatternSelector'
import { ModeToggle } from './components/ModeToggle'
import { Preview } from './components/Preview'
import { CopyButton } from './components/CopyButton'

export function App() {
  const {
    text,
    setText,
    pattern,
    setPattern,
    repeatMode,
    setRepeatMode,
    symmetryMode,
    setSymmetryMode,
    converted,
  } = useConverter()

  const [darkMode, setDarkMode] = useState(() => {
    const saved = localStorage.getItem('darkMode')
    if (saved !== null) return saved === 'true'
    return window.matchMedia('(prefers-color-scheme: dark)').matches
  })

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', darkMode ? 'dark' : 'light')
    localStorage.setItem('darkMode', String(darkMode))
  }, [darkMode])

  return (
    <div className="app">
      <header className="header">
        <h1>Rivals Color Codes</h1>
        <button className="theme-toggle" onClick={() => setDarkMode(!darkMode)}>
          {darkMode ? '☀️' : '🌙'}
        </button>
      </header>
      <main className="main">
        <div className="input-section">
          <TextInput value={text} onChange={setText} />
          <ModeToggle
            repeatMode={repeatMode}
            symmetryMode={symmetryMode}
            onRepeatChange={setRepeatMode}
            onSymmetryChange={setSymmetryMode}
          />
          <PatternSelector selected={pattern} onSelect={setPattern} />
        </div>
        <div className="output-section">
          <Preview converted={converted} />
          <CopyButton text={converted} />
        </div>
      </main>
    </div>
  )
}
