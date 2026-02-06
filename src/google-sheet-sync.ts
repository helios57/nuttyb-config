// google-sheet-sync.ts
// Handles optional exporting of slot metadata to a Google Sheet via Apps Script

const DEFAULT_CONFIG = {
    enabled: false,
    autoSync: false,
    webAppUrl: '',
    sheetId: '',
    sheetName: 'SlotLog',
    includeSlotCommands: false,
    preventDuplicateUploads: true
};

let sheetConfig = { ...DEFAULT_CONFIG };

// Lean stub: disable sheet sync entirely to avoid fetches/404s.
export async function loadConfig() {
    sheetConfig = { ...DEFAULT_CONFIG };
    if (typeof window !== 'undefined') {
        (window as any).googleSheetSyncConfig = sheetConfig;
    }
    return sheetConfig;
}

export function getConfig() {
    return sheetConfig;
}

export function shouldAutoSync() {
    return false;
}

export async function recordSlots() {
    // No-op; sheet sync removed.
    return { success: false, skipped: 'disabled' };
}

// Attach to window for legacy compatibility if needed
if (typeof window !== 'undefined') {
    (window as any).GoogleSheetSync = {
        loadConfig,
        getConfig,
        recordSlots,
        shouldAutoSync
    };
}
