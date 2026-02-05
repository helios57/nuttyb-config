import { ConfigOption, simpleConfig } from './simple-config';

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

export function updateSimpleOutput() {
    const outputArea = document.getElementById('command-output-1') as HTMLTextAreaElement;
    const lobbyNameDisplay = document.getElementById('lobby-name-display') as HTMLElement;
    const part1Section = document.getElementById('part-1-section') as HTMLElement;

    if (!outputArea) return;

    let commands: string[] = [];
    let lobbyName = "[Mod] NuttyB (Static)";

    simpleConfig.forEach(opt => {
        const input = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (input) {
            if (opt.type === 'checkbox') {
                commands.push(`!bset ${opt.modOption} ${input.checked ? 1 : 0}`);
            } else {
                commands.push(`!bset ${opt.modOption} ${input.value}`);
            }
        }
    });

    outputArea.value = commands.join('\n');
    if (lobbyNameDisplay) lobbyNameDisplay.textContent = lobbyName;

    if (part1Section) part1Section.style.display = 'grid';
}
