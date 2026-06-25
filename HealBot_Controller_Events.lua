-- HealBot_Controller_Events.lua
-- Manages WoW Frame events and periodic updates, routing to respective services

HealBot_View_DirtyUnits = {}
local HealBot_Timer1, HealsIn_Timer = 0, 0;

function HealBot_OnLoad(this)
    this:RegisterEvent("VARIABLES_LOADED");
    
    SLASH_HEALBOT1 = "/healbot";
    SLASH_HEALBOT2 = "/hb";
    SlashCmdList["HEALBOT"] = function(msg)
        HealBot_SlashCmd(msg);
    end
    HealBot_AddError(HEALBOT_ADDON .. HEALBOT_LOADED);
    
    -- Register MVC Observers
    HealBot_Model:RegisterObserver("UNIT_HEALTH_CHANGED", function(unitID)
        HealBot_View_DirtyUnits[unitID] = true
    end)
    HealBot_Model:RegisterObserver("UNIT_POWER_CHANGED", function(unitID)
        HealBot_View_DirtyUnits[unitID] = true
    end)
    HealBot_Model:RegisterObserver("UNIT_AURA_CHANGED", function(unitID)
        HealBot_View_DirtyUnits[unitID] = true
    end)
    HealBot_Model:RegisterObserver("ROSTER_CHANGED", function()
        Delay_RecalcParty = 1
    end)
end

function HealBot_RegisterThis(this)
    -- Deprecated / not used
end 

function HealBot_OnUpdate(this, arg1)
    -- Process Dirty Queue for MVC View
    if next(HealBot_View_DirtyUnits) ~= nil then
        for unitID in pairs(HealBot_View_DirtyUnits) do
            HealBot_Action_RefreshButtons(unitID)
            HealBot_View_DirtyUnits[unitID] = nil
        end
    end

    HealBot_Timer1 = HealBot_Timer1 + arg1;
    if HealBot_Timer1 >= 2.5 then
        if not HealBot_IsFighting then
            HealsIn_Timer = HealsIn_Timer + 1;
            if HealsIn_Timer >= 10 then
                HealBot_HealsIn = {};
                HealBot_Healers = {};
                HealsIn_Timer = 0;
            end
            
            if HealBot_EquipChangeTimer > 0 then
                HealBot_EquipChangeTimer = HealBot_EquipChangeTimer - arg1
                if HealBot_EquipChangeTimer <= 0 then
                    HealBot_EquipChangeTimer = 0
                    HealBot_BonusScanner:ScanEquipment()
                    CalcEquipBonus = true;
                    HealBot_RecalcSpells();
                end
            end
            
            if InitSpells > 1 then
                InitSpells = InitSpells + 1;
                if InitSpells > 2 then
                    local cnt = HealBot_InitSpells();
                    InitSpells = 0;
                    HealBot_RecalcSpells();
                end
            end
            if Delay_RecalcParty > 0 then
                Delay_RecalcParty = Delay_RecalcParty + 1
                if Delay_RecalcParty > 1 then
                    Delay_RecalcParty = 0;
                    HealBot_RecalcParty();
                end
            end
        else
            HealsIn_Timer = 0;
        end
        HealBot_Timer1 = 0;
        HealBot_SpamCnt = 0;
    end
end

local HealBot_EventHandlers = {
    ["UNIT_HEALTH"] = function(this, arg1)
        if HealBot_Model:UpdateUnitHealth(arg1) then
            HealBot_Model:NotifyObservers("UNIT_HEALTH_CHANGED", arg1)
        end
        HealBot_OnEvent_UnitHealth(this, arg1)
    end,
    ["UNIT_MANA"] = function(this, arg1)
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
        if (arg1 == "player") then HealBot_RecalcHeals(); end
        HealBot_Action_RefreshButtons(arg1);
    end,
    ["UNIT_RAGE"] = function(this, arg1)
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
        if (arg1 == "player") then HealBot_RecalcHeals(); end
        HealBot_Action_RefreshButtons(arg1);
    end,
    ["UNIT_ENERGY"] = function(this, arg1)
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
        if (arg1 == "player") then HealBot_RecalcHeals(); end
        HealBot_Action_RefreshButtons(arg1);
    end,
    ["UNIT_DISPLAYPOWER"] = function(this, arg1)
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
        if (arg1 == "player") then HealBot_RecalcHeals(); end
        HealBot_Action_RefreshButtons(arg1);
    end,
    ["UNIT_AURA"] = function(this, arg1)
        HealBot_Model:MarkAuraChanged(arg1)
        HealBot_Model:NotifyObservers("UNIT_AURA_CHANGED", arg1)
        HealBot_OnEvent_UnitAura(this, arg1)
    end,
    ["PLAYER_TARGET_CHANGED"] = function(this)
        if HealBot_Model:UpdateUnitIdentity("target") then
            HealBot_Model:NotifyObservers("ROSTER_CHANGED", "target")
        end
        HealBot_Model:UpdateUnitStatus("target")
        HealBot_Model:UpdateUnitHealth("target")
        HealBot_Model:UpdateUnitPower("target")
        HealBot_OnEvent_PlayerTargetChanged(this)
    end,
    ["PARTY_MEMBERS_CHANGED"] = function(this)
        for _, unit in ipairs(HealBot_Model.partyMembers) do
            HealBot_Model:RefreshUnit(unit)
        end
        for _, unit in ipairs(HealBot_Model.raidMembers) do
            HealBot_Model:RefreshUnit(unit)
        end
        HealBot_Model:NotifyObservers("ROSTER_CHANGED")
        HealBot_OnEvent_PartyMembersChanged(this)
    end,
    ["PLAYER_ENTERING_WORLD"] = function(this)
        HealBot_Model:RefreshUnit("player")
        HealBot_Model:RefreshUnit("pet")
        HealBot_OnEvent_PlayerEnteringWorld(this)
    end,
    ["VARIABLES_LOADED"] = function(this)
        HealBot_OnEvent_VariablesLoaded(this)
    end,
    -- Legacy pass-throughs
    ["CHAT_MSG_ADDON"] = function(this, arg1, arg2, arg3, arg4) HealBot_OnEvent_AddonMsg(this, arg1, arg2, arg3, arg4) end,
    ["SPELLCAST_START"] = function(this, arg1, arg2) HealBot_OnEvent_SpellcastStart(this, arg1, arg2) end,
    ["SPELLCAST_STOP"] = function(this) HealBot_OnEvent_SpellcastStop(this) end,
    ["SPELLCAST_INTERRUPTED"] = function(this) HealBot_OnEvent_SpellcastStop(this) end,
    ["SPELLCAST_FAILED"] = function(this) HealBot_OnEvent_SpellcastStop(this) end,
    ["PLAYER_REGEN_DISABLED"] = function(this) HealBot_OnEvent_PlayerRegenDisabled(this) end,
    ["PLAYER_REGEN_ENABLED"] = function(this) HealBot_OnEvent_PlayerRegenEnabled(this) end,
    ["BAG_UPDATE_COOLDOWN"] = function(this, arg1) HealBot_OnEvent_BagUpdateCooldown(this, arg1) end,
    ["BAG_UPDATE"] = function(this, arg1) HealBot_OnEvent_BagUpdate(this, arg1) end,
    ["PARTY_MEMBER_DISABLE"] = function(this, arg1) HealBot_OnEvent_PartyMemberDisable(this, arg1) end,
    ["PARTY_MEMBER_ENABLE"] = function(this, arg1) HealBot_OnEvent_PartyMemberEnable(this, arg1) end,
    ["CHAT_MSG_SYSTEM"] = function(this, arg1) HealBot_OnEvent_SystemMsg(this, arg1) end,
    ["ZONE_CHANGED_NEW_AREA"] = function(this) HealBot_OnEvent_ZoneChanged(this) end,
    ["UPDATE_INVENTORY_ALERTS"] = function(this) HealBot_OnEvent_PlayerEquipmentChanged(this) end,
    ["UNIT_INVENTORY_CHANGED"] = function(this, arg1) HealBot_OnEvent_PlayerEquipmentChanged2(this, arg1) end,
    ["PET_BAR_SHOWGRID"] = function(this) HealBot_OnEvent_PartyMembersChanged(this) end,
    ["PET_BAR_HIDEGRID"] = function(this) HealBot_OnEvent_PartyMembersChanged(this) end,
    ["SPELLS_CHANGED"] = function(this, arg1) HealBot_OnEvent_SpellsChanged(this, arg1) end
}

function HealBot_OnEvent(this, event, arg1, arg2, arg3, arg4)
    local handler = HealBot_EventHandlers[event]
    if handler then
        handler(this, arg1, arg2, arg3, arg4)
    else
        HealBot_AddDebug("OnEvent (" .. event .. ")")
    end
end

function HealBot_OnEvent_VariablesLoaded(this)
    local class = HealBot_UnitClass("player")

    table.foreach(HealBot_ConfigDefaults, function (key, val)
        if not HealBot_Config[key] then
            HealBot_Config[key] = val;
        end
        if type(val) == "table" and type(HealBot_Config[key]) == "table" then
            for k, v in pairs(val) do
                if HealBot_Config[key][k] == nil then
                    HealBot_Config[key][k] = v
                end
            end
        end
    end);
    
    local foundModern = false
    if HealBot_Config.Skins then
        for _, skin in ipairs(HealBot_Config.Skins) do
            if skin == "Modern Flat" then foundModern = true break end
        end
        if not foundModern then
            table.insert(HealBot_Config.Skins, "Modern Flat")
        end
    end
    
    HealBot_InitData();
    
    if class == "PRIEST" or class == "DRUID" or class == "PALADIN" or class == "SHAMAN" then
        HealBot_BonusScanner:ScanEquipment();

        if HealBot_Config.ActionVisible == 1 then HealBot_Action:Show() end

        this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
        this:RegisterEvent("PLAYER_REGEN_DISABLED");
        this:RegisterEvent("PLAYER_REGEN_ENABLED");
        this:RegisterEvent("PLAYER_TARGET_CHANGED");
        this:RegisterEvent("PARTY_MEMBERS_CHANGED");
        this:RegisterEvent("PARTY_MEMBER_DISABLE");
        this:RegisterEvent("PARTY_MEMBER_ENABLE");
        this:RegisterEvent("PET_BAR_SHOWGRID");
        this:RegisterEvent("PET_BAR_HIDEGRID");
        this:RegisterEvent("UNIT_HEALTH");
        this:RegisterEvent("UNIT_MANA");
        this:RegisterEvent("UNIT_RAGE");
        this:RegisterEvent("UNIT_ENERGY");
        this:RegisterEvent("UNIT_DISPLAYPOWER");
        this:RegisterEvent("SPELLS_CHANGED");
        this:RegisterEvent("SPELLCAST_START");
        this:RegisterEvent("SPELLCAST_STOP");
        this:RegisterEvent("SPELLCAST_INTERRUPTED");
        this:RegisterEvent("SPELLCAST_FAILED");
        this:RegisterEvent("BAG_UPDATE");
        this:RegisterEvent("BAG_UPDATE_COOLDOWN");
        this:RegisterEvent("UNIT_AURA");
        this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
        this:RegisterEvent("UNIT_INVENTORY_CHANGED");
        this:RegisterEvent("CHAT_MSG_ADDON");
        this:RegisterEvent("CHAT_MSG_SYSTEM");
        this:RegisterEvent("PLAYER_ENTERING_WORLD");
        InitSpells = 2;
    end
end

function HealBot_OnEvent_UnitHealth(this, unit)
    if (not HealBot_Heals[unit]) then return end
    HealBot_CheckCasting(unit);
    HealBot_RecalcHeals(unit);
    if unit == HealBot_Action_TooltipUnit then
        HealBot_Action_RefreshTooltip(HealBot_Action_TooltipUnit);
    end
end

function HealBot_OnEvent_UnitMana(this, unit)
    if (unit ~= "player") then return end
    HealBot_RecalcHeals();
end

function HealBot_OnEvent_ZoneChanged(this)
    HealBot_ResetRangeScale();
    Delay_RecalcParty = 1;
end

function HealBot_OnEvent_PlayerRegenDisabled(this)
    HealBot_RecalcParty();
    if (UnitIsDeadOrGhost("player")) or (UnitOnTaxi("player")) then
        if HealBot_Config.AutoClose == 1 and HealBot_Config.ActionVisible ~= 0 then HealBot_Action:Hide(); end;
    else
        HealBot_Action:Show();
        HealBot_IsFighting = true;
    end
end

function HealBot_OnEvent_PlayerRegenEnabled(this)
    HealBot_IsFighting = false;
    Delay_RecalcParty = 1;
end

function HealBot_OnEvent_PlayerTargetChanged(this)
    HealBot_RecalcParty();
end

function HealBot_OnEvent_PartyMembersChanged(this)
    Delay_RecalcParty = 1;
end

function HealBot_OnEvent_PartyMemberDisable(this, unit)
    HealBot_RecalcHeals();  
end

function HealBot_OnEvent_SystemMsg(this, msg)
    if type(msg) == "string" then
        local tmpTest, tmpTest, deserter = string.find(msg, HB_HASLEFTRAID);
        if not deserter then
            local tmpTest, tmpTest, deserter = string.find(msg, HB_HASLEFTPARTY);
        end
        if deserter then
            if (HealBot_Healers[deserter]) then
                local tmpTest, unitname, heal_val, heal_valn
                tmpTest, tmpTest, unitname, heal_val = string.find(HealBot_Healers[deserter], ">> (%a+) <<=>> (.%d+) <<" );
                heal_valn = tonumber(heal_val)
                HealBot_Healers[deserter] = nil;
                HealBot_AddDebug("Healer " .. deserter .. " left the group - Last known activity was heal " .. unitname .. " for " .. heal_val .. " << trapped in event SystemMsg");
                if heal_valn > 0 and HealBot_HealsIn[unitname] then
                    HealBot_HealsIn[unitname] = HealBot_HealsIn[unitname] - heal_valn;
                    if HealBot_HealsIn[unitname] < 0 then
                        HealBot_HealsIn[unitname] = 0;
                    end
                end
            end
        elseif msg == HB_YOULEAVETHEGROUP or msg == HB_YOULEAVETHERAID then
            Delay_RecalcParty = 1;
        end
    end
end

function HealBot_OnEvent_PartyMemberEnable(this, unit)
    HealBot_RecalcHeals();
end

function HealBot_OnEvent_PlayerEquipmentChanged(this)
    HealBot_EquipChangeTimer = 1;
end

function HealBot_OnEvent_PlayerEquipmentChanged2(this, unit)
    if unit == "player" then
        HealBot_EquipChangeTimer = 1;
    end
end

function HealBot_OnEvent_SpellsChanged(this, arg1)
    if arg1 then return; end
    HealBot_AddDebug("HB: SpellsChanged");
    InitSpells = 2;
end

function HealBot_OnEvent_TalentsChanged(this, arg1)
    HealBot_AddDebug("HB: TalentsChanged");
end

function HealBot_OnEvent_BagUpdate(this, bag)
    if HealBot_EquipChangeTimer == 0 then
        HealBot_RecalcSpells();
    end
end

function HealBot_OnEvent_BagUpdateCooldown(this, bag)
    if not bag then 
        bag = "undef"
    elseif HealBot_EquipChangeTimer == 0 then
        HealBot_RecalcSpells();
    end
end

function HealBot_OnEvent_PlayerEnteringWorld(this)
    HealBot_IsFighting = false;
end

function HealBot_OnEvent_SpellcastStart(this, spell, duration)
    HealBot_IsCasting = true;
    HealBot_RecalcHeals();
    HealBot_CheckCasting();
    if spell == HEALBOT_RESURRECTION or spell == HEALBOT_ANCESTRALSPIRIT or spell == HEALBOT_REBIRTH or spell == HEALBOT_REDEMPTION then
        if UnitName("Target") then 
            HealBot_SendAddonMessage("CTRA", "RES " .. UnitName("Target"));
            HealBot_IamRessing = true;
        end
    end
end

function HealBot_OnEvent_SpellcastStop(this)
    HealBot_IsCasting = false;
    HealBot_StopCasting();
    HealBot_RecalcHeals();
    if HealBot_IamRessing then
        HealBot_SendAddonMessage("CTRA", "RESNO");
        HealBot_IamRessing = false;
    end
end
