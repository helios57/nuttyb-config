from playwright.sync_api import sync_playwright, expect

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    page = browser.new_page()
    try:
        # Navigate to app
        page.goto("http://localhost:8080")

        # Wait for dynamic tweaks to load (PartialsLoaded event logic)
        page.wait_for_selector("#dynamic-tweaks-container", state="attached")

        # Wait for specific tweak label "T4 Eco"
        t4_eco_label = page.locator("label.file-label", has_text="T4 Eco")
        expect(t4_eco_label).to_be_visible(timeout=10000)

        # Click the label to toggle (should uncheck since default is checked)
        t4_eco_label.click()

        # Verify associated checkbox state (should be unchecked now)
        # We need the ID to find the input
        t4_eco_id = t4_eco_label.get_attribute("for")
        print(f"T4 Eco label for='{t4_eco_id}'")
        checkbox = page.locator(f"#{t4_eco_id}")
        expect(checkbox).not_to_be_checked()

        # Click again to check
        t4_eco_label.click()
        expect(checkbox).to_be_checked()

        # Wait for command generation and slot usage display
        # The slot usage display populates after commands are generated
        expect(page.locator(".slot-usage-card")).to_be_visible(timeout=10000)

        # Take screenshot
        page.screenshot(path="verification/ui_verification.png", full_page=True)
        print("Screenshot saved to verification/ui_verification.png")

    except Exception as e:
        print(f"Verification failed: {e}")
        page.screenshot(path="verification/failure.png")
        raise e
    finally:
        browser.close()

with sync_playwright() as playwright:
    run(playwright)
