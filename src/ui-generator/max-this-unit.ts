// src/ui-generator/max-this-unit.ts

export const MAXTHISUNIT_OVERRIDE_FIELDS = [
    { id: 'maxthisunit-t3-builders', label: 'T3 Builders', marker: 'T3_BUILDERS', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-unit-launchers', label: 'Unit Launchers', marker: 'UNIT_LAUNCHERS', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-ragnarok', label: 'Epic Ragnarok', marker: 'RAGNAROK', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-calamity', label: 'Epic Calamity', marker: 'CALAMITY', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-tyrannus', label: 'Epic Tyrannus', marker: 'T4_AIR', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 },
    { id: 'maxthisunit-epic-starfall', label: 'Epic Starfall', marker: 'STARFALL', placeholder: '0 = ∞ (remove limit)', min: 0, max: 1000 }
];

export const MAXTHISUNIT_DEFAULT_FALLBACKS: any = {
    T3_BUILDERS: '10',
    UNIT_LAUNCHERS: '20',
    RAGNAROK: '80',
    CALAMITY: '80',
    T4_AIR: '80',
    STARFALL: '80'
};

export function renderMaxThisUnitControls(updateOutputCallback: (e?: Event) => void, tweakFileCache: any) {
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
