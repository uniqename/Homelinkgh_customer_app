#!/usr/bin/env python3
"""
HomeLinkGH Feature Graphic Generator
Creates a 1024x500 feature graphic for Google Play Store
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_feature_graphic():
    """Create the feature graphic for HomeLinkGH app"""
    
    # Feature graphic dimensions (Google Play Store requirement)
    width = 1024
    height = 500
    
    # Create image with gradient background
    img = Image.new('RGB', (width, height), color='white')
    draw = ImageDraw.Draw(img)
    
    # Colors matching HomeLinkGH branding
    primary_green = (46, 139, 87)      # #2E8B57
    light_green = (60, 179, 113)       # #3CB371
    orange_accent = (255, 107, 53)     # #FF6B35
    ghana_red = (206, 17, 38)          # #CE1126
    ghana_yellow = (252, 209, 22)      # #FCD116
    ghana_green = (0, 107, 60)         # #006B3C
    
    # Create gradient background
    for y in range(height):
        ratio = y / height
        r = int(primary_green[0] * (1 - ratio) + light_green[0] * ratio)
        g = int(primary_green[1] * (1 - ratio) + light_green[1] * ratio)
        b = int(primary_green[2] * (1 - ratio) + light_green[2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Try to load fonts, fall back to default if not available
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        tagline_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
        feature_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        tagline_font = ImageFont.load_default()
        feature_font = ImageFont.load_default()
    
    # Ghana flag element
    flag_width = 80
    flag_height = 50
    flag_x = width - flag_width - 20
    flag_y = 20
    
    # Draw Ghana flag
    draw.rectangle([flag_x, flag_y, flag_x + flag_width, flag_y + flag_height // 3], fill=ghana_red)
    draw.rectangle([flag_x, flag_y + flag_height // 3, flag_x + flag_width, flag_y + 2 * flag_height // 3], fill=ghana_yellow)
    draw.rectangle([flag_x, flag_y + 2 * flag_height // 3, flag_x + flag_width, flag_y + flag_height], fill=ghana_green)
    
    # Add star to Ghana flag
    star_x = flag_x + flag_width // 2
    star_y = flag_y + flag_height // 2
    draw.text((star_x - 10, star_y - 10), "★", fill='black', font=feature_font)
    
    # Main title
    title_text = "HomeLinkGH"
    title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_height = title_bbox[3] - title_bbox[1]
    title_x = 40
    title_y = 60
    
    # Add shadow effect
    draw.text((title_x + 3, title_y + 3), title_text, fill=(0, 0, 0, 100), font=title_font)
    draw.text((title_x, title_y), title_text, fill='white', font=title_font)
    
    # Subtitle with AI emphasis
    subtitle_text = "🤖 Ghana's Smartest AI-Powered Services"
    subtitle_y = title_y + title_height + 20
    draw.text((title_x, subtitle_y), subtitle_text, fill='white', font=subtitle_font)
    
    # Tagline
    tagline_text = "AI That Learns You, Services That Delight You"
    tagline_y = subtitle_y + 50
    draw.text((title_x, tagline_y), tagline_text, fill=(255, 255, 255, 200), font=tagline_font)
    
    # Feature highlights
    features = [
        "🧠 AI Personalization",
        "🎮 Gamification Rewards", 
        "🇬🇭 Ghana Card Priority",
        "🚀 Smart Recommendations"
    ]
    
    feature_start_y = tagline_y + 60
    for i, feature in enumerate(features):
        feature_y = feature_start_y + (i * 35)
        draw.text((title_x, feature_y), feature, fill='white', font=feature_font)
    
    # Add accent elements
    # Orange accent bar
    accent_height = 8
    draw.rectangle([0, height - accent_height, width, height], fill=orange_accent)
    
    # Add some geometric elements
    # Circle elements
    circle_radius = 40
    circle_x = width - 150
    circle_y = height // 2
    draw.ellipse([circle_x - circle_radius, circle_y - circle_radius, 
                  circle_x + circle_radius, circle_y + circle_radius], 
                 fill=(255, 255, 255, 50))
    
    # Smaller circle
    small_circle_radius = 25
    small_circle_x = width - 200
    small_circle_y = height // 2 + 80
    draw.ellipse([small_circle_x - small_circle_radius, small_circle_y - small_circle_radius,
                  small_circle_x + small_circle_radius, small_circle_y + small_circle_radius],
                 fill=(255, 255, 255, 30))
    
    # App icon representation (house icon)
    icon_size = 80
    icon_x = width - 160
    icon_y = height - 140
    
    # Draw simple house icon
    # House base
    draw.rectangle([icon_x, icon_y + 20, icon_x + icon_size, icon_y + icon_size], 
                   fill='white', outline=primary_green, width=3)
    
    # House roof (triangle)
    roof_points = [
        (icon_x + icon_size // 2, icon_y),
        (icon_x - 10, icon_y + 30),
        (icon_x + icon_size + 10, icon_y + 30)
    ]
    draw.polygon(roof_points, fill=orange_accent)
    
    # Door
    door_width = 20
    door_height = 30
    door_x = icon_x + (icon_size - door_width) // 2
    door_y = icon_y + icon_size - door_height
    draw.rectangle([door_x, door_y, door_x + door_width, door_y + door_height], 
                   fill=primary_green)
    
    # Windows
    window_size = 12
    window_y = icon_y + 35
    # Left window
    draw.rectangle([icon_x + 15, window_y, icon_x + 15 + window_size, window_y + window_size], 
                   fill='lightblue')
    # Right window  
    draw.rectangle([icon_x + icon_size - 15 - window_size, window_y, 
                    icon_x + icon_size - 15, window_y + window_size], 
                   fill='lightblue')
    
    return img

def main():
    """Main function to create and save the feature graphic"""
    try:
        # Create the feature graphic
        feature_graphic = create_feature_graphic()
        
        # Save the feature graphic
        output_path = "/Users/enamegyir/Desktop/HomeLinkGH-Feature-Graphic.png"
        feature_graphic.save(output_path, "PNG", quality=100)
        
        print(f"✅ Feature graphic created successfully!")
        print(f"📍 Saved to: {output_path}")
        print(f"📐 Dimensions: 1024x500 pixels")
        print(f"📊 Size: {os.path.getsize(output_path) / 1024:.1f} KB")
        
        # Also save in the project directory
        project_path = "/Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/assets/feature_graphic.png"
        os.makedirs(os.path.dirname(project_path), exist_ok=True)
        feature_graphic.save(project_path, "PNG", quality=100)
        print(f"📍 Also saved to: {project_path}")
        
    except Exception as e:
        print(f"❌ Error creating feature graphic: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()