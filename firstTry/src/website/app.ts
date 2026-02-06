import { simpleConfig, CustomTweak } from './simple-config';
import { renderSimpleOptions, updateSimpleOutput } from './ui-renderer';
import masterGadgetCode from '../../lua/MasterGadget.lua';

let customTweaks: CustomTweak[] = [
    {
        id: 'default-master-gadget',
        description: 'Master Gadget (Default)',
        type: 'tweakdefs',
        code: masterGadgetCode
    }
];

// Helper
function getElement<T extends HTMLElement>(id: string): T {
    const element = document.getElementById(id);
    if (!element) throw new Error(`Element with id '${id}' not found.`);
    return element as T;
}

// Event Handlers
function handleUpdate() {
    updateSimpleOutput(customTweaks);
    renderCustomTweaksInConfigTab();
}

function handleResetDefault() {
    // Reset checks to default
    simpleConfig.forEach(opt => {
        const input = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (input) {
            if (opt.type === 'checkbox') {
                input.checked = opt.default as boolean;
            } else {
                input.value = (opt.default as number).toString();
                const display = input.nextElementSibling;
                if (display) display.textContent = input.value;
            }
        }
    });
    handleUpdate();
}

function handleResetNone() {
    // Reset checks to false
    simpleConfig.forEach(opt => {
        const input = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (input) {
            if (opt.type === 'checkbox') {
                input.checked = false;
            } else {
                const min = opt.min !== undefined ? opt.min : 0;
                input.value = min.toString();
                const display = input.nextElementSibling;
                if (display) display.textContent = input.value;
            }
        }
    });
    handleUpdate();
}

function switchTab(event: Event) {
    const target = event.target as HTMLElement;
    const targetTabId = target.dataset.tab + '-tab';
    
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => button.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    target.classList.add('active');

    const content = document.getElementById(targetTabId);
    if (content) content.classList.add('active');
}

function renderCustomTweaksTable() {
    const customTweaksTableBody = document.querySelector('#custom-tweaks-table tbody') as HTMLTableSectionElement;
    if (!customTweaksTableBody) return;

    customTweaksTableBody.innerHTML = '';
    customTweaks.forEach(tweak => {
        const row = document.createElement('tr');
        
        const descCell = document.createElement('td');
        descCell.textContent = tweak.description;
        row.appendChild(descCell);

        const typeCell = document.createElement('td');
        typeCell.textContent = tweak.type;
        row.appendChild(typeCell);

        const codeCell = document.createElement('td');
        const codePreview = document.createElement('code');
        codePreview.textContent = tweak.code.substring(0, 20) + (tweak.code.length > 20 ? '...' : '');
        codePreview.title = tweak.code;
        codeCell.appendChild(codePreview);
        row.appendChild(codeCell);

        const actionsCell = document.createElement('td');
        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = 'Delete';
        deleteBtn.className = 'action-button delete-btn';
        deleteBtn.onclick = () => {
            customTweaks = customTweaks.filter(t => t.id !== tweak.id);
            renderCustomTweaksTable();
            handleUpdate();
        };
        actionsCell.appendChild(deleteBtn);
        row.appendChild(actionsCell);

        customTweaksTableBody.appendChild(row);
    });
}

function renderCustomTweaksInConfigTab() {
    const container = document.getElementById('custom-settings-container');
    const leftCol = document.getElementById('custom-left-column');
    const rightCol = document.getElementById('custom-right-column');
    
    if (!container || !leftCol || !rightCol) return;

    if (customTweaks.length === 0) {
        container.style.display = 'none';
        return;
    }

    container.style.display = 'block';
    leftCol.innerHTML = '';
    rightCol.innerHTML = '';

    customTweaks.forEach((tweak, index) => {
        const wrapper = document.createElement('div');
        wrapper.className = 'option-wrapper';
        
        const label = document.createElement('label');
        label.className = 'option-label';
        label.textContent = tweak.description || `Custom Tweak ${index + 1}`;
        wrapper.appendChild(label);

        const desc = document.createElement('p');
        desc.className = 'option-description';
        desc.textContent = `${tweak.type}: ${tweak.code.substring(0, 30)}${tweak.code.length > 30 ? '...' : ''}`;
        wrapper.appendChild(desc);

        if (index % 2 === 0) {
            leftCol.appendChild(wrapper);
        } else {
            rightCol.appendChild(wrapper);
        }
    });
}

function handleCustomTweakSubmit(event: Event) {
    event.preventDefault();
    const descInput = document.getElementById('custom-option-desc') as HTMLInputElement;
    const typeInput = document.getElementById('custom-option-type') as HTMLSelectElement;
    const codeInput = document.getElementById('custom-tweak-code') as HTMLTextAreaElement;

    if (!descInput || !typeInput || !codeInput) return;

    const newTweak: CustomTweak = {
        id: Date.now().toString(),
        description: descInput.value,
        type: typeInput.value as 'tweakdefs' | 'tweakunits',
        code: codeInput.value.trim()
    };

    customTweaks.push(newTweak);
    renderCustomTweaksTable();
    handleUpdate();

    // Reset form
    descInput.value = '';
    codeInput.value = '';
}

// Initialization
function initializeApp() {
    console.log("Initializing NuttyB Configurator (Simplified)");

    const optionsColumn = document.getElementById('left-column') as HTMLElement;
    const resetDefaultBtn = document.getElementById('reset-default-btn') as HTMLElement;
    const resetNoneBtn = document.getElementById('reset-none-btn') as HTMLElement;
    const tabButtons = document.querySelectorAll('.tab-button');
    const customTweakForm = document.getElementById('custom-tweak-form') as HTMLFormElement;

    if (optionsColumn) {
        optionsColumn.innerHTML = ''; // Clear "Loading..."
        renderSimpleOptions(simpleConfig, optionsColumn, handleUpdate);
    }

    if (resetDefaultBtn) resetDefaultBtn.addEventListener('click', handleResetDefault);
    if (resetNoneBtn) resetNoneBtn.addEventListener('click', handleResetNone);

    tabButtons.forEach(button => button.addEventListener('click', switchTab));

    if (customTweakForm) {
        customTweakForm.addEventListener('submit', handleCustomTweakSubmit);
    }

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

    // Initial render of custom tweaks table (even if empty)
    renderCustomTweaksTable();
    handleUpdate();
}

document.addEventListener('DOMContentLoaded', initializeApp);
