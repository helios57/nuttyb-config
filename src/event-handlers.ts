// Event Handlers Module
// Manages all UI event listeners for BAR Configurator

import { deleteCustomTweak, renderCustomTweaksTable, addCustomTweak } from './custom-tweaks';
import { updateOutput } from './output-manager';
import { resetSectionToDefaults } from './helpers/defaults';

/**
 * Switch between tabs
 * @param {Event} event - Click event from tab button
 */
export function switchTab(event: Event) {
    const target = event.target as HTMLElement;
    const targetTabId = target.dataset.tab + '-tab';
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => button.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    target.classList.add('active');
    const targetTab = document.getElementById(targetTabId);
    if (targetTab) {
        targetTab.classList.add('active');
    }

    if (target.dataset.tab === 'custom') {
        // We need to pass the customOptions. 
        // Since state is currently global/localstorage based, we might need to reload it or pass it in.
        // For now, let's assume loadCustomOptions is available or we handle it in the render function.
        // Ideally, renderCustomTweaksTable should load from storage if not passed.
        // But renderCustomTweaksTable in custom-tweaks.ts takes an array.
        // We'll fix this by importing loadCustomOptions.
        const { loadCustomOptions } = require('./custom-tweaks');
        renderCustomTweaksTable(loadCustomOptions());
    }
}

/**
 * Attach copy button handlers
 */
export function attachCopyButtonHandlers() {
    const copyButtons = document.querySelectorAll('.copy-button');
    copyButtons.forEach(button => {
        if ((button as HTMLElement).dataset.copyBound === 'true') {
            return;
        }
        const targetId = (button as HTMLElement).dataset.target;
        (button as HTMLElement).dataset.copyBound = 'true';
        button.addEventListener('click', event => {
            const btn = event.currentTarget as HTMLElement;
            const targetTextArea = targetId ? document.getElementById(targetId) as HTMLTextAreaElement : null;
            const explicitCopyText = btn.dataset.copyText;
            const textToCopy = explicitCopyText || (targetTextArea ? targetTextArea.value : '');
            if (!textToCopy) {
                return;
            }
            const originalText = btn.textContent;
            navigator.clipboard.writeText(textToCopy)
                .then(() => {
                    btn.textContent = 'Copied!';
                    setTimeout(() => { btn.textContent = originalText; }, 2000);
                }).catch(err => { console.error('Failed to copy: ', err); });
        });
    });
}

/**
 * Attach table button handlers (copy row, delete tweak)
 */
export function attachTableButtonHandlers() {
    const customTweaksTableBody = document.querySelector('#custom-tweaks-table tbody');

    if (customTweaksTableBody) {
        customTweaksTableBody.addEventListener('click', event => {
            const button = event.target as HTMLElement;
            if (button.matches('.copy-row-button')) {
                const textToCopy = button.dataset.command || button.dataset.tweakCode;
                if (!textToCopy) return;
                navigator.clipboard.writeText(textToCopy).then(() => {
                    const originalText = button.textContent;
                    button.textContent = 'Copied!';
                    setTimeout(() => { button.textContent = originalText; }, 2000);
                }).catch(err => { console.error('Failed to copy command: ', err); });
            } else if (button.matches('.delete-tweak-btn')) {
                const { loadCustomOptions, saveCustomOptions, renderAllCustomComponents } = require('./custom-tweaks');
                let customOptions = loadCustomOptions();
                customOptions = deleteCustomTweak(parseInt(button.dataset.id!, 10), customOptions);
                saveCustomOptions(customOptions);
                renderAllCustomComponents(customOptions, updateOutput);
                updateOutput();
            }
        });
    }
}

/**
 * Attach reset button handlers
 */
export function attachResetButtonHandlers(formOptionsConfig: any[]) {
    // const getDefaultsHelper = () => (window as any).ConfigDefaults; // We import it directly now

    const resetGameTweaks = () => {
        const container = document.getElementById('options-form-columns');
        if (container) {
            resetSectionToDefaults(container);
        }

        const primaryModeSelect = document.getElementById('primary-mode-select') as HTMLSelectElement;
        if (primaryModeSelect && typeof primaryModeSelect.dataset.defaultValue !== 'undefined') {
            primaryModeSelect.value = primaryModeSelect.dataset.defaultValue;
            primaryModeSelect.dispatchEvent(new Event('change', { bubbles: true }));
        }

        updateOutput();
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    const clearGameTweaks = () => {
        const container = document.getElementById('options-form-columns');
        if (!container) return;

        const checkboxes = container.querySelectorAll('input[type="checkbox"]:not(:disabled)');
        checkboxes.forEach((checkbox: any) => {
            checkbox.checked = false;
            checkbox.dispatchEvent(new Event('change', { bubbles: true }));
        });

        updateOutput();
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    const clearAvailableTweaks = () => {
        const container = document.getElementById('dynamic-tweaks-container');
        if (!container) return;

        container.querySelectorAll('input.tweak-checkbox:not(:disabled)').forEach((checkbox: any) => {
            checkbox.checked = false;
            checkbox.dispatchEvent(new Event('change', { bubbles: true }));
        });

        container.querySelectorAll('input[data-maxthisunit-override="true"]').forEach((input: any) => {
            const basePlaceholder = input.dataset.placeholderOriginal || input.placeholder || '';
            const defaultValue = typeof input.dataset.defaultValue !== 'undefined' ? input.dataset.defaultValue : '';
            if (defaultValue === '0') {
                input.value = '';
                input.dataset.effectiveValue = '0';
                input.placeholder = '∞';
            } else if (defaultValue === '') {
                input.value = '';
                delete input.dataset.effectiveValue;
                input.placeholder = basePlaceholder || input.placeholder;
            } else {
                input.value = defaultValue;
                input.dataset.effectiveValue = defaultValue;
                input.placeholder = basePlaceholder || defaultValue || input.placeholder;
            }
            input.dispatchEvent(new Event('input', { bubbles: true }));
        });

        updateOutput();
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    const resetAvailableTweaks = () => {
        const container = document.getElementById('dynamic-tweaks-container');
        if (!container) return;

        resetSectionToDefaults(container);

        container.querySelectorAll('input[data-maxthisunit-override="true"]').forEach((input: any) => {
            const basePlaceholder = input.dataset.placeholderOriginal || input.placeholder || '';
            const defaultValue = typeof input.dataset.defaultValue !== 'undefined' ? input.dataset.defaultValue : '';
            if (defaultValue === '0') {
                input.value = '';
                input.dataset.effectiveValue = '0';
                input.placeholder = '∞';
            } else if (defaultValue === '') {
                input.value = '';
                delete input.dataset.effectiveValue;
                input.placeholder = basePlaceholder || input.placeholder;
            } else {
                input.value = defaultValue;
                input.dataset.effectiveValue = defaultValue;
                input.placeholder = basePlaceholder || defaultValue || input.placeholder;
            }
            input.dispatchEvent(new Event('input', { bubbles: true }));
        });

        updateOutput();
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    const resetMultipliers = () => {
        const container = document.getElementById('multipliers-container');
        if (!container) return;

        resetSectionToDefaults(container);

        updateOutput();
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    document.querySelectorAll('.section-reset-btn').forEach(button => {
        button.addEventListener('click', () => {
            const section = (button as HTMLElement).dataset.section;
            switch (section) {
                case 'game-tweaks':
                    resetGameTweaks();
                    break;
                case 'available-tweaks':
                    resetAvailableTweaks();
                    break;
                case 'multipliers':
                    resetMultipliers();
                    break;
                default:
                    break;
            }
        });
    });

    document.querySelectorAll('.section-clear-btn').forEach(button => {
        button.addEventListener('click', () => {
            const section = (button as HTMLElement).dataset.section;
            if (section === 'game-tweaks') {
                clearGameTweaks();
            } else if (section === 'available-tweaks') {
                clearAvailableTweaks();
            }
        });
    });
}

/**
 * Attach form submission handler for custom tweaks
 */
export function attachFormSubmissionHandler() {
    const customForms = document.querySelectorAll('.custom-add-form');
    customForms.forEach(form => {
        form.addEventListener('submit', function(event) {
            const { loadCustomOptions, saveCustomOptions, renderAllCustomComponents } = require('./custom-tweaks');
            let customOptions = loadCustomOptions();
            customOptions = addCustomTweak(event, customOptions);
            saveCustomOptions(customOptions);
            renderAllCustomComponents(customOptions, updateOutput);
            updateOutput();
            if (event.target && typeof (event.target as HTMLFormElement).reset === 'function') {
                (event.target as HTMLFormElement).reset();
            }
        });
    });
}

/**
 * Attach tab button handlers
 */
export function attachTabButtonHandlers() {
    const tabButtons = document.querySelectorAll('.tab-button');
    tabButtons.forEach(button => button.addEventListener('click', switchTab));
}

/**
 * Attach global state control buttons (Defaults / None / Rebuild)
 */
export function attachStateButtonsHandler() {
    const defaultsBtn = document.getElementById('defaults-button');
    if (defaultsBtn) {
        defaultsBtn.addEventListener('click', () => {
            if (typeof (window as any).resetAllToDefaults === 'function') {
                (window as any).resetAllToDefaults();
            }
        });
    }

    const noneBtn = document.getElementById('clear-button');
    if (noneBtn) {
        noneBtn.addEventListener('click', () => {
            if (typeof (window as any).clearAllSelections === 'function') {
                (window as any).clearAllSelections();
            }
        });
    }

    const rebuildBtn = document.getElementById('rebuild-button');
    if (rebuildBtn) {
        rebuildBtn.addEventListener('click', async () => {
            if (typeof (window as any).rebuildApp === 'function') {
                await (window as any).rebuildApp();
            } else {
                console.warn('Rebuild function is not available yet.');
            }
        });
    }
}

/**
 * Fallback: ensure output refreshes when inputs change
 */
export function attachOutputRefreshHandlers() {
    const formContainers = Array.from(document.querySelectorAll('.custom-add-form'));
    const containers = [
        document.getElementById('options-form-columns'),
        document.getElementById('dynamic-tweaks-container'),
        document.getElementById('multipliers-container')
    ].filter(Boolean).concat(formContainers as HTMLElement[]);

    const triggerUpdate = (event: Event) => {
        // Ignore programmatic events (state restoration/default application) to avoid
        // spamming output generation; explicit callers will trigger updates themselves.
        if (event && event.isTrusted === false) {
            return;
        }

        updateOutput(event);
        if (typeof (window as any).saveStateToStorage === 'function') {
            (window as any).saveStateToStorage();
        }
    };

    containers.forEach(container => {
        if (!container) return;
        container.addEventListener('change', triggerUpdate);
        container.addEventListener('input', (e) => {
            const target = e && e.target as HTMLInputElement;
            if (target && target.type === 'range') {
                return;
            }
            triggerUpdate(e);
        });
    });
}

/**
 * Attach all event handlers
 * @param {Array} formOptionsConfig - Form options configuration
 */
export function attachEventHandlers(formOptionsConfig: any[]) {
    attachCopyButtonHandlers();
    attachTableButtonHandlers();
    attachResetButtonHandlers(formOptionsConfig);
    attachFormSubmissionHandler();
    attachTabButtonHandlers();
    attachStateButtonsHandler();
    attachOutputRefreshHandlers();
}
