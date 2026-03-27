# Work Log

## Project

- Name: `Sigenerator`
- Path: `D:\road_creator`
- Stack: Flutter Windows desktop

## 2026-03-26

### Metro Guide Refactor

- Reworked the metro guide editor toward the `vi-tool` style asset + canvas workflow.
- Added project save/open/save-as handling for the metro guide editor.
- Introduced custom metro assets into project persistence.
- Added local SVG import support for metro custom assets.
- Added custom metro line creation and editing flow.

### Road Editor Progress

- Switched the road-side material library toward SVG-first rendering.
- Expanded the road sign asset set and aligned it with the ongoing GB 5768 workflow.
- Reworked road sign layout proportions to feel closer to real directional signs.

### Analysis

- Local static analysis reached green state during the refactor stage.

## 2026-03-27

### Metro Asset Audit and Alignment

- Audited the Shanghai, Guangzhou, and MTR metro asset folders against the current model layer.
- Confirmed that Guangzhou and MTR use dedicated local city asset sets instead of Shanghai file reuse.
- Aligned Shanghai model coverage with the current local asset range `line@01-31`.
- Synced local SVG colors back into `MetroLineInfo` for Shanghai, Guangzhou, and MTR.
- Removed Guangzhou placeholder lines `18 / 21 / 22` from the model until matching local SVG exists.
- Added `mtr11.svg` into the MTR model as `High Speed Rail`.

### Metro Rendering Fixes

- Fixed city-aware SVG loading so canvas items no longer try to resolve non-Shanghai assets from the Shanghai root.
- Changed SVG cache behavior to key by resolved asset path instead of file name only.
- Fixed toolbar item type assignment for non-`line@xx` city assets such as `gz*.svg` and `mtr*.svg`.
- Moved custom metro line rendering closer to the built-in asset style by using generated SVG instead of plain container placeholders.
- Reconnected the top city button into a real city selector so Shanghai / Guangzhou / MTR / JR now switch the active material set and background together.
- Rewired the metro guide editor to pass city context into both the toolbar and canvas render path.
- Unified local SVG import into the shared custom-material flow for both `clss` and `oth`.
- Fixed the city-scoped asset resolver so shared root categories such as `way / stn / oth / sub / cls` no longer spin forever by looking in the wrong city folder.
- Switched the built-in material library to a city-native capability model so non-Shanghai cities only expose categories that truly have local asset coverage.
- Added coverage visibility in the top toolbar so the current city's native built-in coverage is explicit instead of implicit.
- Extended local SVG import support so missing native-city categories can be supplemented with real local files instead of waiting on hardcoded packs.

### JR Starter Library

- Added a new selectable city/style option: `JR East`.
- Added starter JR-style metro assets:
  - `jr01.svg`
  - `jr02.svg`
  - `jr03.svg`
  - `jr04.svg`
  - `jr05.svg`
  - `jr06.svg`
  - `jr07.svg`
  - `jr08.svg`
- Added matching JR model entries and guide-material mapping.
- Added JR-aware SVG city inference for the asset loader.

### Documentation

- Added `docs/metro_asset_audit.md` to track:
  - current city asset coverage
  - color extraction results
  - known model/asset gaps
  - next actions
- Rewrote `WORK_PLAN.md` into a clean executable task board.
- Rewrote `WORK_LOG.md` into a clean UTF-8 log.

### Verification

- `flutter analyze --no-pub`
- Result: `No issues found!`

### Remaining Follow-up

- Guangzhou / MTR / JR still need real local SVG packs for `way / stn / oth / sub / cls` if they are meant to reach full native coverage.
- Guangzhou special lines `GF` / `APM` still need a richer metadata model if they are meant to be first-class line entries.
- MTR filename-to-line-name mapping still needs a stronger source manifest if full confidence is required.
- JR is currently a starter library, not yet a full network pack.

### Road Editor Refactor

- Replaced the old four-direction preview workflow with a single editable road board canvas.
- Added direct in-place text editing by double-clicking text nodes on the board.
- Added editable white-box templates and scenic bordered templates that can hold text directly.
- Added replaceable center graphic nodes for crossroad, T junction, roundabout, Y junction, and skewed intersections.
- Introduced slot-based board layout so the reference nine-area sign composition can be snapped back into place.
- Added template-rule snapping that restores slot position, width, height, font size, white-box behavior, and scenic border behavior together.
- Moved the road board layout spec into a dedicated data model file:
  - `lib/models/road_board_template.dart`
- Added a dedicated road board document model:
  - `lib/models/road_board_document.dart`
- Added direct board export actions from the new editor toolbar:
  - save current board state as JSON
  - export current board canvas as PNG
- Wrapped the new editable board canvas in a dedicated capture boundary so exports follow the same single-board source of truth.
- Reframed the road editor back into a generator-style workflow closer to the original reference page instead of a pure freeform board designer.
- Added a top-down generator layout:
  - format settings
  - intersection name section
  - four-direction data matrix
  - visual editing workspace
  - generated multi-direction previews
- Moved road-name editing onto the board itself so the key text fields can be edited visually instead of only through table inputs.
- Kept white and scenic plates as draggable board elements, and added true plate fill support so scenic plates can use a brown fill instead of only a border simulation.
- Changed the road board baseline back to a horizontal guide-board aspect ratio and constrained drag movement to stay inside the board.
- Rebuilt the road editor page into a clean UTF-8 Chinese interface after the previous page text became corrupted by encoding issues.
- Kept the generator-style workflow while restoring direct visual editing of road-name content on the board.
- Refined the horizontal road-board template again toward a GB-style guide sign proportion:
  - larger horizontal board ratio
  - tighter outer margins
  - more balanced top / side / bottom slot sizes
  - larger central intersection graphic area
- Added a more sign-like board render treatment:
  - outer and inner double white borders
  - tighter internal safety margin
  - flatter guide-sign corner radius
  - more restrained center-line stroke weight
- Tightened the default white and scenic sub-plate sizes so newly added plates behave more like attached guide-sign information plates instead of generic cards.
- Localized the in-canvas editing affordances in the road board widget, including edit hints and action buttons.
- Restyled the road editor layout closer to the metro editor structure with a dark three-panel workspace instead of the earlier flat generator page.
- Added Word-like horizontal text alignment options for road-board text elements:
  - align left
  - center
  - align right
- Enlarged the draggable hit area around road-board elements so text and sub-plates are much easier to grab and move.
- Added resizable left and right side panels in the road editor so the canvas no longer gets squeezed by fixed sidebars.
- Added a dedicated canvas zoom slider for the road board preview area so wide signs can be inspected without changing window size.
- Fixed drag-follow behavior under canvas zoom by scaling pointer movement back into board coordinates.
- Restored free board-viewport movement in the central workspace so the entire sign can be panned inside the editor instead of only being scaled.
- Corrected the road-board baseline aspect ratio back toward the reference crossroad sign layout after the previous template pass became too tall.
- Added road-project file actions in the toolbar:
  - new project
  - open project
  - save project
  - save project as
- Extended the road board document model to persist the full editor state:
  - scene colors and intersection shape
  - four-direction source data
  - active direction
  - junction transliteration
  - all board nodes by direction
- Added desktop keyboard shortcuts for road-board elements:
  - `Ctrl+C`
  - `Ctrl+V`
  - `Ctrl+D`
  - `Delete`
- Added a right-click canvas context menu for road-board elements with copy, paste, duplicate, layer order, text alignment, and delete actions.
- Restored visible Chinese labels across the main road-editor toolbar, side panels, selection panel, and in-canvas edit dialog where mojibake had leaked in.
- Added a quick `重置视图` action for the road-board workspace so panned canvases can snap back to a predictable working position.
- Kept the project at a fully green analyzer state after the road editor refactor.
