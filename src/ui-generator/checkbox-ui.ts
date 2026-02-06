// src/ui-generator/checkbox-ui.ts

import { renderMaxThisUnitControls } from './max-this-unit';

function getCacheBuster() {
    if (typeof window !== 'undefined' && (window as any).ASSET_CACHE_BUSTER) {
        return (window as any).ASSET_CACHE_BUSTER;
    }
    return Date.now();
}

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
