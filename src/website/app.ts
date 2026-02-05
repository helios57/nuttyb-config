import { simpleConfig } from './simple-config';
import { renderSimpleOptions, updateSimpleOutput } from './ui-renderer';

// DOM Elements
const optionsColumn = document.getElementById('left-column') as HTMLElement;
const resetDefaultBtn = document.getElementById('reset-default-btn') as HTMLElement;
const resetNoneBtn = document.getElementById('reset-none-btn') as HTMLElement;
const tabButtons = document.querySelectorAll('.tab-button');
const tabContents = document.querySelectorAll('.tab-content');

// Helper
function getElement<T extends HTMLElement>(id: string): T {
    const element = document.getElementById(id);
    if (!element) throw new Error(`Element with id '${id}' not found.`);
    return element as T;
}

// Event Handlers
function handleUpdate() {
    updateSimpleOutput();
}

function handleResetDefault() {
    // Reset checks to default
    simpleConfig.forEach(opt => {
        const checkbox = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (checkbox) checkbox.checked = opt.default;
    });
    handleUpdate();
}

function handleResetNone() {
    // Reset checks to false
    simpleConfig.forEach(opt => {
        const checkbox = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (checkbox) checkbox.checked = false;
    });
    handleUpdate();
}

function switchTab(event: Event) {
    const target = event.target as HTMLElement;
    const targetTabId = target.dataset.tab + '-tab';
    tabButtons.forEach(button => button.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    target.classList.add('active');

    const content = document.getElementById(targetTabId);
    if (content) content.classList.add('active');
}

// Initialization
function initializeApp() {
    console.log("Initializing NuttyB Configurator (Simplified)");

    if (optionsColumn) {
        optionsColumn.innerHTML = ''; // Clear "Loading..."
        renderSimpleOptions(simpleConfig, optionsColumn, handleUpdate);
    }

    if (resetDefaultBtn) resetDefaultBtn.addEventListener('click', handleResetDefault);
    if (resetNoneBtn) resetNoneBtn.addEventListener('click', handleResetNone);

    tabButtons.forEach(button => button.addEventListener('click', switchTab));

    // Handle Copy Buttons
    document.addEventListener('click', event => {
        const target = event.target as HTMLElement;
        if (target.matches('.copy-button')) {
            const targetId = target.dataset.target;
            if (!targetId) return;
            const targetTextArea = getElement<HTMLTextAreaElement>(targetId);
            if (!targetTextArea) return;
            navigator.clipboard.writeText(targetTextArea.value)
                .then(() => {
                    const originalText = target.textContent;
                    target.textContent = 'Copied!';
                    setTimeout(() => { target.textContent = originalText; }, 2000);
                });
        }
    });

    handleUpdate();
}

document.addEventListener('DOMContentLoaded', initializeApp);
