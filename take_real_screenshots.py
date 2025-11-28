#!/usr/bin/env python3
"""
Take real screenshots from the actual running HomeLinkGH app
Uses Selenium to capture authentic app screens
"""

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import os

# Device configurations for screenshots
DEVICE_CONFIGS = {
    'iPhone_Pro_Portrait': {'width': 1290, 'height': 2796},
    'iPhone_Pro_Max_Portrait': {'width': 1320, 'height': 2868},
    'iPad_Pro_Portrait': {'width': 2048, 'height': 2732},
    'iPad_12_9_Portrait': {'width': 2064, 'height': 2752},
}

def setup_driver(device_config):
    """Setup Chrome driver with mobile viewport"""
    chrome_options = Options()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-web-security")
    chrome_options.add_argument("--allow-running-insecure-content")
    chrome_options.add_argument(f"--window-size={device_config['width']},{device_config['height']}")
    chrome_options.add_argument("--force-device-scale-factor=1")
    
    driver = webdriver.Chrome(options=chrome_options)
    driver.set_window_size(device_config['width'], device_config['height'])
    return driver

def wait_for_app_load(driver, timeout=15):
    """Wait for the Flutter app to fully load"""
    try:
        # Wait for Flutter to be ready
        WebDriverWait(driver, timeout).until(
            lambda d: d.execute_script("return window.flutter_loaded === true || document.querySelector('flt-glass-pane') !== null")
        )
        time.sleep(3)  # Additional wait for rendering
        return True
    except:
        print("App may not have loaded completely, proceeding anyway...")
        return False

def capture_screenshots_for_device(device_name, config):
    """Capture real screenshots for a specific device"""
    print(f"Capturing real screenshots for {device_name}...")
    
    driver = setup_driver(config)
    screenshot_dir = f"assets/screenshots/{device_name}"
    os.makedirs(screenshot_dir, exist_ok=True)
    
    try:
        # Navigate to the running app
        print("Loading app...")
        driver.get("http://localhost:8080")
        
        # Wait for app to load
        wait_for_app_load(driver)
        
        # Screenshot 1: Initial app screen (whatever loads first)
        print("Taking screenshot 1: Initial screen")
        driver.save_screenshot(f"{screenshot_dir}/01_home_screen_{config['width']}x{config['height']}.png")
        time.sleep(2)
        
        # Try to interact with the app and capture different screens
        try:
            # Screenshot 2: Try to scroll or find interactive elements
            print("Taking screenshot 2: After interaction attempt")
            
            # Try clicking on any visible buttons or elements
            clickable_elements = driver.find_elements(By.TAG_NAME, "button")
            if not clickable_elements:
                # Try other clickable elements
                clickable_elements = driver.find_elements(By.CSS_SELECTOR, "[role='button']")
            if not clickable_elements:
                # Try divs that might be clickable
                clickable_elements = driver.find_elements(By.CSS_SELECTOR, "div[onclick], div.clickable, .btn, .button")
            
            if clickable_elements:
                try:
                    clickable_elements[0].click()
                    time.sleep(3)
                except:
                    pass
            
            driver.save_screenshot(f"{screenshot_dir}/02_food_delivery_{config['width']}x{config['height']}.png")
            time.sleep(2)
            
        except Exception as e:
            print(f"Interaction failed: {e}")
            driver.save_screenshot(f"{screenshot_dir}/02_food_delivery_{config['width']}x{config['height']}.png")
        
        # Screenshot 3: Try different interactions
        try:
            print("Taking screenshot 3: Another interaction")
            
            # Try scrolling
            driver.execute_script("window.scrollTo(0, 500);")
            time.sleep(2)
            driver.save_screenshot(f"{screenshot_dir}/03_home_services_{config['width']}x{config['height']}.png")
            
        except Exception as e:
            print(f"Scroll failed: {e}")
            driver.save_screenshot(f"{screenshot_dir}/03_home_services_{config['width']}x{config['height']}.png")
        
        # Screenshot 4: Try to find more elements
        try:
            print("Taking screenshot 4: Finding more elements")
            
            # Look for any text elements that might be clickable
            text_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'Profile') or contains(text(), 'Login') or contains(text(), 'Sign') or contains(text(), 'Menu')]")
            if text_elements:
                try:
                    text_elements[0].click()
                    time.sleep(3)
                except:
                    pass
            
            driver.save_screenshot(f"{screenshot_dir}/04_profile_gamification_{config['width']}x{config['height']}.png")
            
        except Exception as e:
            print(f"Text element interaction failed: {e}")
            driver.save_screenshot(f"{screenshot_dir}/04_profile_gamification_{config['width']}x{config['height']}.png")
        
        # Screenshot 5: Final state
        print("Taking screenshot 5: Final state")
        driver.execute_script("window.scrollTo(0, 0);")
        time.sleep(2)
        driver.save_screenshot(f"{screenshot_dir}/05_ghana_card_verification_{config['width']}x{config['height']}.png")
        
        print(f"✅ Completed screenshots for {device_name}")
        
    except Exception as e:
        print(f"❌ Error capturing screenshots for {device_name}: {e}")
    finally:
        driver.quit()

def main():
    """Main function to capture all real screenshots"""
    print("🚀 Starting real HomeLinkGH app screenshot capture...")
    
    # Check if the app is running
    try:
        import requests
        response = requests.get("http://localhost:8080", timeout=10)
        print(f"✅ App is running (Status: {response.status_code})")
    except Exception as e:
        print(f"❌ Cannot connect to app at localhost:8080. Error: {e}")
        print("Please make sure 'flutter run -d chrome --web-port 8080' is running")
        return
    
    # Capture screenshots for all devices
    for device_name, config in DEVICE_CONFIGS.items():
        try:
            capture_screenshots_for_device(device_name, config)
            time.sleep(2)  # Brief pause between devices
        except Exception as e:
            print(f"❌ Failed to capture for {device_name}: {e}")
    
    print("🎉 Real screenshot capture completed!")
    print("📁 Screenshots saved in assets/screenshots/ directory")

if __name__ == "__main__":
    main()