export type RepeatMode = 'continuous' | 'word'
export type SymmetryMode = 'none' | 'mirror' | 'full'

function isAlphanumeric(char: string): boolean {
  return /[a-zA-Z0-9]/.test(char)
}

function processWord(word: string, pattern: string[], symmetry: SymmetryMode): string {
  const len = word.length
  if (len === 0) return ''

  let result = ''

  if (symmetry === 'full') {
    const charsPerColor = Math.ceil(len / pattern.length)
    let charIdx = 0
    for (let colorIdx = 0; colorIdx < pattern.length && charIdx < len; colorIdx++) {
      const color = pattern[colorIdx]!
      const count = colorIdx === pattern.length - 1 ? len - charIdx : charsPerColor
      for (let j = 0; j < count && charIdx < len; j++) {
        result += `#${color}${word[charIdx]}`
        charIdx++
      }
    }
  } else if (symmetry === 'mirror') {
    for (let j = 0; j < len; j++) {
      let pos = j
      if (j >= Math.ceil(len / 2)) {
        pos = len - j - 1
      }
      const color = pattern[pos % pattern.length]!
      result += `#${color}${word[j]}`
    }
  } else {
    for (let j = 0; j < len; j++) {
      const color = pattern[j % pattern.length]!
      result += `#${color}${word[j]}`
    }
  }

  return result
}

function processContinuous(text: string, pattern: string[], symmetry: SymmetryMode): string {
  let result = ''

  if (symmetry === 'full') {
    let totalChars = 0
    for (const char of text) {
      if (isAlphanumeric(char)) totalChars++
    }

    const charsPerColor = Math.ceil(totalChars / pattern.length)
    let charCount = 0

    for (const char of text) {
      if (isAlphanumeric(char)) {
        let colorIdx = Math.floor(charCount / charsPerColor)
        if (colorIdx >= pattern.length) colorIdx = pattern.length - 1
        const color = pattern[colorIdx]!
        result += `#${color}${char}`
        charCount++
      } else {
        result += char
      }
    }
  } else if (symmetry === 'mirror') {
    let totalChars = 0
    for (const char of text) {
      if (isAlphanumeric(char)) totalChars++
    }

    let charCount = 0
    for (const char of text) {
      if (isAlphanumeric(char)) {
        let pos = charCount
        if (charCount >= Math.ceil(totalChars / 2)) {
          pos = totalChars - charCount - 1
        }
        const color = pattern[pos % pattern.length]!
        result += `#${color}${char}`
        charCount++
      } else {
        result += char
      }
    }
  } else {
    let colorIdx = 0
    for (const char of text) {
      if (isAlphanumeric(char)) {
        const color = pattern[colorIdx % pattern.length]!
        result += `#${color}${char}`
        colorIdx++
      } else {
        result += char
      }
    }
  }

  return result
}

export function convertText(
  text: string,
  pattern: string[],
  repeatMode: RepeatMode,
  symmetry: SymmetryMode
): string {
  if (!text || pattern.length === 0) return ''

  if (repeatMode === 'word') {
    let result = ''
    let word = ''

    for (const char of text) {
      if (isAlphanumeric(char)) {
        word += char
      } else {
        if (word) {
          result += processWord(word, pattern, symmetry)
          word = ''
        }
        result += char
      }
    }

    if (word) {
      result += processWord(word, pattern, symmetry)
    }

    return result
  }

  return processContinuous(text, pattern, symmetry)
}
