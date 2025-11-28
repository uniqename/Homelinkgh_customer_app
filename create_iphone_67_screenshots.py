#!/usr/bin/env python3
"""
Script to create 6.7-inch iPhone screenshots from real iPad screenshots
"""

from PIL import Image
import os
import glob

def resize_for_iphone_67():
    """
    Convert iPad screenshots to 6.7-inch iPhone (1320x2868) format
    """
    
    # 6.7-inch iPhone Pro Max dimensions
    target_width = 1320
    target_height = 2868
    
    # Source directory with real screenshots
    source_dir = "assets/screenshots/iPad_12_9_Portrait"
    
    # Target directory
    target_dir = "assets/screenshots/iPhone_67_Portrait"
    
    # Create target directory if it doesn't exist
    os.makedirs(target_dir, exist_ok=True)
    
    # Get all IMG_* files (real screenshots from user)
    img_files = glob.glob(os.path.join(source_dir, "IMG_*.PNG"))
    img_files.extend(glob.glob(os.path.join(source_dir, "IMG_*.png")))
    
    # Sort files to maintain order
    img_files.sort()
    
    print(f"Found {len(img_files)} real screenshots to process")
    
    for i, img_path in enumerate(img_files[:5], 1):  # Take first 5 screenshots
        try:
            print(f"Processing: {os.path.basename(img_path)}")
            
            # Open image
            img = Image.open(img_path)
            
            # Get current dimensions
            current_width, current_height = img.size
            print(f"  Original size: {current_width}x{current_height}")
            
            # Calculate scaling to fit within target dimensions while maintaining aspect ratio
            scale_w = target_width / current_width
            scale_h = target_height / current_height
            scale = min(scale_w, scale_h)
            
            # Calculate new dimensions
            new_width = int(current_width * scale)
            new_height = int(current_height * scale)
            
            # Resize image
            resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
            
            # Create a new image with target dimensions and white background
            final_img = Image.new('RGB', (target_width, target_height), 'white')
            
            # Calculate position to center the resized image
            x_offset = (target_width - new_width) // 2
            y_offset = (target_height - new_height) // 2
            
            # Paste resized image onto white background
            final_img.paste(resized_img, (x_offset, y_offset))
            
            # Save with proper filename
            output_filename = f"0{i}_screenshot_{target_width}x{target_height}.png"
            output_path = os.path.join(target_dir, output_filename)
            
            final_img.save(output_path, 'PNG')
            print(f"  Saved: {output_filename} ({target_width}x{target_height})")
            
        except Exception as e:
            print(f"  Error processing {img_path}: {e}")
    
    print(f"\n6.7-inch iPhone screenshots created in: {target_dir}")

def main():
    print("Creating 6.7-inch iPhone screenshots from real app screenshots...")
    resize_for_iphone_67()
    print("Screenshot creation complete!")

if __name__ == "__main__":
    main()