// src/slot-packer/index.ts

import { packIntoSlots } from './packing';
import { getSlotSummary } from './sizing';

export * from './dependencies';
export * from './sizing';
export * from './packing';

// Expose to window for legacy compatibility if needed
if (typeof window !== 'undefined') {
    (window as any).packIntoSlots = packIntoSlots;
    (window as any).getSlotSummary = getSlotSummary;
    if (typeof window.dispatchEvent === 'function') {
        window.dispatchEvent(new Event('slotPackerReady'));
    }
}
