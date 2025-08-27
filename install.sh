#!/bin/bash

# MYTHOFY SOGo Theme Installer for Mailcow
# Automatically installs and configures the MYTHOFY Phoenix theme

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAILCOW_DIR="/opt/mailcow-dockerized"
THEME_REPO="https://github.com/Kingdragoncat/themesogo.git"
THEME_NAME="mythofy-phoenix-theme"

# Helper functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user with sudo privileges."
    fi
}

# Check if mailcow exists
check_mailcow() {
    if [[ ! -d "$MAILCOW_DIR" ]]; then
        error "Mailcow directory not found at $MAILCOW_DIR. Please install mailcow first."
    fi
    
    if [[ ! -f "$MAILCOW_DIR/docker-compose.yml" ]]; then
        error "Mailcow docker-compose.yml not found. Please check your mailcow installation."
    fi
    
    success "Mailcow installation found"
}

# Install theme
install_theme() {
    log "Installing MYTHOFY Phoenix SOGo Theme..."
    
    # Create SOGo config directory
    sudo mkdir -p "$MAILCOW_DIR/data/conf/sogo"
    
    # Navigate to mailcow directory
    cd "$MAILCOW_DIR"
    
    # Clone or update theme repository
    if [[ -d "data/conf/sogo/$THEME_NAME" ]]; then
        log "Updating existing theme..."
        cd "data/conf/sogo/$THEME_NAME"
        git pull origin main || error "Failed to update theme repository"
    else
        log "Cloning theme repository..."
        git clone "$THEME_REPO" "data/conf/sogo/$THEME_NAME" || error "Failed to clone theme repository"
    fi
    
    cd "$MAILCOW_DIR"
    
    # Combine CSS files
    log "Creating combined theme file..."
    cat "data/conf/sogo/$THEME_NAME/custom-theme.css" \
        "data/conf/sogo/$THEME_NAME/inbox-customizations.css" \
        "data/conf/sogo/$THEME_NAME/admin-customizations.css" \
        "data/conf/sogo/$THEME_NAME/branding-elements.css" > \
        "data/conf/sogo/mythofy-complete-theme.css"
    
    # Copy logos and favicon
    log "Installing logos and favicon..."
    cp -r "data/conf/sogo/$THEME_NAME/logos" "data/conf/sogo/"
    cp "data/conf/sogo/logos/mythofy-logo-dark-240x80.png" "data/conf/sogo/custom-fulllogo.png"
    cp "data/conf/sogo/logos/mythofy-favicon-32x32.png" "data/conf/sogo/custom-favicon.ico"
    
    # Set proper permissions
    sudo chown -R root:root "data/conf/sogo/"
    sudo chmod -R 644 "data/conf/sogo/"*.css "data/conf/sogo/"*.png "data/conf/sogo/"*.ico
    sudo chmod -R 755 "data/conf/sogo/logos"
    
    success "Theme files installed successfully"
}

# Configure docker-compose override
configure_docker() {
    log "Configuring Docker Compose override..."
    
    OVERRIDE_FILE="$MAILCOW_DIR/docker-compose.override.yml"
    
    # Create backup if override exists
    if [[ -f "$OVERRIDE_FILE" ]]; then
        warning "Backing up existing docker-compose.override.yml"
        sudo cp "$OVERRIDE_FILE" "${OVERRIDE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create new override or update existing
    cat << 'EOF' | sudo tee "$OVERRIDE_FILE" > /dev/null
version: '2.1'

services:
  sogo-mailcow:
    volumes:
      - ./data/conf/sogo/mythofy-complete-theme.css:/usr/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
      - ./data/conf/sogo/logos:/usr/lib/GNUstep/SOGo/WebServerResources/logos:z
      - ./data/conf/sogo/custom-fulllogo.png:/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo-full.png:z
      - ./data/conf/sogo/custom-favicon.ico:/usr/lib/GNUstep/SOGo/WebServerResources/img/favicon.ico:z
EOF
    
    success "Docker Compose override configured"
}

# Update SOGo configuration
update_sogo_config() {
    log "Updating SOGo configuration..."
    
    SOGO_CONF="$MAILCOW_DIR/data/conf/sogo/sogo.conf"
    
    # Create backup
    if [[ -f "$SOGO_CONF" ]]; then
        sudo cp "$SOGO_CONF" "${SOGO_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Ensure debug is disabled
    if sudo grep -q "SOGoUIxDebugEnabled" "$SOGO_CONF" 2>/dev/null; then
        sudo sed -i 's/SOGoUIxDebugEnabled = YES;/SOGoUIxDebugEnabled = NO;/' "$SOGO_CONF"
    else
        echo "  SOGoUIxDebugEnabled = NO;" | sudo tee -a "$SOGO_CONF" > /dev/null
    fi
    
    success "SOGo configuration updated"
}

# Restart services
restart_services() {
    log "Restarting SOGo services..."
    
    cd "$MAILCOW_DIR"
    
    # Check if docker-compose or docker compose should be used
    if command -v docker-compose &> /dev/null; then
        DOCKER_CMD="docker-compose"
    else
        DOCKER_CMD="docker compose"
    fi
    
    # Restart specific services
    sudo $DOCKER_CMD restart memcached-mailcow sogo-mailcow || {
        warning "Failed to restart individual services. Trying full restart..."
        sudo $DOCKER_CMD down
        sudo $DOCKER_CMD up -d
    }
    
    success "Services restarted successfully"
}

# Create update script
create_update_script() {
    log "Creating theme update script..."
    
    cat << 'EOF' > "$MAILCOW_DIR/update-sogo-theme.sh"
#!/bin/bash
# MYTHOFY SOGo Theme Updater

MAILCOW_DIR="/opt/mailcow-dockerized"
THEME_NAME="mythofy-phoenix-theme"

cd "$MAILCOW_DIR/data/conf/sogo/$THEME_NAME"
echo "Updating theme from repository..."
git pull origin main

cd "$MAILCOW_DIR"
echo "Rebuilding combined theme file..."
cat "data/conf/sogo/$THEME_NAME/custom-theme.css" \
    "data/conf/sogo/$THEME_NAME/inbox-customizations.css" \
    "data/conf/sogo/$THEME_NAME/admin-customizations.css" \
    "data/conf/sogo/$THEME_NAME/branding-elements.css" > \
    "data/conf/sogo/mythofy-complete-theme.css"

echo "Restarting SOGo services..."
if command -v docker-compose &> /dev/null; then
    sudo docker-compose restart memcached-mailcow sogo-mailcow
else
    sudo docker compose restart memcached-mailcow sogo-mailcow
fi

echo "Theme updated successfully!"
EOF
    
    chmod +x "$MAILCOW_DIR/update-sogo-theme.sh"
    success "Update script created at $MAILCOW_DIR/update-sogo-theme.sh"
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check files exist
    local files=(
        "$MAILCOW_DIR/data/conf/sogo/mythofy-complete-theme.css"
        "$MAILCOW_DIR/data/conf/sogo/custom-fulllogo.png"
        "$MAILCOW_DIR/data/conf/sogo/custom-favicon.ico"
        "$MAILCOW_DIR/docker-compose.override.yml"
    )
    
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file missing: $file"
        fi
    done
    
    # Check SOGo container is running
    cd "$MAILCOW_DIR"
    if command -v docker-compose &> /dev/null; then
        DOCKER_CMD="docker-compose"
    else
        DOCKER_CMD="docker compose"
    fi
    
    if ! sudo $DOCKER_CMD ps | grep -q "sogo-mailcow"; then
        warning "SOGo container may not be running. Check with: sudo $DOCKER_CMD ps"
    fi
    
    success "Installation verification completed"
}

# Main installation process
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║        MYTHOFY Phoenix SOGo Theme            ║"
    echo "║              Installer v1.0                  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "Starting MYTHOFY Phoenix SOGo Theme installation..."
    
    check_root
    check_mailcow
    install_theme
    configure_docker
    update_sogo_config
    restart_services
    create_update_script
    verify_installation
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║             Installation Complete!           ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo
    success "MYTHOFY Phoenix Theme has been installed successfully!"
    echo
    log "Next steps:"
    echo "  1. Open your SOGo webmail interface"
    echo "  2. Verify the theme is applied correctly"
    echo "  3. Test both light and dark modes"
    echo "  4. To update theme: run ./update-sogo-theme.sh"
    echo
    log "Troubleshooting:"
    echo "  - Clear browser cache if theme doesn't appear"
    echo "  - Check logs: sudo docker-compose logs sogo-mailcow"
    echo "  - Verify containers: sudo docker-compose ps"
    echo
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "MYTHOFY Phoenix SOGo Theme Installer"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --update       Update existing theme"
        echo
        exit 0
        ;;
    --update)
        if [[ -f "$MAILCOW_DIR/update-sogo-theme.sh" ]]; then
            exec "$MAILCOW_DIR/update-sogo-theme.sh"
        else
            error "Update script not found. Please run full installation first."
        fi
        ;;
    *)
        main
        ;;
esac