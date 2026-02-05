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
        label.className = 'checkbox-label';

        const input = document.createElement('input');
        input.type = 'checkbox';
        input.checked = opt.default;
        input.dataset.modOption = opt.modOption;
        input.addEventListener('change', onChange);

        label.appendChild(input);
        label.appendChild(document.createTextNode(opt.label));

        wrapper.appendChild(label);

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

    // Static Instructions / Base Commands if needed?
    // For now, just the dynamic Mega Nuke option
    simpleConfig.forEach(opt => {
        const checkbox = document.querySelector(`input[data-mod-option="${opt.modOption}"]`) as HTMLInputElement;
        if (checkbox && checkbox.checked) {
            commands.push(`!bset ${opt.modOption} 1`);
            lobbyName += " [MegaNuke]";
        } else {
             commands.push(`!bset ${opt.modOption} 0`);
        }
    });

    // Provide the Master Gadget load command or reminder?
    // User request: "replaced and the lua scripts are fully containing all mod/tweak units and scripts"
    // The output should likely just be the mod options.

    outputArea.value = commands.join('\n');
    if (lobbyNameDisplay) lobbyNameDisplay.textContent = lobbyName;

    if (part1Section) part1Section.style.display = 'grid';
}
