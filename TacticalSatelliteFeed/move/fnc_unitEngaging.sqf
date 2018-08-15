params ["_unit", "_target", "_point2", "_isWater", "_unitInwater", "_weapon"];
private ["_unitPos", "_targetPos", "_watchDir", "_dir", "_nextMove", "_sleepTime", "_time", "_stopMove"];
if (_unitInwater) exitWith {};
_unitPos = if (_isWater) then {getPosASLVisual _unit} else {getPosATLVisual _unit};
_targetPos = if (_isWater) then {getPosASLVisual _target} else {getPosATLVisual _target};
_watchDir = _targetPos vectorDiff _unitPos;
_dir = [_unitPos, _point2, _watchDir, _unitInwater] call TSF_fnc_getWatchMoveDir;
_stopMove = call compile format["TSF_%2_%1_NON_Anim",(stance _unit), _weapon];
_unit setVariable ["TSF_unitEngaging", true];
_unit setVariable ["TSF_unitChangingMove", true];
_unit setVariable ["TSF_assignedMove", _stopMove];
_unit playMoveNow _stopMove;
_wpn = primaryWeapon _unit;
if (_weapon == "pst") then {_wpn = handgunWeapon _unit};
if (_weapon == "ln") then {_wpn = secondaryWeapon _unit};
_mode = (getArray (configFile >> "CfgWeapons" >> _wpn >> "modes")) select 0;
if (_mode == "this") then {_mode = _wpn};
_sleepTime = 20/(_unit distance2D _target)+1;
if (_sleepTime > 5) then {_sleepTime = 5}; 
_time = 0;
if (needReload _unit > 0.95) then {reload _unit};
_unit forceWeaponFire [_wpn, _mode];
_unit reveal _target;
_unit doFire _target;
while {_time <= _sleepTime && alive _unit && alive _target && (count (crew _target) != 0) && (_unit getVariable "TSF_unitState" == 0) && !(_unit getVariable "TSF_cancelMove")&& (_unit getVariable "TSF_unitEngaging")} do {uiSleep 1; _time = _time + 1};

if (_unit getVariable "TSF_unitState" == 0 && !(_unit getVariable ["TSF_unitIsTurning", false]) && !(_unit getVariable "TSF_cancelMove") && (_unit getVariable "TSF_unitEngaging")) then {
	_nextMove = (_unit getVariable "TSF_baseMove") + _dir;
	_unit setVariable ["TSF_unitChangingMove", true];
	_unit setVariable ["TSF_assignedMove", _nextMove];
	_unit playMoveNow _nextMove;
};
_unit setVariable ["TSF_unitEngaging", false];