#!/usr/bin/env python3
"""
Resize and adapt real HomeLinkGH app screenshots for all device dimensions
Takes actual screenshots from iPhone Pro Portrait folder and creates proper sizes for all devices
"""

from PIL import Image, ImageOps
import os
import glob

# Source directory with actual screenshots
SOURCE_DIR = "assets/screenshots/iPhone_Pro_Portrait"

# Target device dimensions
DEVICE_SIZES = {
    # iPhone (keep original as reference)
    'iPhone_Pro_Portrait': (1290, 2796),
    'iPhone_Pro_Max_Portrait': (1320, 2868),
    
    # iPad - Apple Store requirements
    'iPad_Pro_Portrait': (2048, 2732),      # 12.9" iPad Pro Portrait
    'iPad_Pro_Landscape': (2732, 2048),     # 12.9" iPad Pro Landscape  
    'iPad_12_9_Portrait': (2064, 2752),     # iPad 12.9" Portrait
    'iPad_12_9_Landscape': (2752, 2064),    # iPad 12.9" Landscape
    
    # Android - Google Play requirements
    'Android_Phone_Portrait': (1080, 1920),   # Standard Android phone
    'Android_Phone_Large_Portrait': (1440, 2560), # Large Android phone
    'Android_Tablet_Portrait': (1200, 1920),  # Android tablet portrait
    'Android_Tablet_Landscape': (1920, 1200), # Android tablet landscape
}

def resize_image_smart(image, target_width, target_height):
    """
    Smart resize that maintains aspect ratio and fills the target dimensions
    """
    original_width, original_height = image.size
    target_ratio = target_width / target_height
    original_ratio = original_width / original_height
    
    if original_ratio > target_ratio:
        # Original is wider - fit by height
        new_height = target_height
        new_width = int(original_width * (target_height / original_height))
        resized = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Crop from center to fit width
        left = (new_width - target_width) // 2
        resized = resized.crop((left, 0, left + target_width, target_height))
    else:
        # Original is taller - fit by width
        new_width = target_width
        new_height = int(original_height * (target_width / original_width))
        resized = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Crop from center to fit height
        top = (new_height - target_height) // 2
        resized = resized.crop((0, top, target_width, top + target_height))
    
    return resized

def resize_for_landscape(image, target_width, target_height):
    """
    For landscape orientations, rotate the image if needed
    """
    original_width, original_height = image.size
    
    # If target is landscape but source is portrait, we might need special handling
    if target_width > target_height and original_height > original_width:
        # Target is landscape, source is portrait
        # Just resize normally - the content will be cropped appropriately
        return resize_image_smart(image, target_width, target_height)
    else:
        return resize_image_smart(image, target_width, target_height)

def process_screenshots():
    """
    Process all screenshots from the source directory
    """
    print("🚀 Processing real HomeLinkGH app screenshots...")
    
    # Get all PNG files from source directory
    source_files = glob.glob(os.path.join(SOURCE_DIR, "*.PNG")) + glob.glob(os.path.join(SOURCE_DIR, "*.png"))
    
    if not source_files:
        print("❌ No screenshots found in", SOURCE_DIR)
        return
    
    print(f"📁 Found {len(source_files)} screenshots to process")
    
    # Sort files to ensure consistent numbering
    source_files.sort()
    
    # Create base screenshots directory
    base_dir = "assets/screenshots"
    os.makedirs(base_dir, exist_ok=True)
    
    # Process each device size
    for device_name, (target_width, target_height) in DEVICE_SIZES.items():
        print(f"\n📱 Processing {device_name} ({target_width}x{target_height})")
        
        # Create device directory
        device_dir = os.path.join(base_dir, device_name)
        os.makedirs(device_dir, exist_ok=True)
        
        # Process each source screenshot
        for i, source_file in enumerate(source_files, 1):
            try:
                # Open source image
                with Image.open(source_file) as img:
                    # Convert to RGB if needed (in case of RGBA)
                    if img.mode in ('RGBA', 'LA'):
                        # Create white background
                        background = Image.new('RGB', img.size, (255, 255, 255))
                        if img.mode == 'RGBA':
                            background.paste(img, mask=img.split()[-1])  # Use alpha channel as mask
                        else:
                            background.paste(img)
                        img = background
                    elif img.mode != 'RGB':
                        img = img.convert('RGB')
                    
                    # Resize for target device
                    if 'Landscape' in device_name:
                        resized_img = resize_for_landscape(img, target_width, target_height)
                    else:
                        resized_img = resize_image_smart(img, target_width, target_height)
                    
                    # Save with proper naming
                    filename = f"{i:02d}_screenshot_{target_width}x{target_height}.png"
                    output_path = os.path.join(device_dir, filename)
                    resized_img.save(output_path, 'PNG', quality=95)
                    
                    print(f"  ✅ Saved {filename}")
                    
            except Exception as e:
                print(f"  ❌ Error processing {source_file}: {e}")
    
    print(f"\n🎉 Screenshot processing completed!")
    print(f"📁 Screenshots saved in {base_dir}")
    print(f"📱 Created screenshots for {len(DEVICE_SIZES)} device configurations")
    
    # List what was created
    print(f"\n📋 Device configurations created:")
    for device_name, (width, height) in DEVICE_SIZES.items():
        orientation = "Landscape" if width > height else "Portrait"
        print(f"  - {device_name}: {width}x{height} ({orientation})")

def rename_original_screenshots():
    """
    Rename the original screenshots to follow proper naming convention
    """
    print("\n🔄 Renaming original screenshots...")
    
    source_files = glob.glob(os.path.join(SOURCE_DIR, "IMG_*.PNG"))
    source_files.sort()
    
    for i, source_file in enumerate(source_files, 1):
        try:
            # New filename following the pattern
            new_filename = f"{i:02d}_screenshot_1290x2796.png"
            new_path = os.path.join(SOURCE_DIR, new_filename)
            
            # Only rename if the new name doesn't exist
            if not os.path.exists(new_path):
                os.rename(source_file, new_path)
                print(f"  ✅ Renamed {os.path.basename(source_file)} -> {new_filename}")
            else:
                print(f"  ⚠️  {new_filename} already exists, skipping {os.path.basename(source_file)}")
                
        except Exception as e:
            print(f"  ❌ Error renaming {source_file}: {e}")

def main():
    """
    Main function to process all screenshots
    """
    print("📸 HomeLinkGH Real Screenshot Processor")
    print("=" * 50)
    
    # Check if source directory exists
    if not os.path.exists(SOURCE_DIR):
        print(f"❌ Source directory not found: {SOURCE_DIR}")
        return
    
    # Rename original screenshots first
    rename_original_screenshots()
    
    # Process screenshots for all devices
    process_screenshots()
    
    print("\n✅ All done! Your real app screenshots are now available in all required dimensions.")

if __name__ == "__main__":
    main()