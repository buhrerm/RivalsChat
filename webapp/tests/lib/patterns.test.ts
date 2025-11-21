import { describe, it, expect } from 'vitest'
import { PATTERNS, PATTERN_NAMES } from '../../src/lib/patterns'
import { COLOR_CODES } from '../../src/lib/colors'

describe('patterns', () => {
  it('has all pattern names defined', () => {
    expect(PATTERN_NAMES.length).toBeGreaterThan(0)
  })

  it('all patterns use valid color codes', () => {
    for (const name of PATTERN_NAMES) {
      const pattern = PATTERNS[name]!
      for (const code of pattern) {
        expect(COLOR_CODES).toContain(code)
      }
    }
  })
})
