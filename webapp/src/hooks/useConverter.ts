import { useState, useMemo } from 'react'
import { convertText, type RepeatMode, type SymmetryMode } from '../lib/converter'
import { PATTERNS } from '../lib/patterns'

export function useConverter() {
  const [text, setText] = useState('')
  const [pattern, setPattern] = useState('Rainbow')
  const [repeatMode, setRepeatMode] = useState<RepeatMode>('word')
  const [symmetryMode, setSymmetryMode] = useState<SymmetryMode>('none')

  const converted = useMemo(() => {
    const p = PATTERNS[pattern]
    if (!p) return ''
    return convertText(text, p, repeatMode, symmetryMode)
  }, [text, pattern, repeatMode, symmetryMode])

  return {
    text,
    setText,
    pattern,
    setPattern,
    repeatMode,
    setRepeatMode,
    symmetryMode,
    setSymmetryMode,
    converted,
  }
}
