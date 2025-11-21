import { useState, useEffect } from 'react'
import { PATTERNS } from '../lib/patterns'

export type CustomPattern = {
  name: string
  colors: string[]
}

const STORAGE_KEY = 'rivals-custom-patterns'

function loadPatterns(): CustomPattern[] {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    return saved ? JSON.parse(saved) : []
  } catch {
    return []
  }
}

function savePatterns(patterns: CustomPattern[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(patterns))
}

export function usePatterns() {
  const [customPatterns, setCustomPatterns] = useState<CustomPattern[]>(loadPatterns)

  useEffect(() => {
    savePatterns(customPatterns)
  }, [customPatterns])

  const allPatterns: Record<string, string[]> = {
    ...PATTERNS,
    ...Object.fromEntries(customPatterns.map((p) => [p.name, p.colors])),
  }

  const allPatternNames = [...Object.keys(PATTERNS), ...customPatterns.map((p) => p.name)]

  const isBuiltin = (name: string) => name in PATTERNS

  const addPattern = (pattern: CustomPattern) => {
    if (!pattern.name || pattern.colors.length === 0) return false
    if (allPatternNames.includes(pattern.name)) return false
    setCustomPatterns((prev) => [...prev, pattern])
    return true
  }

  const updatePattern = (oldName: string, pattern: CustomPattern) => {
    if (isBuiltin(oldName)) return false
    if (!pattern.name || pattern.colors.length === 0) return false
    if (oldName !== pattern.name && allPatternNames.includes(pattern.name)) return false
    setCustomPatterns((prev) => prev.map((p) => (p.name === oldName ? pattern : p)))
    return true
  }

  const deletePattern = (name: string) => {
    if (isBuiltin(name)) return false
    setCustomPatterns((prev) => prev.filter((p) => p.name !== name))
    return true
  }

  const exportPatterns = () => JSON.stringify(customPatterns, null, 2)

  const importPatterns = (json: string) => {
    try {
      const imported = JSON.parse(json) as CustomPattern[]
      if (!Array.isArray(imported)) return false
      const valid = imported.filter(
        (p) => p.name && Array.isArray(p.colors) && p.colors.length > 0 && !isBuiltin(p.name)
      )
      setCustomPatterns((prev) => {
        const existing = new Set(prev.map((p) => p.name))
        const newOnes = valid.filter((p) => !existing.has(p.name))
        return [...prev, ...newOnes]
      })
      return true
    } catch {
      return false
    }
  }

  return {
    allPatterns,
    allPatternNames,
    customPatterns,
    isBuiltin,
    addPattern,
    updatePattern,
    deletePattern,
    exportPatterns,
    importPatterns,
  }
}
