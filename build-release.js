const fs = require('fs');
const path = require('path');

const srcDir = __dirname;
const destDir = path.join(__dirname, 'release');

if (fs.existsSync(destDir)) {
    fs.rmSync(destDir, { recursive: true, force: true });
}
fs.mkdirSync(destDir);

const filesToCopy = [
    'index.html',
    'modes.txt',
    'luamin.js',
    'links.md'
];

filesToCopy.forEach(file => {
    const srcPath = path.join(srcDir, file);
    if (fs.existsSync(srcPath)) {
        fs.copyFileSync(srcPath, path.join(destDir, file));
        console.log(`Copied ${file}`);
    } else {
        console.warn(`Warning: ${file} not found`);
    }
});

// Copy dist
const distDir = path.join(destDir, 'dist');
if (!fs.existsSync(distDir)) fs.mkdirSync(distDir);
if (fs.existsSync(path.join(srcDir, 'dist', 'bundle.js'))) {
    fs.copyFileSync(path.join(srcDir, 'dist', 'bundle.js'), path.join(distDir, 'bundle.js'));
    console.log('Copied dist/bundle.js');
}

// Copy css
const cssSrc = path.join(srcDir, 'css');
const cssDest = path.join(destDir, 'css');
if (fs.existsSync(cssSrc)) {
    if (!fs.existsSync(cssDest)) fs.mkdirSync(cssDest);
    fs.readdirSync(cssSrc).forEach(file => {
        fs.copyFileSync(path.join(cssSrc, file), path.join(cssDest, file));
    });
    console.log('Copied css folder');
}

console.log('Release build created in ./release');
