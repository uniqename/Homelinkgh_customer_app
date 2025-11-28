#!/usr/bin/env python3
"""
Script to create HomeLinkGH app icon
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_homelink_icon():
    # Create 1024x1024 image with Ghana colors
    size = 1024
    img = Image.new('RGB', (size, size), '#006B3C')  # Ghana green
    draw = ImageDraw.Draw(img)
    
    # Draw house shape
    house_size = 400
    house_x = (size - house_size) // 2
    house_y = (size - house_size) // 2 + 50
    
    # House base (white)
    draw.rectangle([house_x, house_y + 100, house_x + house_size, house_y + house_size], fill='white')
    
    # Roof (red)
    roof_points = [
        (house_x - 30, house_y + 100),
        (house_x + house_size // 2, house_y),
        (house_x + house_size + 30, house_y + 100)
    ]
    draw.polygon(roof_points, fill='#CE1126')  # Ghana red
    
    # Door (green)
    door_width = 80
    door_height = 120
    door_x = house_x + (house_size - door_width) // 2
    door_y = house_y + house_size - door_height
    draw.rectangle([door_x, door_y, door_x + door_width, door_y + door_height], fill='#006B3C')
    
    # Door handle
    draw.ellipse([door_x + door_width - 20, door_y + door_height // 2 - 5, 
                  door_x + door_width - 10, door_y + door_height // 2 + 5], fill='#FCD116')
    
    # Windows
    window_size = 60
    window_y = house_y + 150
    
    # Left window
    left_window_x = house_x + 60
    draw.rectangle([left_window_x, window_y, left_window_x + window_size, window_y + window_size], 
                  fill='#E8F4FD', outline='#006B3C', width=4)
    # Window cross
    draw.line([left_window_x + window_size//2, window_y, left_window_x + window_size//2, window_y + window_size], 
              fill='#006B3C', width=3)
    draw.line([left_window_x, window_y + window_size//2, left_window_x + window_size, window_y + window_size//2], 
              fill='#006B3C', width=3)
    
    # Right window
    right_window_x = house_x + house_size - 60 - window_size
    draw.rectangle([right_window_x, window_y, right_window_x + window_size, window_y + window_size], 
                  fill='#E8F4FD', outline='#006B3C', width=4)
    # Window cross
    draw.line([right_window_x + window_size//2, window_y, right_window_x + window_size//2, window_y + window_size], 
              fill='#006B3C', width=3)
    draw.line([right_window_x, window_y + window_size//2, right_window_x + window_size, window_y + window_size//2], 
              fill='#006B3C', width=3)
    
    # Ghana flag in corner
    flag_width = 100
    flag_height = 60
    flag_x = 50
    flag_y = size - flag_height - 50
    
    # Flag stripes
    stripe_height = flag_height // 3
    draw.rectangle([flag_x, flag_y, flag_x + flag_width, flag_y + stripe_height], fill='#CE1126')  # Red
    draw.rectangle([flag_x, flag_y + stripe_height, flag_x + flag_width, flag_y + 2*stripe_height], fill='#FCD116')  # Gold
    draw.rectangle([flag_x, flag_y + 2*stripe_height, flag_x + flag_width, flag_y + flag_height], fill='#006B3C')  # Green
    
    # Star on gold stripe
    star_center_x = flag_x + flag_width // 2
    star_center_y = flag_y + stripe_height + stripe_height // 2
    star_size = 15
    draw.ellipse([star_center_x - star_size//2, star_center_y - star_size//2, 
                  star_center_x + star_size//2, star_center_y + star_size//2], fill='black')
    
    # Text "HomeLinkGH" at the top
    try:
        # Try to use a bold font
        font_size = 80
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    text = "HomeLinkGH"
    # Get text dimensions
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Position text at top center
    text_x = (size - text_width) // 2
    text_y = 80
    
    # Draw text with outline for better visibility
    outline_width = 3
    for adj_x in range(-outline_width, outline_width + 1):
        for adj_y in range(-outline_width, outline_width + 1):
            if adj_x != 0 or adj_y != 0:
                draw.text((text_x + adj_x, text_y + adj_y), text, font=font, fill='white')
    
    # Draw main text
    draw.text((text_x, text_y), text, font=font, fill='#FCD116')
    
    return img

def resize_for_all_ios_sizes(base_img):
    """Create all required iOS icon sizes"""
    ios_sizes = [
        (20, "Icon-App-20x20@1x.png"),
        (40, "Icon-App-20x20@2x.png"),
        (60, "Icon-App-20x20@3x.png"),
        (29, "Icon-App-29x29@1x.png"),
        (58, "Icon-App-29x29@2x.png"),
        (87, "Icon-App-29x29@3x.png"),
        (40, "Icon-App-40x40@1x.png"),
        (80, "Icon-App-40x40@2x.png"),
        (120, "Icon-App-40x40@3x.png"),
        (120, "Icon-App-60x60@2x.png"),
        (180, "Icon-App-60x60@3x.png"),
        (76, "Icon-App-76x76@1x.png"),
        (152, "Icon-App-76x76@2x.png"),
        (167, "Icon-App-83.5x83.5@2x.png"),
        (1024, "Icon-App-1024x1024@1x.png"),
    ]
    
    ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
    
    for size, filename in ios_sizes:
        resized = base_img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(ios_dir, filename))
        print(f"Created {filename} ({size}x{size})")

def main():
    print("Creating HomeLinkGH app icon...")
    
    # Create base 1024x1024 icon
    icon = create_homelink_icon()
    
    # Save to assets folder
    icon.save("assets/ios_icons/icon_1024x1024.png")
    print("Saved base icon to assets/ios_icons/icon_1024x1024.png")
    
    # Create all iOS sizes
    resize_for_all_ios_sizes(icon)
    
    print("HomeLinkGH app icon creation complete!")

if __name__ == "__main__":
    main()