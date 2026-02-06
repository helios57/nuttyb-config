// tests/utils.ts

/**
 * Decodes a Base64URL string to its original content.
 * Handles substitution of URL-safe characters back to standard Base64,
 * and adds padding if necessary.
 */
export function decodeBase64Url(str: string): string {
    // Replace URL-safe characters
    let base64 = str.replace(/-/g, '+').replace(/_/g, '/');

    // Add padding
    while (base64.length % 4) {
        base64 += '=';
    }

    // Decode Base64
    return Buffer.from(base64, 'base64').toString('utf-8');
}

/**
 * Extracts the payload from a !bset command string.
 * Example input: "!bset tweakdefs0 <payload>"
 * Returns: "<payload>"
 */
export function extractBsetPayload(command: string): string | null {
    const match = command.match(/^!bset\s+\w+\s+(.+)$/);
    return match ? match[1] : null;
}

/**
 * Parses a full command output block into a map of slot -> payload.
 */
export function parseCommandOutput(output: string): Map<string, string> {
    const map = new Map<string, string>();
    const lines = output.split('\n');
    for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('!bset')) {
            const parts = trimmed.split(/\s+/);
            if (parts.length >= 3) {
                const slotName = parts[1]; // e.g., tweakdefs0
                const payload = parts[2];
                map.set(slotName, payload);
            }
        }
    }
    return map;
}
