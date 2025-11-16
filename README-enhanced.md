# Marvel Rivals Rainbow Text Converter - Enhanced Edition

## New Features in Enhanced Edition

The enhanced version of the Marvel Rivals Rainbow Text Converter adds powerful pattern creation and management capabilities while maintaining the simplicity of the original.

### What's New

#### Custom Pattern Creator
- **Interactive Pattern Building** - Create patterns step-by-step with visual feedback
- **Live Preview** - See your pattern applied to sample text in real-time
- **Persistent Storage** - Your patterns are saved to `~/.config/rivals/custom_patterns.json`
- **Icon Selection** - Choose from 12 icons to personalize your patterns

#### Pattern Manager
- **Unified Pattern Library** - Browse all built-in and custom patterns in one place
- **Edit Existing Patterns** - Modify your custom patterns anytime
- **Delete Unwanted Patterns** - Clean up patterns you no longer need
- **Smart Navigation** - Scrollable list with keyboard navigation

#### Enhanced Navigation
- **Visual Pattern Browser** - See previous/next pattern hints
- **Pattern Counter** - Always know where you are (e.g., "3/15")
- **Custom Pattern Tags** - Easily identify which patterns are yours
- **Improved Keyboard Shortcuts** - More intuitive controls

### Installation

```bash
# Make the enhanced version executable
chmod +x rivals-tui-enhanced.zsh

# Run the enhanced TUI
./rivals-tui-enhanced.zsh
```

### Quick Start Guide

1. **Launch the Enhanced TUI**
   ```bash
   ./rivals-tui-enhanced.zsh
   ```

2. **Create Your First Custom Pattern**
   - Press `P` to open the Pattern Manager
   - Press `N` to create a new pattern
   - Enter a name (e.g., "Fire and Ice")
   - Select an icon using arrow keys and Space
   - Build your color sequence with Space to toggle colors
   - Press `S` to save your pattern

3. **Use Your Pattern**
   - Type your text in the main screen
   - Use Tab/Shift+Tab to navigate to your pattern
   - Press Enter to copy the rainbow text to clipboard
   - Paste in Marvel Rivals chat!

### Pattern File Format

Custom patterns are stored in JSON format at `~/.config/rivals/custom_patterns.json`:

```json
{
  "patterns": {
    "MyPattern": {
      "pattern": "R O Y G B",
      "icon": "🌟"
    }
  }
}
```

### Tips & Tricks

1. **Quick Pattern Testing**
   - The preview shows "The quick brown fox jumps" with your pattern
   - This helps you see how the pattern flows across text

2. **Color Combinations**
   - Fewer colors = faster repetition
   - 3-5 colors work great for most patterns
   - 7+ colors create smooth gradients

3. **Pattern Ideas**
   - **Team Colors**: Use 2-3 colors of your team
   - **Gradients**: Select adjacent colors for smooth transitions
   - **Contrast**: Mix bright and dark colors for pop
   - **Monochrome**: Use shades of the same color family

### Keyboard Reference

| Key | Action | Context |
|-----|--------|---------|
| P | Open Pattern Manager | Main Screen |
| Tab | Next Pattern | Main Screen |
| Shift+Tab | Previous Pattern | Main Screen |
| Enter | Copy to Clipboard | Main Screen |
| N | New Pattern | Pattern Manager |
| E | Edit Pattern | Pattern Manager (Custom Only) |
| D | Delete Pattern | Pattern Manager (Custom Only) |
| Space | Toggle/Select | Pattern Creator |
| S | Save Pattern | Pattern Creator |
| Esc | Cancel/Back/Quit | Any Screen |

### Compatibility

- **Shell**: Zsh 5.0+
- **Terminal**: Any terminal with 256-color support
- **Clipboard**: xclip (Linux), pbcopy (macOS), or xsel (Linux)
- **Optional**: jq for better JSON handling

### Troubleshooting

**Pattern not saving?**
- Check that `~/.config/rivals/` directory exists
- Ensure you have write permissions
- Verify jq is installed for better JSON handling

**Colors not showing?**
- Make sure your terminal supports 256 colors
- Try `echo $TERM` - should show something like `xterm-256color`

**Clipboard not working?**
- Install clipboard tool: `xclip` (Linux) or use `pbcopy` (macOS)
- The tool auto-detects available clipboard commands

### Comparison with Original

| Feature | Original | Enhanced |
|---------|----------|----------|
| Built-in Patterns | 10 | 10+ |
| Custom Patterns | ❌ | ✅ Unlimited |
| Pattern Editor | ❌ | ✅ Interactive |
| Pattern Manager | ❌ | ✅ Full CRUD |
| Pattern Persistence | ❌ | ✅ JSON Storage |
| Navigation | Basic | Advanced with hints |
| File Size | ~550 lines | ~850 lines |
| Dependencies | None | Optional: jq |

### Contributing

Feel free to suggest new features or report issues! The enhanced version is designed to be extensible while maintaining the simplicity of the original.

### License

Created for the Marvel Rivals community. Use freely and have fun!

---

*Enhanced with love for the Marvel Rivals community* 🎮