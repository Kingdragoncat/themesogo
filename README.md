# MYTHOFY Phoenix SOGo Theme

A modern, ultra-clean SOGo theme with phoenix fire branding for MYTHOFY Inc. Features light/dark mode support, professional corporate styling, and comprehensive customizations for inbox, admin, and all SOGo interfaces.

## 🔥 Features

- **MYTHOFY Fire Branding**: Red/orange gradient colors and custom logo
- **Material Design**: Uses SOGo's native Material Design system properly
- **Light & Dark Mode**: Proper theme variables that work with SOGo's built-in themes
- **Clean & Professional**: Subtle styling that enhances SOGo without breaking functionality
- **SOGo Native**: Works with all SOGo components (mail, calendar, contacts, admin)
- **Corporate Ready**: Professional appearance for business environments
- **Responsive**: Mobile-optimized without interfering with SOGo's responsive design

## 🎨 Color Scheme

### Fire Palette
- **Primary Fire**: #dc2626 (Red)
- **Secondary Fire**: #f97316 (Orange)  
- **Accent Fire**: #fbbf24 (Amber)

### Light Mode
- **Background**: #ffffff (White)
- **Surface**: #fafaf9 (Off-white)
- **Text**: #1c1917 (Dark warm gray)

### Dark Mode
- **Background**: #0c0a09 (Almost black with warm undertone)
- **Surface**: #1c1917 (Dark warm gray)
- **Text**: #fafaf9 (Off-white)

## 📁 File Structure

```
SOGO custom theme/
├── custom-theme.css           # Main theme file (required)
├── inbox-customizations.css   # Enhanced inbox styling
├── admin-customizations.css   # Admin interface styling  
├── branding-elements.css      # MYTHOFY branding elements
├── logos/
│   ├── mythofy-logo-light-160x40.png    # Header logo (light mode)
│   ├── mythofy-logo-dark-160x40.png     # Header logo (dark mode)  
│   ├── mythofy-logo-light-240x80.png    # Login page logo (light mode)
│   ├── mythofy-logo-dark-240x80.png     # Login page logo (dark mode)
│   ├── mythofy-logo-light-80x24.png     # Small logo (light mode)
│   ├── mythofy-logo-dark-80x24.png      # Small logo (dark mode)
│   └── mythofy-favicon-32x32.png        # Favicon
├── mythofy-theme-config.md    # Brand configuration
└── README.md                  # This file
```

## 🚀 Installation

### Step 1: Prepare Files

1. Copy `custom-theme.css` to your mailcow server
2. Copy the `logos/` folder to the same directory
3. Optionally copy additional CSS files for enhanced features

### Step 2: Upload to Mailcow

```bash
# Navigate to mailcow directory
cd /opt/mailcow-dockerized

# Create SOGo configuration directory if it doesn't exist
mkdir -p data/conf/sogo

# Copy theme files
cp /path/to/your/custom-theme.css data/conf/sogo/
cp -r /path/to/your/logos data/conf/sogo/

# Copy logo files for SOGo branding  
cp logos/mythofy-logo-light-240x80.png data/conf/sogo/custom-fulllogo.png
cp logos/mythofy-favicon-32x32.png data/conf/sogo/custom-favicon.ico
```

### Step 3: Configure Docker

Edit or create `docker-compose.override.yml`:

```yaml
version: '2.1'

services:
  sogo-mailcow:
    volumes:
      - ./data/conf/sogo/custom-theme.css:/usr/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
      - ./data/conf/sogo/custom-fulllogo.png:/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo-full.png:z
      - ./data/conf/sogo/custom-favicon.ico:/usr/lib/GNUstep/SOGo/WebServerResources/img/favicon.ico:z
```

### Step 4: Update SOGo Configuration

Edit `data/conf/sogo/sogo.conf` and ensure:

```
SOGoUIxDebugEnabled = NO;
```

### Step 5: Restart Services

```bash
# Restart required services
docker-compose restart memcached-mailcow sogo-mailcow

# Or restart everything
docker-compose down && docker-compose up -d
```

## 🎯 Advanced Installation (Full Theme)

For the complete MYTHOFY experience, you can combine multiple CSS files:

```bash
# Combine all CSS files into one
cat custom-theme.css inbox-customizations.css admin-customizations.css branding-elements.css > data/conf/sogo/mythofy-complete-theme.css

# Update docker-compose.override.yml to use the combined file
# Replace the volume mount with:
- ./data/conf/sogo/mythofy-complete-theme.css:/usr/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```

## 🔧 Customization

### Changing Colors

Edit the CSS variables in `custom-theme.css`:

```css
:root {
  --mythofy-primary: #dc2626;    /* Change primary color */
  --mythofy-secondary: #f97316;  /* Change secondary color */
  --mythofy-accent: #fbbf24;     /* Change accent color */
}
```

### Using Your Own Logo

1. Replace files in the `logos/` directory with your own SVG files
2. Maintain the same file names and structure
3. Ensure logos are optimized SVG format for best performance

### Dark Mode Toggle

The theme automatically supports system dark mode. To add a manual toggle, implement JavaScript:

```javascript
// Add this to your SOGo instance
function toggleTheme() {
  document.body.classList.toggle('dark-mode');
  localStorage.setItem('theme', document.body.classList.contains('dark-mode') ? 'dark' : 'light');
}
```

## 🐛 Troubleshooting

### Theme Not Loading
- Check file permissions: `chmod 644 data/conf/sogo/custom-theme.css`
- Verify docker-compose.override.yml syntax
- Restart containers: `docker-compose restart sogo-mailcow`

### Logo Not Appearing  
- Ensure SVG files are properly formatted
- Check file paths in CSS match your directory structure
- Verify volume mounts in docker-compose.override.yml

### Performance Issues
- Use minified CSS for production
- Optimize SVG files with tools like SVGO
- Enable browser caching

### Mobile Responsiveness
- Test on various screen sizes
- Adjust CSS media queries if needed
- Ensure touch targets are adequately sized

## 📱 Browser Support

- ✅ Chrome/Chromium 90+
- ✅ Firefox 88+  
- ✅ Safari 14+
- ✅ Edge 90+
- ⚠️ IE 11 (limited support)

## 🔒 Security Notes

- All theme files are client-side CSS/SVG only
- No JavaScript execution or external resources
- Follows SOGo security best practices
- Safe for corporate/enterprise environments

## 📄 License

This theme is created for MYTHOFY Inc. internal use. Modify and distribute according to your organization's policies.

## 🆘 Support

For theme issues:
1. Check the troubleshooting section above
2. Verify mailcow and SOGo versions compatibility  
3. Review browser console for CSS errors
4. Test with a minimal custom-theme.css first

## 📈 Version History

- **v1.0**: Initial MYTHOFY Phoenix theme
  - Light/dark mode support
  - Complete SOGo interface styling
  - Phoenix fire branding
  - Responsive design
  - Professional corporate styling

---

**🔥 Rise from the ashes of boring email interfaces with MYTHOFY Phoenix Theme! 🔥**