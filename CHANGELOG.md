# Arma 3 Subtitle Tool — Changelog

All notable changes are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [0.2.1] — 2026-04-29

### Added
- **Output Format select** — choose between `fn_createSubtitle` (default) and `fn_createSideTitle` directly in the Style step
- **Text Alignment select** — configure subtitle text alignment (Center / Left / Right); applied to both the preview and all generated SQF structured text tags
- **SideTitle reimplemented** — selecting `fn_createSideTitle` applies a right-anchored, typewriter-style preview; generates `remoteExec ["SB_fnc_createSideTitle", 0]` calls
- **`fn_createSideTitle.sqf`** — new companion function; displays a speaker name and subtitle right-aligned on the right side of the screen with optional fade-out
- **Audioless timeline playback** — Play All now works with no audio file loaded; a timer-based engine paces through timeline entries and shows a live `0:00 / 0:00` counter

### Fixed
- **Drag coordinate accuracy** — `getSubtitlePosition()` and drag `mousemove` now account for the 1px preview frame border, so editor positions map accurately to in-game safezone coordinates
- **Duration auto-pacing for manual entries** — typing subtitle text into a timeline row now auto-calculates duration from character count using the Reading Speed (c/s) setting; manually editing the duration field locks it and prevents auto-override
- **Play All button** always visible regardless of whether an audio file is loaded

### Changed
- **"Manual" mode renamed to "Preview"** in the Subtitle step mode picker and toggle buttons

---

## [0.2.0-beta] — 2026-04-27

### UI Overhaul — Wizard Sidebar & Resizable Layout

#### Wizard-style workflow
- Sidebar now guides users through three sequential steps: **① Style → ② Subtitle → ③ Generate**
- Clickable step pills at the top show progress; completed steps display a ✓ checkmark
- Each step panel has **Next / Back** navigation buttons at the bottom
- Step 2 opens to a **mode picker** — two large cards (✏ Manual, 🎙 Transcribed) before revealing any fields
- After picking a mode, a compact **Manual / Transcribed** pill toggle stays visible to switch between them without returning to the picker

#### Subtitle step improvements
- **Manual mode**: Speaker/Title, Subtitle Text, Preview, Fade Out, and Copy SQF
- **Transcribed mode**: Speaker/Title input now present (previously missing), Audio File, Sound Class, Duration, Paste Transcript, Auto-Split & Pace, and AI Transcribe
- Speaker/Title input **syncs automatically** when switching between Manual and Transcribed tabs
- Auto-Split & Pace and AI Transcribe now apply the **Transcribed pane's Speaker/Title** to all generated timeline entries (falls back to Manual input if empty)
- Audio & Transcription section merged into the Subtitle step — no longer a separate collapsed section

#### Resizable tab panel
- Tab area has a **drag handle** at the top to resize the panel height
- Dragging up expands the timeline/code area over the preview; dragging down shrinks it
- Handle is a subtle three-line grip icon that glows accent blue on hover and drag
- Tab panel can expand to near-fullscreen, overlapping the preview frame
- Minimum height enforced at 150px; maximum capped to the available main area

#### Audio bar
- Audio playback controls relocated **inside the tabs wrapper**, directly below the tab buttons
- No longer floats between the preview and the tab area

#### Preview scaling
- Preview frame content (subtitle text, HUD overlays) now **scales with window size** using CSS container queries
- Compass, GPS panel, and squad bar slot widths converted from fixed `px` to `cqw` units
- Subtitle font size scales proportionally — what you see matches Arma proportions at any window width

#### Bug fixes
- Resize handle drag direction was inverted — fixed; dragging up now correctly expands the panel
- Resize handle cursor now tracks the mouse accurately (converted from inside-wrapper to true splitter architecture)

---

## [0.1.0-beta] — 2026-04-26

Initial public beta release.

### Added
- Live 16:9 preview frame with Arma 3 HUD overlay (compass, GPS, squad bar)
- Style presets: BLUFOR, OPFOR, INDFOR, Civilian, Unknown, Call of Duty, Wingman, Halo, Halo AI
- Custom preset save/delete/restore
- Drag-to-position and resize handle on subtitle display
- Timeline editor with per-entry title, subtitle, start time, and duration
- Speed indicators (characters-per-second) per entry with warning thresholds
- Audio file loading with auto-detected duration and manual override
- Character-weighted auto-split of transcript text into timed timeline entries
- CPS-paced split when no audio duration is available
- In-browser Whisper AI transcription via Transformers.js (no server required)
- **Batch transcription** — select multiple audio files; all transcribed sequentially
- **Generation History tab** — last 15 generates/copies/transcriptions stored in localStorage; click any entry to restore all settings and timeline
- Dual SQF generation modes: `remoteExec` function call and inline `cutText` spawn block
- `playSound` integration (MP-compatible `remoteExec ["playSound", 0]`)
- CfgSounds config auto-generator
- Function Call mode wraps multi-entry output in `[] spawn {}` for scheduled environment
- Inline layout support (COD/Halo-style speaker:text on one line with two-control split)
- Two-control SQF output for inline positioned mode (stable speaker anchoring)
- Project save/load to localStorage
- `fn_createSubtitle.sqf` — multiplayer-safe Arma 3 subtitle function
  - Supports stacked and inline layouts
  - Classic `cutText` fallback and positioned `ctrlCreate` mode
  - Two-control speaker/subtitle split for inline+positioned (prevents speaker shift)
