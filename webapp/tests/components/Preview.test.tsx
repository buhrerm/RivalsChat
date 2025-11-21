import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { Preview } from '../../src/components/Preview'

describe('Preview', () => {
  it('renders converted text', () => {
    render(<Preview converted="#Ra#Gb#Bc" />)
    expect(screen.getByText('a')).toBeDefined()
    expect(screen.getByText('b')).toBeDefined()
    expect(screen.getByText('c')).toBeDefined()
  })

  it('shows the raw code', () => {
    render(<Preview converted="#Ra#Gb" />)
    expect(screen.getByText('#Ra#Gb')).toBeDefined()
  })
})
