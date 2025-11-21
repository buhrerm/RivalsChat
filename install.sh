#!/usr/bin/env bash

# Rivals Rainbow TUI - Installation Script
# Simple installer for the Marvel Rivals rainbow text converter

set -e

SCRIPT_NAME="rivals-tui"
SCRIPT_FILE="rivals-tui.zsh"
INSTALL_DIR="/usr/local/bin"
VERSION="1.0.0"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║   Rivals Rainbow TUI Installer       ║"
echo "║   Version ${VERSION}                       ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root for system install
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}Warning: Running as root. Installing system-wide.${NC}"
    SYSTEM_INSTALL=true
else
    SYSTEM_INSTALL=false
fi

# Check for zsh
echo -e "${BLUE}[1/5]${NC} Checking requirements..."
if ! command -v zsh &> /dev/null; then
    echo -e "${RED}✗ zsh is not installed!${NC}"
    echo "Please install zsh first:"
    echo "  Ubuntu/Debian: sudo apt install zsh"
    echo "  macOS: brew install zsh (usually pre-installed)"
    echo "  Arch: sudo pacman -S zsh"
    exit 1
fi
echo -e "${GREEN}✓ zsh found${NC}"

# Check for clipboard utilities
CLIPBOARD_FOUND=false
if command -v xclip &> /dev/null; then
    echo -e "${GREEN}✓ xclip found${NC}"
    CLIPBOARD_FOUND=true
elif command -v pbcopy &> /dev/null; then
    echo -e "${GREEN}✓ pbcopy found${NC}"
    CLIPBOARD_FOUND=true
elif command -v xsel &> /dev/null; then
    echo -e "${GREEN}✓ xsel found${NC}"
    CLIPBOARD_FOUND=true
else
    echo -e "${YELLOW}⚠ No clipboard utility found (xclip, pbcopy, or xsel)${NC}"
    echo -e "${YELLOW}  Install xclip for clipboard support:${NC}"
    echo "    Ubuntu/Debian: sudo apt install xclip"
    echo "    Arch: sudo pacman -S xclip"
fi

# Check for jq (optional)
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ jq found${NC}"
else
    echo -e "${YELLOW}⚠ jq not found (optional, recommended for custom patterns)${NC}"
    echo "  Install jq for better pattern management:"
    echo "    Ubuntu/Debian: sudo apt install jq"
    echo "    macOS: brew install jq"
    echo "    Arch: sudo pacman -S jq"
fi

# Check if script exists
echo ""
echo -e "${BLUE}[2/5]${NC} Checking script file..."
if [[ ! -f "$SCRIPT_FILE" ]]; then
    echo -e "${RED}✗ $SCRIPT_FILE not found!${NC}"
    echo "Please run this installer from the repository directory."
    exit 1
fi
echo -e "${GREEN}✓ Script file found${NC}"

# Ask user for installation preference
echo ""
echo -e "${BLUE}[3/5]${NC} Choose installation type:"
echo "  1) System-wide install ($INSTALL_DIR/$SCRIPT_NAME) [requires sudo]"
echo "  2) Local install (~/.local/bin/$SCRIPT_NAME)"
echo "  3) Skip install (just make executable)"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        if [[ $SYSTEM_INSTALL == false ]]; then
            echo ""
            echo -e "${BLUE}[4/5]${NC} Installing to $INSTALL_DIR (requires sudo)..."
            sudo cp "$SCRIPT_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
            sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        else
            echo ""
            echo -e "${BLUE}[4/5]${NC} Installing to $INSTALL_DIR..."
            cp "$SCRIPT_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
            chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        fi
        echo -e "${GREEN}✓ Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"
        INSTALL_PATH="$INSTALL_DIR/$SCRIPT_NAME"
        ;;
    2)
        LOCAL_BIN="$HOME/.local/bin"
        mkdir -p "$LOCAL_BIN"
        echo ""
        echo -e "${BLUE}[4/5]${NC} Installing to $LOCAL_BIN..."
        cp "$SCRIPT_FILE" "$LOCAL_BIN/$SCRIPT_NAME"
        chmod +x "$LOCAL_BIN/$SCRIPT_NAME"
        echo -e "${GREEN}✓ Installed to $LOCAL_BIN/$SCRIPT_NAME${NC}"

        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
            echo ""
            echo -e "${YELLOW}⚠ $LOCAL_BIN is not in your PATH${NC}"
            echo "Add this line to your ~/.zshrc or ~/.bashrc:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
        INSTALL_PATH="$LOCAL_BIN/$SCRIPT_NAME"
        ;;
    3)
        echo ""
        echo -e "${BLUE}[4/5]${NC} Making script executable..."
        chmod +x "$SCRIPT_FILE"
        echo -e "${GREEN}✓ Script is executable${NC}"
        INSTALL_PATH="./$SCRIPT_FILE"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# Create config directory
echo ""
echo -e "${BLUE}[5/5]${NC} Setting up configuration..."
CONFIG_DIR="$HOME/.config/rivals"
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/custom_patterns.json" ]]; then
    echo '{"patterns": {}}' > "$CONFIG_DIR/custom_patterns.json"
    echo -e "${GREEN}✓ Created config directory: $CONFIG_DIR${NC}"
else
    echo -e "${GREEN}✓ Config directory already exists${NC}"
fi

# Success message
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🌈           ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

case $choice in
    1|2)
        echo -e "Run with: ${GREEN}$SCRIPT_NAME${NC}"
        ;;
    3)
        echo -e "Run with: ${GREEN}$INSTALL_PATH${NC}"
        ;;
esac

echo ""
echo "Quick start:"
echo "  1. Type your text"
echo "  2. Press Tab to change patterns"
echo "  3. Press Enter to copy"
echo "  4. Press Ctrl+P for Pattern Manager"
echo "  5. Press Esc to quit"
echo ""
echo "For more help, see README.md"
echo ""

exit 0
