const puppeteer = require('puppeteer');
const path = require('path');

async function generateScreenshots() {
    let browser;
    try {
        browser = await puppeteer.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--disable-gpu'
            ]
        });
        
        const page = await browser.newPage();
        
        // Set iPad Pro dimensions exactly
        await page.setViewport({
            width: 2048,
            height: 2732,
            deviceScaleFactor: 1
        });
        
        // Generate welcome screenshot
        const welcomeFile = path.resolve(__dirname, 'docs/ipad_screenshots/screenshot_1_welcome.html');
        console.log('Loading welcome screen...');
        
        await page.goto(`file://${welcomeFile}`, { 
            waitUntil: 'domcontentloaded',
            timeout: 10000 
        });
        
        await page.waitForTimeout(3000); // Wait for fonts
        
        await page.screenshot({ 
            path: '/Users/enamegyir/Desktop/HomeLinkGH_iPad_Screenshot.png',
            type: 'png',
            fullPage: false
        });
        
        console.log('✅ Screenshot saved to Desktop: HomeLinkGH_iPad_Screenshot.png');
        
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

generateScreenshots();