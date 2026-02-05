export interface ConfigOption {
    label: string;
    type: 'checkbox';
    default: boolean;
    modOption: string;
    description: string;
}

export const simpleConfig: ConfigOption[] = [];
