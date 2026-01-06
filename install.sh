#!/bin/bash
# Zero-config installer for mobile-check

set -e

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS-$ARCH" in
  "darwin-x86_64") BINARY="mobile-check-macos-x86_64" ;;
  "darwin-arm64") BINARY="mobile-check-macos-arm64" ;;
  "linux-x86_64") BINARY="mobile-check-linux-x86_64" ;;
  *) echo "❌ Unsupported OS: $OS $ARCH"; exit 1 ;;
esac

INSTALL_DIR="$HOME/.mobile-check/bin"
mkdir -p "$INSTALL_DIR"

echo "📥 Downloading $BINARY..."
curl -L "https://github.com/Ravi4242/mobile-check/releases/latest/download/$BINARY" -o "$INSTALL_DIR/mobile-check"
chmod +x "$INSTALL_DIR/mobile-check"

# Add to PATH
echo 'export PATH="$HOME/.mobile-check/bin:$PATH"' >> ~/.bashrc
[ -f ~/.zshrc ] && echo 'export PATH="$HOME/.mobile-check/bin:$PATH"' >> ~/.zshrc

export PATH="$INSTALL_DIR:$PATH"

echo "✅ Installed! Run: mobile-check --help"
mobile-check --help
