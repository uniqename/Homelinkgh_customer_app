# iPad Screenshot Generation Instructions for HomeLinkGH

## Created Files

I've created 3 iPad screenshot HTML templates optimized for 2048 x 2732 pixels (iPad Pro 12.9"):

### 1. Welcome Screenshot (`screenshot_1_welcome.html`)
- **Focus**: Main welcome screen with service categories
- **Content**: HomeLinkGH logo, tagline, 8 service cards, key features
- **Style**: Clean, professional layout with Ghana colors

### 2. Services Screenshot (`screenshot_2_services.html`)  
- **Focus**: Detailed service offerings
- **Content**: 12 service categories with descriptions, popular tags
- **Style**: Grid layout with enhanced visual hierarchy

### 3. Features Screenshot (`screenshot_3_features.html`)
- **Focus**: App features and trust indicators
- **Content**: 6 key features, statistics, diaspora messaging
- **Style**: Feature cards with trust section

## How to Generate PNG Screenshots

### Option A: Browser Screenshot (Recommended)

1. **Open each HTML file in Chrome/Safari**
   ```bash
   open docs/ipad_screenshots/screenshot_1_welcome.html
   ```

2. **Set browser to iPad dimensions**
   - Press F12 (Developer Tools)
   - Click device toggle icon
   - Select "iPad Pro 12.9" or custom 2048 x 2732
   - Zoom to 100%

3. **Take screenshot**
   - Right-click → "Capture screenshot" 
   - Or use browser's screenshot feature
   - Save as PNG format

### Option B: macOS Screenshot Tool

1. **Open HTML in browser at full size**
2. **Use macOS screenshot**
   ```bash
   # Take screenshot of specific area
   Command + Shift + 4
   # Then drag to select the 2048x2732 area
   ```

### Option C: Online Conversion

1. **Use online HTML to PNG converter**
   - Upload HTML files to htmlcsstoimage.com
   - Set dimensions to 2048 x 2732
   - Download PNG files

### Option D: Command Line (if you have wkhtmltopdf/wkhtmltoimage)

```bash
# Install if needed: brew install wkhtmltopdf
wkhtmltoimage --width 2048 --height 2732 screenshot_1_welcome.html welcome.png
wkhtmltoimage --width 2048 --height 2732 screenshot_2_services.html services.png  
wkhtmltoimage --width 2048 --height 2732 screenshot_3_features.html features.png
```

## Quick Upload to App Store Connect

1. **Generate at least 1 iPad screenshot** (any of the 3 templates)
2. **Verify dimensions**: Must be exactly 2048 x 2732 pixels
3. **Upload to App Store Connect**:
   - Go to your app version
   - Scroll to "iPad Pro (6th generation)" section
   - Drag and drop the PNG file

## File Specifications Met

✅ **Resolution**: 2048 x 2732 pixels (iPad Pro 12.9")  
✅ **Format**: HTML (convert to PNG)  
✅ **Orientation**: Portrait  
✅ **Content**: HomeLinkGH branding and features  
✅ **Colors**: Ghana flag colors (#006B3C, #FCD116)  
✅ **Professional**: Clean, App Store-ready design  

## Which Screenshot to Use

**For immediate submission**: Use `screenshot_1_welcome.html` - it's the most comprehensive overview.

**For enhanced presentation**: Generate all 3 and upload multiple screenshots to show different aspects of the app.

## Quick Browser Method (5 minutes)

1. Open `screenshot_1_welcome.html` in Chrome
2. Press F12, click device icon, select iPad Pro
3. Take screenshot and save as PNG
4. Upload to App Store Connect
5. Continue with submission!

The screenshots are designed to be professional, App Store-compliant, and showcase HomeLinkGH's key value propositions for both local Ghanaians and diaspora users.