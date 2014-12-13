// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: setupPlayerDB.sqf
//	@file Author: AgentRev

if (isDedicated) exitWith {};

_playerFuncs = "persistence\client\players";

fn_applyPlayerData = [_playerFuncs, "applyPlayerData.sqf"] call mf_compile;
fn_applyPlayerInfo = [_playerFuncs, "applyPlayerInfo.sqf"] call mf_compile;
fn_savePlayerData = [_playerFuncs, "savePlayerData.sqf"] call mf_compile;

fn_requestPlayerData =
{
	playerData_alive = nil;
	playerData_loaded = nil;
	playerData_resetPos = nil;
	pvar_requestPlayerData = [player, getPlayerUID player, netId player];
	publicVariableServer "pvar_requestPlayerData";
} call mf_compile;

fn_deletePlayerData =
{
	pvar_deletePlayerData = getPlayerUID player;
	publicVariableServer "pvar_deletePlayerData";
	playerData_infoPairs = nil;
	playerData_savePairs = nil;
} call mf_compile;


("pvar_applyPlayerData_" + getPlayerUID player) addPublicVariableEventHandler
{
	(_this select 1) spawn
	{
		_data = _this;
		_saveValid = [_data, "PlayerSaveValid", false] call fn_getFromPairs;

		if (_saveValid) then
		{
			playerData_alive = true;

			_pos = [_data, "Position", []] call fn_getFromPairs;
			_preload = profileNamespace getVariable ["A3W_preloadSpawn", true];

			if (count _pos == 2) then { _pos set [2, 0] };
			if (count _pos == 3) then
			{
				if (_preload) then
				{
					9999 cutText ["Preloading previous location...", "BLACK", 0.01];
					waitUntil {sleep 0.1; preloadCamera _pos};
				}
				else
				{
					9999 cutText ["Loading previous location...", "BLACK", 0.01];
				};
			}
			else
			{
				playerData_resetPos = true;
			};

			waitUntil {!isNil "bis_fnc_init" && {bis_fnc_init}}; // wait for loading screen to be done

			_data call fn_applyPlayerData;
		};

		_data call fn_applyPlayerInfo;

		if (_saveValid) then
		{
			player groupChat "Player account loaded!";

			if (isNil "playerData_resetPos") then
			{
				player enableSimulation true;
				player allowDamage true;
				player setVelocity [0,0,0];

				execVM "client\functions\firstSpawn.sqf";
			}
			else
			{
				player groupChat "Your position has been reset";
			};
		};

		playerData_loaded = true;
	};
};