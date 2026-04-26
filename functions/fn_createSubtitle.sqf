/*
*
*   Subtitle Broadcast (Multiplayer-safe)
*   Default Colors:
*   #3399FF = Blue Title
*   #FFFFFF = White Subtitle
*
*   Uses a fixed layer ID ("SB_subtitle") so consecutive calls from the same
*   speaker seamlessly replace subtitle text without flickering the title.
*   Set _fadeOut to false when chaining lines from the same speaker,
*   then true (or omit) on the final line to fade out.
*
*   Optional: _titleSize (default 2.2), _subtitleSize (default 1.8),
*   _font (default "PuristaSemibold") can be passed as params 7-9.
*
*   Position: _posX, _posY, _posW (params 10-12) control screen placement
*   as normalized 0-1 fractions of the safezone. When _posX is -1 (default),
*   the classic cutText center-bottom layout is used. When a position is set,
*   a dynamically created RscStructuredText control is used instead.
*
*   Layout: _layout (param 13) controls text arrangement:
*   "stacked" (default) — title on top, subtitle below
*   "inline" — "Speaker: text" on the same line with colon separator
*
*/

params [
    "_title",
    "_subtitle",
    "_length",
    ["_titleColor", "#3399FF"],
    ["_subtitleColor", "#FFFFFF"],
    ["_fadeOut", true],
    ["_titleSize", 2.2],
    ["_subtitleSize", 1.8],
    ["_font", "PuristaSemibold"],
    ["_posX", -1],
    ["_posY", -1],
    ["_posW", 0.8],
    ["_layout", "stacked", [""]]
];

if (!hasInterface) exitWith {};

// Build format string based on layout
private _fmtStacked = "<t align='center' size='%5' color='%3' font='%7'>%1</t><br/><t align='center' size='%6' color='%4' font='%7'>%2</t>";
private _fmtInline = "<t align='left' size='%5' color='%3' font='%7'>%1:  </t><t align='left' size='%6' color='%4' font='%7'>%2</t>";
private _fmt = if (_layout == "inline") then { _fmtInline } else { _fmtStacked };

// Positioned mode — inline layout with split controls for stable speaker anchoring
// Uses two side-by-side controls: speaker (right-aligned) | subtitle (left-aligned)
// so the speaker never shifts when the subtitle text changes.
if (_posX != -1 && _layout == "inline") exitWith {
    [_title, _subtitle, _length, _titleColor, _subtitleColor, _fadeOut, _titleSize, _subtitleSize, _font, _posX, _posY, _posW] spawn {
        params ["_title", "_subtitle", "_length", "_titleColor", "_subtitleColor", "_fadeOut", "_titleSize", "_subtitleSize", "_font", "_posX", "_posY", "_posW"];

        private _splitRatio = 0.45;
        private _speakerW = _posW * _splitRatio;
        private _subW = _posW * (1 - _splitRatio);

        private _speakerText = format [
            "<t align='right' size='%1' color='%2' font='%3'>%4:  </t>",
            _titleSize, _titleColor, _font, _title
        ];
        private _subtitleText = format [
            "<t align='left' size='%1' color='%2' font='%3'>%4</t>",
            _subtitleSize, _subtitleColor, _font, _subtitle
        ];

        // Reuse or create speaker control
        private _speakerCtrl = uiNamespace getVariable ["SB_subtitleSpeakerCtrl", controlNull];
        if (isNull _speakerCtrl) then {
            _speakerCtrl = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];
            uiNamespace setVariable ["SB_subtitleSpeakerCtrl", _speakerCtrl];
        };

        // Reuse or create subtitle control
        private _subCtrl = uiNamespace getVariable ["SB_subtitleTextCtrl", controlNull];
        if (isNull _subCtrl) then {
            _subCtrl = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];
            uiNamespace setVariable ["SB_subtitleTextCtrl", _subCtrl];
        };

        _speakerCtrl ctrlSetStructuredText parseText _speakerText;
        _speakerCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
        _speakerCtrl ctrlSetFade 0;
        _speakerCtrl ctrlSetPosition [
            safezoneX + _posX * safezoneW,
            safezoneY + _posY * safezoneH,
            _speakerW * safezoneW,
            0.15 * safezoneH
        ];
        _speakerCtrl ctrlCommit 0;

        _subCtrl ctrlSetStructuredText parseText _subtitleText;
        _subCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
        _subCtrl ctrlSetFade 0;
        _subCtrl ctrlSetPosition [
            safezoneX + (_posX + _speakerW) * safezoneW,
            safezoneY + _posY * safezoneH,
            _subW * safezoneW,
            0.15 * safezoneH
        ];
        _subCtrl ctrlCommit 0;

        sleep _length;

        if (_fadeOut) then {
            _speakerCtrl ctrlSetFade 1;
            _subCtrl ctrlSetFade 1;
            _speakerCtrl ctrlCommit 0.5;
            _subCtrl ctrlCommit 0.5;
            sleep 0.5;
            ctrlDelete _speakerCtrl;
            ctrlDelete _subCtrl;
            uiNamespace setVariable ["SB_subtitleSpeakerCtrl", controlNull];
            uiNamespace setVariable ["SB_subtitleTextCtrl", controlNull];
        };
    };
};

// Positioned mode — uses ctrlCreate for arbitrary screen placement
if (_posX != -1) exitWith {
    [_title, _subtitle, _length, _titleColor, _subtitleColor, _fadeOut, _titleSize, _subtitleSize, _font, _posX, _posY, _posW, _fmt] spawn {
        params ["_title", "_subtitle", "_length", "_titleColor", "_subtitleColor", "_fadeOut", "_titleSize", "_subtitleSize", "_font", "_posX", "_posY", "_posW", "_fmt"];

        private _formattedText = format [
            _fmt,
            _title, _subtitle, _titleColor, _subtitleColor, _titleSize, _subtitleSize, _font
        ];

        // Reuse or create subtitle control
        private _ctrl = uiNamespace getVariable ["SB_subtitleCtrl", controlNull];
        if (isNull _ctrl) then {
            _ctrl = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];
            uiNamespace setVariable ["SB_subtitleCtrl", _ctrl];
        };

        _ctrl ctrlSetStructuredText parseText _formattedText;
        _ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
        _ctrl ctrlSetFade 0;
        _ctrl ctrlSetPosition [
            safezoneX + _posX * safezoneW,
            safezoneY + _posY * safezoneH,
            _posW * safezoneW,
            0.15 * safezoneH
        ];
        _ctrl ctrlCommit 0;

        sleep _length;

        if (_fadeOut) then {
            _ctrl ctrlSetFade 1;
            _ctrl ctrlCommit 0.5;
            sleep 0.5;
            ctrlDelete _ctrl;
            uiNamespace setVariable ["SB_subtitleCtrl", controlNull];
        };
    };
};

// Classic mode — cutText center-bottom layout
private _fmtClassicStacked = "<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
        <t color='%3' size='%5' font='%7'>%1</t>
        <br /><t color='%4' size='%6' font='%7'>%2</t>";
private _fmtClassicInline = "<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
        <t align='left' color='%3' size='%5' font='%7'>%1:  </t><t align='left' color='%4' size='%6' font='%7'>%2</t>";
private _fmtClassic = if (_layout == "inline") then { _fmtClassicInline } else { _fmtClassicStacked };
private _cutSpeed = if (_layout == "inline") then { 0 } else { 0.3 };

[_title, _subtitle, _length, _titleColor, _subtitleColor, _fadeOut, _titleSize, _subtitleSize, _font, _fmtClassic, _cutSpeed] spawn {
    params ["_title", "_subtitle", "_length", "_titleColor", "_subtitleColor", "_fadeOut", "_titleSize", "_subtitleSize", "_font", "_fmtClassic", "_cutSpeed"];

    private _formattedText = format [
        _fmtClassic,
        _title, _subtitle, _titleColor, _subtitleColor, _titleSize, _subtitleSize, _font
    ];

    "SB_subtitle" cutText [_formattedText, "PLAIN", _cutSpeed, true, true];
    sleep _length;

    if (_fadeOut) then {
        "SB_subtitle" cutFadeOut 0.5;
    };
};

/*
* Example usage:
*
*   ["Incoming Transmission", "Enemy activity detected west of the village", 5] remoteExec ["SB_fnc_subtitle", 0];
*
*   ["HQ", "All units, be advised.", 3, "#3399FF", "#FFFFFF", false] remoteExec ["SB_fnc_subtitle", 0];
*   sleep 3;
*   ["HQ", "Enemy armor spotted at grid 045-128.", 4, "#3399FF", "#FFFFFF", true] remoteExec ["SB_fnc_subtitle", 0];
*
*   ["OVERLORD", "Weapons free.", 4, "#FF6600", "#FFFFFF", true, 2.5, 2.0, "RobotoCondensed"] remoteExec ["SB_fnc_subtitle", 0];
*
*   ["HQ", "Objective updated.", 5, "#3399FF", "#FFFFFF", true, 2.2, 1.8, "PuristaSemibold", 0.1, 0.08, 0.6] remoteExec ["SB_fnc_subtitle", 0];
*
*   ["CORTANA", "Chief, we need to move.", 4, "#ADD8E6", "#ADD8E6", true, 1.0, 1.1, "RobotoCondensedLight", -1, -1, 0.8, "inline"] remoteExec ["SB_fnc_subtitle", 0];
*
*   ["Incoming Transmission", "Enemy activity detected", 5, "#FF3333", "#FFAA00"] remoteExec ["SB_fnc_subtitle", 0];
*/
