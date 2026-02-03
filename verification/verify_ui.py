from playwright.sync_api import Page, expect, sync_playwright
import time

def verify_nuttyb_ui(page: Page):
    page.goto("http://localhost:3000")

    # Wait for the UI to render
    page.wait_for_selector("#left-column")

    # Check for the new options
    expect(page.get_by_text("NuttyB Main Tweaks", exact=False)).to_be_visible()
    expect(page.get_by_text("NuttyB Evolving Commanders", exact=False)).to_be_visible()

    # Take a screenshot of the top left column where these should be
    page.locator("#left-column").screenshot(path="verification/nuttyb_ui.png")

    # Also verify Scavengers/Raptors toggle works visually
    page.select_option("#primary-mode-select", "Scavengers")
    time.sleep(0.5) # Wait for UI update
    page.locator("#left-column").screenshot(path="verification/scavengers_mode.png")

    page.select_option("#primary-mode-select", "Raptors")
    time.sleep(0.5)
    page.locator("#left-column").screenshot(path="verification/raptors_mode.png")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            verify_nuttyb_ui(page)
        except Exception as e:
            print(f"Error: {e}")
            page.screenshot(path="verification/error.png")
        finally:
            browser.close()
