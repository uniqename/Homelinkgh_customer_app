#!/usr/bin/env python3
"""
Capture real screenshots from the running HomeLinkGH app
Uses selenium to automate screenshot capture from different app screens
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import time
import os

# Screenshot configurations for different device sizes
DEVICE_CONFIGS = {
    'iPhone_Pro_Portrait': {'width': 1290, 'height': 2796},
    'iPhone_Pro_Max_Portrait': {'width': 1320, 'height': 2868},  
    'iPad_Pro_Portrait': {'width': 2048, 'height': 2732},
    'iPad_12_9_Portrait': {'width': 2064, 'height': 2752},
}

def setup_driver(device_config):
    """Setup Chrome driver with mobile viewport"""
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument(f"--window-size={device_config['width']},{device_config['height']}")
    chrome_options.add_argument("--device-scale-factor=1")
    chrome_options.add_argument("--force-device-scale-factor=1")
    
    driver = webdriver.Chrome(options=chrome_options)
    driver.set_window_size(device_config['width'], device_config['height'])
    return driver

def capture_screenshots():
    """Capture screenshots from different app screens"""
    
    # Start local server for Flutter web app
    import subprocess
    import threading
    
    # Start a simple HTTP server for the built web app
    def start_server():
        os.chdir('build/web')
        subprocess.run(['python3', '-m', 'http.server', '8000'], check=False)
    
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    time.sleep(3)  # Wait for server to start
    
    base_url = "http://localhost:8000"
    
    for device_name, config in DEVICE_CONFIGS.items():
        print(f"Capturing screenshots for {device_name}...")
        
        driver = setup_driver(config)
        
        try:
            # Navigate to app
            driver.get(base_url)
            time.sleep(5)  # Wait for app to load
            
            # Create screenshots directory
            screenshot_dir = f"assets/screenshots/{device_name}"
            os.makedirs(screenshot_dir, exist_ok=True)
            
            # Screenshot 1: Home screen
            print("Capturing home screen...")
            driver.save_screenshot(f"{screenshot_dir}/01_home_screen_{config['width']}x{config['height']}.png")
            time.sleep(2)
            
            # Try to navigate to different screens and capture
            try:
                # Screenshot 2: Try to click on Food Delivery
                food_delivery_btn = driver.find_element(By.XPATH, "//div[contains(text(), 'Food Delivery')]")
                food_delivery_btn.click()
                time.sleep(3)
                driver.save_screenshot(f"{screenshot_dir}/02_food_delivery_{config['width']}x{config['height']}.png")
                
                # Go back to home
                driver.back()
                time.sleep(2)
                
            except Exception as e:
                print(f"Could not capture food delivery screen: {e}")
                
            try:
                # Screenshot 3: Try to click on Home Services  
                home_services_btn = driver.find_element(By.XPATH, "//div[contains(text(), 'Home Services')]")
                home_services_btn.click()
                time.sleep(3)
                driver.save_screenshot(f"{screenshot_dir}/03_home_services_{config['width']}x{config['height']}.png")
                
                # Go back to home
                driver.back()
                time.sleep(2)
                
            except Exception as e:
                print(f"Could not capture home services screen: {e}")
            
            try:
                # Screenshot 4: Try to access profile/settings
                profile_btn = driver.find_element(By.XPATH, "//div[contains(text(), 'Profile')]")
                profile_btn.click()
                time.sleep(3)
                driver.save_screenshot(f"{screenshot_dir}/04_profile_gamification_{config['width']}x{config['height']}.png")
                
            except Exception as e:
                print(f"Could not capture profile screen: {e}")
                
            # Screenshot 5: Try to capture any additional unique screen
            driver.get(base_url)
            time.sleep(3)
            driver.save_screenshot(f"{screenshot_dir}/05_app_features_{config['width']}x{config['height']}.png")
            
            print(f"Completed screenshots for {device_name}")
            
        finally:
            driver.quit()
            
    print("Screenshot capture completed!")

if __name__ == "__main__":
    capture_screenshots()