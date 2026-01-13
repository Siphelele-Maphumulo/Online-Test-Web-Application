
from playwright.sync_api import sync_playwright
import time

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    try:
        time.sleep(30) # Add a 30-second delay
        page.goto("http://localhost:8080/login.jsp")
        page.fill("input[name='userName']", "admin")
        page.fill("input[name='userPassword']", "admin")
        page.click("button[type='submit']")
        page.wait_for_url("http://localhost:8080/adm-page.jsp?pgprt=0")

        page.goto("http://localhost:8080/adm-page.jsp?pgprt=5")

        delete_button = page.locator("button.delete-btn").first
        delete_button.click()

        # Wait for the modal to appear
        page.wait_for_selector(".modal-overlay", state="visible")

        # Get the modal's content and assert that it contains the correct data
        modal_content = page.locator(".modal-content").inner_text()

        # Take a screenshot of the modal
        page.screenshot(path="verification/delete-modal.png")

    except Exception as e:
        print(f"An error occurred: {e}")
        page.screenshot(path="verification/error.png")

    finally:
        browser.close()

with sync_playwright() as playwright:
    run(playwright)
