// UI Generator module for BAR Configurator
// Generates dynamic checkbox UI from scanned tweak files

function getCacheBuster() {
    if (typeof window !== 'undefined' && (window as any).ASSET_CACHE_BUSTER) {
        return (window as any).ASSET_CACHE_BUSTER;
    }
    return Date.now();
}

const MAXTHISUNIT_OVERRIDE_FIELDS = [
    { id: 'maxthisunit-t3-builders', label: 'T3 Builders', marker: 'T3_BUILDERS', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-unit-launchers', label: 'Unit Launchers', marker: 'UNIT_LAUNCHERS', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-ragnarok', label: 'Epic Ragnarok', marker: 'RAGNAROK', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-calamity', label: 'Epic Calamity', marker: 'CALAMITY', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-tyrannus', label: 'Epic Tyrannus', marker: 'T4_AIR', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-starfall', label: 'Epic Starfall', marker: 'STARFALL', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 }
];

const MAXTHISUNIT_DEFAULT_FALLBACKS: any = {
    T3_BUILDERS: '10',
    UNIT_LAUNCHERS: '20',
    RAGNAROK: '80',
    CALAMITY: '80',
    T4_AIR: '80',
    STARFALL: '80'
};

async function loadDynamicTweaksDefaults() {
    try {
        const response = await fetch(`dynamic-tweaks.json?v=${getCacheBuster()}`);
        const data = await response.json();

        (window as any).allTweaksData = data;
        (window as any).dynamicTweaksConfig = data.dynamic_tweaks || {};
        console.log('Loaded dependency metadata:', Object.keys(data.dynamic_tweaks || {}).length, 'tweaks');

        if ((window as any).ConfigDefaults && typeof (window as any).ConfigDefaults.buildDefaultLookup === 'function') {
            return (window as any).ConfigDefaults.buildDefaultLookup(data);
        }

        const fallback: any = {};
        Object.entries(data.dynamic_tweaks || {}).forEach(([key, config]: [string, any]) => {
            if (!config) return;
            const cleanKey = key.replace(/_/g, ' ');
            if (Array.isArray(config.options)) {
                const defaults = config.options.filter((opt: any) => opt && opt.default === true).map((opt: any) => opt.id);
                if (defaults.length > 0) {
                    fallback[key] = { options: defaults, dropdown: null };
                    fallback[cleanKey] = fallback[key];
                }
            }
            if (config.type === 'dropdown' && typeof config.default !== 'undefined') {
                fallback[key] = fallback[key] || { options: [], dropdown: null };
                fallback[key].dropdown = config.default;
                fallback[cleanKey] = fallback[key];
            }
        });

        return fallback;
    } catch (error) {
        console.warn("Could not load dynamic-tweaks.json defaults:", error);
        return {};
    }
}

export function generateRaptorWaveDropdown(updateOutputCallback: () => void) {
    console.log("Generating Raptor Wave Mode selector...");

    const container = document.getElementById('dynamic-tweaks-container');
    if (!container) {
        console.error("No container found for Raptor Wave selector");
        return;
    }

    const selectorContainer = document.createElement('div');
    selectorContainer.className = 'raptor-wave-dropdown-container';
    selectorContainer.id = 'raptor-wave-mode-container';

    const waveConfig = (window as any).allTweaksData?.dynamic_tweaks?.Raptor_Wave_Mode;
    const dropdownOptions = Array.isArray(waveConfig?.dropdown_options) ? waveConfig.dropdown_options : null;
    const defaultValue = waveConfig?.default;

    const selectorLabel = document.createElement('label');
    selectorLabel.style.display = 'block';
    selectorLabel.style.marginBottom = '6px';
    selectorLabel.style.fontWeight = 'bold';
    selectorLabel.textContent = 'Raptor Wave Mode:';

    selectorContainer.appendChild(selectorLabel);

    const optionsToUse = (dropdownOptions && dropdownOptions.length > 0) ? dropdownOptions : [
        { value: 'none', label: 'None' },
        { value: 'mini_bosses', label: 'Mini Bosses' },
        { value: 'experimental_wave', label: 'Experimental Wave Challenge' }
    ];

    if (!dropdownOptions || dropdownOptions.length === 0) {
        console.warn('Raptor_Wave_Mode options missing in dynamic-tweaks.json; using fallback list.');
    }

    const resolvedDefault = defaultValue
        || (optionsToUse.some((opt: any) => opt.value === 'mini_bosses') ? 'mini_bosses' : optionsToUse[0].value);

    const radioGroup = document.createElement('div');
    radioGroup.className = 'raptor-wave-radio-group';
    radioGroup.id = 'raptor-wave-mode';

    optionsToUse.forEach((option: any) => {
        const optionWrapper = document.createElement('label');
        optionWrapper.className = 'raptor-wave-radio-option';

        const radio = document.createElement('input');
        radio.type = 'radio';
        radio.name = 'raptor-wave-mode';
        radio.value = option.value;
        radio.id = `raptor-wave-mode-${option.value}`;
        radio.className = 'raptor-wave-radio-input';

        const isDefault = option.value === resolvedDefault;
        radio.checked = isDefault;
        radio.dataset.defaultChecked = isDefault ? 'true' : 'false';

        radio.addEventListener('change', () => {
            if (radio.checked && typeof updateOutputCallback === 'function') {
                updateOutputCallback();
            }
        });

        const labelText = document.createElement('span');
        labelText.className = 'raptor-wave-radio-label';
        labelText.textContent = option.label;

        optionWrapper.appendChild(radio);
        optionWrapper.appendChild(labelText);
        radioGroup.appendChild(optionWrapper);
    });

    selectorContainer.appendChild(radioGroup);

    const dropdownInfo = document.createElement('div');
    dropdownInfo.style.fontSize = '0.9em';
    dropdownInfo.style.color = '#888';
    dropdownInfo.style.marginTop = '5px';
    dropdownInfo.textContent = waveConfig?.description || 'Choose between standard Mini Bosses or Experimental Wave Challenge for Raptors mode';
    selectorContainer.appendChild(dropdownInfo);

    container.insertBefore(selectorContainer, container.firstChild);

    console.log("Raptor Wave Mode selector generated");
}

function renderMaxThisUnitControls(updateOutputCallback: (e?: Event) => void, tweakFileCache: any) {
    const container = document.getElementById('dynamic-tweaks-container');
    if (!container) {
        return;
    }

    const existing = document.getElementById('maxthisunit-overrides');
    if (existing) {
        existing.remove();
    }

    const wrapper = document.createElement('div');
    wrapper.id = 'maxthisunit-overrides';
    wrapper.className = 'maxthisunit-overrides';

    const divider = document.createElement('div');
    divider.className = 'tweak-divider';
    wrapper.appendChild(divider);

    const headerRow = document.createElement('div');
    headerRow.className = 'maxthisunit-header-row';

    const header = document.createElement('div');
    header.className = 'maxthisunit-header';
    header.textContent = 'Limit Max Allowed';
    headerRow.appendChild(header);

    wrapper.appendChild(headerRow);

    const helper = document.createElement('div');
    helper.className = 'maxthisunit-helper';
    helper.textContent = 'Leave blank for defaults. Enter 0 to clear the limit (∞) for that tweak when slots are packed.';
    wrapper.appendChild(helper);

    const grid = document.createElement('div');
    grid.className = 'maxthisunit-grid';

    const findDefaultValueForMarker = (markerName: string) => {
        if (!tweakFileCache || typeof tweakFileCache !== 'object') {
            return { value: MAXTHISUNIT_DEFAULT_FALLBACKS[markerName] || '', found: false };
        }

        let best: number | null = null;
        let found = false;
        Object.values(tweakFileCache).forEach((sections: any) => {
            if (Array.isArray(sections)) {
                sections.forEach((section: any) => {
                    if (section && section.name === markerName && typeof section.code === 'string') {
                        const matches = Array.from(section.code.matchAll(/maxthisunit\s*=\s*(\d+)/gi))
                            .map((m: any) => Number.parseInt(m[1], 10))
                            .filter(Number.isFinite);
                        if (matches.length > 0) {
                            found = true;
                            const localMax = Math.max(...matches);
                            if (best === null || localMax > best) {
                                best = localMax;
                            }
                        }
                    }
                });
            }
        });

        if (found && best !== null && best !== undefined) {
            return { value: String(best), found: true };
        }

        return { value: MAXTHISUNIT_DEFAULT_FALLBACKS[markerName] || '', found: false };
    };

    const formatStatus = (val: string) => {
        if (val === '') return 'Default';
        if (val === '0') return '∞ (no cap)';
        return `${val} max/unit`;
    };

    const normalizeEffectiveValue = (rawVal: string) => {
        if (!rawVal) return '';
        const trimmed = rawVal.trim();
        if (trimmed === '∞') return '0';
        if (trimmed === '0') return '0';
        const parsed = Number.parseInt(trimmed, 10);
        return Number.isFinite(parsed) && parsed >= 0 ? String(parsed) : '';
    };

    const setDisplayValue = (input: HTMLInputElement, effectiveValue: string, originalPlaceholder: string) => {
        const basePlaceholder = originalPlaceholder || input.dataset.placeholderOriginal || input.placeholder || '';
        if (effectiveValue === '0') {
            input.value = '';
            input.dataset.effectiveValue = '0';
            input.placeholder = '∞';
        } else if (effectiveValue === '') {
            input.value = '';
            delete input.dataset.effectiveValue;
            input.placeholder = basePlaceholder;
        } else {
            input.value = effectiveValue;
            input.dataset.effectiveValue = effectiveValue;
            input.placeholder = basePlaceholder;
        }
    };

    const updateStatus = (effectiveVal: string, statusEl: HTMLElement) => {
        statusEl.textContent = formatStatus(effectiveVal);
        statusEl.dataset.state = effectiveVal === '' ? 'default' : (effectiveVal === '0' ? 'infinity' : 'custom');
    };

    MAXTHISUNIT_OVERRIDE_FIELDS.forEach(field => {
        const fieldWrapper = document.createElement('label');
        fieldWrapper.className = 'maxthisunit-field';
        fieldWrapper.dataset.markerTarget = field.marker;

        const title = document.createElement('span');
        title.className = 'maxthisunit-label';
        title.textContent = field.label;

        const input = document.createElement('input');
        input.type = 'number';
        input.inputMode = 'numeric';
        input.id = field.id;
        input.dataset.markerTarget = field.marker;
        input.dataset.maxthisunitOverride = 'true';
        input.min = typeof field.min === 'number' ? String(field.min) : '0';
        if (typeof field.max === 'number') {
            input.max = String(field.max);
        }
        // input.step = field.step ? String(field.step) : '1'; // step is not in the definition above, assuming 1
        input.step = '1';

        const defaultInfo = findDefaultValueForMarker(field.marker);
        const hasMaxValue = defaultInfo.found || (defaultInfo.value && defaultInfo.value !== '');
        if (!hasMaxValue) {
            return; // Skip rendering if the marker has no maxthisunit in code
        }

        const defaultFromCode = defaultInfo.value;
        const basePlaceholder = defaultFromCode || field.placeholder || 'Default';
        input.dataset.placeholderOriginal = basePlaceholder;
        input.placeholder = basePlaceholder;
        // const defaultValue = typeof field.defaultValue !== 'undefined' ? field.defaultValue : defaultFromCode; // defaultValue not in definition
        const defaultValue = defaultFromCode;
        setDisplayValue(input, normalizeEffectiveValue(defaultValue), basePlaceholder);
        input.dataset.defaultValue = defaultValue;

        const status = document.createElement('span');
        status.className = 'maxthisunit-status';
        updateStatus(normalizeEffectiveValue(defaultValue), status);

        const inputShell = document.createElement('div');
        inputShell.className = 'maxthisunit-input-shell';

        const spinnerCol = document.createElement('div');
        spinnerCol.className = 'maxthisunit-spinner-col';

        const adjustValue = (direction: string) => {
            const step = 1;
            const min = typeof field.min === 'number' ? field.min : 0;
            const hasMax = typeof field.max === 'number';
            const max = hasMax ? field.max : Number.POSITIVE_INFINITY;
            let current = Number.parseInt(normalizeEffectiveValue(input.dataset.effectiveValue || input.value || ''), 10);
            if (!Number.isFinite(current)) {
                current = min;
            }
            current = direction === 'up' ? current + step : current - step;
            if (current < min) current = min;
            if (hasMax && current > (max as number)) current = (max as number);
            setDisplayValue(input, String(current), basePlaceholder);
            input.dispatchEvent(new Event('input', { bubbles: true }));
        };

        const upBtn = document.createElement('button');
        upBtn.type = 'button';
        upBtn.className = 'maxthisunit-spin maxthisunit-spin-up';
        upBtn.textContent = '▲';
        upBtn.title = 'Increase';
        upBtn.addEventListener('click', (e) => {
            e.preventDefault();
            adjustValue('up');
        });

        const downBtn = document.createElement('button');
        downBtn.type = 'button';
        downBtn.className = 'maxthisunit-spin maxthisunit-spin-down';
        downBtn.textContent = '▼';
        downBtn.title = 'Decrease';
        downBtn.addEventListener('click', (e) => {
            e.preventDefault();
            adjustValue('down');
        });

        spinnerCol.appendChild(upBtn);
        spinnerCol.appendChild(downBtn);
        inputShell.appendChild(input);
        inputShell.appendChild(spinnerCol);

        const syncStatus = () => updateStatus(normalizeEffectiveValue(input.dataset.effectiveValue || input.value || ''), status);

        input.addEventListener('input', (e) => {
            const effective = normalizeEffectiveValue(input.value || input.dataset.effectiveValue || '');
            setDisplayValue(input, effective, basePlaceholder);
            updateStatus(effective, status);

            const suppressOutput = (typeof window !== 'undefined' && (window as any).suppressOutputDuringStateRestore);
            if (!suppressOutput) {
                if (typeof (window as any).saveStateToStorage === 'function') {
                    (window as any).saveStateToStorage();
                }
                if (typeof updateOutputCallback === 'function') {
                    updateOutputCallback(e);
                }
            }
        });

        input.addEventListener('blur', syncStatus);
        input.addEventListener('change', syncStatus);

        const titleWrapper = document.createElement('div');
        titleWrapper.className = 'maxthisunit-title';
        titleWrapper.appendChild(title);
        titleWrapper.appendChild(status);

        fieldWrapper.appendChild(titleWrapper);
        fieldWrapper.appendChild(inputShell);
        updateStatus(normalizeEffectiveValue(input.dataset.effectiveValue || input.value || ''), status);
        grid.appendChild(fieldWrapper);
    });

    wrapper.appendChild(grid);
    container.appendChild(wrapper);

    const applyVisibility = () => {
        const rows = container.querySelectorAll('.maxthisunit-field');
        rows.forEach((row: any) => {
            const marker = row.dataset.markerTarget;
            if (!marker) return;
            const checkboxes = Array.from(document.querySelectorAll(`.tweak-checkbox[data-marker="${marker}"]`));
            const anyChecked = checkboxes.some((cb: any) => cb.checked);
            row.style.display = anyChecked ? '' : 'none';
        });
    };

    container.addEventListener('change', () => {
        applyVisibility();
    });

    applyVisibility();
}

export async function generateDynamicCheckboxUI(tweakFileCache: any, updateOutputCallback: () => void) {
    console.log("Generating dynamic checkbox UI from scanned sections...");

    const container = document.getElementById('dynamic-tweaks-container');
    if (!container) {
        console.error("No container found for dynamic checkboxes");
        return;
    }

    container.querySelectorAll('p').forEach(p => p.remove());

    let loader = container.querySelector('.tweaks-loader') as HTMLElement;
    if (!loader) {
        loader = document.createElement('div');
        loader.className = 'tweaks-loader';
        loader.innerHTML = '<span class="spinner"></span><span class="text">Loading tweaks...</span>';
        container.insertBefore(loader, container.firstChild);
    } else {
        loader.style.display = 'flex';
        const textEl = loader.querySelector('.text');
        if (textEl) textEl.textContent = 'Loading tweaks...';
    }

    let suppressUpdateDuringInit = false;

    const existingColumnsWrapper = container.querySelector('.checkbox-columns');
    if (existingColumnsWrapper) {
        existingColumnsWrapper.remove();
    }

    const tweakDefaults = await loadDynamicTweaksDefaults();

    const columnsWrapper = document.createElement('div');
    columnsWrapper.className = 'checkbox-columns';

    const groupedByDisplayName: any = {};
    const displayNameRenames: any = {
        'LRPC Rebalance v2': 'LRPC v2',
        'LRPC v2': 'T2 LRPC v2',
        'T4 Defences Test': 'T4 Defenses',
        'T4 Air Rework': 'T4 Air',
        'Epics - New': 'T4 Epics'
    };

    Object.entries(tweakFileCache).forEach(([filePath, sections]: [string, any]) => {
        const fileName = filePath.split('/').pop()?.replace('.lua', '') || '';

        if (fileName.includes('Mini_Bosses') || fileName.includes('Experimental_Wave_Challenge')) {
            console.log(`Skipping ${fileName} - handled by Raptor Wave Mode selector`);
            return;
        }

        const originalRawDisplayName = fileName
            .replace(/^(Defs_|Units_)/, '')
            .replace(/_/g, ' ')
            .replace(/ - /g, ' - ');

        let rawDisplayName = originalRawDisplayName;

        if (/^LRPC/i.test(rawDisplayName) || rawDisplayName.toLowerCase().includes('lrpc')) {
            rawDisplayName = 'T2 LRPC v2';
        }
        if (rawDisplayName.toLowerCase().includes('cross faction')) {
            rawDisplayName = 'T2 Cross Faction';
        }

        let displayName = displayNameRenames[rawDisplayName] || rawDisplayName;
        if (rawDisplayName.includes('Evolving Commanders')) {
            displayName = 'Evolving Commanders';
        }

        if (/\bmain\b/i.test(displayName)) {
            displayName = 'Main';
        }

        if (!groupedByDisplayName[displayName]) {
            groupedByDisplayName[displayName] = [];
        }

        groupedByDisplayName[displayName].push({
            filePath: filePath,
            fileName: fileName,
            rawDisplayName: rawDisplayName,
            originalDisplayName: originalRawDisplayName,
            sections: sections
        });
    });

    const getGroupPriority = (name: string) => {
        const lower = name.toLowerCase();
        if (lower === 'main') return 0;
        if (lower === 'evolving commanders') return 1;
        return 2;
    };

    const sortedGroups = Object.entries(groupedByDisplayName).sort(([aName], [bName]) => {
        const priorityA = getGroupPriority(aName);
        const priorityB = getGroupPriority(bName);
        if (priorityA !== priorityB) return priorityA - priorityB;
        return aName.localeCompare(bName);
    });

    sortedGroups.forEach(([displayName, fileGroups]: [string, any]) => {
        const isMainGroup = displayName.toLowerCase() === 'main';

        const fileGroup = document.createElement('div');
        fileGroup.className = 'file-group';
        if (isMainGroup) {
            fileGroup.className += ' main-group';
        }

        const fileHeader = document.createElement('div');
        fileHeader.className = 'file-header';

        const fileHeaderLeft = document.createElement('div');
        fileHeaderLeft.className = 'file-header-left';

        const parentCheckbox = document.createElement('input');
        parentCheckbox.type = 'checkbox';
        parentCheckbox.className = 'file-parent-checkbox';
        parentCheckbox.id = `file-${displayName.replace(/ /g, '-')}`;

        const forceDefaultAll = displayName.toLowerCase().includes('t4 defenses') || displayName.toLowerCase().includes('t4 epics');

        if (isMainGroup) {
            parentCheckbox.checked = true;
            parentCheckbox.disabled = true;
            parentCheckbox.dataset.defaultChecked = 'true';
        } else {
            const curatedDefaults = [
                'NuttyB Evolving Commanders',
                'Epics - New',
                'T4 Epics',
                'T4 Defenses',
                'T4 Air',
                'T3 Builders',
                'T3 Eco',
                'T4 Eco',
                'Unit Launchers'
            ];

            const defaultCheckName = (fileGroups && fileGroups[0] && (fileGroups[0].originalDisplayName || fileGroups[0].rawDisplayName))
                ? (fileGroups[0].originalDisplayName || fileGroups[0].rawDisplayName)
                : displayName;
            const shouldBeDefault = (window as any).ConfigDefaults && typeof (window as any).ConfigDefaults.shouldEnableByDefault === 'function'
                ? (window as any).ConfigDefaults.shouldEnableByDefault(defaultCheckName, curatedDefaults, tweakDefaults)
                : curatedDefaults.some(defaultName =>
                    defaultCheckName.toLowerCase().includes(defaultName.toLowerCase().replace(/ /g, '')) ||
                    defaultCheckName.toLowerCase().replace(/[ -]/g, '') === defaultName.toLowerCase().replace(/[ -]/g, '')
                );

            const parentDefault = shouldBeDefault || forceDefaultAll;
            parentCheckbox.dataset.defaultChecked = parentDefault ? 'true' : 'false';
            if (parentDefault) {
                parentCheckbox.checked = true;
                console.log(`Setting default for ${displayName}: checked (default enabled tweak)`);
            }
        }

        const fileLabel = document.createElement('label');
        fileLabel.className = 'file-label';
        fileLabel.htmlFor = parentCheckbox.id;
        fileLabel.textContent = isMainGroup ? `${displayName} (Always Enabled)` : displayName;

        fileHeaderLeft.appendChild(parentCheckbox);
        fileHeaderLeft.appendChild(fileLabel);
        fileHeader.appendChild(fileHeaderLeft);

        const totalSections = fileGroups.reduce((sum: number, fg: any) => {
            return sum + (Array.isArray(fg.sections) ? fg.sections.length : 0);
        }, 0);
        const hasMultipleSections = totalSections > 1;

        const expandButton = document.createElement('span');
        if (hasMultipleSections) {
            expandButton.className = 'expand-button collapsed';
            fileHeader.appendChild(expandButton);
        }

        fileGroup.appendChild(fileHeader);

        const childrenContainer = document.createElement('div');
        childrenContainer.className = 'children-checkboxes';

        const childCheckboxes: HTMLInputElement[] = [];

        const sortedFileGroups = [...fileGroups].sort((a: any, b: any) => {
            const aName = a.rawDisplayName || a.fileName || '';
            const bName = b.rawDisplayName || b.fileName || '';
            return aName.localeCompare(bName);
        });

        let singleSectionAttached = false;
        let visibleSectionCount = 0;

        sortedFileGroups.forEach((fileGroup: any) => {
            const sortedSections = Array.isArray(fileGroup.sections)
                ? [...fileGroup.sections].sort((a: any, b: any) => (a.name || '').localeCompare(b.name || ''))
                : [];

            sortedSections.forEach((section: any) => {
                let shouldHide = false;
                let matchedOption: any = null;
                Object.entries((window as any).dynamicTweaksConfig || {}).forEach(([tweakKey, tweakConfig]: [string, any]) => {
                    if (tweakConfig.options) {
                        tweakConfig.options.forEach((option: any) => {
                            const optionId = option.id.toUpperCase();
                            if (section.name === `${tweakKey.replace(/_/g, '_')}_${optionId}` ||
                                section.name === optionId) {
                                if (option.hidden === true) {
                                    shouldHide = true;
                                    console.log(`Hiding section: ${section.name} (marked as hidden)`);
                                }
                                matchedOption = option;
                            }
                        });
                    }
                });

                if (section.name === 'EPICS_BUILDOPTIONS' || section.name === 'EVO_XP') {
                    shouldHide = true;
                    console.log(`Hiding ${section.name} checkbox (auto-enable feature)`);
                }

                if (shouldHide) {
                    const hiddenLabel = document.createElement('label');
                    hiddenLabel.className = 'section-checkbox hidden-section';
                    hiddenLabel.style.display = 'none';

                    const hiddenCheckbox = document.createElement('input');
                    hiddenCheckbox.type = 'checkbox';
                    hiddenCheckbox.className = 'tweak-checkbox';
                    hiddenCheckbox.dataset.file = fileGroup.filePath;
                    hiddenCheckbox.dataset.marker = section.name;
                    hiddenCheckbox.dataset.type = section.type;
                    hiddenCheckbox.id = `section-${section.name}`;

                    const defaultState = matchedOption && typeof matchedOption.default !== 'undefined'
                        ? matchedOption.default
                        : true;
                    const autoEnable = matchedOption && matchedOption.auto_enable === true;
                    hiddenCheckbox.checked = autoEnable || defaultState === true;
                    hiddenCheckbox.dataset.defaultChecked = hiddenCheckbox.checked ? 'true' : 'false';

                    childCheckboxes.push(hiddenCheckbox);
                    hiddenLabel.appendChild(hiddenCheckbox);
                    childrenContainer.appendChild(hiddenLabel);
                    return;
                }

                visibleSectionCount += 1;

                if (!hasMultipleSections && !singleSectionAttached) {
                    parentCheckbox.classList.add('tweak-checkbox');
                    parentCheckbox.dataset.file = fileGroup.filePath;
                    parentCheckbox.dataset.marker = section.name;
                    parentCheckbox.dataset.type = section.type;
                    parentCheckbox.id = `section-${section.name}`;
                    if (typeof parentCheckbox.dataset.defaultChecked === 'undefined') {
                        const defaultFlag = isMainGroup ? true : (forceDefaultAll ? true : (matchedOption && typeof matchedOption.default !== 'undefined' ? matchedOption.default : false));
                        parentCheckbox.dataset.defaultChecked = defaultFlag ? 'true' : 'false';
                        parentCheckbox.checked = defaultFlag;
                    }
                    singleSectionAttached = true;
                    return;
                }

                const label = document.createElement('label');
                label.className = 'section-checkbox';

                const checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.className = 'tweak-checkbox';
                checkbox.dataset.file = fileGroup.filePath;
                checkbox.dataset.marker = section.name;
                checkbox.dataset.type = section.type;
                checkbox.id = `section-${section.name}`;

                if (isMainGroup) {
                    checkbox.checked = true;
                    checkbox.disabled = true;
                    checkbox.dataset.defaultChecked = 'true';
                } else if (forceDefaultAll) {
                    checkbox.checked = true;
                    checkbox.dataset.defaultChecked = 'true';
                } else if (matchedOption && typeof matchedOption.default !== 'undefined') {
                    checkbox.dataset.defaultChecked = matchedOption.default ? 'true' : 'false';
                } else {
                    checkbox.dataset.defaultChecked = checkbox.checked ? 'true' : 'false';
                }

                const span = document.createElement('span');
                const rawName = section.name.replace(/_/g, ' ');
                const isEpicsGroup = displayName.toLowerCase().includes('epic');
                const normalized = rawName.trim();
                const displayText = (isEpicsGroup && !normalized.toUpperCase().startsWith('EPIC ')) ? `EPIC ${normalized}` : normalized;
                span.textContent = displayText;

                label.appendChild(checkbox);
                label.appendChild(span);
                childrenContainer.appendChild(label);

                childCheckboxes.push(checkbox);

                checkbox.addEventListener('change', () => {
                    updateParentCheckboxState();
                    if (!suppressUpdateDuringInit && updateOutputCallback) updateOutputCallback();
                });
            });
        });

        if (visibleSectionCount === 0) {
            fileGroup.style.display = 'none';
        }

        fileGroup.appendChild(childrenContainer);

        if (!isMainGroup) {
            parentCheckbox.addEventListener('change', () => {
                const isChecked = parentCheckbox.checked;
                childCheckboxes.forEach(cb => {
                    cb.checked = isChecked;
                    cb.dispatchEvent(new Event('change', { bubbles: true }));
                });
                if (!suppressUpdateDuringInit && updateOutputCallback) updateOutputCallback();
            });
        }

        if (hasMultipleSections) {
            expandButton.addEventListener('click', (e) => {
                e.stopPropagation();
                const isCollapsed = expandButton.classList.contains('collapsed');

                if (isCollapsed) {
                    expandButton.classList.remove('collapsed');
                    expandButton.classList.add('expanded');
                    childrenContainer.classList.add('show');
                } else {
                    expandButton.classList.remove('expanded');
                    expandButton.classList.add('collapsed');
                    childrenContainer.classList.remove('show');
                }
            });
        } else {
            if (childCheckboxes.length > 0) {
                childrenContainer.classList.add('show');
            }
        }

        function updateParentCheckboxState() {
            const checkedCount = childCheckboxes.filter(cb => cb.checked).length;
            const totalCount = childCheckboxes.length;

            if (checkedCount === 0) {
                parentCheckbox.checked = false;
                parentCheckbox.indeterminate = false;
            } else if (checkedCount === totalCount) {
                parentCheckbox.checked = true;
                parentCheckbox.indeterminate = false;
            } else {
                parentCheckbox.checked = false;
                parentCheckbox.indeterminate = true;
            }
        }

        columnsWrapper.appendChild(fileGroup);
    });

    container.appendChild(columnsWrapper);
    console.log("Dynamic UI generated with combined parent groups for files with matching display names");

    renderMaxThisUnitControls(updateOutputCallback, tweakFileCache);

    if (loader) {
        loader.style.display = 'none';
    }

    setTimeout(() => {
        const checkedParents = container.querySelectorAll('.file-parent-checkbox:checked:not(:disabled)');
        suppressUpdateDuringInit = true;
        try {
            checkedParents.forEach(parentCheckbox => {
                const event = new Event('change', { bubbles: true });
                parentCheckbox.dispatchEvent(event);
            });
        } finally {
            suppressUpdateDuringInit = false;
        }
        console.log(`Auto-checked ${checkedParents.length} default-enabled tweaks`);

        if (updateOutputCallback) {
            setTimeout(() => {
                if (typeof window !== 'undefined' && (window as any).skipInitialCommandGeneration) {
                    (window as any).skipInitialCommandGeneration = false;
                    return;
                }
                console.log("Triggering initial command generation...");
                updateOutputCallback();
            }, 50);
        }
    }, 10);
}
