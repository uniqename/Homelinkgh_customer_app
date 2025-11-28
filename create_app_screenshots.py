#!/usr/bin/env python3
"""
Create realistic HomeLinkGH app screenshots using PIL
Based on the actual app design and features
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Device sizes for screenshots
DEVICE_SIZES = {
    'iPhone_Pro_Portrait': (1290, 2796),
    'iPhone_Pro_Max_Portrait': (1320, 2868),
    'iPad_Pro_Portrait': (2048, 2732),
    'iPad_12_9_Portrait': (2064, 2752),
}

# HomeLinkGH colors
COLORS = {
    'primary_green': '#006B3C',
    'light_green': '#4CAF50',
    'background': '#F5F5F5',
    'white': '#FFFFFF',
    'text_dark': '#333333',
    'text_light': '#666666',
    'ghana_gold': '#FFD700'
}

def create_home_screen(width, height, device_name):
    """Create home screen screenshot"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    # Try to load a system font
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        text_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Header area with Ghana colors
    header_height = height // 8
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    
    # Status bar simulation
    draw.text((50, 40), "9:41", fill=COLORS['white'], font=text_font)
    draw.text((width-200, 40), "100%", fill=COLORS['white'], font=text_font)
    
    # App title
    draw.text((50, header_height + 60), "HomeLinkGH", fill=COLORS['primary_green'], font=title_font)
    draw.text((50, header_height + 140), "Ghana's Smart Home Services", fill=COLORS['text_light'], font=subtitle_font)
    
    # Service cards
    y_pos = header_height + 220
    card_height = 150
    card_margin = 30
    
    services = [
        ("🏠 Home Services", "Cleaning, Plumbing, Electrical"),
        ("🍽️ Food Delivery", "Local restaurants & cuisine"),
        ("🚗 Transportation", "Reliable ride services"),
        ("💄 Beauty Services", "Professional styling"),
    ]
    
    for i, (service, desc) in enumerate(services):
        if y_pos + card_height > height - 100:
            break
            
        # Service card
        draw.rectangle([50, y_pos, width-50, y_pos + card_height], 
                      fill=COLORS['white'], outline=COLORS['light_green'], width=2)
        
        draw.text((80, y_pos + 30), service, fill=COLORS['primary_green'], font=subtitle_font)
        draw.text((80, y_pos + 80), desc, fill=COLORS['text_light'], font=text_font)
        
        y_pos += card_height + card_margin
    
    # Bottom navigation
    nav_height = 120
    draw.rectangle([0, height - nav_height, width, height], fill=COLORS['white'])
    draw.line([0, height - nav_height, width, height - nav_height], fill=COLORS['text_light'], width=1)
    
    nav_items = ["Home", "Services", "Orders", "Profile"]
    nav_width = width // len(nav_items)
    
    for i, item in enumerate(nav_items):
        x_center = nav_width * i + nav_width // 2
        draw.text((x_center - 30, height - 80), item, fill=COLORS['primary_green'], font=text_font)
    
    return img

def create_food_delivery_screen(width, height, device_name):
    """Create food delivery screen screenshot"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
        text_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
    except:
        title_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Header
    header_height = height // 10
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    draw.text((50, 50), "← Food Delivery", fill=COLORS['white'], font=title_font)
    
    # Search bar
    y_pos = header_height + 40
    draw.rectangle([50, y_pos, width-50, y_pos + 60], 
                  fill=COLORS['white'], outline=COLORS['text_light'], width=1)
    draw.text((80, y_pos + 20), "🔍 Search restaurants...", fill=COLORS['text_light'], font=text_font)
    
    # Restaurant cards
    y_pos += 100
    restaurants = [
        ("Auntie Muni's Kitchen", "⭐ 4.8 • Ghanaian • ₵₵"),
        ("Buka Restaurant", "⭐ 4.6 • Local Food • ₵₵₵"),
        ("KFC Accra Mall", "⭐ 4.3 • Fast Food • ₵₵"),
        ("Chop Bar Express", "⭐ 4.9 • Traditional • ₵")
    ]
    
    for restaurant, details in restaurants:
        if y_pos + 120 > height - 150:
            break
            
        # Restaurant card
        draw.rectangle([50, y_pos, width-50, y_pos + 120], 
                      fill=COLORS['white'], outline=COLORS['text_light'], width=1)
        
        # Restaurant image placeholder
        draw.rectangle([70, y_pos + 20, 170, y_pos + 100], fill=COLORS['light_green'])
        draw.text((85, y_pos + 50), "🍽️", font=title_font)
        
        # Restaurant info
        draw.text((190, y_pos + 25), restaurant, fill=COLORS['text_dark'], font=text_font)
        draw.text((190, y_pos + 60), details, fill=COLORS['text_light'], font=text_font)
        
        y_pos += 140
    
    return img

def create_services_screen(width, height, device_name):
    """Create home services screen screenshot"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
        text_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
    except:
        title_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Header
    header_height = height // 10
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    draw.text((50, 50), "← Home Services", fill=COLORS['white'], font=title_font)
    
    # Service categories grid
    y_pos = header_height + 60
    categories = [
        ("🧹", "House Cleaning", "Professional cleaning"),
        ("🔧", "Plumbing", "Repairs & installations"),
        ("⚡", "Electrical", "Wiring & fixtures"),
        ("🎨", "Painting", "Interior & exterior"),
        ("🌿", "Gardening", "Lawn care & landscaping"),
        ("🛠️", "Handyman", "General repairs")
    ]
    
    cols = 2
    col_width = (width - 100) // cols
    row_height = 180
    
    for i, (icon, title, desc) in enumerate(categories):
        if i >= 6:  # Limit to 6 items
            break
            
        row = i // cols
        col = i % cols
        
        x = 50 + col * (col_width + 20)
        y = y_pos + row * (row_height + 20)
        
        if y + row_height > height - 100:
            break
        
        # Service card
        draw.rectangle([x, y, x + col_width, y + row_height], 
                      fill=COLORS['white'], outline=COLORS['light_green'], width=2)
        
        # Icon
        draw.text((x + col_width//2 - 30, y + 30), icon, font=title_font)
        
        # Title and description
        draw.text((x + 20, y + 100), title, fill=COLORS['primary_green'], font=text_font)
        draw.text((x + 20, y + 135), desc, fill=COLORS['text_light'], font=text_font)
    
    return img

def create_profile_screen(width, height, device_name):
    """Create profile/gamification screen screenshot"""
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
        text_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    except:
        title_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    header_height = height // 8
    draw.rectangle([0, 0, width, header_height], fill=COLORS['primary_green'])
    draw.text((50, 50), "Profile", fill=COLORS['white'], font=title_font)
    
    # Profile info
    y_pos = header_height + 40
    
    # Profile picture placeholder
    draw.ellipse([50, y_pos, 150, y_pos + 100], fill=COLORS['light_green'])
    draw.text((85, y_pos + 35), "👤", font=title_font)
    
    # User info
    draw.text((180, y_pos + 20), "Kwame Asante", fill=COLORS['text_dark'], font=text_font)
    draw.text((180, y_pos + 55), "Accra, Ghana", fill=COLORS['text_light'], font=text_font)
    
    # Ghana Card verification
    y_pos += 140
    draw.rectangle([50, y_pos, width-50, y_pos + 80], 
                  fill=COLORS['ghana_gold'], outline=COLORS['primary_green'], width=2)
    draw.text((70, y_pos + 25), "🇬🇭 Ghana Card Verified", fill=COLORS['text_dark'], font=text_font)
    
    # Gamification section
    y_pos += 120
    draw.text((50, y_pos), "Your Rewards", fill=COLORS['primary_green'], font=title_font)
    
    y_pos += 60
    rewards = [
        ("🏆 Loyal Customer", "5 completed orders"),
        ("⭐ Top Reviewer", "10+ reviews given"),
        ("🎯 Service Explorer", "Tried 3+ categories")
    ]
    
    for reward, desc in rewards:
        draw.rectangle([50, y_pos, width-50, y_pos + 70], 
                      fill=COLORS['white'], outline=COLORS['light_green'], width=1)
        draw.text((70, y_pos + 15), reward, fill=COLORS['primary_green'], font=text_font)
        draw.text((70, y_pos + 45), desc, fill=COLORS['text_light'], font=small_font)
        
        y_pos += 90
    
    return img

def main():
    """Generate all screenshots"""
    print("Creating realistic HomeLinkGH app screenshots...")
    
    # Create screenshots directory
    base_dir = "assets/screenshots"
    os.makedirs(base_dir, exist_ok=True)
    
    screen_creators = {
        '01_home_screen': create_home_screen,
        '02_food_delivery': create_food_delivery_screen,
        '03_home_services': create_services_screen,
        '04_profile_gamification': create_profile_screen,
        '05_ghana_features': create_home_screen  # Reuse home screen for 5th screenshot
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
            print(f"  ✓ Saved {filename}")
    
    print("All screenshots created successfully!")
    print("Screenshots saved in assets/screenshots/ directory")

if __name__ == "__main__":
    main()