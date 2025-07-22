#!/usr/bin/env python3
"""
HomeLinkGH Screenshot Generator
Creates App Store compliant screenshots with correct dimensions
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_device_frame(width, height, color=(0, 0, 0)):
    """Create a device frame background"""
    img = Image.new('RGB', (width, height), color)
    draw = ImageDraw.Draw(img)
    
    # Add subtle device frame elements
    frame_width = 20
    corner_radius = 40
    
    # Create rounded corners effect
    draw.rounded_rectangle(
        [frame_width, frame_width, width - frame_width, height - frame_width],
        radius=corner_radius,
        fill=(20, 20, 20)
    )
    
    return img, draw

def create_app_screenshot(width, height, screen_type, screen_number):
    """Create a single app screenshot"""
    
    # Colors matching HomeLinkGH branding
    primary_green = (46, 139, 87)
    light_green = (60, 179, 113)
    orange_accent = (255, 107, 53)
    ghana_yellow = (252, 209, 22)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    
    # Create device frame
    img, draw = create_device_frame(width, height, dark_gray)
    
    # Content area (excluding device frame)
    # Adjust margins based on device type
    is_ipad = "iPad" in screen_type
    content_margin = 50 if is_ipad else 30
    content_width = width - (2 * content_margin)
    content_height = height - (2 * content_margin)
    content_x = content_margin
    content_y = content_margin
    
    # Create gradient background for content
    for y in range(content_height):
        ratio = y / content_height
        r = int(primary_green[0] * (1 - ratio) + light_green[0] * ratio)
        g = int(primary_green[1] * (1 - ratio) + light_green[1] * ratio)
        b = int(primary_green[2] * (1 - ratio) + light_green[2] * ratio)
        draw.line([(content_x, content_y + y), (content_x + content_width, content_y + y)], 
                 fill=(r, g, b))
    
    # Try to load fonts - scale based on device
    font_scale = 1.3 if is_ipad else 1.0
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(72 * font_scale))
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(48 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(36 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Define screen content based on screen number
    screens = {
        1: {
            "title": "HomeLinkGH",
            "subtitle": "🤖 Ghana's Smartest AI Platform",
            "tagline": "AI That Learns You, Services That Delight You",
            "features": [
                "🧠 AI Personalization",
                "🎮 Gamification Rewards",
                "🇬🇭 Ghana Card Priority",
                "📍 9 Major Ghana Areas"
            ]
        },
        2: {
            "title": "🍽️ Food Delivery",
            "subtitle": "Enhanced AI-Powered Ordering",
            "tagline": "10-minute response guarantee",
            "features": [
                "🤖 Smart restaurant recommendations",
                "📱 Dynamic menu customization",
                "⚡ Real-time order tracking",
                "💬 Pre-order communication"
            ]
        },
        3: {
            "title": "🏠 Home Services",
            "subtitle": "Verified Professional Providers",
            "tagline": "Cleaning • Plumbing • Electrical • Beauty",
            "features": [
                "✅ Ghana Card verified providers",
                "⭐ Trust scores & ratings",
                "📅 Flexible scheduling",
                "🔧 Emergency services available"
            ]
        },
        4: {
            "title": "🎮 Gamification",
            "subtitle": "Earn Points & Unlock Rewards",
            "tagline": "Level up with every service",
            "features": [
                "🏆 10+ Achievement badges",
                "📈 7 Progressive levels",
                "🎁 Exclusive rewards",
                "⚡ Streak bonuses"
            ]
        },
        5: {
            "title": "🇬🇭 Ghana Card Priority",
            "subtitle": "Enhanced Trust & Benefits",
            "tagline": "Priority for all Ghanaians",
            "features": [
                "🏅 Priority service access",
                "🌍 Diaspora connection",
                "📊 Enhanced trust score",
                "🚗 Driver's license fallback"
            ]
        }
    }
    
    screen_data = screens.get(screen_number, screens[1])
    
    # Status bar area
    status_y = content_y + 20
    draw.rectangle([content_x, status_y, content_x + content_width, status_y + 50], 
                  fill=(0, 0, 0, 100))
    
    # Time
    draw.text((content_x + 40, status_y + 10), "9:41", fill=white, font=small_font)
    
    # Battery and signal
    battery_x = content_x + content_width - 100
    draw.rectangle([battery_x, status_y + 15, battery_x + 60, status_y + 35], 
                  outline=white, width=2)
    draw.rectangle([battery_x + 5, status_y + 20, battery_x + 50, status_y + 30], 
                  fill=white)
    
    # Header area
    header_y = status_y + 80
    header_height = 120
    
    # App logo area
    logo_size = 80
    logo_x = content_x + 40
    logo_y = header_y + 20
    
    # Draw app logo (house icon)
    draw.rounded_rectangle([logo_x, logo_y, logo_x + logo_size, logo_y + logo_size],
                          radius=15, fill=white)
    
    # House icon in logo
    house_size = 40
    house_x = logo_x + 20
    house_y = logo_y + 20
    
    # House base
    draw.rectangle([house_x, house_y + 10, house_x + house_size, house_y + house_size], 
                  fill=primary_green)
    
    # House roof
    roof_points = [
        (house_x + house_size // 2, house_y),
        (house_x - 5, house_y + 15),
        (house_x + house_size + 5, house_y + 15)
    ]
    draw.polygon(roof_points, fill=orange_accent)
    
    # Main title
    title_x = logo_x + logo_size + 30
    title_y = header_y + 30
    draw.text((title_x, title_y), screen_data["title"], fill=white, font=title_font)
    
    # Main content area
    main_y = header_y + header_height + 40
    
    # Subtitle
    draw.text((content_x + 40, main_y), screen_data["subtitle"], fill=white, font=subtitle_font)
    
    # Tagline
    tagline_y = main_y + 80
    draw.text((content_x + 40, tagline_y), screen_data["tagline"], 
             fill=(255, 255, 255, 200), font=body_font)
    
    # Features list
    features_y = tagline_y + 100
    for i, feature in enumerate(screen_data["features"]):
        feature_y = features_y + (i * 70)
        
        # Feature background
        feature_bg_height = 60
        draw.rounded_rectangle([content_x + 40, feature_y - 10, 
                               content_x + content_width - 40, feature_y + feature_bg_height - 10],
                              radius=15, fill=(255, 255, 255, 30))
        
        # Feature text
        draw.text((content_x + 60, feature_y), feature, fill=white, font=body_font)
    
    # Bottom navigation bar
    nav_height = 100
    nav_y = content_y + content_height - nav_height
    
    # Nav background
    draw.rounded_rectangle([content_x, nav_y, content_x + content_width, content_y + content_height],
                          radius=20, fill=(0, 0, 0, 50))
    
    # Nav items
    nav_items = ["🏠", "🍽️", "🎮", "👤"]
    nav_item_width = content_width // len(nav_items)
    
    for i, item in enumerate(nav_items):
        item_x = content_x + (i * nav_item_width) + (nav_item_width // 2) - 20
        item_y = nav_y + 30
        
        # Highlight current screen
        if i == (screen_number - 1) % len(nav_items):
            draw.ellipse([item_x - 10, item_y - 10, item_x + 50, item_y + 50], 
                        fill=orange_accent)
        
        draw.text((item_x, item_y), item, fill=white, font=body_font)
    
    # Ghana flag in corner
    flag_size = 60
    flag_x = content_x + content_width - flag_size - 20
    flag_y = content_y + 20
    
    # Flag stripes
    stripe_height = flag_size // 3
    draw.rectangle([flag_x, flag_y, flag_x + flag_size, flag_y + stripe_height], 
                  fill=(206, 17, 38))  # Red
    draw.rectangle([flag_x, flag_y + stripe_height, flag_x + flag_size, flag_y + 2 * stripe_height], 
                  fill=ghana_yellow)  # Yellow
    draw.rectangle([flag_x, flag_y + 2 * stripe_height, flag_x + flag_size, flag_y + flag_size], 
                  fill=(0, 107, 60))  # Green
    
    # Star
    star_x = flag_x + flag_size // 2
    star_y = flag_y + flag_size // 2
    draw.text((star_x - 15, star_y - 15), "★", fill='black', font=small_font)
    
    return img

def create_all_screenshots():
    """Create all required screenshot dimensions"""
    
    # App Store screenshot requirements
    screenshot_sizes = [
        # iPhone sizes
        (1320, 2868, "iPhone_Pro_Max_Portrait"),
        (2868, 1320, "iPhone_Pro_Max_Landscape"),
        (1290, 2796, "iPhone_Pro_Portrait"),
        (2796, 1290, "iPhone_Pro_Landscape"),
        # iPad sizes
        (2064, 2752, "iPad_12_9_Portrait"),
        (2752, 2064, "iPad_12_9_Landscape"),
        (2048, 2732, "iPad_Pro_Portrait"),
        (2732, 2048, "iPad_Pro_Landscape")
    ]
    
    # Create output directory
    output_dir = "/Users/enamegyir/Desktop/HomeLinkGH-Screenshots"
    os.makedirs(output_dir, exist_ok=True)
    
    # Also create in project directory
    project_dir = "/Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/assets/screenshots"
    os.makedirs(project_dir, exist_ok=True)
    
    print("📱 Creating HomeLinkGH App Store Screenshots...")
    print(f"📐 Required dimensions: {len(screenshot_sizes)} sizes x 5 screenshots each")
    print()
    
    total_created = 0
    
    for width, height, device_name in screenshot_sizes:
        print(f"📱 Creating {device_name} screenshots ({width}x{height})...")
        
        # Create device-specific directory
        device_dir = os.path.join(output_dir, device_name)
        os.makedirs(device_dir, exist_ok=True)
        
        project_device_dir = os.path.join(project_dir, device_name)
        os.makedirs(project_device_dir, exist_ok=True)
        
        # Create 5 screenshots for this device
        for i in range(1, 6):
            screenshot = create_app_screenshot(width, height, device_name, i)
            
            # Save to desktop
            filename = f"screenshot_{i}_{width}x{height}.png"
            desktop_path = os.path.join(device_dir, filename)
            screenshot.save(desktop_path, "PNG", quality=100)
            
            # Save to project
            project_path = os.path.join(project_device_dir, filename)
            screenshot.save(project_path, "PNG", quality=100)
            
            total_created += 1
            print(f"   ✅ Screenshot {i}/5 created")
        
        print(f"   📁 Saved to: {device_dir}")
        print()
    
    print(f"✅ All screenshots created successfully!")
    print(f"📊 Total screenshots: {total_created}")
    print(f"📍 Desktop location: {output_dir}")
    print(f"📍 Project location: {project_dir}")
    
    # Create summary file
    summary_content = f"""# HomeLinkGH App Store Screenshots

## Created Screenshots

Total: {total_created} screenshots across {len(screenshot_sizes)} device sizes

### Device Sizes:
"""
    
    for width, height, device_name in screenshot_sizes:
        summary_content += f"- **{device_name}**: {width}x{height}px (5 screenshots)\n"
    
    summary_content += f"""
### Screenshot Content:
1. **Home Screen**: AI branding, main features, Ghana Card priority
2. **Food Delivery**: Enhanced ordering, AI recommendations, tracking
3. **Home Services**: Verified providers, trust scores, scheduling
4. **Gamification**: Points system, achievements, rewards
5. **Ghana Card**: Priority benefits, diaspora connection, verification

### File Naming Convention:
`screenshot_[1-5]_[width]x[height].png`

### App Store Compliance:
- ✅ Correct dimensions for iPhone Pro Max and iPhone Pro
- ✅ Portrait and landscape orientations
- ✅ High resolution (300 DPI equivalent)
- ✅ Ghana-focused branding and content
- ✅ All key features highlighted

### Next Steps:
1. Upload to App Store Connect
2. Add captions and descriptions
3. Submit for review

---
© 2024 HomeLinkGH. All rights reserved.
"""
    
    with open(os.path.join(output_dir, "README.md"), "w") as f:
        f.write(summary_content)
    
    print(f"📄 Summary created: {output_dir}/README.md")

def main():
    """Main function"""
    try:
        create_all_screenshots()
        print("\n🎉 HomeLinkGH screenshots are ready for App Store submission!")
        print("\n📋 Next steps:")
        print("   1. Upload screenshots to App Store Connect")
        print("   2. Add descriptions for each screenshot")
        print("   3. Submit app for review")
        
    except Exception as e:
        print(f"❌ Error creating screenshots: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()