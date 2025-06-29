const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

async function generateScreenshots() {
    const browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    
    // Set iPad Pro 12.9" dimensions
    await page.setViewport({
        width: 2048,
        height: 2732,
        deviceScaleFactor: 1
    });
    
    const screenshots = [
        {
            file: 'docs/ipad_screenshots/screenshot_1_welcome.html',
            output: '/Users/enamegyir/Desktop/HomeLinkGH_iPad_Welcome.png'
        },
        {
            file: 'docs/ipad_screenshots/screenshot_2_services.html', 
            output: '/Users/enamegyir/Desktop/HomeLinkGH_iPad_Services.png'
        },
        {
            file: 'docs/ipad_screenshots/screenshot_3_features.html',
            output: '/Users/enamegyir/Desktop/HomeLinkGH_iPad_Features.png'
        }
    ];
    
    for (const screenshot of screenshots) {
        const fullPath = path.resolve(__dirname, screenshot.file);
        console.log(`Generating ${screenshot.output}...`);
        
        await page.goto(`file://${fullPath}`, { 
            waitUntil: 'networkidle0',
            timeout: 30000 
        });
        
        // Wait a bit for fonts and styling to load
        await page.waitForTimeout(2000);
        
        await page.screenshot({ 
            path: screenshot.output,
            type: 'png',
            fullPage: false,
            clip: {
                x: 0,
                y: 0,
                width: 2048,
                height: 2732
            }
        });
        
        console.log(`✅ Created: ${screenshot.output}`);
    }
    
    await browser.close();
    console.log('\n🎉 All iPad screenshots generated successfully!');
    console.log('📁 Check your Desktop for the PNG files');
    console.log('📱 Ready for App Store Connect upload');
}

generateScreenshots().catch(console.error);