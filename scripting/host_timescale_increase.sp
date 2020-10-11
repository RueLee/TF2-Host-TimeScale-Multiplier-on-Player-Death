#pragma semicolon 1
#undef REQUIRE_PLUGIN

#include <sourcemod>
#include <multicolors>
#include <updater>

#define PLUGIN_VERSION	"0.2.3"
#define UPDATE_URL		"https://github.com/RueLee/TF2-Increase-Host-TimeScale-on-Player-Death/blob/main/updater.txt"

ConVar g_hTimeScale;
ConVar g_hSVCheats;
ConVar g_hAddition;

bool g_bWaitingForPlayers;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) {
	char Game[32];
	GetGameFolderName(Game, sizeof(Game));
	if(!StrEqual(Game, "tf")) {
		Format(error, err_max, "This plugin only works for Team Fortress 2");
		return APLRes_Failure;
	}
	return APLRes_Success;
}

public Plugin:myinfo = {
	name = "[TF2] Increase Host TimeScale on Player Death",
	author = "RueLee",
	description = "It's TF2 but the game gets 0.04+ faster everytime when a player dies.",
	version = PLUGIN_VERSION,
	url = "https://github.com/RueLee/TF2-Increase-Host-TimeScale-on-Player-Death"
}

public OnPluginStart() {
	CreateConVar("sm_timescale_version", PLUGIN_VERSION, "Plugin Version -- DO NOT MODIFY!", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_hTimeScale = FindConVar("host_timescale");
	g_hSVCheats = FindConVar("sv_cheats");
	g_hAddition = CreateConVar("sm_timescale_addition", "0.04", "Change timescale by adding. | Default: 0.04");
	
	RegAdminCmd("sm_resettimescale", CmdResetTimeScale, ADMFLAG_GENERIC, "Resets host_timescale to the default value.");
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundWin);
	
	if (LibraryExists("updater")) {
		Updater_AddPlugin(UPDATE_URL);
	}
}

public void OnLibraryAdded(const char[] sName) {
	if (StrEqual(sName, "updater")) {
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnMapEnd() {
	g_hTimeScale.FloatValue = 1.0;
	UnhookEvent("player_death", Event_PlayerDeath);
}

public void TF2_OnWaitingForPlayersStart() {
	g_bWaitingForPlayers = true;
}

public void TF2_OnWaitingForPlayersEnd() {
	g_bWaitingForPlayers = false;
}

public Action Event_RoundStart(Event hEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bWaitingForPlayers) {
		g_hSVCheats.IntValue = 1;
		g_hTimeScale.FloatValue = 1.0;
		HookEvent("player_death", Event_PlayerDeath);
	}
}

public Action Event_PlayerDeath(Event hEvent, const char[] sName, bool bDontBroadcast) {
	g_hTimeScale.FloatValue += g_hAddition.FloatValue;
	CPrintToChatAll("{green}[SM] {default}TimeScale is now %.2f", g_hTimeScale.FloatValue);
}

public Action Event_RoundWin(Event hEvent, const char[] sName, bool bDontBroadcast) {
	g_hTimeScale.FloatValue = 1.0;
	CPrintToChatAll("{green}[SM] {default}TimeScale resetted.");
	UnhookEvent("player_death", Event_PlayerDeath);
}

public Action CmdResetTimeScale(int client, int args) {
	g_hTimeScale.FloatValue = 1.0;
	CPrintToChatAll("{green}[SM] {mediumvioletred}%N {default}has reset the timescale to the default value!", client);
	return Plugin_Handled;
}