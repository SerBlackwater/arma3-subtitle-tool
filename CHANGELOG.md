# Arma 3 Subtitle Tool — Changelog

All notable changes are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
