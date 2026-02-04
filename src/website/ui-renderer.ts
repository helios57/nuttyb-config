import { generateLuaTweak, decodeBase64Url } from '../mod-logic/utils';
import { FormOptionsConfig, GameConfigs, CustomTweak } from '../mod-logic/types';

export function renderOptions(formOptionsConfig: FormOptionsConfig[], gameConfigs: GameConfigs, updateOutputCallback: (event?: Event) => void): void {
    const leftColumn = document.getElementById('left-column')!;
    const rightColumn = document.getElementById('right-column')!;
    const optionsFormColumns = document.getElementById('options-form-columns')!;

    leftColumn.innerHTML = '';
    rightColumn.innerHTML = '';

    const formOptionsMap = new Map(formOptionsConfig.map(og => [og.label, og]));
    const specialLeftOptions = ['NuttyB Main Tweaks', 'NuttyB Evolving Commanders'];
    const specialLeftOptionsSet = new Set(specialLeftOptions);

    specialLeftOptions.forEach(optLabel => {
        const optionGroup = formOptionsMap.get(optLabel);
        if (optionGroup) {
            const label = document.createElement('label');
            const inputElement = document.createElement('input');
            inputElement.type = 'checkbox';
            inputElement.dataset.commandBlocks = JSON.stringify(optionGroup.commandBlocks);
            if (optionGroup.tweakTemplateId) inputElement.dataset.tweakTemplateId = optionGroup.tweakTemplateId;
            inputElement.dataset.optionLabel = optionGroup.label;
            inputElement.checked = !!optionGroup.default;
            inputElement.disabled = !!optionGroup.disabled;
            label.appendChild(inputElement);
            label.appendChild(document.createTextNode(' ' + optionGroup.label));
            if (!inputElement.disabled) inputElement.addEventListener('change', updateOutputCallback);
            leftColumn.appendChild(label);
        }
    });

    const primaryModeLabel = document.createElement('label');
    primaryModeLabel.textContent = 'Mode: ';
    const primaryModeSelect = document.createElement('select');
    primaryModeSelect.id = 'primary-mode-select';
    primaryModeSelect.innerHTML = `<option value="Raptors">Raptors</option><option value="Scavengers">Scavengers</option>`;
    primaryModeSelect.addEventListener('change', (e) => updateOutputCallback(e));
    primaryModeLabel.appendChild(primaryModeSelect);
    leftColumn.appendChild(primaryModeLabel);

    const scavOnlyContainer = document.createElement('div');
    scavOnlyContainer.id = 'scav-only-options';

    const scavHpLabel = document.createElement('label');
    scavHpLabel.textContent = 'Scavengers HP: ';
    const scavHpSelect = document.createElement('select');
    scavHpSelect.id = 'scav-hp-select';
    scavHpSelect.dataset.isScavHpGenerator = 'true';
    scavHpSelect.dataset.hpType = 'scav';
    scavHpSelect.dataset.slot = '';
    scavHpSelect.dataset.slotType = 'tweakdefs';
    const scavHpOptions = [
        {v: "", t: "Default"}, {v: "1", t: "1x HP"}, {v: "1.3", t: "1.3x HP"}, {v: "1.5", t: "1.5x HP"}, {v: "1.7", t: "1.7x HP"},
        {v: "2", t: "2x HP"}, {v: "2.5", t: "2.5x HP"}, {v: "3", t: "3x HP"}, {v: "4", t: "4x HP"}, {v: "5", t: "5x HP"}
    ];
    scavHpOptions.forEach(opt => scavHpSelect.add(new Option(opt.t, opt.v)));
    scavHpSelect.value = "";
    scavHpSelect.addEventListener('change', updateOutputCallback);
    scavHpLabel.appendChild(scavHpSelect);
    scavOnlyContainer.appendChild(scavHpLabel);

    const bossHpLabel = document.createElement('label');
    bossHpLabel.textContent = 'Scav Boss HP: ';
    const bossHpSelect = document.createElement('select');
    bossHpSelect.id = 'boss-hp-select';
    bossHpSelect.dataset.isScavHpGenerator = 'true';
    bossHpSelect.dataset.hpType = 'boss';
    bossHpSelect.dataset.slot = '1';
    bossHpSelect.dataset.slotType = 'tweakdefs';
    const bossHpOptions = [
        {v: "", t: "Default"}, {v: "1", t: "1x BHP"}, {v: "1.3", t: "1.3x BHP"}, {v: "1.5", t: "1.5x BHP"}, {v: "1.7", t: "1.7x BHP"},
        {v: "2", t: "2x BHP"}, {v: "2.5", t: "2.5x BHP"}, {v: "3", t: "3x BHP"}, {v: "4", t: "4x BHP"}, {v: "5", t: "5x BHP"},
    ];
    bossHpOptions.forEach(opt => bossHpSelect.add(new Option(opt.t, opt.v)));
    bossHpSelect.value = "";
    bossHpSelect.addEventListener('change', updateOutputCallback);
    bossHpLabel.appendChild(bossHpSelect);
    scavOnlyContainer.appendChild(bossHpLabel);

    leftColumn.appendChild(scavOnlyContainer);

    const raptorOnlyContainer = document.createElement('div');
    raptorOnlyContainer.id = 'raptor-only-options';
    leftColumn.appendChild(raptorOnlyContainer);

    formOptionsConfig.forEach(optionGroup => {
        if (specialLeftOptionsSet.has(optionGroup.label)) return;
        if (optionGroup.label === 'Scavengers HP' || optionGroup.label === 'Boss HP') return;

        const raptorLabels = new Set(['Raptor Health', 'Queen Health', 'Extras', 'Raptor Settings', 'Queen Quantity', 'Wave Multiplier', 'First Waves Boost', 'Grace Period Multiplier']);

        if (optionGroup.type === 'header') {
             const h3 = document.createElement('h3');
             h3.textContent = optionGroup.label;

             if (raptorLabels.has(optionGroup.label) || optionGroup.label === 'Raptor Settings') {
                 raptorOnlyContainer.appendChild(h3);
             } else if (optionGroup.column === 'right') {
                 rightColumn.appendChild(h3);
             } else {
                 leftColumn.appendChild(h3);
             }
             return;
        }

        const label = document.createElement('label');
        let inputElement: HTMLInputElement | HTMLSelectElement;
        if (optionGroup.type === 'checkbox') {
            inputElement = document.createElement('input');
            inputElement.type = 'checkbox';
            inputElement.dataset.commandBlocks = JSON.stringify(optionGroup.commandBlocks);
            if (optionGroup.tweakTemplateId) inputElement.dataset.tweakTemplateId = optionGroup.tweakTemplateId;
            if (optionGroup.modOption) inputElement.dataset.modOption = optionGroup.modOption;
            inputElement.checked = !!optionGroup.default;
            inputElement.disabled = !!optionGroup.disabled;
            label.appendChild(inputElement);
            label.appendChild(document.createTextNode(' ' + optionGroup.label));
            if (!inputElement.disabled) inputElement.addEventListener('change', updateOutputCallback);
        } else if (optionGroup.type === 'numeric-tweak') {
            inputElement = document.createElement('input');
            inputElement.type = 'number';
            if (optionGroup.min !== undefined) inputElement.min = String(optionGroup.min);
            if (optionGroup.max !== undefined) inputElement.max = String(optionGroup.max);
            if (optionGroup.step !== undefined) inputElement.step = String(optionGroup.step);
            inputElement.value = optionGroup.defaultValue || "";

            if (optionGroup.tweakTemplateId) inputElement.dataset.tweakTemplateId = optionGroup.tweakTemplateId;
            if (optionGroup.tweakVar) inputElement.dataset.tweakVar = optionGroup.tweakVar;
            if (optionGroup.modOption) inputElement.dataset.modOption = optionGroup.modOption;
            inputElement.dataset.optionLabel = optionGroup.label;

            label.textContent = optionGroup.label + ': ';
            label.appendChild(inputElement);
            if (optionGroup.unitLabel) {
                label.appendChild(document.createTextNode(' ' + optionGroup.unitLabel));
            }
            inputElement.addEventListener('input', updateOutputCallback);
        } else if (optionGroup.type === 'select') {
            inputElement = document.createElement('select');
            inputElement.dataset.optionType = optionGroup.label;
            inputElement.dataset.optionLabel = optionGroup.label;

            if (optionGroup.isHpGenerator) {
                inputElement.dataset.isHpGenerator = 'true';
                inputElement.dataset.hpType = optionGroup.hpType;
                inputElement.dataset.slot = String(optionGroup.slot);
                inputElement.dataset.slotType = optionGroup.slotType;
                inputElement.disabled = true;
            }

            optionGroup.choices?.forEach(choice => {
                const optionElement = document.createElement('option');
                optionElement.value = choice.value;
                optionElement.textContent = choice.label;
                if (optionGroup.defaultValue && choice.value === optionGroup.defaultValue) {
                    optionElement.selected = true;
                }
                optionElement.dataset.shortLabel = choice.shortLabel || "";
                inputElement.appendChild(optionElement);
            });
            label.textContent = optionGroup.label + ': '; label.appendChild(inputElement);
            inputElement.addEventListener('change', updateOutputCallback);
        }

        if (optionGroup.column === 'right') {
            rightColumn.appendChild(label);
        } else if (raptorLabels.has(optionGroup.label)) {
            raptorOnlyContainer.appendChild(label);
        } else {
            leftColumn.appendChild(label);
        }
    });

    if (gameConfigs && (gameConfigs.maps.length > 0 || gameConfigs.modes.length > 0)) {
        let mapsLabel, modesLabel;

        if (gameConfigs.maps.length > 0) {
            mapsLabel = document.createElement('label');
            mapsLabel.textContent = 'Map: ';
            const mapsSelect = document.createElement('select');
            mapsSelect.id = 'maps-select';
            gameConfigs.maps.forEach((map, index) => {
                mapsSelect.add(new Option(map.name, String(index)));
            });
            mapsSelect.selectedIndex = 0;
            mapsSelect.addEventListener('change', updateOutputCallback);
            mapsLabel.appendChild(mapsSelect);
        }
        if (gameConfigs.modes.length > 0) {
            modesLabel = document.createElement('label');
            modesLabel.textContent = 'Start: ';
            const modesSelect = document.createElement('select');
            modesSelect.id = 'modes-select';
            modesSelect.addEventListener('change', updateOutputCallback);
            modesLabel.appendChild(modesSelect);
        }

        const container = document.getElementById('raptor-only-options');
        if (container) {
            if (modesLabel) container.after(modesLabel);
            if (mapsLabel) container.after(mapsLabel);
        } else {
            if (mapsLabel) leftColumn.appendChild(mapsLabel);
            if (modesLabel) leftColumn.appendChild(modesLabel);
        }
    }
}

export function renderCustomTweaksTable(customOptions: CustomTweak[]): void {
    const customTweaksTableBody = document.querySelector('#custom-tweaks-table tbody')!;
    customTweaksTableBody.innerHTML = '';
    if (customOptions.length === 0) {
        customTweaksTableBody.innerHTML = '<tr><td colspan="4" style="text-align: center;">No custom tweaks saved</td></tr>';
        return;
    }
    customOptions.forEach(tweak => {
        const row = (customTweaksTableBody as HTMLTableSectionElement).insertRow();
        row.innerHTML = `<td title="${tweak.desc}">${tweak.desc}</td><td title="${tweak.type}">${tweak.type}</td><td><div class="command-cell-wrapper"><span class="command-text" title="${tweak.tweak}">${tweak.tweak}</span><button class="copy-row-button" data-tweak-code="${tweak.tweak}">Copy</button></div></td><td><button class="delete-tweak-btn" data-id="${tweak.id}">Delete</button></td>`;
    });
}

export function renderCustomTweaksAsCheckboxes(customOptions: CustomTweak[], updateOutputCallback: (event?: Event) => void): void {
    const customLeftColumn = document.getElementById('custom-left-column')!;
    const customRightColumn = document.getElementById('custom-right-column')!;
    const customSettingsContainer = document.getElementById('custom-settings-container')!;

    customLeftColumn.innerHTML = '';
    customRightColumn.innerHTML = '';
    if (customOptions.length > 0) {
        customSettingsContainer.style.display = 'block';
        customOptions.forEach((tweak, index) => {
            const label = document.createElement('label');
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.dataset.isCustom = 'true';
            checkbox.dataset.customData = JSON.stringify({ type: tweak.type, tweak: tweak.tweak });
            checkbox.addEventListener('change', updateOutputCallback);

            const textSpan = document.createElement('span');
            textSpan.className = 'custom-option-label-text';
            textSpan.textContent = ` ${tweak.desc}`;

            const typeSpan = document.createElement('span');
            typeSpan.className = 'custom-option-type-display';
            typeSpan.textContent = `(${tweak.type})`;

            label.appendChild(checkbox);
            label.appendChild(textSpan);
            label.appendChild(typeSpan);

            if (index % 2 === 0) customLeftColumn.appendChild(label);
            else customRightColumn.appendChild(label);
        });
    } else {
        customSettingsContainer.style.display = 'none';
    }
}

export function updateCustomOptionUI(): void {
    const slotWarningContainer = document.getElementById('slot-warning-messages')!;
    const usedTweakDefs = new Set<number>();
    const usedTweakUnits = new Set<number>();
    const slotRegex = /!bset\s+(tweakdefs|tweakunits)([1-9])\b/;

    const allFormElements = document.querySelectorAll('#options-form-columns input[type="checkbox"], #options-form-columns select');

    allFormElements.forEach(el => {
        const element = el as HTMLInputElement | HTMLSelectElement;
        if (element.dataset.isCustom) return;

        if ((element.dataset.isHpGenerator || element.dataset.isScavHpGenerator) && element.value && element.dataset.slot) {
            const slotNum = parseInt(element.dataset.slot, 10);
            if (!isNaN(slotNum)) {
                if (element.dataset.slotType === 'tweakdefs') usedTweakDefs.add(slotNum);
                else if (element.dataset.slotType === 'tweakunits') usedTweakUnits.add(slotNum);
            }
            return;
        }

        let commands: string[] = [];
        if (element.tagName === 'SELECT' && element.value) {
            commands.push(element.value);
        } else if (element.type === 'checkbox' && (element as HTMLInputElement).checked) {
            commands = JSON.parse(element.dataset.commandBlocks || '[]');
        }

        commands.forEach(cmd => {
            if (!cmd) return;
            const match = cmd.match(slotRegex);
            if (match) {
                const slotNum = parseInt(match[2], 10);
                if (match[1] === 'tweakdefs') usedTweakDefs.add(slotNum);
                else if (match[1] === 'tweakunits') usedTweakUnits.add(slotNum);
            }
        });
    });

    const customCheckboxes = document.querySelectorAll('input[data-is-custom="true"]');
    customCheckboxes.forEach(checkbox => {
        const cb = checkbox as HTMLInputElement;
        const typeSpan = cb.nextElementSibling!.nextElementSibling!;
        const textSpan = cb.nextElementSibling!;
        const tweakData = JSON.parse(cb.dataset.customData!);
        textSpan.classList.remove('disabled');

        if (cb.checked) {
            const targetSet = (tweakData.type === 'tweakdefs') ? usedTweakDefs : usedTweakUnits;
            let assignedSlot: number | null = null;
            for (let i = 1; i <= 9; i++) {
                if (!targetSet.has(i)) {
                    assignedSlot = i;
                    break;
                }
            }
            if (assignedSlot !== null) {
                typeSpan.textContent = `(${tweakData.type}${assignedSlot})`;
                targetSet.add(assignedSlot);
            } else {
                typeSpan.textContent = `(${tweakData.type} - No Slot!)`;
            }
        } else {
                typeSpan.textContent = `(${tweakData.type})`;
        }
    });

    let defsAvailable = 9 - usedTweakDefs.size;
    let unitsAvailable = 9 - usedTweakUnits.size;

    customCheckboxes.forEach(checkbox => {
        const cb = checkbox as HTMLInputElement;
        if (!cb.checked) {
            const tweakData = JSON.parse(cb.dataset.customData!);
            let shouldBeDisabled = false;
            if (tweakData.type === 'tweakdefs' && defsAvailable <= 0) {
                shouldBeDisabled = true;
            }
            if (tweakData.type === 'tweakunits' && unitsAvailable <= 0) {
                shouldBeDisabled = true;
            }
            cb.disabled = shouldBeDisabled;
            cb.nextElementSibling!.classList.toggle('disabled', shouldBeDisabled);
        }
    });

    slotWarningContainer.innerHTML = '';
    const defsSlotWord = Math.max(0, defsAvailable) === 1 ? 'slot' : 'slots';
    const unitsSlotWord = Math.max(0, unitsAvailable) === 1 ? 'slot' : 'slots';
    const message = document.createElement('p');
    message.textContent = `${Math.max(0, defsAvailable)} available tweakdefs ${defsSlotWord} and ${Math.max(0, unitsAvailable)} available tweakunits ${unitsSlotWord}`;
    slotWarningContainer.appendChild(message);
}

export function populateDataTable(rawOptionsData: any[]): void {
    const dataTableBody = document.querySelector('#data-table tbody')!;
    dataTableBody.innerHTML = '';

    rawOptionsData.filter(item => item.status !== 'Hidden').forEach(item => {
        const row = (dataTableBody as HTMLTableSectionElement).insertRow();
        row.insertCell().textContent = item.label;
        row.insertCell().textContent = item.status;
        row.insertCell().textContent = item.summary;
        const commandsCell = row.insertCell();
        const wrapper = document.createElement('div'); wrapper.className = 'command-cell-wrapper';
        const textSpan = document.createElement('span'); textSpan.className = 'command-text';
        textSpan.textContent = item.commandBlock; textSpan.title = item.commandBlock;
        const copyBtn = document.createElement('button'); copyBtn.textContent = 'Copy';
        copyBtn.className = 'copy-row-button'; copyBtn.dataset.command = item.commandBlock;
        wrapper.appendChild(textSpan); wrapper.appendChild(copyBtn); commandsCell.appendChild(wrapper);
    });

    document.querySelectorAll('select[data-slot]').forEach(selector => {
        const sel = selector as HTMLSelectElement;
        const selectedValue = sel.value;
        if (!selectedValue) return;

        const selectedOptionText = sel.options[sel.selectedIndex].text;
        const type = sel.dataset.hpType!;
        const slot = sel.dataset.slot!;
        const slotType = sel.dataset.slotType!;
        const commandSlot = `${slotType}${slot}`;
        const base64tweak = generateLuaTweak(type, selectedValue);

        if (base64tweak.startsWith("Error")) return;

        const fullCommand = `!bset ${commandSlot} ${base64tweak}`;
        const summary = decodeBase64Url(base64tweak).split('\n')[0].trim();

        const row = (dataTableBody as HTMLTableSectionElement).insertRow();
        row.insertCell().textContent = selectedOptionText;
        row.insertCell().textContent = 'Optional/Generated';
        row.insertCell().textContent = summary;

        const commandsCell = row.insertCell();
        const wrapper = document.createElement('div'); wrapper.className = 'command-cell-wrapper';
        const textSpan = document.createElement('span'); textSpan.className = 'command-text';
        textSpan.textContent = fullCommand; textSpan.title = fullCommand;
        const copyBtn = document.createElement('button'); copyBtn.textContent = 'Copy';
        copyBtn.className = 'copy-row-button'; copyBtn.dataset.command = fullCommand;
        wrapper.appendChild(textSpan); wrapper.appendChild(copyBtn); commandsCell.appendChild(wrapper);
    });
}

export function populateMapsModesTable(gameConfigs: GameConfigs): void {
    const tableBody = document.querySelector('#maps-modes-table tbody')!;
    tableBody.innerHTML = '';

    if (gameConfigs.maps.length === 0 && gameConfigs.modes.length === 0 && gameConfigs.scavengers.length === 0 && gameConfigs.base.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="3" style="text-align: center;">No maps or modes found.</td></tr>';
        return;
    }

    const createCommandCellWithSingleCopy = (cell: HTMLTableCellElement, commands: string[]) => {
        if (!commands || commands.length === 0) {
            cell.textContent = 'N/A';
            return;
        }

        const wrapper = document.createElement('div');
        wrapper.className = 'command-cell-wrapper';

        const textSpan = document.createElement('span');
        textSpan.style.whiteSpace = 'normal';
        textSpan.innerHTML = commands.join('<br>');

        const copyBtn = document.createElement('button');
        copyBtn.textContent = 'Copy All';
        copyBtn.className = 'copy-row-button';
        copyBtn.dataset.command = commands.join('\n');

        wrapper.appendChild(textSpan);
        wrapper.appendChild(copyBtn);
        cell.appendChild(wrapper);
    };

    const populateCategory = (category: { name: string; commands: string[] }[], categoryName: string) => {
        category.forEach(item => {
            const row = (tableBody as HTMLTableSectionElement).insertRow();
            row.insertCell().textContent = categoryName;
            row.insertCell().textContent = item.name;
            createCommandCellWithSingleCopy(row.insertCell(), item.commands);
        });
    };

    const populateSimpleCategory = (commands: string[], categoryName: string, name: string) => {
            if(commands.length > 0) {
            const row = (tableBody as HTMLTableSectionElement).insertRow();
            row.insertCell().textContent = categoryName;
            row.insertCell().textContent = name;
            createCommandCellWithSingleCopy(row.insertCell(), commands);
        }
    };

    populateSimpleCategory(gameConfigs.base, 'base', 'Raptors (Default)');
    populateSimpleCategory(gameConfigs.scavengers, 'scavengers', 'Default');
    populateCategory(gameConfigs.maps, 'maps');
    populateCategory(gameConfigs.modes, 'modes');
}

export function populateStartSelector(gameConfigs: GameConfigs, updateOutputCallback: (event?: Event) => void): void {
    const startSelect = document.getElementById('modes-select') as HTMLSelectElement;
    if (!startSelect) return;

    const originalValue = startSelect.value;
    startSelect.innerHTML = '';

    if (gameConfigs && gameConfigs.modes) {
        gameConfigs.modes.forEach((mode, index) => {
            const option = document.createElement('option');
            option.value = String(index);
            option.textContent = mode.name;
            startSelect.appendChild(option);
        });

        if (Array.from(startSelect.options).some(opt => opt.value === originalValue)) {
            startSelect.value = originalValue;
        } else if (startSelect.options.length > 0) {
            startSelect.selectedIndex = 0;
        }
    }

    updateOutputCallback();
}
