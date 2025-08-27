#!/bin/bash

# MYTHOFY SOGo Theme Updater
# Quick script to update theme from GitHub repository

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Configuration
MAILCOW_DIR="/opt/mailcow-dockerized"
THEME_NAME="mythofy-phoenix-theme"

# Check if we're in the right directory
if [[ ! -f "$MAILCOW_DIR/docker-compose.yml" ]]; then
    echo "Error: Mailcow directory not found at $MAILCOW_DIR"
    exit 1
fi

log "Updating MYTHOFY Phoenix SOGo Theme..."

# Navigate to theme directory and pull updates
cd "$MAILCOW_DIR/data/conf/sogo/$THEME_NAME"
git pull origin main

# Navigate back to mailcow directory
cd "$MAILCOW_DIR"

# Rebuild combined theme file
log "Rebuilding combined theme file..."
cat "data/conf/sogo/$THEME_NAME/custom-theme.css" \
    "data/conf/sogo/$THEME_NAME/inbox-customizations.css" \
    "data/conf/sogo/$THEME_NAME/admin-customizations.css" \
    "data/conf/sogo/$THEME_NAME/branding-elements.css" > \
    "data/conf/sogo/mythofy-complete-theme.css"

# Update logos if changed
log "Updating logos..."
cp -r "data/conf/sogo/$THEME_NAME/logos" "data/conf/sogo/"
cp "data/conf/sogo/logos/mythofy-logo-dark-240x80.png" "data/conf/sogo/custom-fulllogo.png"
cp "data/conf/sogo/logos/mythofy-favicon-32x32.png" "data/conf/sogo/custom-favicon.ico"

# Set proper permissions
sudo chown -R root:root "data/conf/sogo/"*.css "data/conf/sogo/"*.png "data/conf/sogo/"*.ico
sudo chmod -R 644 "data/conf/sogo/"*.css "data/conf/sogo/"*.png "data/conf/sogo/"*.ico

# Restart SOGo services
log "Restarting SOGo services..."

# Determine docker command
if command -v docker-compose &> /dev/null; then
    DOCKER_CMD="docker-compose"
else
    DOCKER_CMD="docker compose"
fi

# Restart services
sudo $DOCKER_CMD restart memcached-mailcow sogo-mailcow

success "Theme updated successfully!"
echo
log "Changes applied. Please refresh your browser to see updates."