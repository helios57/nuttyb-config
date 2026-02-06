import { ConfigOption, simpleConfig, CustomTweak } from './simple-config';

export function renderSimpleOptions(
    config: ConfigOption[],
    container: HTMLElement,
    onChange: () => void
) {
    config.forEach(opt => {
        const wrapper = document.createElement('div');
        wrapper.className = 'option-wrapper';

        const label = document.createElement('label');
        label.className = 'option-label';
        label.textContent = opt.label;
        wrapper.appendChild(label);

        if (opt.type === 'checkbox') {
            const input = document.createElement('input');
            input.type = 'checkbox';
            input.checked = opt.default as boolean;
            input.dataset.modOption = opt.modOption;
            input.addEventListener('change', onChange);
            label.prepend(input); // Checkbox before text
        } else if (opt.type === 'slider') {
            const controlsDiv = document.createElement('div');
            controlsDiv.className = 'slider-controls';

            const input = document.createElement('input');
            input.type = 'range';
            input.min = (opt.min !== undefined ? opt.min : 0).toString();
            input.max = (opt.max !== undefined ? opt.max : 100).toString();
            input.step = (opt.step !== undefined ? opt.step : 1).toString();
            input.value = opt.default.toString();
            input.dataset.modOption = opt.modOption;

            const valueDisplay = document.createElement('span');
            valueDisplay.className = 'slider-value';
            valueDisplay.textContent = input.value;

            input.addEventListener('input', () => {
                valueDisplay.textContent = input.value;
                onChange();
            });

            controlsDiv.appendChild(input);
            controlsDiv.appendChild(valueDisplay);
            wrapper.appendChild(controlsDiv);
        }

        if (opt.description) {
            const desc = document.createElement('p');
            desc.className = 'option-description';
            desc.textContent = opt.description;
            wrapper.appendChild(desc);
        }

        container.appendChild(wrapper);
    });
}

function encodeBase64(str: string): string {
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, (match, p1) => {
        return String.fromCharCode(parseInt(p1, 16));
    }));
}

function splitString(str: string, size: number): string[] {
    const numChunks = Math.ceil(str.length / size);
    const chunks: string[] = [];
    for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
        chunks.push(str.substring(o, o + size));
    }
    return chunks;
}

export function updateSimpleOutput(customTweaks: CustomTweak[] = []) {
    const outputAreas: (HTMLTextAreaElement | null)[] = [];
    const sectionDivs: (HTMLElement | null)[] = [];
    const MAX_PARTS = 15; // index.html has 15 parts
    const CHUNK_SIZE = 40000; // Increased to fit in 3 chunks (0, 1, 2)
    const MAX_ALLOWED_SLOTS = 3; // Limit to tweakdefs/tweakdefs1/tweakdefs2

    for (let i = 1; i <= MAX_PARTS; i++) {
        outputAreas.push(document.getElementById(`command-output-${i}`) as HTMLTextAreaElement);
        sectionDivs.push(document.getElementById(`part-${i}-section`) as HTMLElement);
    }

    const lobbyNameDisplay = document.getElementById('lobby-name-display') as HTMLElement;
    
    if (!outputAreas[0]) {
        console.error("Output area 'command-output-1' not found.");
        return;
    }

    // Initialize parts arrays
    const partsCommands: string[][] = Array.from({ length: MAX_PARTS }, () => []);
    let lobbyName = "[Mod] NuttyB (Static)";

    // Standard Options (Always in Part 1)
    simpleConfig.forEach(opt => {
        const input = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (input) {
            if (opt.type === 'checkbox') {
                partsCommands[0].push(`!bset ${opt.modOption} ${input.checked ? 1 : 0}`);
            } else {
                partsCommands[0].push(`!bset ${opt.modOption} ${input.value}`);
            }
        }
    });

    // Custom Tweaks Distribution
    const defsTweaks = customTweaks.filter(t => t.type === 'tweakdefs');
    const unitsTweaks = customTweaks.filter(t => t.type === 'tweakunits');

    // Slot Management
    // We share slots 0-9 across Output Parts 1-10 (mapped by index 0-9)
    // tweakdefs -> Part 1
    // tweakdefs1 -> Part 2
    // ...
    const MAX_SLOTS = MAX_ALLOWED_SLOTS; // Restrict slots to what the mod supports
    
    // Distribute tweakdefs
    let currentDefSlot = 0;
    for (const tweak of defsTweaks) {
        const encoded = encodeBase64(tweak.code);
        const chunks = splitString(encoded, CHUNK_SIZE);
        
        for (const chunk of chunks) {
            if (currentDefSlot >= MAX_SLOTS) break;
            
            const defKey = currentDefSlot === 0 ? 'tweakdefs' : `tweakdefs${currentDefSlot}`;
            partsCommands[currentDefSlot].push(`!bset ${defKey} "${chunk}"`);
            currentDefSlot++;
        }
    }
    
    // Fill remaining slots with 0 (Clear command)
    while (currentDefSlot < MAX_SLOTS) {
         const defKey = currentDefSlot === 0 ? 'tweakdefs' : `tweakdefs${currentDefSlot}`;
         partsCommands[currentDefSlot].push(`!bset ${defKey} 0`);
         currentDefSlot++;
    }

    // Distribute tweakunits (similar logic, typically independent slots but mapped to same output parts)
    let currentUnitSlot = 0;
    for (const tweak of unitsTweaks) {
        const encoded = encodeBase64(tweak.code);
        const chunks = splitString(encoded, CHUNK_SIZE);
        
        for (const chunk of chunks) {
            if (currentUnitSlot >= MAX_SLOTS) break;
            
            const unitKey = currentUnitSlot === 0 ? 'tweakunits' : `tweakunits${currentUnitSlot}`;
            partsCommands[currentUnitSlot].push(`!bset ${unitKey} "${chunk}"`);
            currentUnitSlot++;
        }
    }
     while (currentUnitSlot < MAX_SLOTS) {
         const unitKey = currentUnitSlot === 0 ? 'tweakunits' : `tweakunits${currentUnitSlot}`;
         partsCommands[currentUnitSlot].push(`!bset ${unitKey} 0`);
         currentUnitSlot++;
    }

    // Update UI
    for (let i = 0; i < MAX_PARTS; i++) {
        const area = outputAreas[i];
        const section = sectionDivs[i];
        
        if (area && section) {
            if (partsCommands[i].length > 0) {
                area.value = partsCommands[i].join('\n');
                section.style.display = 'grid';
            } else {
                area.value = '';
                section.style.display = 'none';
            }
        }
    }

    if (lobbyNameDisplay) lobbyNameDisplay.textContent = lobbyName;
}
