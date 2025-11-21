import { describe, it, expect } from 'vitest'
import { convertText } from '../../src/lib/converter'

describe('convertText', () => {
  const pattern = ['R', 'G', 'B']

  it('converts simple text in continuous mode', () => {
    const result = convertText('abc', pattern, 'continuous', 'none')
    expect(result).toBe('#Ra#Gb#Bc')
  })

  it('preserves spaces', () => {
    const result = convertText('a b', pattern, 'continuous', 'none')
    expect(result).toBe('#Ra #Gb')
  })

  it('resets pattern per word in word mode', () => {
    const result = convertText('ab cd', pattern, 'word', 'none')
    expect(result).toBe('#Ra#Gb #Rc#Gd')
  })

  it('handles mirror symmetry', () => {
    const result = convertText('abcde', pattern, 'continuous', 'mirror')
    expect(result).toBe('#Ra#Gb#Bc#Gd#Re')
  })

  it('handles full symmetry', () => {
    const result = convertText('abcdef', pattern, 'continuous', 'full')
    expect(result).toBe('#Ra#Rb#Gc#Gd#Be#Bf')
  })

  it('returns empty for empty input', () => {
    const result = convertText('', pattern, 'continuous', 'none')
    expect(result).toBe('')
  })
})
