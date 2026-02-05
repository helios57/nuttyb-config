import { loadConfigData, loadLinksContent, parseModesFile } from '../mod-logic/config-loader';
import { loadCustomOptions, addCustomTweak, deleteCustomTweak, getCustomOptions } from '../mod-logic/custom-tweaks';
import { generateCommands, CommandGeneratorInput } from '../mod-logic/command-generator';
import {
    renderOptions,
    renderCustomTweaksTable,
    renderCustomTweaksAsCheckboxes,
    updateCustomOptionUI,
    populateDataTable,
    populateMapsModesTable,
    populateStartSelector
} from './ui-renderer';
import { GameConfigs, FormOptionsConfig, RawOptionsData, CustomTweak } from '../mod-logic/types';

let rawOptionsData: RawOptionsData[] = [];
let formOptionsConfig: FormOptionsConfig[] = [];
let gameConfigs: GameConfigs = { maps: [], modes: [], base: [], scavengers: [] };

const lobbyNameDisplay = getElement<HTMLElement>('lobby-name-display');
const copyButtons = document.querySelectorAll('.copy-button');
const dataTableBody = safeQuerySelector<HTMLElement>('#data-table tbody');
const customTweakForm = getElement<HTMLFormElement>('custom-tweak-form');
const customTweaksTableBody = safeQuerySelector<HTMLElement>('#custom-tweaks-table tbody');
const mapsModesTableBody = safeQuerySelector<HTMLElement>('#maps-modes-table tbody');
const tabButtons = document.querySelectorAll('.tab-button');
const tabContents = document.querySelectorAll('.tab-content');
const resetNoneBtn = getElement<HTMLElement>('reset-none-btn');
const resetDefaultBtn = getElement<HTMLElement>('reset-default-btn');
const optionsFormColumns = getElement<HTMLElement>('options-form-columns');

function updateOutput(event?: Event) {
    const primaryModeSelect = safeQuerySelector<HTMLSelectElement>('#primary-mode-select');
    const raptorOnlyContainer = safeQuerySelector<HTMLElement>('#raptor-only-options');
    const scavOnlyContainer = safeQuerySelector<HTMLElement>('#scav-only-options');
    const scavHpSelect = safeQuerySelector<HTMLSelectElement>('#scav-hp-select');
    const bossHpSelect = safeQuerySelector<HTMLSelectElement>('#boss-hp-select');
    const mapsSelect = safeQuerySelector<HTMLSelectElement>('#maps-select');
    const modesSelect = safeQuerySelector<HTMLSelectElement>('#modes-select');

    if (primaryModeSelect && raptorOnlyContainer && scavOnlyContainer) {
        const newMode = primaryModeSelect.value;
        const modeChanged = event && event.target === primaryModeSelect;

        if (modeChanged) {
            if (newMode === 'Scavengers') {
                if (scavHpSelect) scavHpSelect.value = "1.3";
                if (bossHpSelect) bossHpSelect.value = "1.3";
                raptorOnlyContainer.querySelectorAll('select, input').forEach(el => (el as HTMLInputElement).value = "");
            } else { // Switching back to Raptors
                if (scavHpSelect) scavHpSelect.value = "";
                if (bossHpSelect) bossHpSelect.value = "";
                raptorOnlyContainer.querySelectorAll('select, input').forEach(el => {
                    const htmlEl = el as HTMLElement;
                    let optionGroup = formOptionsConfig.find(og => og.label === htmlEl.dataset.optionType);

                    if (!optionGroup && htmlEl.dataset.modOption) {
                         optionGroup = formOptionsConfig.find(og => og.modOption === htmlEl.dataset.modOption);
                    }
                    if (!optionGroup && htmlEl.dataset.tweakTemplateId) {
                         optionGroup = formOptionsConfig.find(og => og.tweakTemplateId === htmlEl.dataset.tweakTemplateId);
                    }

                    if (optionGroup) {
                        (el as HTMLInputElement).value = optionGroup.defaultValue || "";
                    }
                });
            }
        }

        const isScavengers = newMode === 'Scavengers';
        raptorOnlyContainer.style.display = isScavengers ? 'none' : 'block';
        scavOnlyContainer.style.display = isScavengers ? 'block' : 'none';
    }

    updateCustomOptionUI();

    // Gather input for command generator
    const formElements = Array.from(document.querySelectorAll('#options-form-columns input[type="checkbox"], #options-form-columns input[type="number"], #options-form-columns select, #custom-options-form-columns input[type="checkbox"]')).map(el => {
        const element = el as HTMLInputElement | HTMLSelectElement;
        return {
            isCustom: element.dataset.isCustom === 'true',
            customData: element.dataset.customData ? JSON.parse(element.dataset.customData) : undefined,
            isHpGenerator: element.dataset.isHpGenerator === 'true',
            isScavHpGenerator: element.dataset.isScavHpGenerator === 'true',
            value: element.value,
            checked: (element as HTMLInputElement).checked,
            hpType: element.dataset.hpType,
            slot: element.dataset.slot,
            slotType: element.dataset.slotType,
            tagName: element.tagName,
            type: element.type,
            id: element.id,
            dataset: element.dataset,
            commandBlocks: element.dataset.commandBlocks ? JSON.parse(element.dataset.commandBlocks) : undefined
        };
    });

    const raptorOptions = Array.from(document.querySelectorAll('#raptor-only-options select')).map(el => ({
        value: (el as HTMLSelectElement).value,
        optionType: (el as HTMLElement).dataset.optionType || ''
    }));

    const mainTweaksCheckbox = document.querySelector('input[data-option-label="NuttyB Main Tweaks"]') as HTMLInputElement;
    const isMainTweaksEnabled = mainTweaksCheckbox ? mainTweaksCheckbox.checked : true;

    const generatorInput: CommandGeneratorInput = {
        isMainTweaksEnabled,
        gameConfigs,
        formOptionsConfig,
        mapsSelectValue: mapsSelect ? mapsSelect.value : "",
        modesSelectValue: modesSelect ? modesSelect.value : "",
        primaryModeSelectValue: primaryModeSelect ? primaryModeSelect.value : "Raptors",
        scavHpSelectValue: scavHpSelect ? scavHpSelect.value : "",
        scavHpSelectText: scavHpSelect && scavHpSelect.options[scavHpSelect.selectedIndex] ? scavHpSelect.options[scavHpSelect.selectedIndex].text : "",
        bossHpSelectValue: bossHpSelect ? bossHpSelect.value : "",
        bossHpSelectText: bossHpSelect && bossHpSelect.options[bossHpSelect.selectedIndex] ? bossHpSelect.options[bossHpSelect.selectedIndex].text : "",
        formElements,
        raptorOptions
    };

    const generatedData = generateCommands(generatorInput);
    lobbyNameDisplay.textContent = generatedData.lobbyName;

    for (let i = 1; i <= 7; i++) {
        const sectionDiv = getElement<HTMLElement>(`part-${i}-section`);
        const textArea = getElement<HTMLTextAreaElement>(`command-output-${i}`);
        if (generatedData.sections[i-1]) {
            textArea.value = generatedData.sections[i-1];
            sectionDiv.style.display = 'grid';
        } else {
            textArea.value = '';
            sectionDiv.style.display = 'none';
        }
    }
}

function switchTab(event: Event) {
    const target = event.target as HTMLElement;
    const targetTabId = target.dataset.tab + '-tab';
    tabButtons.forEach(button => button.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    target.classList.add('active');
    getElement<HTMLElement>(targetTabId).classList.add('active');

    if (target.dataset.tab === 'data') {
        populateDataTable(rawOptionsData);
        populateMapsModesTable(gameConfigs);
    }
    if (target.dataset.tab === 'custom') {
        renderCustomTweaksTable(getCustomOptions());
    }
}

function renderAllCustomComponents() {
    renderCustomTweaksTable(getCustomOptions());
    renderCustomTweaksAsCheckboxes(getCustomOptions(), updateOutput);
}

function handleAddCustomTweak(event: Event) {
    event.preventDefault();
    const desc = getElement<HTMLInputElement>('custom-option-desc').value.trim();
    const type = getElement<HTMLSelectElement>('custom-option-type').value;
    const tweak = getElement<HTMLTextAreaElement>('custom-tweak-code').value.trim();

    addCustomTweak(desc, type, tweak);
    renderAllCustomComponents();
    updateOutput();
    customTweakForm.reset();
}

function handleDeleteCustomTweak(id: number) {
    deleteCustomTweak(id);
    renderAllCustomComponents();
    updateOutput();
}

// This handles all copy buttons, including the new reset button
document.addEventListener('click', event => {
    const target = event.target as HTMLElement;
    if (target.matches('.copy-button')) {
        const targetId = target.dataset.target;
        if (!targetId) return;

        const targetTextArea = getElement<HTMLTextAreaElement>(targetId);
        if (!targetTextArea) return;

        const originalText = target.textContent;
        navigator.clipboard.writeText(targetTextArea.value)
            .then(() => {
                target.textContent = 'Copied!';
                setTimeout(() => { target.textContent = originalText; }, 2000);
            }).catch(err => { console.error('Failed to copy: ', err); });
    }
});

[dataTableBody, customTweaksTableBody, mapsModesTableBody].forEach(tbody => {
    if (!tbody) return;
    tbody.addEventListener('click', event => {
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
                handleDeleteCustomTweak(parseInt(button.dataset.id!, 10));
        }
    });
});

resetNoneBtn.addEventListener('click', () => {
    const formElements = document.querySelectorAll('#options-form-columns input[type="checkbox"], #options-form-columns input[type="number"], #options-form-columns select');
    formElements.forEach(el => {
        const element = el as HTMLInputElement | HTMLSelectElement;
        if (element.type === 'checkbox') {
            (element as HTMLInputElement).checked = false;
        } else if (element.tagName === 'SELECT') {
            if (element.id === 'maps-select' || element.id === 'modes-select') {
                (element as HTMLSelectElement).selectedIndex = -1;
            } else if (element.id !== 'primary-mode-select') {
                element.value = "";
            }
        } else if (element.type === 'number') {
             // Reset number inputs
             const templateId = element.dataset.tweakTemplateId;
             if (templateId) {
                 const config = formOptionsConfig.find(c => c.tweakTemplateId === templateId);
                 if (config) element.value = config.defaultValue || "";
                 else element.value = "";
             } else {
                 element.value = "";
             }
        }
    });
    updateOutput();
});

resetDefaultBtn.addEventListener('click', () => {
    const primaryModeSelect = safeQuerySelector<HTMLSelectElement>('#primary-mode-select');
    if (primaryModeSelect) primaryModeSelect.value = 'Raptors';

    // Create a map for faster lookup of checkbox labels
    const checkboxLabelsMap = new Map<string, HTMLLabelElement>();
    document.querySelectorAll('#options-form-columns label').forEach(l => {
        const text = l.textContent?.trim();
        if (text) checkboxLabelsMap.set(text, l as HTMLLabelElement);
    });

    formOptionsConfig.forEach(optionGroup => {
        if (optionGroup.type === 'checkbox') {
            const label = checkboxLabelsMap.get(optionGroup.label);
            if (label) {
                const checkbox = label.querySelector('input[type="checkbox"]') as HTMLInputElement;
                if (checkbox) checkbox.checked = !!optionGroup.default;
            }
        } else if (optionGroup.type === 'select') {
            const select = optionsFormColumns.querySelector(`select[data-option-type="${optionGroup.label}"]`) as HTMLSelectElement;
            if (select) select.value = optionGroup.defaultValue || "";
        } else if (optionGroup.type === 'numeric-tweak') {
             if (optionGroup.tweakTemplateId) {
                 const numInput = optionsFormColumns.querySelector(`input[data-tweak-template-id="${optionGroup.tweakTemplateId}"]`) as HTMLInputElement;
                 if (numInput) numInput.value = optionGroup.defaultValue || "";
             }
        }
    });

    const bossHpSelect = safeQuerySelector<HTMLSelectElement>('#boss-hp-select');
    const scavHpSelect = safeQuerySelector<HTMLSelectElement>('#scav-hp-select');
    if (bossHpSelect) bossHpSelect.value = "";
    if (scavHpSelect) scavHpSelect.value = "";

    const mapsSelect = safeQuerySelector<HTMLSelectElement>('#maps-select');
    if (mapsSelect && mapsSelect.options.length > 0) mapsSelect.selectedIndex = 0;

    const modesSelect = safeQuerySelector<HTMLSelectElement>('#modes-select');
    if(modesSelect && modesSelect.options.length > 0) {
        modesSelect.selectedIndex = 0;
    }

    updateOutput();
});

customTweakForm.addEventListener('submit', handleAddCustomTweak);
tabButtons.forEach(button => button.addEventListener('click', switchTab));

function getElement<T extends HTMLElement>(id: string): T {
    const element = document.getElementById(id);
    if (!element) {
        throw new Error(`Element with id '${id}' not found.`);
    }
    return element as T;
}

function safeQuerySelector<T extends HTMLElement>(selector: string, parent: Element | Document = document): T | null {
    return parent.querySelector(selector) as T | null;
}

async function initializeApp() {
    try {
        loadCustomOptions();

        const [parsedConfigs, configData, linksContent] = await Promise.all([
            parseModesFile('modes.txt'),
            loadConfigData(),
            loadLinksContent()
        ]);

        gameConfigs = parsedConfigs;
        rawOptionsData = configData.rawOptionsData;
        formOptionsConfig = configData.formOptionsConfig;

        if (linksContent) {
            const linksTab = getElement<HTMLElement>('links-tab');
            linksTab.innerHTML = linksContent;
        }

        console.log("Modes file loaded and parsed:", gameConfigs);

        renderOptions(formOptionsConfig, gameConfigs, updateOutput);

        // Enable generators immediately as dependencies are bundled
        document.querySelectorAll('select[data-is-hp-generator="true"], select[data-is-scav-hp-generator="true"]').forEach(select => {
            (select as HTMLSelectElement).disabled = false;
        });
        updateOutput();

        renderAllCustomComponents();
        populateStartSelector(gameConfigs, updateOutput);

        // Populate Reset All textarea
        const resetOutput = getElement<HTMLTextAreaElement>('reset-output');
        resetOutput.value = Array.from({ length: 9 }, (_, i) => `!bset tweakdefs${i + 1} ""\n!bset tweakunits${i + 1} ""`).join('\n');

    } catch (error) {
        console.error("Failed to initialize the configurator:", error);
        document.querySelector('.container')!.innerHTML = '<h1>Initialization Error</h1><p style="color: red;">Could not load essential configuration files (e.g., modes.txt or tweakdata.txt). Please check that the files exist and refresh the page.</p>';
    }
}

document.addEventListener('DOMContentLoaded', initializeApp);
