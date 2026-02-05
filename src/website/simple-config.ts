export interface ConfigOption {
    label: string;
    type: 'checkbox';
    default: boolean;
    modOption: string;
    description: string;
}

export const simpleConfig: ConfigOption[] = [
    {
        label: 'Mega Nuke',
        type: 'checkbox',
        default: false,
        modOption: 'meganuke',
        description: 'Enables the Mega Nuke weapon (Atomic Blast on high-tier fusion destruction).'
    }
];
