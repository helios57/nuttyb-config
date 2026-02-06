// src/ui-generator/raptor-wave.ts

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
