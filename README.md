# Rivals Rainbow TUI

A beautiful terminal-based rainbow text converter for Marvel Rivals. Create vibrant, colorful chat messages with custom patterns and real-time preview.

## Features

- **10 Built-in Patterns**: Rainbow, Warm, Cool, Neon, Sunset, Ocean, Psychedelic, Spring, Cherry, Matrix
- **Custom Pattern Creator**: Build and save your own color patterns with visual preview
- **Pattern Manager**: Browse, edit, and delete custom patterns
- **Three Repeat Modes**: Continuous, per-word, or per-phrase coloring
- **Symmetry Effects**: Mirror or full symmetry for unique effects
- **Clipboard Integration**: One-click copy to clipboard
- **Text Editing**: Full cursor control, selection, cut/copy/paste support

## Requirements

- `zsh` shell
- Clipboard utility (one of):
  - `xclip` (Linux/X11)
  - `pbcopy` (macOS)
  - `xsel` (Linux alternative)
- `jq` (optional, for custom pattern storage)

## Directory Structure

```
Rivals/
├── src/                    # Modular source code
│   ├── components/         # UI components (header, input, preview, etc)
│   ├── handlers/           # Input handlers for different modes
│   ├── lib/                # Business logic (converter, renderer)
│   ├── pages/              # Page views (main, creator, manager)
│   ├── state/              # State management
│   ├── utils/              # Utilities (config, clipboard, constants)
│   └── rivals-tui-modular.zsh  # Modular entry point
├── tests/                  # Test suite
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── component_test.zsh  # Component smoke tests
├── rivals-tui.zsh          # Modular version (default)
├── rivals-tui-original.zsh # Original monolithic version
├── CLAUDE.md               # Architecture documentation
├── README.md               # This file
└── LICENSE                 # MIT License
```

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/rivals-rainbow-tui.git
cd rivals-rainbow-tui

# Run the installer
./install.sh

# Or run directly without installing
./rivals-tui.zsh          # Modular version (default)
./rivals-tui-original.zsh # Original monolithic version
```

### Manual Install

```bash
# Make executable
chmod +x rivals-tui.zsh

# Optional: Copy to PATH
sudo cp rivals-tui.zsh /usr/local/bin/rivals-tui

# Run
rivals-tui
```

## Usage

### Basic Controls

| Key | Action |
|-----|--------|
| **Type** | Enter your text |
| **Tab** / **← →** | Navigate patterns |
| **Shift+Tab** | Previous pattern |
| **Enter** | Copy to clipboard |
| **Esc** | Quit |

### Advanced Controls

| Key | Action |
|-----|--------|
| **Ctrl+P** | Open Pattern Manager |
| **Ctrl+R** | Cycle repeat modes (Continuous/Word/Phrase) |
| **Ctrl+S** | Cycle symmetry modes (Off/Mirror/Full) |
| **Ctrl+A** | Select all text |
| **Ctrl+X** | Cut selection |
| **Ctrl+V** | Paste from clipboard |
| **Ctrl+U** | Clear text |

### Creating Custom Patterns

1. Press **Ctrl+P** to open Pattern Manager
2. Press **N** to create new pattern
3. Enter a pattern name
4. Press **Tab**, use arrows to select an icon, press **Space**
5. Press **Tab**, use arrows to navigate colors, press **Space** to add
6. Press **S** to save

### Pattern Modes

**Repeat Modes** (Ctrl+R):
- **Continuous**: Pattern flows through entire text
- **Per Word**: Pattern resets for each word
- **Per Phrase**: Single pattern instance across text

**Symmetry Modes** (Ctrl+S):
- **Off**: Normal pattern flow
- **Mirror**: Text mirrors from center
- **Full**: Complete pattern always shown

## Marvel Rivals Color Codes

The tool uses official Marvel Rivals color codes:

| Code | Color |
|------|-------|
| Y | Gold |
| O | Orange |
| R | Red |
| P | Pink |
| M | Really Pink |
| U | Purple |
| B | Blue |
| I | Dark Blue |
| A | Teal |
| T | Blue Green |
| G | Green |
| E | Green Yellow |
| K | Yellow |

## Examples

Input: `Hello World`
- Rainbow pattern: `#YH#Oe#Rl#Pl#Mo#U #BW#Io#Ar#Tl#Gd`
- Copy and paste into Marvel Rivals chat!

## Configuration

Custom patterns are stored in: `~/.config/rivals/custom_patterns.json`

## Troubleshooting

**No clipboard support?**
Install a clipboard utility:
```bash
# Ubuntu/Debian
sudo apt install xclip

# macOS (built-in)
# pbcopy should already be available

# Arch
sudo pacman -S xclip
```

**jq not found?**
Custom patterns still work with basic fallback, but for best experience:
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Arch
sudo pacman -S jq
```

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please feel free to submit issues and pull requests.

## Support

- Report issues: [GitHub Issues](https://github.com/yourusername/rivals-rainbow-tui/issues)
- Marvel Rivals community: Share your patterns!

---

Made with 🌈 for the Marvel Rivals community
