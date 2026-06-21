/*
*
*   Side Title Display (Multiplayer-safe)
*   Displays a speaker name with an adaptive typewriter subtitle reveal.
*   Typing speed auto-adjusts so the reveal fills the speech duration naturally —
*   faster than BIS_fnc_typeText's dramatic title cadence, timed for spoken dialogue.
*
*   Minimal:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF"] remoteExec ["SB_fnc_createSideTitle", 0];
*
*   Full:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF", 5, true, 0, 0, "right-center", "right", false, true] remoteExec ["SB_fnc_createSideTitle", 0];
*
*   Parameters:
*       0: STRING - Speaker name (displayed statically throughout)
*       1: STRING - Spoken line (revealed character by character)
*       2: STRING - Speaker name hex color (default: "#3399FF")
*       3: NUMBER - Total display time in seconds (default: 5)
*       4: BOOL   - Whether to fade out at the end (default: true)
*       5: NUMBER - Custom X position 0-1, only used when preset is "custom" (default: 0)
*       6: NUMBER - Custom Y position 0-1, only used when preset is "custom" (default: 0)
*       7: STRING - Position preset: "right-center" | "left-center" | "center-top" |
*                   "center-bottom" | "left-bottom" | "custom" (default: "right-center")
*       8: STRING - Text alignment: "left" | "center" | "right" (default: "right")
*       9: BOOL   - Play a click sound on each typed character (default: false)
*      10: BOOL   - Show a typing cursor while text is revealing (default: false)
*
*/

params [
    "_title",
    "_subtitle",
    ["_titleColor", "#3399FF"],
    ["_duration", 5],
    ["_fadeOut", true],
    ["_posX", 0],
    ["_posY", 0],
    ["_positionPreset", "right-center"],
    ["_textAlign", "right"],
    ["_playClicks", false],
    ["_showCursor", false]
];

if (!hasInterface) exitWith {};

private _font = "PuristaSemibold";

// Side titles are rendered CENTRE-justified and placed by their centre point. This is the
// only width-independent way to position BIS_fnc_dynamicText: centred text always lands at
// the control's centre regardless of the control's (unknown, monitor-dependent) width, so the
// line sits exactly where _typePosX puts it on any monitor. (_textAlign is kept for signature
// compatibility but no longer changes placement — it would re-introduce the width dependence.)
private _align = "center";

// --- Resolve screen position from preset ---
// _typePosX is the BIS_fnc_dynamicText X offset for the line's CENTRE: 0 = screen centre,
// positive = right, negative = left. safeZoneX is the (negative) left-edge offset, so
// |safeZoneX| is roughly a half-screen; _edgeInset pulls the left/right presets back in from
// the very edge so the line doesn't clip. _typePosY is the vertical placement (0 = top,
// 1 = bottom); values are deliberately low for "bottom" presets so the line sits near the floor.
private _typePosX = 0;
private _typePosY = 0;
private _edgeInset = 0.13;

switch (toLower _positionPreset) do {
    case "right-center":  { _typePosX = (-safeZoneX) - _edgeInset; _typePosY = 0.46; };
    case "left-center":   { _typePosX = safeZoneX + _edgeInset;     _typePosY = 0.46; };
    case "center-top":    { _typePosX = 0;                          _typePosY = 0.12; };
    case "center-bottom": { _typePosX = 0;                          _typePosY = 0.82; };
    case "left-bottom":   { _typePosX = safeZoneX + _edgeInset;     _typePosY = 0.82; };
    default {
        // Custom: HTML sends a 0-1 screen-fraction anchor as _posX (0 = left, 0.5 = centre,
        // 1 = right) for where the line's centre should sit. Map it to the same centre-offset
        // model the presets use:  BIS_X = (-safeZoneX) * (2*anchorX - 1).
        private _anchorX = (_posX max 0) min 1;
        _typePosX = (-safeZoneX) * ((2 * _anchorX) - 1);
        _typePosY = _posY min 1;
    };
};

[_title, _subtitle, _titleColor, _duration, _fadeOut, _typePosX, _typePosY, _font, _align, _playClicks, _showCursor] spawn {
    params ["_title", "_subtitle", "_titleColor", "_duration", "_fadeOut", "_typePosX", "_typePosY", "_font", "_align", "_playClicks", "_showCursor"];

    // Queue side titles per-client to prevent overlap between consecutive lines.
    // Timeout after 15s in case a previous call crashed without releasing the lock.
    private _lockWait = 0;
    while {(uiNamespace getVariable ["SB_sideTitleBusy", false]) && (_lockWait < 15)} do {
        sleep 0.1;
        _lockWait = _lockWait + 0.1;
    };
    uiNamespace setVariable ["SB_sideTitleBusy", true];

    // Clear any residual text from a previous entry before starting this one.
    ["", _typePosX, _typePosY, 0, 0, 0, 90] spawn BIS_fnc_dynamicText;

    private _titleColorBase = toUpper _titleColor;
    if ((_titleColorBase select [0, 1]) == "#") then { _titleColorBase = _titleColorBase select [1]; };
    if ((count (toArray _titleColorBase)) >= 6) then {
        _titleColorBase = _titleColorBase select [0, 6];
    } else {
        _titleColorBase = "3399FF";
    };

    // Convert subtitle to array of single-char strings for iteration
    private _chars = toArray _subtitle;
    { _chars set [_forEachIndex, toString [_x]] } forEach _chars;
    private _charCount = count _chars;

    // Adaptive timing:
    //   - Typing reveals ~70% of total duration; the remaining ~30% is a static hold.
    //   - Per-char delay is clamped to [0.025s, 0.12s]:
    //       0.025s = 40 CPS (fast speech / short subtitle)
    //       0.12s  =  8 CPS (slow speech — near BIS_fnc_typeText natural pace)
    private _charDelay = 0.05;
    private _holdTime  = _duration;
    if (_charCount > 0) then {
        _charDelay = ((_duration * 0.7) / _charCount) max 0.025 min 0.12;
        _holdTime  = (_duration - (_charCount * _charDelay)) max 0.5;
    };

    // Pre-build static fragments to avoid repeated format calls inside the loop
    private _titleLine = format ["<t align='%1' size='0.886' color='%2' font='%3'>%4</t><br/>", _align, _titleColor, _font, _title];
    private _subOpen   = format ["<t align='%1' size='0.732' color='#FFFFFF' font='%2'>", _align, _font];

    // Show title immediately; subtitle starts empty
    [_titleLine + _subOpen + "</t>", _typePosX, _typePosY, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;

    // Reveal subtitle one character at a time
    private _typed = "";
    private _cursorVisible = "_";
    private _cursorHidden = "<t color='#00FFFFFF'>_</t>";
    private _halfDelay = (_charDelay / 2) max 0.01;
    {
        _typed = _typed + _x;
        if (_playClicks) then { playSound "ReadoutClick"; };
        if (_showCursor) then {
            [_titleLine + _subOpen + _typed + _cursorVisible + "</t>", _typePosX, _typePosY, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
            sleep _halfDelay;
            [_titleLine + _subOpen + _typed + _cursorHidden + "</t>", _typePosX, _typePosY, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
            sleep _halfDelay;
        } else {
            [_titleLine + _subOpen + _typed + "</t>", _typePosX, _typePosY, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
            sleep _charDelay;
        };
    } forEach _chars;

    // Hold the complete text for the remainder of the duration.
    private _finalText = _titleLine + _subOpen + _subtitle + "</t>";
    if (_fadeOut) then {
        [_finalText, _typePosX, _typePosY, _holdTime, 0, 0, 90] spawn BIS_fnc_dynamicText;
        sleep _holdTime;

        // Fade in-place by stepping alpha down while redrawing at the same coordinates.
        private _alphaSteps = ["CC", "99", "66", "44", "22", "00"];
        {
            private _titleFadeColor = "#" + _x + _titleColorBase;
            private _subFadeColor = "#" + _x + "FFFFFF";
            private _fadeText = format [
                "<t align='%1' size='0.886' color='%2' font='%3'>%4</t><br/><t align='%1' size='0.732' color='%5' font='%3'>%6</t>",
                _align, _titleFadeColor, _font, _title, _subFadeColor, _subtitle
            ];
            [_fadeText, _typePosX, _typePosY, 0.12, 0, 0, 90] spawn BIS_fnc_dynamicText;
            sleep 0.08;
        } forEach _alphaSteps;

        ["", _typePosX, _typePosY, 0, 0, 0, 90] spawn BIS_fnc_dynamicText;
    } else {
        [_finalText, _typePosX, _typePosY, _holdTime, 0, 0, 90] spawn BIS_fnc_dynamicText;
        sleep _holdTime;
    };

    uiNamespace setVariable ["SB_sideTitleBusy", false];
};
