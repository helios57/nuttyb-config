declare module 'luamin' {
    export function minify(code: string): string;
    export const version: string;
}

declare module '*.lua' {
    const content: string;
    export default content;
}
