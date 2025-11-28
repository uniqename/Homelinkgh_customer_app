#!/usr/bin/env python3
"""
Manual screenshot capture tool using simple browser automation
Creates realistic app screenshots for store submission
"""

import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Device configurations
DEVICES = {
    'iPhone_Pro_Portrait': {'width': 1290, 'height': 2796},
    'iPhone_Pro_Max_Portrait': {'width': 1320, 'height': 2868},
    'iPad_Pro_Portrait': {'width': 2048, 'height': 2732},
    'iPad_12_9_Portrait': {'width': 2064, 'height': 2752},
}

def setup_driver(width, height):
    """Setup Chrome driver with specific dimensions"""
    options = Options()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument(f"--window-size={width},{height}")
    options.add_argument("--force-device-scale-factor=2")
    
    driver = webdriver.Chrome(options=options)
    driver.set_window_size(width, height)
    return driver

def capture_for_device(device_name, config):
    """Capture screenshots for a specific device"""
    print(f"Capturing for {device_name}...")
    
    driver = setup_driver(config['width'], config['height'])
    screenshot_dir = f"assets/screenshots/{device_name}"
    os.makedirs(screenshot_dir, exist_ok=True)
    
    try:
        # Load the app
        driver.get("http://localhost:8000")
        time.sleep(5)
        
        # Screenshot 1: Home screen
        driver.save_screenshot(f"{screenshot_dir}/01_home_screen_{config['width']}x{config['height']}.png")
        print(f"✓ Saved home screen for {device_name}")
        
        # Try to interact with the app
        time.sleep(2)
        
        # Screenshot 2: Scroll or click to show more content
        driver.execute_script("window.scrollTo(0, 500);")
        time.sleep(2)
        driver.save_screenshot(f"{screenshot_dir}/02_services_view_{config['width']}x{config['height']}.png")
        print(f"✓ Saved services view for {device_name}")
        
        # Screenshot 3: Try to interact with food delivery section
        try:
            # Look for any clickable elements
            clickable_elements = driver.find_elements(By.XPATH, "//div[@role='button'] | //button | //*[contains(@class, 'button')]")
            if clickable_elements and len(clickable_elements) > 0:
                clickable_elements[0].click()
                time.sleep(3)
                driver.save_screenshot(f"{screenshot_dir}/03_interaction_screen_{config['width']}x{config['height']}.png")
                print(f"✓ Saved interaction screen for {device_name}")
            else:
                # Just take another screenshot with different scroll position
                driver.execute_script("window.scrollTo(0, 1000);")
                time.sleep(2)
                driver.save_screenshot(f"{screenshot_dir}/03_scrolled_view_{config['width']}x{config['height']}.png")
                print(f"✓ Saved scrolled view for {device_name}")
        except Exception as e:
            driver.save_screenshot(f"{screenshot_dir}/03_fallback_screen_{config['width']}x{config['height']}.png")
            print(f"✓ Saved fallback screen for {device_name}")
        
        # Screenshot 4: Another view
        driver.execute_script("window.scrollTo(0, 0);")
        time.sleep(2)
        driver.save_screenshot(f"{screenshot_dir}/04_top_view_{config['width']}x{config['height']}.png")
        print(f"✓ Saved top view for {device_name}")
        
        # Screenshot 5: Final screenshot
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2) 
        driver.save_screenshot(f"{screenshot_dir}/05_bottom_view_{config['width']}x{config['height']}.png")
        print(f"✓ Saved bottom view for {device_name}")
        
    except Exception as e:
        print(f"Error capturing for {device_name}: {e}")
    finally:
        driver.quit()

def main():
    """Main function to capture all screenshots"""
    print("Starting real screenshot capture...")
    
    # Check if server is running
    try:
        import requests
        response = requests.get("http://localhost:8000", timeout=5)
        if response.status_code != 200:
            print("Server not responding. Please start the server first.")
            return
    except:
        print("Cannot connect to localhost:8000. Please start the server first.")
        return
    
    # Capture for all devices
    for device_name, config in DEVICES.items():
        capture_for_device(device_name, config)
        time.sleep(1)  # Small delay between devices
    
    print("Screenshot capture completed!")
    print("Screenshots saved in assets/screenshots/ directory")

if __name__ == "__main__":
    main()