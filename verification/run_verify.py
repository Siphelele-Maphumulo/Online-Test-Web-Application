from playwright.sync_api import Page, expect, sync_playwright
import os

def test_enhanced_parsing(page: Page):
    # Load the local HTML file
    file_path = "file://" + os.path.abspath("verification/verify_enhanced_parsing.html")
    page.goto(file_path)

    # Click the run test button
    page.click("#runTestBtn")

    # Wait for results to appear
    page.wait_for_selector(".result-item")

    # Capture the screenshot
    page.screenshot(path="verification/parsing_verification.png")
    print("Screenshot saved to verification/parsing_verification.png")

    # Check if all tests passed (all match-indicators should have 'success' class)
    success_indicators = page.locator(".match-indicator.success")
    count = success_indicators.count()
    print(f"Passed detections: {count}")

    if count == 3:
        print("All detections correct!")
    else:
        print(f"Error: Only {count}/3 detections passed.")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            test_enhanced_parsing(page)
        finally:
            browser.close()
