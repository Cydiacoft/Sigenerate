# Architecture Split (Core + Shell)

This repository is moving from a page-driven implementation to a data-driven
editor architecture.

Design Goals
- Keep Flutter as the desktop shell and UI layer only.
- Make assets, canvas model, and standards independent and reusable.
- Store standards as data, not hardcoded page logic.

Modules
1) core_assets
   - City manifests, category abilities, SVG metadata, palettes, tags.
2) core_canvas_model
   - Node types, layout rules, export rules, undo/redo command stack.
3) core_standards
   - GB 5768.2-2022 and metro guide standards as JSON.

UI Layer
- Flutter loads JSON from core modules.
- UI does not contain standard ratios or asset rules directly.
