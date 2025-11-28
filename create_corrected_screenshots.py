#!/usr/bin/env python3
"""
Create corrected HomeLinkGH app screenshots with proper dimensions
- iPad: 2064 × 2752px, 2752 × 2064px, 2048 × 2732px or 2732 × 2048px
- Android: Various phone and tablet sizes
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Corrected device sizes for all platforms
DEVICE_SIZES = {
    # iPhone (unchanged - these were correct)
    'iPhone_Pro_Portrait': (1290, 2796),
    'iPhone_Pro_Max_Portrait': (1320, 2868),
    
    # iPad - Corrected dimensions per Apple requirements
    'iPad_Pro_Portrait': (2048, 2732),      # 12.9" iPad Pro Portrait
    'iPad_Pro_Landscape': (2732, 2048),     # 12.9" iPad Pro Landscape  
    'iPad_12_9_Portrait': (2064, 2752),     # iPad 12.9" Portrait
    'iPad_12_9_Landscape': (2752, 2064),    # iPad 12.9" Landscape
    
    # Android Phones
    'Android_Phone_Portrait': (1080, 1920),   # Standard Android phone
    'Android_Phone_Large_Portrait': (1440, 2560), # Large Android phone
    
    # Android Tablets  
    'Android_Tablet_Portrait': (1200, 1920),  # Android tablet portrait
    'Android_Tablet_Landscape': (1920, 1200), # Android tablet landscape
}

# HomeLinkGH colors from actual app code
COLORS = {
    'primary_green': '#006B3C',      # From the code
    'secondary_green': '#008A4A',    # From gradient
    'sea_green': '#2E8B57',          # From theme
    'warm_orange': '#FF6B35',        # Secondary color
    'background': '#F5F5F5',
    'white': '#FFFFFF',
    'text_dark': '#333333',
    'text_light': '#666666',
    'card_bg': '#FAFAFA'
}

def get_font(size):
    """Get system font with fallback"""
    try:
        return ImageFont.truetype("/System/Library/Fonts/SF-Pro-Display-Regular.otf", size)
    except:
        try:
            return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
        except:
            return ImageFont.load_default()

def get_responsive_sizes(width, height):
    """Get responsive font and element sizes based on device dimensions"""
    base_size = min(width, height)
    
    return {
        'title_font': get_font(max(32, base_size // 35)),
        'subtitle_font': get_font(max(28, base_size // 45)), 
        'text_font': get_font(max(24, base_size // 55)),
        'small_font': get_font(max(20, base_size // 65)),
        'header_height': max(120, height // 10),
        'padding': max(20, width // 50),
        'card_height': max(100, height // 20)
    }

def create_guest_home_screen(width, height, device_name):
    """Create responsive guest home screen"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    sizes = get_responsive_sizes(width, height)
    padding = sizes['padding']
    header_height = sizes['header_height']
    
    # Header with gradient
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    
    # Status bar
    draw.text((padding, 30), "9:41", fill=COLORS['white'], font=sizes['text_font'])
    draw.text((width-150, 30), "🔋 100%", fill=COLORS['white'], font=sizes['text_font'])
    
    # App logo area
    logo_y = 70
    logo_size = 50
    draw.ellipse([padding, logo_y, padding + logo_size, logo_y + logo_size], fill=COLORS['white'])
    draw.text((padding + 10, logo_y + 10), "🏠", font=sizes['text_font'])
    
    draw.text((padding + logo_size + 20, logo_y + 5), "HomeLinkGH", fill=COLORS['white'], font=sizes['subtitle_font'])
    draw.text((padding + logo_size + 20, logo_y + 35), "Ghana's Service Hub", fill=COLORS['white'], font=sizes['small_font'])
    
    # Action buttons
    btn_width = 80
    btn_height = 40
    btn_y = header_height - 60
    
    draw.rectangle([width-220, btn_y, width-130, btn_y + btn_height], 
                  fill=COLORS['white'], outline=COLORS['primary_green'], width=2)
    draw.text((width-210, btn_y + 12), "Sign In", fill=COLORS['primary_green'], font=sizes['small_font'])
    
    draw.rectangle([width-120, btn_y, width-30, btn_y + btn_height], fill=COLORS['warm_orange'])
    draw.text((width-110, btn_y + 12), "Join", fill=COLORS['white'], font=sizes['small_font'])
    
    # Content area
    y_pos = header_height + padding
    
    # Welcome text
    draw.text((padding, y_pos), "🇬🇭 Welcome to Ghana's Premier Service Platform", 
              fill=COLORS['text_dark'], font=sizes['text_font'])
    
    # Quick Actions
    y_pos += 80
    draw.text((padding, y_pos), "Quick Actions", fill=COLORS['text_dark'], font=sizes['subtitle_font'])
    
    y_pos += 50
    
    # Service cards - responsive grid
    cols = 2 if width < 1500 else 3
    card_width = (width - padding * 2 - (cols - 1) * 20) // cols
    card_height = sizes['card_height']
    
    quick_actions = [
        ("🍽️", "Food Delivery", "Order from local restaurants"),
        ("🏠", "Home Services", "Cleaning, repairs & more"),
        ("🚗", "Transportation", "Reliable rides across Ghana"),
        ("💄", "Beauty Services", "Professional styling")
    ]
    
    for i, (emoji, title, desc) in enumerate(quick_actions):
        if i >= 6:  # Limit cards
            break
            
        row = i // cols
        col = i % cols
        
        x = padding + col * (card_width + 20)
        y = y_pos + row * (card_height + 20)
        
        if y + card_height > height - 150:
            break
        
        # Service card
        draw.rectangle([x, y, x + card_width, y + card_height], 
                      fill=COLORS['white'], outline=COLORS['text_light'], width=1)
        
        # Content
        draw.text((x + 15, y + 15), emoji, font=sizes['text_font'])
        draw.text((x + 15, y + 50), title, fill=COLORS['primary_green'], font=sizes['text_font'])
        draw.text((x + 15, y + 75), desc, fill=COLORS['text_light'], font=sizes['small_font'])
    
    # Service Categories
    y_pos += 2 * (card_height + 20) + 40
    if y_pos < height - 300:
        draw.text((padding, y_pos), "Service Categories", fill=COLORS['text_dark'], font=sizes['subtitle_font'])
        
        y_pos += 40
        categories = [
            "🧹 House Cleaning & Deep Cleaning",
            "🔧 Plumbing & Pipe Repairs", 
            "⚡ Electrical Work & Installations",
            "🎨 Painting & Home Decoration"
        ]
        
        for category in categories:
            if y_pos > height - 120:
                break
            draw.rectangle([padding, y_pos, width-padding, y_pos + 50], 
                          fill=COLORS['card_bg'], outline=COLORS['text_light'], width=1)
            draw.text((padding + 20, y_pos + 15), category, fill=COLORS['text_dark'], font=sizes['text_font'])
            y_pos += 60
    
    return img

def create_food_delivery_screen(width, height, device_name):
    """Create responsive food delivery screen"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    sizes = get_responsive_sizes(width, height)
    padding = sizes['padding']
    header_height = sizes['header_height']
    
    # Header
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    draw.text((padding, header_height//2 - 20), "← Food Delivery", fill=COLORS['white'], font=sizes['title_font'])
    
    # Search bar
    y_pos = header_height + padding
    search_height = 60
    draw.rectangle([padding, y_pos, width-padding, y_pos + search_height], 
                  fill=COLORS['white'], outline=COLORS['text_light'], width=2)
    draw.text((padding + 20, y_pos + 20), "🔍 Search restaurants in Ghana...", 
              fill=COLORS['text_light'], font=sizes['text_font'])
    
    # Location
    y_pos += search_height + 20
    draw.rectangle([padding, y_pos, width-padding, y_pos + 50], fill=COLORS['card_bg'])
    draw.text((padding + 20, y_pos + 15), "📍 Delivering to: Accra, Greater Accra", 
              fill=COLORS['text_dark'], font=sizes['text_font'])
    
    # Restaurants
    y_pos += 80
    draw.text((padding, y_pos), "Popular Restaurants", fill=COLORS['text_dark'], font=sizes['title_font'])
    
    y_pos += 50
    restaurants = [
        ("Auntie Muni's Kitchen", "⭐ 4.8 • Ghanaian Cuisine • ₵₵", "30-45 min"),
        ("Buka Restaurant", "⭐ 4.6 • Traditional Food • ₵₵₵", "25-40 min"),
        ("KFC Accra Mall", "⭐ 4.3 • Fast Food • ₵₵", "20-30 min"),
        ("Chop Bar Express", "⭐ 4.9 • Local Dishes • ₵", "35-50 min")
    ]
    
    restaurant_height = 130
    for restaurant, details, time in restaurants:
        if y_pos + restaurant_height > height - 100:
            break
            
        # Restaurant card
        draw.rectangle([padding, y_pos, width-padding, y_pos + restaurant_height], 
                      fill=COLORS['white'], outline=COLORS['text_light'], width=1)
        
        # Restaurant image placeholder
        img_size = 100
        draw.rectangle([padding + 20, y_pos + 15, padding + 20 + img_size, y_pos + 15 + img_size], 
                      fill=COLORS['primary_green'])
        draw.text((padding + 50, y_pos + 50), "🍽️", font=sizes['text_font'])
        
        # Restaurant info
        text_x = padding + 20 + img_size + 20
        draw.text((text_x, y_pos + 20), restaurant, fill=COLORS['text_dark'], font=sizes['text_font'])
        draw.text((text_x, y_pos + 50), details, fill=COLORS['text_light'], font=sizes['small_font'])
        draw.text((text_x, y_pos + 80), f"⏱️ {time}", fill=COLORS['warm_orange'], font=sizes['small_font'])
        
        y_pos += restaurant_height + 15
    
    return img

def create_profile_screen(width, height, device_name):
    """Create responsive profile screen"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    sizes = get_responsive_sizes(width, height)
    padding = sizes['padding']
    header_height = sizes['header_height']
    
    # Header
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    draw.text((padding, header_height//2 - 20), "My Profile", fill=COLORS['white'], font=sizes['title_font'])
    
    # Profile section
    y_pos = header_height + padding
    
    # Profile picture
    profile_size = 100
    draw.ellipse([padding, y_pos, padding + profile_size, y_pos + profile_size], fill=COLORS['sea_green'])
    draw.text((padding + 30, y_pos + 30), "👤", font=sizes['title_font'])
    
    # User info
    draw.text((padding + profile_size + 30, y_pos + 20), "Guest User", fill=COLORS['text_dark'], font=sizes['text_font'])
    draw.text((padding + profile_size + 30, y_pos + 55), "Join HomeLinkGH today!", fill=COLORS['text_light'], font=sizes['small_font'])
    
    # Sign up prompt
    y_pos += profile_size + 40
    signup_height = 80
    draw.rectangle([padding, y_pos, width-padding, y_pos + signup_height], 
                  fill=COLORS['warm_orange'], outline=COLORS['primary_green'], width=2)
    draw.text((padding + 20, y_pos + 20), "🇬🇭 Sign Up for Full Access", fill=COLORS['white'], font=sizes['text_font'])
    draw.text((padding + 20, y_pos + 50), "Get Ghana Card verification & rewards", fill=COLORS['white'], font=sizes['small_font'])
    
    # Features
    y_pos += signup_height + 40
    draw.text((padding, y_pos), "What You'll Get:", fill=COLORS['text_dark'], font=sizes['title_font'])
    
    y_pos += 50
    features = [
        ("🏆", "Loyalty Rewards", "Earn points with every service"),
        ("🇬🇭", "Ghana Card Verification", "Trusted identity verification"),
        ("📱", "Smart Recommendations", "AI-powered service suggestions"),
        ("⭐", "Review System", "Rate and review providers")
    ]
    
    feature_height = 70
    for icon, title, desc in features:
        if y_pos + feature_height > height - 100:
            break
            
        draw.rectangle([padding, y_pos, width-padding, y_pos + feature_height], 
                      fill=COLORS['white'], outline=COLORS['text_light'], width=1)
        
        draw.text((padding + 20, y_pos + 15), icon, font=sizes['text_font'])
        draw.text((padding + 70, y_pos + 15), title, fill=COLORS['primary_green'], font=sizes['text_font'])
        draw.text((padding + 70, y_pos + 45), desc, fill=COLORS['text_light'], font=sizes['small_font'])
        
        y_pos += feature_height + 10
    
    return img

def main():
    """Generate corrected screenshots for all devices"""
    print("🚀 Creating corrected HomeLinkGH screenshots with proper dimensions...")
    
    # Create screenshots directory
    base_dir = "assets/screenshots"
    os.makedirs(base_dir, exist_ok=True)
    
    screen_creators = {
        '01_home_screen': create_guest_home_screen,
        '02_food_delivery': create_food_delivery_screen,
        '03_home_services': create_guest_home_screen,
        '04_profile_gamification': create_profile_screen,
        '05_ghana_features': create_profile_screen
    }
    
    for device_name, (width, height) in DEVICE_SIZES.items():
        print(f"Creating screenshots for {device_name} ({width}x{height})")
        
        device_dir = os.path.join(base_dir, device_name)
        os.makedirs(device_dir, exist_ok=True)
        
        for screen_name, creator_func in screen_creators.items():
            img = creator_func(width, height, device_name)
            filename = f"{screen_name}_{width}x{height}.png"
            filepath = os.path.join(device_dir, filename)
            img.save(filepath)
            print(f"  ✅ Saved {filename}")
    
    print("🎉 All corrected screenshots created successfully!")
    print("📁 Screenshots saved in assets/screenshots/ directory")
    print("✅ iPad dimensions now match Apple requirements:")
    print("   - iPad Pro: 2048 × 2732px (Portrait), 2732 × 2048px (Landscape)")
    print("   - iPad 12.9: 2064 × 2752px (Portrait), 2752 × 2064px (Landscape)")
    print("✅ Added Android device screenshots with proper dimensions")

if __name__ == "__main__":
    main()