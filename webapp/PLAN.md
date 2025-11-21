# Webapp Plan

## Overview
React + Bun frontend-only app. Converts text to Marvel Rivals color codes with pattern selection and clipboard copy.

## Tech Stack
- **Runtime**: Bun
- **Framework**: React 18
- **Build**: Vite (bun compatible)
- **Styling**: CSS Modules (no framework, fast)
- **Testing**: Vitest + React Testing Library

## Directory Structure

```
webapp/
├── src/
│   ├── main.tsx              # Entry point
│   ├── App.tsx               # Root component
│   ├── components/           # All UI components
│   │   ├── TextInput.tsx
│   │   ├── PatternSelector.tsx
│   │   ├── Preview.tsx
│   │   ├── CopyButton.tsx
│   │   └── ModeToggle.tsx
│   ├── lib/                  # Business logic (shared with TUI concepts)
│   │   ├── converter.ts      # Text → Rivals code conversion
│   │   ├── patterns.ts       # Pattern definitions
│   │   └── colors.ts         # Color code mappings
│   ├── hooks/                # Custom hooks
│   │   └── useConverter.ts   # Main conversion hook
│   └── styles/               # Global styles
│       └── global.css
├── tests/                    # Centralized tests
│   ├── components/
│   │   ├── TextInput.test.tsx
│   │   ├── PatternSelector.test.tsx
│   │   └── Preview.test.tsx
│   ├── lib/
│   │   ├── converter.test.ts
│   │   └── patterns.test.ts
│   └── setup.ts
├── index.html
├── package.json
├── vite.config.ts
├── tsconfig.json
└── vitest.config.ts
```

## Components

### TextInput
- Textarea for user input
- Debounced updates (150ms)
- Auto-focus on load

### PatternSelector
- Grid of pattern buttons with color preview swatches
- Active state highlight
- Keyboard navigation (arrow keys)

### Preview
- Shows converted text with inline colors
- Visual representation of how it looks
- Raw code display for copy

### CopyButton
- One-click copy to clipboard
- Success feedback (checkmark, brief)
- Keyboard shortcut (Ctrl+Enter)

### ModeToggle
- Repeat mode: continuous/word/phrase
- Symmetry: off/mirror/full
- Simple toggle buttons

## Core Logic (lib/)

### converter.ts
Port TUI's text_converter.zsh logic:
- `convertText(text: string, pattern: string[], mode: Mode): string`
- Handle repeat modes
- Handle symmetry

### patterns.ts
```ts
export const PATTERNS = {
  rainbow: ['Y', 'O', 'R', 'P', 'M', 'U', 'B', 'I', 'A', 'T', 'G', 'E', 'K'],
  warm: ['Y', 'O', 'R', 'P'],
  cool: ['B', 'I', 'A', 'T', 'G'],
  // ... etc
}
```

### colors.ts
```ts
export const COLORS: Record<string, string> = {
  Y: '#FFD700', // Gold
  O: '#FF8C00', // Orange
  R: '#FF0000', // Red
  // ... etc
}
```

## Design

### Dark Mode
- CSS custom properties for theming
- `prefers-color-scheme` media query for system default
- Manual toggle in header (persisted to localStorage)

### Mobile Responsive
- Mobile-first CSS
- Breakpoints: 480px (mobile), 768px (tablet), 1024px+ (desktop)
- Stack layout on mobile, side-by-side on desktop
- Touch-friendly pattern selector (larger tap targets)

## Performance

- No heavy dependencies
- CSS Modules = scoped styles, tree-shakeable
- Vite = fast HMR, optimized production build
- Lazy load pattern previews if needed
- < 50KB bundle target

## Testing Strategy

All tests in `/tests/` directory:
- Unit tests for lib/ functions
- Component tests with React Testing Library
- No E2E (overkill for this)

Run: `bun test`

## Implementation Order

1. Setup (vite, bun, tsconfig)
2. lib/ - converter, patterns, colors
3. Tests for lib/
4. Components - TextInput, Preview, CopyButton
5. PatternSelector, ModeToggle
6. Component tests
7. Styling polish
