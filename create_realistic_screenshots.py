#!/usr/bin/env python3
"""
HomeLinkGH Realistic App Screenshots Creator
Creates realistic app screenshots that look like actual app screens
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_realistic_home_screen(width, height, device_type):
    """Create realistic home screen screenshot"""
    img = Image.new('RGB', (width, height), (248, 249, 250))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_green = (46, 139, 87)
    orange_accent = (255, 107, 53)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    ghana_red = (206, 17, 38)
    ghana_yellow = (252, 209, 22)
    ghana_green = (0, 107, 60)
    
    # Font scaling
    is_ipad = "iPad" in device_type
    font_scale = 1.4 if is_ipad else 1.0
    
    try:
        header_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(24 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(18 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(14 * font_scale))
    except:
        header_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Status bar
    draw.rectangle([0, 0, width, 60], fill=primary_green)
    draw.text((30, 20), "9:41", fill=white, font=title_font)
    draw.text((width-150, 20), "🔋 100%", fill=white, font=title_font)
    
    # Header with Ghana flag
    header_height = 140
    draw.rectangle([0, 60, width, 60 + header_height], fill=primary_green)
    
    # Logo
    logo_size = 50
    draw.ellipse([30, 80, 30 + logo_size, 80 + logo_size], fill=white)
    draw.text((45, 95), "🏠", fill=primary_green, font=header_font)
    
    # App name
    draw.text((100, 90), "HomeLinkGH", fill=white, font=header_font)
    
    # Ghana flag
    flag_size = 40
    flag_x = width - 80
    flag_y = 90
    draw.rectangle([flag_x, flag_y, flag_x + flag_size, flag_y + 13], fill=ghana_red)
    draw.rectangle([flag_x, flag_y + 13, flag_x + flag_size, flag_y + 26], fill=ghana_yellow)
    draw.rectangle([flag_x, flag_y + 26, flag_x + flag_size, flag_y + 40], fill=ghana_green)
    draw.text((flag_x + 18, flag_y + 15), "★", fill='black', font=small_font)
    
    # Location
    draw.text((30, 140), "📍 Greater Accra, Ghana", fill=white, font=body_font)
    
    # AI Banner
    y_pos = 220
    ai_banner_height = 100
    draw.rounded_rectangle([20, y_pos, width-20, y_pos + ai_banner_height], 
                          radius=15, fill=orange_accent)
    draw.text((40, y_pos + 20), "🤖 AI Personalization Active", fill=white, font=title_font)
    draw.text((40, y_pos + 50), "Learning your preferences...", fill=white, font=body_font)
    
    # Ghana Card Priority Section
    y_pos += 120
    card_height = 80
    draw.rounded_rectangle([20, y_pos, width-20, y_pos + card_height], 
                          radius=15, fill=ghana_green)
    draw.text((40, y_pos + 20), "🇬🇭 Ghana Card Priority", fill=white, font=title_font)
    draw.text((40, y_pos + 50), "Enhanced trust & benefits", fill=white, font=body_font)
    
    # Service Categories
    y_pos += 100
    categories = [
        ("🍽️", "Food Delivery", "500+ restaurants"),
        ("🏠", "Home Services", "Verified providers"),
        ("🛒", "Grocery", "Fresh & local"),
        ("💅", "Beauty", "Professional artists")
    ]
    
    cols = 2
    card_width = (width - 60) // cols
    card_height = 120
    
    for i, (icon, title, subtitle) in enumerate(categories):
        row = i // cols
        col = i % cols
        x = 20 + col * (card_width + 20)
        y = y_pos + row * (card_height + 20)
        
        draw.rounded_rectangle([x, y, x + card_width, y + card_height], 
                              radius=10, fill=white)
        draw.text((x + 20, y + 15), icon, fill=primary_green, font=header_font)
        draw.text((x + 20, y + 50), title, fill=dark_gray, font=title_font)
        draw.text((x + 20, y + 80), subtitle, fill=primary_green, font=small_font)
    
    # Bottom navigation
    nav_height = 80
    nav_y = height - nav_height
    draw.rectangle([0, nav_y, width, height], fill=white)
    
    nav_items = [("🏠", "Home"), ("🍽️", "Food"), ("🎮", "Rewards"), ("👤", "Profile")]
    nav_width = width // len(nav_items)
    
    for i, (icon, label) in enumerate(nav_items):
        x = i * nav_width
        center_x = x + nav_width // 2
        
        # Highlight home
        if i == 0:
            draw.rectangle([x, nav_y, x + nav_width, height], fill=primary_green)
            text_color = white
        else:
            text_color = dark_gray
        
        draw.text((center_x - 15, nav_y + 10), icon, fill=text_color, font=title_font)
        draw.text((center_x - 20, nav_y + 45), label, fill=text_color, font=small_font)
    
    return img

def create_realistic_food_screen(width, height, device_type):
    """Create realistic food delivery screen"""
    img = Image.new('RGB', (width, height), (248, 249, 250))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_green = (46, 139, 87)
    orange_accent = (255, 107, 53)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    
    # Font scaling
    is_ipad = "iPad" in device_type
    font_scale = 1.4 if is_ipad else 1.0
    
    try:
        header_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(24 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(18 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(14 * font_scale))
    except:
        header_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Status bar
    draw.rectangle([0, 0, width, 60], fill=primary_green)
    draw.text((30, 20), "9:41", fill=white, font=title_font)
    draw.text((width-150, 20), "🔋 100%", fill=white, font=title_font)
    
    # Header
    draw.rectangle([0, 60, width, 140], fill=primary_green)
    draw.text((30, 85), "🍽️ Food Delivery", fill=white, font=header_font)
    draw.text((30, 115), "📍 Accra, Ghana", fill=white, font=body_font)
    
    # AI Recommendations Banner
    y_pos = 160
    draw.rounded_rectangle([20, y_pos, width-20, y_pos + 60], 
                          radius=10, fill=orange_accent)
    draw.text((40, y_pos + 20), "🤖 AI Recommendations for You", fill=white, font=title_font)
    
    # Restaurant listings
    restaurants = [
        ("🍗 KFC Ghana", "Fast Food • 15 min", "⭐ 4.8", "✅ Ghana Card Verified"),
        ("🍕 Pizza Hut", "Italian • 20 min", "⭐ 4.6", "✅ Ghana Card Verified"),
        ("🌮 Buka Restaurant", "Local • 12 min", "⭐ 4.9", "✅ Ghana Card Verified"),
        ("🍛 Chop Bar Central", "Ghanaian • 18 min", "⭐ 4.7", "✅ Ghana Card Verified"),
    ]
    
    y_pos = 240
    for i, (name, category, rating, verification) in enumerate(restaurants):
        card_height = 120
        
        # Restaurant card
        draw.rounded_rectangle([20, y_pos, width-20, y_pos + card_height], 
                              radius=10, fill=white)
        
        # Restaurant image placeholder
        img_size = 80
        draw.rounded_rectangle([40, y_pos + 20, 40 + img_size, y_pos + 20 + img_size], 
                              radius=8, fill=primary_green)
        draw.text((60, y_pos + 50), "🍽️", fill=white, font=header_font)
        
        # Restaurant info
        info_x = 140
        draw.text((info_x, y_pos + 15), name, fill=dark_gray, font=title_font)
        draw.text((info_x, y_pos + 40), category, fill=primary_green, font=body_font)
        draw.text((info_x, y_pos + 65), rating, fill=orange_accent, font=body_font)
        draw.text((info_x, y_pos + 90), verification, fill=primary_green, font=small_font)
        
        y_pos += 140
    
    # Bottom navigation
    nav_height = 80
    nav_y = height - nav_height
    draw.rectangle([0, nav_y, width, height], fill=white)
    
    nav_items = [("🏠", "Home"), ("🍽️", "Food"), ("🎮", "Rewards"), ("👤", "Profile")]
    nav_width = width // len(nav_items)
    
    for i, (icon, label) in enumerate(nav_items):
        x = i * nav_width
        center_x = x + nav_width // 2
        
        # Highlight food
        if i == 1:
            draw.rectangle([x, nav_y, x + nav_width, height], fill=primary_green)
            text_color = white
        else:
            text_color = dark_gray
        
        draw.text((center_x - 15, nav_y + 10), icon, fill=text_color, font=title_font)
        draw.text((center_x - 20, nav_y + 45), label, fill=text_color, font=small_font)
    
    return img

def create_realistic_services_screen(width, height, device_type):
    """Create realistic home services screen"""
    img = Image.new('RGB', (width, height), (248, 249, 250))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_green = (46, 139, 87)
    orange_accent = (255, 107, 53)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    
    # Font scaling
    is_ipad = "iPad" in device_type
    font_scale = 1.4 if is_ipad else 1.0
    
    try:
        header_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(24 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(18 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(14 * font_scale))
    except:
        header_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Status bar
    draw.rectangle([0, 0, width, 60], fill=primary_green)
    draw.text((30, 20), "9:41", fill=white, font=title_font)
    draw.text((width-150, 20), "🔋 100%", fill=white, font=title_font)
    
    # Header
    draw.rectangle([0, 60, width, 140], fill=primary_green)
    draw.text((30, 85), "🏠 Home Services", fill=white, font=header_font)
    draw.text((30, 115), "📍 Verified Providers", fill=white, font=body_font)
    
    # Service categories
    categories = [
        ("🧹", "Cleaning", "Available now"),
        ("🔧", "Plumbing", "Emergency 24/7"),
        ("⚡", "Electrical", "Licensed pros"),
        ("💅", "Beauty", "In-home service")
    ]
    
    y_pos = 160
    cols = 2
    card_width = (width - 60) // cols
    card_height = 100
    
    for i, (icon, title, subtitle) in enumerate(categories):
        row = i // cols
        col = i % cols
        x = 20 + col * (card_width + 20)
        y = y_pos + row * (card_height + 20)
        
        draw.rounded_rectangle([x, y, x + card_width, y + card_height], 
                              radius=10, fill=white)
        draw.text((x + 20, y + 15), icon, fill=primary_green, font=header_font)
        draw.text((x + 20, y + 45), title, fill=dark_gray, font=title_font)
        draw.text((x + 20, y + 70), subtitle, fill=primary_green, font=small_font)
    
    # Provider listings
    providers = [
        ("Kwame Cleaning Services", "⭐ 4.9 • 50+ reviews", "🇬🇭 Ghana Card Verified"),
        ("Akosua Plumbing", "⭐ 4.8 • 120+ reviews", "🇬🇭 Ghana Card Verified"),
        ("Elite Beauty Services", "⭐ 4.7 • 89+ reviews", "🇬🇭 Ghana Card Verified")
    ]
    
    y_pos = 400
    for i, (name, rating, verification) in enumerate(providers):
        card_height = 100
        
        # Provider card
        draw.rounded_rectangle([20, y_pos, width-20, y_pos + card_height], 
                              radius=10, fill=white)
        
        # Provider avatar
        avatar_size = 60
        draw.ellipse([40, y_pos + 20, 40 + avatar_size, y_pos + 20 + avatar_size], 
                    fill=primary_green)
        draw.text((55, y_pos + 35), "👤", fill=white, font=title_font)
        
        # Provider info
        info_x = 120
        draw.text((info_x, y_pos + 15), name, fill=dark_gray, font=title_font)
        draw.text((info_x, y_pos + 40), rating, fill=orange_accent, font=body_font)
        draw.text((info_x, y_pos + 65), verification, fill=primary_green, font=small_font)
        
        y_pos += 120
    
    # Bottom navigation - same pattern as other screens
    nav_height = 80
    nav_y = height - nav_height
    draw.rectangle([0, nav_y, width, height], fill=white)
    
    nav_items = [("🏠", "Home"), ("🍽️", "Food"), ("🎮", "Rewards"), ("👤", "Profile")]
    nav_width = width // len(nav_items)
    
    for i, (icon, label) in enumerate(nav_items):
        x = i * nav_width
        center_x = x + nav_width // 2
        draw.text((center_x - 15, nav_y + 10), icon, fill=dark_gray, font=title_font)
        draw.text((center_x - 20, nav_y + 45), label, fill=dark_gray, font=small_font)
    
    return img

def create_realistic_profile_screen(width, height, device_type):
    """Create realistic profile/gamification screen"""
    img = Image.new('RGB', (width, height), (248, 249, 250))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_green = (46, 139, 87)
    orange_accent = (255, 107, 53)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    ghana_green = (0, 107, 60)
    
    # Font scaling
    is_ipad = "iPad" in device_type
    font_scale = 1.4 if is_ipad else 1.0
    
    try:
        header_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(24 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(18 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(14 * font_scale))
    except:
        header_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Status bar
    draw.rectangle([0, 0, width, 60], fill=primary_green)
    draw.text((30, 20), "9:41", fill=white, font=title_font)
    draw.text((width-150, 20), "🔋 100%", fill=white, font=title_font)
    
    # Header
    draw.rectangle([0, 60, width, 180], fill=primary_green)
    
    # Profile avatar
    avatar_size = 80
    draw.ellipse([30, 80, 30 + avatar_size, 80 + avatar_size], fill=white)
    draw.text((55, 105), "👤", fill=primary_green, font=header_font)
    
    # Profile info
    draw.text((130, 85), "Kofi Mensah", fill=white, font=header_font)
    draw.text((130, 115), "🇬🇭 Ghana Card Verified", fill=white, font=body_font)
    draw.text((130, 140), "Level 5 • Explorer", fill=white, font=body_font)
    
    # Gamification stats
    y_pos = 200
    stats_height = 120
    draw.rounded_rectangle([20, y_pos, width-20, y_pos + stats_height], 
                          radius=15, fill=white)
    
    # Points display
    draw.text((40, y_pos + 20), "🎮 Your Progress", fill=dark_gray, font=title_font)
    draw.text((40, y_pos + 50), "2,450 Points", fill=primary_green, font=header_font)
    
    # Progress bar
    bar_width = width - 80
    bar_height = 20
    bar_y = y_pos + 85
    draw.rounded_rectangle([40, bar_y, 40 + bar_width, bar_y + bar_height], 
                          radius=10, fill=(200, 200, 200))
    progress_width = int(bar_width * 0.7)  # 70% progress
    draw.rounded_rectangle([40, bar_y, 40 + progress_width, bar_y + bar_height], 
                          radius=10, fill=primary_green)
    
    # Achievements
    y_pos += 140
    achievements = [
        ("🏆", "First Order", "Completed"),
        ("🎯", "5 Star Rating", "Achieved"),
        ("🔥", "Weekly Streak", "7 days"),
        ("💎", "Ghana Card Pro", "Verified")
    ]
    
    cols = 2
    card_width = (width - 60) // cols
    card_height = 100
    
    for i, (icon, title, status) in enumerate(achievements):
        row = i // cols
        col = i % cols
        x = 20 + col * (card_width + 20)
        y = y_pos + row * (card_height + 20)
        
        draw.rounded_rectangle([x, y, x + card_width, y + card_height], 
                              radius=10, fill=white)
        draw.text((x + 20, y + 15), icon, fill=orange_accent, font=header_font)
        draw.text((x + 20, y + 45), title, fill=dark_gray, font=title_font)
        draw.text((x + 20, y + 70), status, fill=primary_green, font=small_font)
    
    # Level progression
    y_pos += 240
    draw.rounded_rectangle([20, y_pos, width-20, y_pos + 80], 
                          radius=10, fill=ghana_green)
    draw.text((40, y_pos + 20), "🚀 Next Level: Premium User", fill=white, font=title_font)
    draw.text((40, y_pos + 50), "550 more points needed", fill=white, font=body_font)
    
    # Bottom navigation
    nav_height = 80
    nav_y = height - nav_height
    draw.rectangle([0, nav_y, width, height], fill=white)
    
    nav_items = [("🏠", "Home"), ("🍽️", "Food"), ("🎮", "Rewards"), ("👤", "Profile")]
    nav_width = width // len(nav_items)
    
    for i, (icon, label) in enumerate(nav_items):
        x = i * nav_width
        center_x = x + nav_width // 2
        
        # Highlight profile
        if i == 3:
            draw.rectangle([x, nav_y, x + nav_width, height], fill=primary_green)
            text_color = white
        else:
            text_color = dark_gray
        
        draw.text((center_x - 15, nav_y + 10), icon, fill=text_color, font=title_font)
        draw.text((center_x - 20, nav_y + 45), label, fill=text_color, font=small_font)
    
    return img

def create_realistic_verification_screen(width, height, device_type):
    """Create realistic Ghana Card verification screen"""
    img = Image.new('RGB', (width, height), (248, 249, 250))
    draw = ImageDraw.Draw(img)
    
    # Colors
    primary_green = (46, 139, 87)
    white = (255, 255, 255)
    dark_gray = (33, 33, 33)
    ghana_red = (206, 17, 38)
    ghana_yellow = (252, 209, 22)
    ghana_green = (0, 107, 60)
    
    # Font scaling
    is_ipad = "iPad" in device_type
    font_scale = 1.4 if is_ipad else 1.0
    
    try:
        header_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(28 * font_scale))
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(24 * font_scale))
        body_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(18 * font_scale))
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(14 * font_scale))
    except:
        header_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        body_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Status bar
    draw.rectangle([0, 0, width, 60], fill=primary_green)
    draw.text((30, 20), "9:41", fill=white, font=title_font)
    draw.text((width-150, 20), "🔋 100%", fill=white, font=title_font)
    
    # Header with Ghana flag gradient
    header_height = 140
    # Create Ghana flag gradient background
    stripe_height = header_height // 3
    draw.rectangle([0, 60, width, 60 + stripe_height], fill=ghana_red)
    draw.rectangle([0, 60 + stripe_height, width, 60 + 2*stripe_height], fill=ghana_yellow)
    draw.rectangle([0, 60 + 2*stripe_height, width, 60 + header_height], fill=ghana_green)
    
    # Header text
    draw.text((30, 85), "🇬🇭 Ghana Card Verification", fill=white, font=header_font)
    draw.text((30, 115), "Priority Access System", fill=white, font=body_font)
    
    # Ghana Card mockup
    y_pos = 220
    card_width = width - 40
    card_height = 180
    
    # Ghana Card background
    draw.rounded_rectangle([20, y_pos, 20 + card_width, y_pos + card_height], 
                          radius=15, fill=white)
    
    # Ghana Card header
    draw.rectangle([20, y_pos, 20 + card_width, y_pos + 40], fill=ghana_green)
    draw.text((30, y_pos + 10), "🇬🇭 GHANA CARD", fill=white, font=title_font)
    
    # Card details
    draw.text((40, y_pos + 60), "Name: KOFI MENSAH", fill=dark_gray, font=body_font)
    draw.text((40, y_pos + 85), "ID: GHA-123456789-0", fill=dark_gray, font=body_font)
    draw.text((40, y_pos + 110), "Date of Birth: 15/03/1990", fill=dark_gray, font=body_font)
    draw.text((40, y_pos + 135), "Status: ✅ VERIFIED", fill=primary_green, font=body_font)
    
    # Benefits section
    y_pos += 200
    benefits = [
        "🏆 Priority service access",
        "🌍 Diaspora connection benefits",
        "📊 Enhanced trust score",
        "🚀 Faster booking process"
    ]
    
    draw.text((30, y_pos), "Your Benefits:", fill=dark_gray, font=title_font)
    y_pos += 40
    
    for benefit in benefits:
        draw.rounded_rectangle([20, y_pos, width-20, y_pos + 50], 
                              radius=10, fill=white)
        draw.text((40, y_pos + 15), benefit, fill=primary_green, font=body_font)
        y_pos += 60
    
    # Action button
    button_y = y_pos + 20
    draw.rounded_rectangle([20, button_y, width-20, button_y + 60], 
                          radius=30, fill=primary_green)
    draw.text((width//2 - 60, button_y + 20), "Update Verification", fill=white, font=title_font)
    
    # Bottom navigation
    nav_height = 80
    nav_y = height - nav_height
    draw.rectangle([0, nav_y, width, height], fill=white)
    
    nav_items = [("🏠", "Home"), ("🍽️", "Food"), ("🎮", "Rewards"), ("👤", "Profile")]
    nav_width = width // len(nav_items)
    
    for i, (icon, label) in enumerate(nav_items):
        x = i * nav_width
        center_x = x + nav_width // 2
        draw.text((center_x - 15, nav_y + 10), icon, fill=dark_gray, font=title_font)
        draw.text((center_x - 20, nav_y + 45), label, fill=dark_gray, font=small_font)
    
    return img

def create_all_realistic_screenshots():
    """Create all realistic screenshots for App Store submission"""
    
    # Screenshot dimensions
    screenshot_sizes = [
        # iPhone sizes
        (1320, 2868, "iPhone_Pro_Max_Portrait"),
        (1290, 2796, "iPhone_Pro_Portrait"),
        # iPad sizes  
        (2064, 2752, "iPad_12_9_Portrait"),
        (2048, 2732, "iPad_Pro_Portrait")
    ]
    
    # Screenshot creators
    screen_creators = [
        ("01_home_screen", create_realistic_home_screen),
        ("02_food_delivery", create_realistic_food_screen),
        ("03_home_services", create_realistic_services_screen),
        ("04_profile_gamification", create_realistic_profile_screen),
        ("05_ghana_card_verification", create_realistic_verification_screen)
    ]
    
    # Create output directory
    output_dir = "/Users/enamegyir/Desktop/HomeLinkGH-Realistic-Screenshots"
    os.makedirs(output_dir, exist_ok=True)
    
    print("📱 Creating Realistic HomeLinkGH App Screenshots...")
    print(f"📐 Device sizes: {len(screenshot_sizes)}")
    print(f"📄 Screens per device: {len(screen_creators)}")
    print(f"📊 Total screenshots: {len(screenshot_sizes) * len(screen_creators)}")
    print()
    
    total_created = 0
    
    for width, height, device_name in screenshot_sizes:
        print(f"📱 Creating {device_name} screenshots ({width}x{height})...")
        
        # Create device-specific directory
        device_dir = os.path.join(output_dir, device_name)
        os.makedirs(device_dir, exist_ok=True)
        
        for screen_name, screen_creator in screen_creators:
            screenshot = screen_creator(width, height, device_name)
            
            # Save screenshot
            filename = f"{screen_name}_{width}x{height}.png"
            filepath = os.path.join(device_dir, filename)
            screenshot.save(filepath, "PNG", quality=100)
            
            total_created += 1
            print(f"   ✅ {screen_name} created")
        
        print(f"   📁 Saved to: {device_dir}")
        print()
    
    print(f"✅ All realistic screenshots created successfully!")
    print(f"📊 Total screenshots: {total_created}")
    print(f"📍 Location: {output_dir}")
    
    # Create summary
    summary_content = f"""# HomeLinkGH Realistic App Screenshots

## Screenshots Created: {total_created}

### Device Sizes:
"""
    
    for width, height, device_name in screenshot_sizes:
        summary_content += f"- **{device_name}**: {width}x{height}px ({len(screen_creators)} screenshots)\n"
    
    summary_content += f"""
### Screenshot Content:
1. **Home Screen**: AI features, Ghana Card priority, service categories
2. **Food Delivery**: Restaurant listings, AI recommendations, Ghana Card verified
3. **Home Services**: Provider profiles, trust scores, verification badges
4. **Profile & Gamification**: Points, achievements, level progression
5. **Ghana Card Verification**: Priority system, benefits, verification status

### App Store Ready:
- ✅ Correct dimensions for iPhone and iPad
- ✅ Realistic app UI and content
- ✅ Ghana-focused branding and features
- ✅ Professional quality screenshots
- ✅ All key features highlighted

### Upload Instructions:
1. Upload to App Store Connect
2. Add screenshot descriptions
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
        create_all_realistic_screenshots()
        print("\n🎉 HomeLinkGH realistic screenshots are ready for App Store submission!")
        print("\n📋 Next steps:")
        print("   1. Upload screenshots to App Store Connect")
        print("   2. Add descriptions for each screenshot")
        print("   3. Submit app for review")
        
    except Exception as e:
        print(f"❌ Error creating screenshots: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()