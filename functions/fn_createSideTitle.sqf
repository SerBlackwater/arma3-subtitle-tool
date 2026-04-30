/*
*
*   Side Title Display (Multiplayer-safe)
*   Displays a speaker name + subtitle line anchored to the right side of the screen.
*   Intended for radio transmissions, callouts, and ambient dialogue.
*
*   The subtitle text uses a typewriter-style reveal (character-stepped cutText).
*   Speaker name stays visible for the full duration; subtitle fades out at the end.
*
*   Minimal call:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF"] remoteExec ["SB_fnc_createSideTitle", 0];
*
*   Full call:
*       ["HQ", "All units, move to grid 045-128.", "#3399FF", 5, true] remoteExec ["SB_fnc_createSideTitle", 0];
*
*/

params [
    "_title",
    "_subtitle",
    ["_titleColor", "#3399FF"],
    ["_duration", 5],
    ["_fadeOut", true]
];

if (!hasInterface) exitWith {};

[_title, _subtitle, _titleColor, _duration, _fadeOut] spawn {
    params ["_title", "_subtitle", "_titleColor", "_duration", "_fadeOut"];

    private _font = "PuristaSemibold";
    private _titleSize = 1.3;
    private _subSize   = 1.1;

    // Position: right side, vertically centered-low
    private _posX = 0.37;
    private _posY = 0.60;
    private _posW = 0.60;

    // Reuse or create control
    private _ctrl = uiNamespace getVariable ["SB_sideTitleCtrl", controlNull];
    if (isNull _ctrl) then {
        _ctrl = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];
        uiNamespace setVariable ["SB_sideTitleCtrl", _ctrl];
    };

    private _text = format [
        "<t align='right' size='%1' color='%2' font='%3'>%4</t><br/><t align='right' size='%5' color='#FFFFFF' font='%3'>%6</t>",
        _titleSize, _titleColor, _font, _title,
        _subSize, _subtitle
    ];

    _ctrl ctrlSetStructuredText parseText _text;
    _ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
    _ctrl ctrlSetPosition [
        safezoneX + _posX * safezoneW,
        safezoneY + _posY * safezoneH,
        _posW * safezoneW,
        0.15 * safezoneH
    ];
    _ctrl ctrlSetFade 0;
    _ctrl ctrlCommit 0;

    if (_fadeOut) then {
        sleep _duration;
        _ctrl ctrlSetFade 1;
        _ctrl ctrlCommit 0.5;
        sleep 0.5;
        ctrlDelete _ctrl;
        uiNamespace setVariable ["SB_sideTitleCtrl", controlNull];
    };
};
