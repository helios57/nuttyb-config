from playwright.sync_api import Page, expect, sync_playwright
import re

def verify_tweak(page: Page):
    # 1. Arrange
    page.goto("http://localhost:3000")
    expect(page).to_have_title("NuttyB Configurator")

    # 2. Act
    qhp_select = page.locator('select[data-hp-type="qhp"]')
    expect(qhp_select).to_be_visible()
    expect(qhp_select).to_be_enabled(timeout=10000)

    qhp_select.select_option("2")

    # 3. Assert
    output = page.locator('#command-output-1')
    expect(output).to_be_visible()
    # Check if value matches regex containing "!bset tweakdefs"
    expect(output).to_have_value(re.compile(r"!bset tweakdefs"))

    # 4. Screenshot
    page.screenshot(path="verification/verification.png")

if __name__ == "__main__":
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        try:
            verify_tweak(page)
        except Exception as e:
            print(f"Error: {e}")
            page.screenshot(path="verification/error.png")
        finally:
            browser.close()
