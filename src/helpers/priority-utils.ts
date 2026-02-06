// Shared priority rules for slot packing and execution ordering.

export const DEF_PRIORITY = {
    HP: 0,
    WAVES: 1,
    BUILDERS: 2,
    T2: 3,
    T3: 4,
    T4: 5,
    OTHER: 6
};

export const UNIT_PRIORITY = {
    T1: 1,
    T2: 2,
    T3: 3,
    T4: 4,
    OTHER: 5
};

function getSectionFile(section: any) {
    return section && typeof section.file === 'string' ? section.file : '';
}

export function getTierRankFromFile(filePath: string) {
    const file = typeof filePath === 'string' ? filePath : '';
    if (/(^|[_-])T1([_.-]|$)/i.test(file)) return UNIT_PRIORITY.T1;
    if (/(^|[_-])T2([_.-]|$)/i.test(file)) return UNIT_PRIORITY.T2;
    if (/(^|[_-])T3([_.-]|$)/i.test(file)) return UNIT_PRIORITY.T3;
    if (/(^|[_-])T4([_.-]|$)/i.test(file)) return UNIT_PRIORITY.T4;
    return 99;
}

export function isHpPrioritySection(section: any) {
    if (!section) {
        return false;
    }

    if (section.isHpMultiplier) {
        return true;
    }

    const marker = typeof section.marker === 'string' ? section.marker : '';
    const name = typeof section.name === 'string' ? section.name : '';
    const key = marker || name;

    return /^(HP|QHP|SCAV_HP|BOSS_HP)_/i.test(key);
}

function getDefsPriorityRank(section: any) {
    if (isHpPrioritySection(section)) {
        return DEF_PRIORITY.HP;
    }

    const file = getSectionFile(section);
    if (/Defs_Waves_/i.test(file)) {
        return DEF_PRIORITY.WAVES;
    }
    if (/Builders/i.test(file)) {
        return DEF_PRIORITY.BUILDERS;
    }
    if (/(^|[_-])T2([_.-]|$)/i.test(file)) {
        return DEF_PRIORITY.T2;
    }
    if (/(^|[_-])T3([_.-]|$)/i.test(file)) {
        return DEF_PRIORITY.T3;
    }
    if (/(^|[_-])T4([_.-]|$)/i.test(file)) {
        return DEF_PRIORITY.T4;
    }

    return DEF_PRIORITY.OTHER;
}

function getUnitsPriorityRank(section: any, tierRank: number) {
    const fileTier = typeof tierRank === 'number' ? tierRank : getTierRankFromFile(getSectionFile(section));
    if (fileTier >= UNIT_PRIORITY.T1 && fileTier <= UNIT_PRIORITY.T4) {
        return fileTier;
    }
    return UNIT_PRIORITY.OTHER;
}

export function getPriorityMeta(section: any, type: string) {
    const filePath = getSectionFile(section);
    const tierRank = getTierRankFromFile(filePath);
    const priorityRank = type === 'defs'
        ? getDefsPriorityRank(section)
        : getUnitsPriorityRank(section, tierRank);

    return {
        priorityRank,
        tierRank
    };
}

export function getDefaultPriority(type: string) {
    return type === 'defs' ? DEF_PRIORITY.OTHER : UNIT_PRIORITY.OTHER;
}

export function getDefaultTierRank() {
    return 99;
}

// Expose to window for legacy compatibility if needed
if (typeof window !== 'undefined') {
    (window as any).PriorityUtils = {
        DEF_PRIORITY,
        UNIT_PRIORITY,
        getPriorityMeta,
        getDefaultPriority,
        getDefaultTierRank,
        getTierRankFromFile,
        isHpPrioritySection
    };
}
