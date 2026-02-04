
const fs = require('fs');
const config = require('./master_config_normalized.json');

console.log("Total items:", config.length);
const names = config.map(c => c.name);
const counts = {};
names.forEach(n => counts[n] = (counts[n] || 0) + 1);

Object.entries(counts).forEach(([n, c]) => {
    if (c > 1) console.log("Duplicate:", n, c);
});
console.log("Done check.");
