#!/usr/bin/env python3
"""
HomeLinkGH App Icon Generator
Creates all required app icon sizes for iOS and Android
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_app_icon(size):
    """Create app icon for HomeLinkGH at specified size"""
    
    # Create square image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors matching HomeLinkGH branding
    primary_green = (46, 139, 87)      # #2E8B57
    light_green = (60, 179, 113)       # #3CB371
    orange_accent = (255, 107, 53)     # #FF6B35
    ghana_yellow = (252, 209, 22)      # #FCD116
    white = (255, 255, 255)
    
    # Background with gradient
    for y in range(size):
        ratio = y / size
        r = int(primary_green[0] * (1 - ratio) + light_green[0] * ratio)
        g = int(primary_green[1] * (1 - ratio) + light_green[1] * ratio)
        b = int(primary_green[2] * (1 - ratio) + light_green[2] * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # Calculate proportional sizes
    house_size = int(size * 0.6)
    house_x = (size - house_size) // 2
    house_y = int(size * 0.3)
    
    # Draw house shape
    # House base
    base_height = int(house_size * 0.6)
    base_y = house_y + int(house_size * 0.3)
    draw.rectangle([house_x, base_y, house_x + house_size, base_y + base_height], 
                   fill=white, outline=primary_green, width=max(1, size // 100))
    
    # House roof (triangle)
    roof_peak_x = house_x + house_size // 2
    roof_peak_y = house_y
    roof_left_x = house_x - int(house_size * 0.1)
    roof_right_x = house_x + house_size + int(house_size * 0.1)
    roof_base_y = base_y + int(house_size * 0.05)
    
    roof_points = [
        (roof_peak_x, roof_peak_y),
        (roof_left_x, roof_base_y),
        (roof_right_x, roof_base_y)
    ]
    draw.polygon(roof_points, fill=orange_accent)
    
    # Door
    door_width = max(int(house_size * 0.25), 4)
    door_height = max(int(house_size * 0.4), 6)
    door_x = house_x + (house_size - door_width) // 2
    door_y = base_y + base_height - door_height
    draw.rectangle([door_x, door_y, door_x + door_width, door_y + door_height], 
                   fill=primary_green)
    
    # Door handle
    handle_size = max(size // 80, 1)
    handle_x = door_x + door_width - handle_size * 3
    handle_y = door_y + door_height // 2
    draw.ellipse([handle_x, handle_y, handle_x + handle_size, handle_y + handle_size], 
                 fill=ghana_yellow)
    
    # Windows
    window_size = max(int(house_size * 0.15), 4)
    window_y = base_y + int(house_size * 0.15)
    
    # Left window
    left_window_x = house_x + int(house_size * 0.2)
    draw.rectangle([left_window_x, window_y, left_window_x + window_size, window_y + window_size], 
                   fill='lightblue', outline=primary_green, width=max(1, size // 200))
    
    # Right window  
    right_window_x = house_x + house_size - int(house_size * 0.2) - window_size
    draw.rectangle([right_window_x, window_y, right_window_x + window_size, window_y + window_size], 
                   fill='lightblue', outline=primary_green, width=max(1, size // 200))
    
    # Window crosses
    if size >= 64:
        # Left window cross
        cross_mid_x = left_window_x + window_size // 2
        cross_mid_y = window_y + window_size // 2
        draw.line([cross_mid_x, window_y, cross_mid_x, window_y + window_size], 
                  fill=primary_green, width=max(1, size // 300))
        draw.line([left_window_x, cross_mid_y, left_window_x + window_size, cross_mid_y], 
                  fill=primary_green, width=max(1, size // 300))
        
        # Right window cross
        cross_mid_x = right_window_x + window_size // 2
        draw.line([cross_mid_x, window_y, cross_mid_x, window_y + window_size], 
                  fill=primary_green, width=max(1, size // 300))
        draw.line([right_window_x, cross_mid_y, right_window_x + window_size, cross_mid_y], 
                  fill=primary_green, width=max(1, size // 300))
    
    # "QUICK" badge in corner
    if size >= 64:
        badge_width = int(size * 0.35)
        badge_height = int(size * 0.15)
        badge_x = size - badge_width - int(size * 0.05)
        badge_y = int(size * 0.05)
        
        # Badge background
        draw.rounded_rectangle([badge_x, badge_y, badge_x + badge_width, badge_y + badge_height], 
                              radius=max(badge_height // 4, 2), fill=ghana_yellow)
        
        # Badge text
        try:
            font_size = max(int(size * 0.08), 8)
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            font = ImageFont.load_default()
        
        text = "QUICK"
        text_bbox = draw.textbbox((0, 0), text, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        text_x = badge_x + (badge_width - text_width) // 2
        text_y = badge_y + (badge_height - text_height) // 2
        draw.text((text_x, text_y), text, fill=primary_green, font=font)
    
    # Ghana flag accent (small)
    if size >= 48:
        flag_size = int(size * 0.12)
        flag_x = int(size * 0.05)
        flag_y = size - flag_size - int(size * 0.05)
        
        # Flag stripes
        stripe_height = flag_size // 3
        draw.rectangle([flag_x, flag_y, flag_x + flag_size, flag_y + stripe_height], 
                       fill=(206, 17, 38))  # Red
        draw.rectangle([flag_x, flag_y + stripe_height, flag_x + flag_size, flag_y + 2 * stripe_height], 
                       fill=ghana_yellow)  # Yellow
        draw.rectangle([flag_x, flag_y + 2 * stripe_height, flag_x + flag_size, flag_y + flag_size], 
                       fill=(0, 107, 60))  # Green
    
    return img

def create_all_icons():
    """Create all required icon sizes for iOS and Android"""
    
    # iOS icon sizes
    ios_sizes = [
        (20, "20x20"),      # iPhone Notification iOS 7-13
        (29, "29x29"),      # iPhone Settings iOS 7-13
        (40, "40x40"),      # iPhone Spotlight iOS 7-13
        (58, "58x58"),      # iPhone Settings iOS 7-13 @2x
        (60, "60x60"),      # iPhone App iOS 7-13
        (76, "76x76"),      # iPad App iOS 7-13
        (80, "80x80"),      # iPhone Spotlight iOS 7-13 @2x
        (87, "87x87"),      # iPhone Settings iOS 7-13 @3x
        (120, "120x120"),   # iPhone App iOS 7-13 @2x
        (152, "152x152"),   # iPad App iOS 7-13 @2x
        (167, "167x167"),   # iPad Pro App iOS 9-13 @2x
        (180, "180x180"),   # iPhone App iOS 7-13 @3x
        (1024, "1024x1024") # App Store iOS
    ]
    
    # Android icon sizes
    android_sizes = [
        (36, "36x36_ldpi"),     # ldpi
        (48, "48x48_mdpi"),     # mdpi
        (72, "72x72_hdpi"),     # hdpi
        (96, "96x96_xhdpi"),    # xhdpi
        (144, "144x144_xxhdpi"), # xxhdpi
        (192, "192x192_xxxhdpi"), # xxxhdpi
        (512, "512x512_playstore") # Play Store
    ]
    
    # Create output directories
    ios_dir = "/Users/enamegyir/Desktop/HomeLinkGH-iOS-Icons"
    android_dir = "/Users/enamegyir/Desktop/HomeLinkGH-Android-Icons"
    project_ios_dir = "/Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/assets/ios_icons"
    project_android_dir = "/Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/assets/android_icons"
    
    os.makedirs(ios_dir, exist_ok=True)
    os.makedirs(android_dir, exist_ok=True)
    os.makedirs(project_ios_dir, exist_ok=True)
    os.makedirs(project_android_dir, exist_ok=True)
    
    total_icons = len(ios_sizes) + len(android_sizes)
    current_icon = 0
    
    print("🚀 Creating HomeLinkGH App Icons...")
    print(f"📱 Total icons to create: {total_icons}")
    print()
    
    # Create iOS icons
    print("🍎 Creating iOS Icons...")
    for size, name in ios_sizes:
        current_icon += 1
        icon = create_app_icon(size)
        
        # Save to desktop
        desktop_path = os.path.join(ios_dir, f"icon_{name}.png")
        icon.save(desktop_path, "PNG")
        
        # Save to project
        project_path = os.path.join(project_ios_dir, f"icon_{name}.png")
        icon.save(project_path, "PNG")
        
        print(f"   ✅ [{current_icon:2d}/{total_icons}] {name} ({size}x{size})")
    
    # Create Android icons
    print("\n🤖 Creating Android Icons...")
    for size, name in android_sizes:
        current_icon += 1
        icon = create_app_icon(size)
        
        # Save to desktop
        desktop_path = os.path.join(android_dir, f"ic_launcher_{name}.png")
        icon.save(desktop_path, "PNG")
        
        # Save to project
        project_path = os.path.join(project_android_dir, f"ic_launcher_{name}.png")
        icon.save(project_path, "PNG")
        
        print(f"   ✅ [{current_icon:2d}/{total_icons}] {name} ({size}x{size})")
    
    print()
    print("✅ All icons created successfully!")
    print(f"📍 Desktop iOS icons: {ios_dir}")
    print(f"📍 Desktop Android icons: {android_dir}")
    print(f"📍 Project iOS icons: {project_ios_dir}")
    print(f"📍 Project Android icons: {project_android_dir}")

def main():
    """Main function"""
    try:
        create_all_icons()
        print("\n🎉 HomeLinkGH app icons are ready for submission!")
        
    except Exception as e:
        print(f"❌ Error creating app icons: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()