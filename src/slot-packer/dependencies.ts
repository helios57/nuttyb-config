// src/slot-packer/dependencies.ts

import { getPriorityMeta, getDefaultPriority, getDefaultTierRank } from '../helpers/priority-utils';

export function assignPriorityMetadata(sections: any[], dependencyMap: any, type: string) {
    const sectionByName = new Map();

    sections.forEach(section => {
        if (section && section.name) {
            sectionByName.set(section.name, section);
        }
    });

    sections.forEach(section => {
        const meta = getPriorityMeta(section, type) || {};
        const basePriority = typeof meta.priorityRank === 'number'
            ? meta.priorityRank
            : getDefaultPriority(type);
        const tierRank = typeof meta.tierRank === 'number'
            ? meta.tierRank
            : getDefaultTierRank();

        section.basePriorityRank = basePriority;
        section.tierRank = tierRank;
    });

    const memo: any = {};
    const visiting = new Set();
    const resolvePriority = (name: string): number => {
        if (memo[name] !== undefined) {
            return memo[name];
        }

        const section = sectionByName.get(name);
        const basePriority = section && typeof section.basePriorityRank === 'number'
            ? section.basePriorityRank
            : getDefaultPriority(type);

        if (visiting.has(name)) {
            return basePriority;
        }

        visiting.add(name);
        let effectivePriority = basePriority;

        const deps = dependencyMap && Array.isArray(dependencyMap[name]) ? dependencyMap[name] : [];
        deps.forEach((dep: string) => {
            if (!sectionByName.has(dep)) {
                return;
            }
            effectivePriority = Math.max(effectivePriority, resolvePriority(dep));
        });

        visiting.delete(name);
        memo[name] = effectivePriority;
        return effectivePriority;
    };

    sections.forEach(section => {
        if (!section || !section.name) {
            return;
        }
        section.priorityRank = resolvePriority(section.name);
    });
}

/**
 * Build dependency map + levels + topo order in one pass (leaner than separate steps)
 * @param {Array} sections - Sections being packed
 * @param {Object} allTweaks - Tweaks metadata
 * @returns {Object} { dependencyMap, sectionLevels, orderedSections }
 */
export function buildDependencyData(sections: any[], allTweaks: any) {
    const dependencyMap = buildDependencyMap(allTweaks);
    const { levels: sectionLevels, orderedSections } = computeTopologicalLevels(sections, dependencyMap);
    return { dependencyMap, sectionLevels, orderedSections };
}

/**
 * Topological ordering with level calculation (Kahn) to avoid recursive walkers
 * @param {Array} sections - Sections being packed
 * @param {Object} dependencyMap - Map of dependencies
 * @returns {Object} { levels, orderedSections }
 */
export function computeTopologicalLevels(sections: any[], dependencyMap: any) {
    const levels: any = {};
    const indegree: any = {};
    const graph: any = {};
    const sectionNames = new Set(sections.map(s => s.name));

    // Initialize nodes from sections
    sectionNames.forEach(name => {
        indegree[name] = indegree[name] || 0;
        graph[name] = graph[name] || [];
    });

    // Build graph edges dep -> section
    for (const [name, deps] of Object.entries(dependencyMap) as any) {
        if (!graph[name]) {
            graph[name] = [];
        }
        deps.forEach((dep: string) => {
            if (!graph[dep]) {
                graph[dep] = [];
            }
            indegree[name] = (indegree[name] || 0) + 1;
            graph[dep].push(name);
            if (indegree[dep] === undefined) {
                indegree[dep] = 0;
            }
        });
    }

    // Queue nodes with indegree 0
    const queue = Object.keys(graph).filter(node => indegree[node] === 0).sort();
    queue.forEach(node => {
        levels[node] = 0;
    });

    const ordered: string[] = [];

    while (queue.length) {
        const node = queue.shift()!;
        ordered.push(node);
        const neighbors = graph[node] || [];
        neighbors.forEach((n: string) => {
            indegree[n] -= 1;
            const candidateLevel = (levels[node] || 0) + 1;
            if (candidateLevel > (levels[n] || 0)) {
                levels[n] = candidateLevel;
            }
            if (indegree[n] === 0) {
                queue.push(n);
            }
        });
    }

    // Handle cycles by logging and assigning level 0
    Object.entries(indegree).forEach(([node, deg]: [string, any]) => {
        if (deg > 0) {
            console.warn(`Circular dependency detected involving ${node}`);
            if (levels[node] === undefined) {
                levels[node] = 0;
            }
            ordered.push(node);
        }
    });

    // Filter ordered names to the sections we actually pack
    const orderedSections = ordered.filter(name => sectionNames.has(name));

    // Ensure every section has a level
    sectionNames.forEach(name => {
        if (levels[name] === undefined) {
            levels[name] = 0;
        }
    });

    return { levels, orderedSections };
}

/**
 * Build a map of section name -> dependencies from tweak metadata
 * @param {Object} allTweaks - Tweaks configuration object
 * @returns {Object} Map of { sectionName: [dependencies] }
 */
export function buildDependencyMap(allTweaks: any) {
    const depMap: any = {};

    if (allTweaks && allTweaks.dependencyMap && typeof allTweaks.dependencyMap === 'object') {
        return allTweaks.dependencyMap;
    }

    if (allTweaks && allTweaks.deps && typeof allTweaks.deps === 'object') {
        return allTweaks.deps;
    }

    if (!allTweaks || !allTweaks.dynamic_tweaks) {
        return depMap;
    }

    const addDependencies = (sectionName: string, deps: string[]) => {
        if (!sectionName || !Array.isArray(deps) || deps.length === 0) {
            return;
        }
        depMap[sectionName] = Array.from(new Set(deps));
    };

    const markerToSectionName = (markers: any) => {
        if (!markers || typeof markers.start !== 'string') return null;
        const m = markers.start.match(/--\s*(\w+)_START/);
        return m && m[1] ? m[1] : null;
    };

    for (const [name, tweak] of Object.entries(allTweaks.dynamic_tweaks) as any) {
        if (!tweak) continue;

        const deps = Array.isArray(tweak.dependencies) ? [...tweak.dependencies] : [];

        // Ensure builders sit immediately after main defs by default
        if (name === 'T3_BUILDERS' && !deps.includes('MAIN_DEFS')) {
            deps.unshift('MAIN_DEFS');
        }

        addDependencies(name, deps);

        const options = Array.isArray(tweak.options) ? tweak.options : [];
        const dropdownOptions = Array.isArray(tweak.dropdown_options) ? tweak.dropdown_options : [];
        const allOptions = options.concat(dropdownOptions);

        allOptions.forEach((option: any) => {
            const sectionName = markerToSectionName(option?.markers);
            if (sectionName) {
                addDependencies(sectionName, deps);
            }
        });
    }

    return depMap;
}

/**
 * Validate all dependency constraints were satisfied
 * @param {Array} slots - Packed slots
 * @param {Object} slotAssignments - Map of section name -> slot number
 * @param {Object} dependencyMap - Map of dependencies
 */
export function validateDependencyConstraints(slots: any[], slotAssignments: any, dependencyMap: any) {
    let violations = 0;

    for (const [section, deps] of Object.entries(dependencyMap) as any) {
        const sectionSlot = slotAssignments[section];
        if (!sectionSlot) continue; // Section not included

        for (const dep of deps) {
            const depSlot = slotAssignments[dep];
            if (!depSlot) {
                console.warn(`Dependency warning: ${section} depends on ${dep}, but ${dep} is not included`);
                violations++;
            } else if (depSlot > sectionSlot) {
                console.error(`Dependency violation: ${section} (slot ${sectionSlot}) depends on ${dep} (slot ${depSlot})`);
                violations++;
            }
        }
    }

    if (violations > 0) {
        console.warn(`Total dependency violations: ${violations}`);
    }
}
