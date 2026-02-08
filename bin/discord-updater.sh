#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Configuration
# -----------------------------
DOWNLOAD_URL="https://discord.com/api/download/stable?platform=linux&format=tar.gz"
INSTALL_DIR="$HOME/.tarball-installations"
DISCORD_DIR="$INSTALL_DIR/Discord"
VERSION_FILE="$DISCORD_DIR/version.txt"
TEMP_DIR="$(mktemp -d)"

# -----------------------------
# Cleanup function
# -----------------------------
cleanup() {
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "== Discord Tarball Updater =="

# -----------------------------
# Detect latest version via redirect
# -----------------------------
REDIRECT_URL=$(curl -s -I -L "$DOWNLOAD_URL" | grep -i '^location:' | tail -n1 | awk '{print $2}' | tr -d '\r\n')
if [[ -z "$REDIRECT_URL" ]]; then
    echo "❌ Failed to detect latest version from Discord redirect."
    exit 1
fi

LATEST_VERSION=$(basename "$REDIRECT_URL" | grep -oP 'discord-\K[0-9]+\.[0-9]+\.[0-9]+')
if [[ -z "$LATEST_VERSION" ]]; then
    echo "❌ Failed to parse version from redirect URL."
    exit 1
fi

echo "📦 Latest available version: $LATEST_VERSION"

# -----------------------------
# Check installed version
# -----------------------------
INSTALLED_VERSION="none"
if [[ -f "$VERSION_FILE" ]]; then
    INSTALLED_VERSION=$(<"$VERSION_FILE")
fi

echo "💾 Installed version: $INSTALLED_VERSION"

# -----------------------------
# Update if needed
# -----------------------------
if [[ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]]; then
    echo "⬇️  Downloading Discord $LATEST_VERSION..."
    curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/discord.tar.gz"

    echo "📂 Extracting..."
    tar -xzf "$TEMP_DIR/discord.tar.gz" -C "$TEMP_DIR"

    FOUND_DISCORD_DIR=$(find "$TEMP_DIR" -type d -name "Discord" | head -n1)
    if [[ -z "$FOUND_DISCORD_DIR" ]]; then
        echo "❌ Could not find Discord folder in tarball."
        exit 1
    fi

    echo "⚙️  Installing Discord..."
    rm -rf "$DISCORD_DIR"
    mkdir -p "$INSTALL_DIR"
    mv "$FOUND_DISCORD_DIR" "$DISCORD_DIR"

    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "✅ Installation complete! Installed version: $LATEST_VERSION"
else
    echo "✅ Discord is already up to date."
fi