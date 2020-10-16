#define FILTERSCRIPT
 
#include <a_samp>
 
#undef MAX_PLAYERS
#define MAX_PLAYERS 100
 
#define DIALOG_EDIT_BONE 5000
#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
 
enum weaponSettings
{
    Float:Position[6],
    Bone,
    Hidden
}
new WeaponSettings[MAX_PLAYERS][17][weaponSettings], WeaponTick[MAX_PLAYERS], EditingWeapon[MAX_PLAYERS];
 
GetWeaponObjectSlot(weaponid)
{
    new objectslot;
 
    switch (weaponid)
    {
        case 22..24: objectslot = 0;
        case 25..27: objectslot = 1;
        case 28, 29, 32: objectslot = 2;
        case 30, 31: objectslot = 3;
        case 33, 34: objectslot = 4;
        case 35..38: objectslot = 5;
    }
    return objectslot;
}
 
GetWeaponModel(weaponid)
{
    new model;
   
    switch(weaponid)
    {
        case 22..29: model = 324 + weaponid;
        case 30: model = 355;
        case 31: model = 356;
        case 32: model = 372;
        case 33..38: model = 324 + weaponid;
    }
    return model;
}
 
PlayerHasWeapon(playerid, weaponid)
{
    new weapon, ammo;
 
    for (new i; i < 13; i++)
    {
        GetPlayerWeaponData(playerid, i, weapon, ammo);
        if (weapon == weaponid && ammo) return 1;
    }
    return 0;
}
 
IsWeaponWearable(weaponid)
    return (weaponid >= 22 && weaponid <= 38);
 
IsWeaponHideable(weaponid)
    return (weaponid >= 22 && weaponid <= 24 || weaponid == 28 || weaponid == 32);
 
public OnPlayerUpdate(playerid)
{
    if (NetStats_GetConnectedTime(playerid) - WeaponTick[playerid] >= 250)
    {
        new weaponid, ammo, objectslot, count, index;
 
        for (new i = 2; i <= 7; i++) //Loop only through the slots that may contain the wearable weapons
        {
            GetPlayerWeaponData(playerid, i, weaponid, ammo);
            index = weaponid - 22;
           
            if (weaponid && ammo && !WeaponSettings[playerid][index][Hidden] && IsWeaponWearable(weaponid) && EditingWeapon[playerid] != weaponid)
            {
                objectslot = GetWeaponObjectSlot(weaponid);
 
                if (GetPlayerWeapon(playerid) != weaponid)
                    SetPlayerAttachedObject(playerid, objectslot, GetWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
 
                else if (IsPlayerAttachedObjectSlotUsed(playerid, objectslot)) RemovePlayerAttachedObject(playerid, objectslot);
            }
        }
        for (new i; i <= 5; i++) if (IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            count = 0;
 
            for (new j = 22; j <= 38; j++) if (PlayerHasWeapon(playerid, j) && GetWeaponObjectSlot(j) == i)
                count++;
 
            if (!count) RemovePlayerAttachedObject(playerid, i);
        }
        WeaponTick[playerid] = NetStats_GetConnectedTime(playerid);
    }
    return 1;
}
 
public OnPlayerConnect(playerid)
{
    for (new i; i < 17; i++)
    {
        WeaponSettings[playerid][i][Position][0] = -0.116;
        WeaponSettings[playerid][i][Position][1] = 0.189;
        WeaponSettings[playerid][i][Position][2] = 0.088;
        WeaponSettings[playerid][i][Position][3] = 0.0;
        WeaponSettings[playerid][i][Position][4] = 44.50;
        WeaponSettings[playerid][i][Position][5] = 0.0;
        WeaponSettings[playerid][i][Bone] = 1;
        WeaponSettings[playerid][i][Hidden] = false;
    }
    WeaponTick[playerid] = 0;
    EditingWeapon[playerid] = 0;
	return 1;
}
 
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_EDIT_BONE)
    {
        if (response)
        {
            new weaponid = EditingWeapon[playerid], weaponname[18], string[68];
 
            GetWeaponName(weaponid, weaponname, sizeof(weaponname));
            WeaponSettings[playerid][weaponid - 22][Bone] = listitem + 1;
 
            format(string, sizeof(string), "You have successfully changed the bone of your %s.", weaponname);
            SendClientMessage(playerid, -1, string);
        }
        EditingWeapon[playerid] = 0;
        return 1;
    }
    return 0;
}
 
public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    new weaponid = EditingWeapon[playerid];
 
    if (weaponid)
    {
        if (response)
        {
            new enum_index = weaponid - 22, weaponname[18], string[80];
 
            GetWeaponName(weaponid, weaponname, sizeof(weaponname));
 
            WeaponSettings[playerid][enum_index][Position][0] = fOffsetX;
            WeaponSettings[playerid][enum_index][Position][1] = fOffsetY;
            WeaponSettings[playerid][enum_index][Position][2] = fOffsetZ;
            WeaponSettings[playerid][enum_index][Position][3] = fRotX;
            WeaponSettings[playerid][enum_index][Position][4] = fRotY;
            WeaponSettings[playerid][enum_index][Position][5] = fRotZ;
 
            RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
            SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetWeaponModel(weaponid), WeaponSettings[playerid][enum_index][Bone], fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, 1.0, 1.0, 1.0);
 
            format(string, sizeof(string), "You have successfully adjusted the position of your %s.", weaponname);
            SendClientMessage(playerid, -1, string);
        }
        EditingWeapon[playerid] = 0;
    }
    return 1;
}
 
public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[24], params[64], len = strlen(cmdtext);
   
    for (new i; i < len; i++) if (cmdtext[i] == ' ')
    {
        strmid(cmd, cmdtext, 0, i);
        strcat(params, cmdtext[i + 1]);    
        break;
    }
    if (isnull(cmd)) strcat(cmd, cmdtext);
 
    if (!strcmp(cmd, "/weapon", true))
    {
        new weaponid = GetPlayerWeapon(playerid);
 
        if (!weaponid)
            return SendClientMessage(playerid, -1, "You are not holding a weapon.");
 
        if (!IsWeaponWearable(weaponid))
            return SendClientMessage(playerid, -1, "This weapon cannot be edited.");
 
        if (isnull(params))
            return SendClientMessage(playerid, -1, "USAGE: /weapon [adjustpos/bone/hide]");
 
        if (!strcmp(params, "adjustpos", true))
        {
            if (EditingWeapon[playerid])
                return SendClientMessage(playerid, -1, "You are already editing a weapon.");
 
            if (WeaponSettings[playerid][weaponid - 22][Hidden])
                return SendClientMessage(playerid, -1, "You cannot adjust a hidden weapon.");
 
            new index = weaponid - 22;
               
            SetPlayerArmedWeapon(playerid, 0);
           
            SetPlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid), GetWeaponModel(weaponid), WeaponSettings[playerid][index][Bone], WeaponSettings[playerid][index][Position][0], WeaponSettings[playerid][index][Position][1], WeaponSettings[playerid][index][Position][2], WeaponSettings[playerid][index][Position][3], WeaponSettings[playerid][index][Position][4], WeaponSettings[playerid][index][Position][5], 1.0, 1.0, 1.0);
            EditAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
           
            EditingWeapon[playerid] = weaponid;
        }
        else if (!strcmp(params, "bone", true))
        {
            if (EditingWeapon[playerid])
                return SendClientMessage(playerid, -1, "You are already editing a weapon.");
 
            ShowPlayerDialog(playerid, DIALOG_EDIT_BONE, DIALOG_STYLE_LIST, "Bone", "Spine\nHead\nLeft upper arm\nRight upper arm\nLeft hand\nRight hand\nLeft thigh\nRight thigh\nLeft foot\nRight foot\nRight calf\nLeft calf\nLeft forearm\nRight forearm\nLeft shoulder\nRight shoulder\nNeck\nJaw", "Choose", "Cancel");
            EditingWeapon[playerid] = weaponid;
        }
        else if (!strcmp(params, "hide", true))
        {
            if (EditingWeapon[playerid])
                return SendClientMessage(playerid, -1, "You cannot hide a weapon while you are editing it.");
 
            if (!IsWeaponHideable(weaponid))
                return SendClientMessage(playerid, -1, "This weapon cannot be hidden.");
 
            new index = weaponid - 22, weaponname[18], string[48];
 
            GetWeaponName(weaponid, weaponname, sizeof(weaponname));
 
            if (WeaponSettings[playerid][index][Hidden])
            {
                format(string, sizeof(string), "You have set your %s to show.", weaponname);
                WeaponSettings[playerid][index][Hidden] = false;
            }
            else
            {
                if (IsPlayerAttachedObjectSlotUsed(playerid, GetWeaponObjectSlot(weaponid)))
                    RemovePlayerAttachedObject(playerid, GetWeaponObjectSlot(weaponid));
 
                format(string, sizeof(string), "You have set your %s not to show.", weaponname);
                WeaponSettings[playerid][index][Hidden] = true;
            }
            SendClientMessage(playerid, -1, string);
        }
        else SendClientMessage(playerid, -1, "You have specified an invalid option.");
        return 1;
    }
    return 0;
}