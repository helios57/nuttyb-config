# NuttyB Configurator

A web-based configuration tool for Beyond All Reason (BAR) game settings, specifically designed for the NuttyB modpack. This tool allows users to customize game modes, multipliers, and enable/disable various tweaks and units.

## Features

*   **Game Mode Selection:** Choose between Raptors and Scavengers modes.
*   **Multiplier Configuration:** Adjust resource income, shield power, build range, and build power.
*   **Raptor/Scavenger Settings:** Customize health multipliers, queen count, and wave difficulty.
*   **Dynamic Tweaks:** Enable/disable specific tweaks and units (e.g., T3 Eco, T4 Defenses, Epic Units).
*   **Slot Packing:** Automatically packs selected tweaks into available game slots to work around engine limitations.
*   **Custom Tweaks:** Add your own custom Lua or Base64 encoded tweaks.
*   **Command Generation:** Generates the necessary `!bset` commands to apply your configuration in-game.

## Available Tweaks

The following tweaks are available and can be configured via the "Configuration" tab:

### Core
*   **Main Gameplay Tweaks:** Core gameplay adjustments and improvements.

### Commanders
*   **NuttyB Evolving Commanders:** Enables evolving commanders for Armada, Cortex, and Legion factions.
*   **Evo XP Inheritance:** Allows evolving commanders to inherit XP.

### Units
*   **Cross Faction T2:** Enables T2 units from other factions (with a tax).
*   **Mini Bosses:** Adds mini-boss units to waves.
*   **T4 Epics:** Adds massive epic units like Ragnarok, Calamity, Starfall, Bastion, Sentinel, and Fortress.

### Economy
*   **T3 Economy Buildings:** Adds Tier 3 economy structures.
*   **T4 Economy Buildings:** Adds Tier 4 economy structures (safe, non-explosive).

### Defenses
*   **T4 Defense Structures:** Adds experimental Tier 4 defensive buildings (Pulsar, Bulwark, Bastion).

### Weapons
*   **Mega Nuke:** Adds enhanced nuclear weapons.

### Air
*   **T4 Air:** Reworks Tier 4 aircraft.

### Builders
*   **T3 Builder Units:** Adds Tier 3 construction units.

### Balance
*   **T2 LRPC v2:** Rebalances Long Range Plasma Cannons.

### Raptors
*   **Experimental Wave Challenge:** Custom raptor squad configurations for wave challenges.

### Structures
*   **Unit Launchers:** Adds buildings that launch units.

## Development

### Project Structure

The project is structured as a static web application with modular JavaScript files.

```
nuttyb-config/
|-- index.html              # Main entry point
|-- css/                    # Stylesheets
|   |-- base.css            # Base styles and variables
|   |-- layout.css          # Layout structure
|   `-- styles.css          # Component styles
|-- js/                     # JavaScript modules
|   |-- main.js             # Main application logic
|   |-- command-builder.js  # Command generation logic
|   |-- config-loader.js    # Configuration file loader
|   |-- custom-tweaks.js    # Custom tweak management
|   |-- event-handlers.js   # UI event handlers
|   |-- lua-minifier.js     # Lua minification utility
|   |-- metadata.js         # Metadata handling
|   |-- multiplier-handler.js # Game multiplier logic
|   |-- output-manager.js   # Output display management
|   |-- slot-packer.js      # Slot packing algorithm
|   |-- slot-scanner.js     # Tweak file scanner
|   |-- ui-generator.js     # Dynamic UI generation
|   |-- ui-renderer.js      # UI rendering logic
|   `-- utils.js            # Utility functions
|-- partials/               # HTML partials for tabs
|-- tweaks/                 # Lua tweak files
`-- ...
```

### Building and Deploying

This project is designed to be hosted on GitHub Pages. No complex build step is required as it uses native ES modules (mostly) and standard web technologies.

To deploy to GitHub Pages:

1.  Push changes to the `main` branch.
2.  Ensure GitHub Pages is enabled in the repository settings, pointing to the root directory.

### Local Development

To run the project locally:

1.  Clone the repository.
2.  Run a local web server in the root directory. For example, using Python:
    ```bash
    python -m http.server 8080
    ```
3.  Open `http://localhost:8080` in your browser.

## Credits

*   **NuttyB:** Original modpack creator.
*   **Pyrem:** Configurator development.
*   **Community:** Various tweak authors and contributors.
