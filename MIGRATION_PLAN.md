# Migration Plan (Phase 1)

Phase 1 Goals
- Scaffold core modules and seed baseline JSON files.
- Move "rules" data out of page code into core JSON.

Step 1: Assets Module
- Define city manifests for Shanghai, Guangzhou, and MTR.
- Add category capability specs for metro_line, metro_station, road_sign.
- Create shared palettes and tags registries.

Step 2: Standards Module
- Seed GB 5768.2-2022 layout/typography JSON.
- Seed metro guide JSON for Shanghai, Guangzhou, and MTR.

Step 3: Canvas Model Module
- Seed layout rules and export rules JSON.
- Prepare node/layout/history submodules.

Next Work (Phase 2)
- Connect Flutter to load these JSON files.
- Replace hardcoded ratios and templates with standard data.
- Introduce a shared asset registry reader.
