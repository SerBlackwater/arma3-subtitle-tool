/*
*
*   Side Title Display (Multiplayer-safe)
*   Displays a speaker name + subtitle line with a typewriter reveal using BIS_fnc_typeText.
*   Intended for radio transmissions, callouts, and ambient dialogue.
*
*   Minimal call:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF"] remoteExec ["SB_fnc_createSideTitle", 0];
*
*   Full call:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF", 5, true, 0.65, 0.85, "right-center", "right"] remoteExec ["SB_fnc_createSideTitle", 0];
*
*   Parameters:
*       0: STRING  - Speaker / title text
*       1: STRING  - Subtitle body text
*       2: STRING  - Title colour hex (default "#3399FF")
*       3: NUMBER  - Duration in seconds (default 5)
*       4: BOOL    - Fade out after duration (default true)
*       5: NUMBER  - posX normalized 0-1 (default 0)
*       6: NUMBER  - posY normalized 0-1 (default 0)
*       7: STRING  - Position preset key (default "custom")
*       8: STRING  - Text alignment "left|center|right" (default "right")
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
    ["_positionPreset", "custom"],
    ["_textAlign", "right"]
];

if (!hasInterface) exitWith {};

private _font = "PuristaSemibold";

private _align = toLower _textAlign;
if !(_align in ["left", "center", "right"]) then {
    _align = "right";
};

private _preset = toLower _positionPreset;
private _typePosX = 0;
private _typePosY = 0;
private _verticalOffset = -0.13;
private _edgeInset = 0.02;

switch (_preset) do {
    case "right-center": {
        _typePosX = (-safeZoneX) - _edgeInset;
        _typePosY = 0.5;
    };
    case "left-center": {
        _typePosX = _edgeInset;
        _typePosY = 0.5;
    };
    case "center-top": {
        _typePosX = 0;
        _typePosY = 0.2;
    };
    case "center-bottom": {
        _typePosX = 0;
        _typePosY = 0.85;
    };
    case "left-bottom": {
        _typePosX = _edgeInset;
        _typePosY = 0.85;
    };
    default {
        // Fallback for custom/legacy numeric coordinates.
        _typePosX = ((_posX max 0) min 1) * (-safeZoneX);
        _typePosY = (_posY max 0) min 1;
    };
};

_typePosY = (_typePosY + _verticalOffset) max 0;

// Keep title static via rootFormat and type only subtitle.
// Note: %%1 is required so SQF format outputs a literal %1 placeholder for BIS_fnc_typeText.
private _rootFormat = format ["<t align='%4' size='0.886' color='%1' font='%2'>%3</t><br/>%%1", _titleColor, _font, _title, _align];
private _subtitleFormat = format ["<t align='%2' size='0.732' color='#FFFFFF' font='%1'>%%1</t>", _font, _align];

// Syntax: [stringLines, posX, posY, rootFormat] spawn BIS_fnc_typeText
private _typingHandle = [
    [
        [_subtitle, _subtitleFormat, 5]
    ],
    _typePosX,
    _typePosY,
    _rootFormat
] spawn BIS_fnc_typeText;

if (_fadeOut) then {
    waitUntil {scriptDone _typingHandle};
    sleep _duration;
    0 cutText ["", "PLAIN", 0.5];
};
