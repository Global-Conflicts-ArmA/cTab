/*
	Name: cTab_fnc_remoteControlUav
	
	Author(s):
		Gundy

	Description:
		Take control of the currently selected UAV's gunner turret
	
	Parameters:
		NONE
 	
	Returns:
		BOOLEAN - TRUE
	
	Example:
		[] call cTab_fnc_remoteControlUav;
*/

private ["_uavGunner"];

// see if there is a selected UAV and if it is alive before continuing
if (isNil 'cTabActUav' || {!alive cTabActUav}) exitWith {false};

// close cTab since there is either an error message to be shown which would be obstructed by the tablet, or the view will be switched to the UAV gunner
[] call cTab_fnc_close;

// make sure there is noone currently controlling the gunner seat
// unfortunately this fails as soon as there is a driver connected as only one unit is returned using UAVControl and it will alwasys be the driver if present.
// see http://feedback.arma3.com/view.php?id=23693
if (UAVControl cTabActUav select 1 != "GUNNER") then {
	// see if there is actually a gunner AI that we can remote control
	_uavGunner = gunner cTabActUav;
	if (!isNull _uavGunner) then {
		player remoteControl _uavGunner;
		cTabActUav switchCamera "Gunner";
		cTabUavViewActive = true;
		// spawn a loop in-case control of the UAV is released elsewhere
		cTabActUav spawn {
			waitUntil {(cameraOn != _this) || (!cTabUavViewActive)};
			cTabUavViewActive = false;
		};
	} else {
		["cTabUavNotAval",["UAV has no gunner optics that can be controlled"]] call BIS_fnc_showNotification;
	};
} else {
	["cTabUavNotAval",["Another user has control, no control given"]] call BIS_fnc_showNotification;
};

true