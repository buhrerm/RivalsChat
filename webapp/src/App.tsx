import { useEffect, useState, useMemo } from 'react'
import { usePatterns, type CustomPattern } from './hooks/usePatterns'
import { convertText, type RepeatMode, type SymmetryMode } from './lib/converter'
import { TextInput } from './components/TextInput'
import { PatternSelector } from './components/PatternSelector'
import { ModeToggle } from './components/ModeToggle'
import { Preview } from './components/Preview'
import { CopyButton } from './components/CopyButton'
import { PatternManager } from './components/PatternManager'
import { PatternEditor } from './components/PatternEditor'

export function App() {
  const {
    allPatterns,
    allPatternNames,
    customPatterns,
    isBuiltin,
    addPattern,
    updatePattern,
    deletePattern,
    exportPatterns,
    importPatterns,
  } = usePatterns()

  const [text, setText] = useState('')
  const [pattern, setPattern] = useState('Rainbow')
  const [repeatMode, setRepeatMode] = useState<RepeatMode>('word')
  const [symmetryMode, setSymmetryMode] = useState<SymmetryMode>('none')

  const [showManager, setShowManager] = useState(false)
  const [editingPattern, setEditingPattern] = useState<CustomPattern | null>(null)
  const [showEditor, setShowEditor] = useState(false)

  const converted = useMemo(() => {
    const p = allPatterns[pattern]
    if (!p) return ''
    return convertText(text, p, repeatMode, symmetryMode)
  }, [text, pattern, repeatMode, symmetryMode, allPatterns])

  const [darkMode, setDarkMode] = useState(() => {
    const saved = localStorage.getItem('darkMode')
    if (saved !== null) return saved === 'true'
    return window.matchMedia('(prefers-color-scheme: dark)').matches
  })

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', darkMode ? 'dark' : 'light')
    localStorage.setItem('darkMode', String(darkMode))
  }, [darkMode])

  const handleSavePattern = (p: CustomPattern) => {
    if (editingPattern) {
      const success = updatePattern(editingPattern.name, p)
      if (success) {
        if (pattern === editingPattern.name && p.name !== editingPattern.name) {
          setPattern(p.name)
        }
        setEditingPattern(null)
        setShowEditor(false)
      }
      return success
    }
    const success = addPattern(p)
    if (success) {
      setShowEditor(false)
      setPattern(p.name)
    }
    return success
  }

  const handleDelete = (name: string) => {
    if (confirm(`Delete pattern "${name}"?`)) {
      deletePattern(name)
      if (pattern === name) {
        setPattern('Rainbow')
      }
    }
  }

  const handleEdit = (p: CustomPattern) => {
    setEditingPattern(p)
    setShowEditor(true)
    setShowManager(false)
  }

  const handleNewPattern = () => {
    setEditingPattern(null)
    setShowEditor(true)
    setShowManager(false)
  }

  return (
    <div className="app">
      <header className="header">
        <h1>Rivals Color Codes</h1>
        <div className="header-actions">
          <button className="manage-btn" onClick={() => setShowManager(true)}>
            Patterns
          </button>
          <button className="theme-toggle" onClick={() => setDarkMode(!darkMode)}>
            {darkMode ? '☀️' : '🌙'}
          </button>
        </div>
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
          <PatternSelector
            patterns={allPatterns}
            patternNames={allPatternNames}
            selected={pattern}
            onSelect={setPattern}
          />
        </div>
        <div className="output-section">
          <Preview converted={converted} />
          <CopyButton text={converted} />
        </div>
      </main>

      {showManager && (
        <PatternManager
          patterns={allPatterns}
          patternNames={allPatternNames}
          customPatterns={customPatterns}
          isBuiltin={isBuiltin}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onNew={handleNewPattern}
          onExport={exportPatterns}
          onImport={importPatterns}
          onClose={() => setShowManager(false)}
        />
      )}

      {showEditor && (
        <PatternEditor
          initial={editingPattern ?? undefined}
          onSave={handleSavePattern}
          onCancel={() => {
            setShowEditor(false)
            setEditingPattern(null)
          }}
        />
      )}
    </div>
  )
}
