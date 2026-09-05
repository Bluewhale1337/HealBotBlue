-- HealBot_Controller_Events.lua
-- Manages WoW Frame events and periodic updates, routing to respective services

HealBot_View_DirtyUnits = {}
HealBot_View_DirtyPower = {}
local HealBot_Timer1, HealsIn_Timer = 0, 0;
HealBot_LastModState = ""

-- HealBot_OnLoad: Registers core events and observers on addon load.
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
        HealBot_View_DirtyPower[unitID] = true
    end)
    HealBot_Model:RegisterObserver("UNIT_AURA_CHANGED", function(unitID)
        HealBot_View_DirtyUnits[unitID] = true
    end)
    HealBot_Model:RegisterObserver("ROSTER_CHANGED", function()
        HealBot_Delay_RecalcParty = 1
    end)
    HealBot_Model:RegisterObserver("EQUIPMENT_CHANGED", function(unitID)
        if unitID == "player" then
            HealBot_EquipChangeTimer = 1
        end
    end)
end

-- HealBot_RegisterThis: Internal utility: HealBot_RegisterThis
function HealBot_RegisterThis(this)
    -- Deprecated / not used
end 

-- HealBot_OnUpdate: Main loop: processes dirty queues and timers.
function HealBot_OnUpdate(this, arg1)
    if HealBot_Action_TooltipUnit and HealBot_Tooltip:IsVisible() then
        local s = IsShiftKeyDown() and true or false
        local c = IsControlKeyDown() and true or false
        local a = IsAltKeyDown() and true or false
        
        if HealBot_LastModS ~= s or HealBot_LastModC ~= c or HealBot_LastModA ~= a then
            HealBot_LastModS = s
            HealBot_LastModC = c
            HealBot_LastModA = a
            HealBot_Action_RefreshTooltip(HealBot_Action_TooltipUnit)
        end
    else
        HealBot_LastModS = false
        HealBot_LastModC = false
        HealBot_LastModA = false
    end

    if HealBot_TargetRestorePending then
        HealBot_TargetRestoreTimer = HealBot_TargetRestoreTimer + arg1;
        if HealBot_TargetRestoreTimer >= 0.1 then
            local pending = HealBot_TargetRestorePending;
            HealBot_TargetRestorePending = nil;
            HealBot_TargetRestoreTimer = 0;
            if pending.type == "enemy" then
                TargetLastEnemy();
            elseif pending.type == "friend" then
                TargetLastTarget();
            elseif pending.type == "clear" then
                ClearTarget();
            end
        end
    end

    if HealBot_PendingShapeshiftCast then
        local pendingCast = HealBot_PendingShapeshiftCast
        
        -- Wait for server to process the unshift before attempting the cast
        if GetTime() >= pendingCast.fireTime then
            if not HealBot_GetShapeshiftForm() then
                -- Target the unit if necessary before casting
                -- Target the unit if necessary before casting
                if pendingCast.oldTarget ~= UnitName(pendingCast.target) then
                    TargetUnit(pendingCast.target)
                end
                
                -- 1. Initialize the MVC side effects (AnnounceCast, Incoming Heals) only ONCE
                if not pendingCast.started then
                    pendingCast.started = true
                    
                    -- Extract base spell
                    local baseSpell = pendingCast.spell
                    local parenIndex = string.find(pendingCast.spell, "%(")
                    if parenIndex then
                        baseSpell = string.sub(pendingCast.spell, 1, parenIndex - 1)
                    end
                    baseSpell = string.gsub(baseSpell, "%s+$", "")
                    
                    -- Force MVC updates since we guarantee the cast will eventually pierce the server
                    HealBot_CastFailed = true -- Trigger first attempt immediately
                    HealBot_CastingSpell = baseSpell
                    HealBot_CastingTarget = pendingCast.target
                    HealBot_Process_HealValue(baseSpell, pendingCast.target)
                    HealBot_AnnounceCast(pendingCast.spell, pendingCast.target)
                    
                    -- Restore target logic
                    if pendingCast.targetEnemy then
                        HealBot_TargetRestorePending = { type = "enemy" }
                    elseif pendingCast.oldTarget and pendingCast.oldTarget ~= UnitName(pendingCast.target) then
                        HealBot_TargetRestorePending = { type = "friend" }
                    elseif not pendingCast.oldTarget then
                        HealBot_TargetRestorePending = { type = "clear" }
                    end
                    HealBot_TargetRestoreTimer = 0
                end
                
                -- 2. Spam the cast until the server explicitly accepts it (firing SPELLCAST_START)
                if pendingCast.started then
                    if not pendingCast.nextSpam or GetTime() >= pendingCast.nextSpam then
                        pendingCast.nextSpam = GetTime() + 0.10
                        
                        -- Safely suppress UI errors
                        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
                        
                        -- Only use HealBot's native cast wrapper
                        HealBot_CastSpellByName(pendingCast.spell)
                        
                        if SpellCanTargetUnit(pendingCast.target) then
                            SpellTargetUnit(pendingCast.target)
                        elseif SpellIsTargeting() then
                            SpellTargetUnit(pendingCast.target)
                            SpellStopTargeting()
                        end
                        
                        UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
                    end
                end
            end
        end
        
        -- Failsafe timeout
        if HealBot_PendingShapeshiftCast and GetTime() > pendingCast.expires then
            HealBot_PendingShapeshiftCast = nil
            HealBot_StopCasting()
            HealBot_RecalcHeals()
        end
    end

    -- Process Dirty Queue for MVC View
    local unitsToRefresh = {}
    for unitID in pairs(HealBot_View_DirtyUnits) do
        unitsToRefresh[unitID] = true
        HealBot_View_DirtyUnits[unitID] = nil
        HealBot_View_DirtyPower[unitID] = nil -- No need to do power-only if full refresh is queued
    end
    for unitID in pairs(unitsToRefresh) do
        HealBot_Action_Refresh(unitID)
    end
    
    local powerToRefresh = {}
    for unitID in pairs(HealBot_View_DirtyPower) do
        powerToRefresh[unitID] = true
        HealBot_View_DirtyPower[unitID] = nil
    end
    for unitID in pairs(powerToRefresh) do
        HealBot_Action_RefreshPower(unitID)
    end
    
    if HealBot_EquipChangeTimer > 0 then
        HealBot_EquipChangeTimer = HealBot_EquipChangeTimer - arg1
        if HealBot_EquipChangeTimer <= 0 then
            HealBot_EquipChangeTimer = 0
            HealBot_BonusScanner:ScanEquipment()
            HealBot_CalcEquipBonus = true;
            HealBot_RecalcSpells();
        end
    end

    HealBot_Timer1 = HealBot_Timer1 + arg1;
    if HealBot_Timer1 >= 2.5 then
        if not HealBot_IsFighting then
            HealsIn_Timer = HealsIn_Timer + 1;
            if HealsIn_Timer >= 10 then
                for k in pairs(HealBot_HealsIn) do HealBot_HealsIn[k] = nil end
                for k in pairs(HealBot_Healers) do HealBot_Healers[k] = nil end
                HealsIn_Timer = 0;
            end
            

            
            if HealBot_SpellsInitFlag > 1 then
                HealBot_SpellsInitFlag = HealBot_SpellsInitFlag + 1;
                if HealBot_SpellsInitFlag > 2 then
                    local cnt = HealBot_InitSpells();
                    HealBot_SpellsInitFlag = 0;
                    HealBot_RecalcSpells();
                end
            end
            if HealBot_Delay_RecalcParty > 0 then
                HealBot_Delay_RecalcParty = HealBot_Delay_RecalcParty + 1
                if HealBot_Delay_RecalcParty > 1 then
                    HealBot_Delay_RecalcParty = 0;
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
        if arg1 ~= "player" and HealBot_Config.ShowManaBars == 0 then return end
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
    end,
    ["UNIT_RAGE"] = function(this, arg1)
        if arg1 ~= "player" and HealBot_Config.ShowManaBars == 0 then return end
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
    end,
    ["UNIT_ENERGY"] = function(this, arg1)
        if arg1 ~= "player" and HealBot_Config.ShowManaBars == 0 then return end
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
    end,
    ["UNIT_DISPLAYPOWER"] = function(this, arg1)
        if arg1 ~= "player" and HealBot_Config.ShowManaBars == 0 then return end
        if HealBot_Model:UpdateUnitPower(arg1) then
            HealBot_Model:NotifyObservers("UNIT_POWER_CHANGED", arg1)
        end
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
    ["RAID_ROSTER_UPDATE"] = function(this)
        for _, unit in ipairs(HealBot_Model.partyMembers) do
            HealBot_Model:RefreshUnit(unit)
        end
        for _, unit in ipairs(HealBot_Model.raidMembers) do
            HealBot_Model:RefreshUnit(unit)
        end
        HealBot_Model:NotifyObservers("ROSTER_CHANGED")
        HealBot_OnEvent_PartyMembersChanged(this)
    end,
    ["RAID_TARGET_UPDATE"] = function(this)
        if HealBot_Action_UnitButtons then
            for unit, _ in pairs(HealBot_Action_UnitButtons) do
                HealBot_View_DirtyUnits[unit] = true
            end
        end
    end,
    ["PLAYER_ENTERING_WORLD"] = function(this)
        HealBot_Model:RefreshUnit("player")
        HealBot_Model:RefreshUnit("pet")
        if HealBot_UnitClass("player") == "DRUID" then
            HealBot_UpdateShapeshiftForm()
        end
        HealBot_OnEvent_PlayerEnteringWorld(this)
    end,
    ["VARIABLES_LOADED"] = function(this)
        HealBot_OnEvent_VariablesLoaded(this)
        HealBot_Integrations_Toggle()
    end,
    -- Legacy pass-throughs
    ["CHAT_MSG_ADDON"] = function(this, arg1, arg2, arg3, arg4) HealBot_OnEvent_AddonMsg(this, arg1, arg2, arg3, arg4) end,
    ["SPELLCAST_START"] = function(this, arg1, arg2) HealBot_OnEvent_SpellcastStart(this, arg1, arg2) end,
    ["SPELLCAST_STOP"] = function(this) HealBot_OnEvent_SpellcastStop(this, "SPELLCAST_STOP") end,
    ["SPELLCAST_INTERRUPTED"] = function(this) HealBot_OnEvent_SpellcastStop(this, "SPELLCAST_INTERRUPTED") end,
    ["SPELLCAST_FAILED"] = function(this) HealBot_OnEvent_SpellcastStop(this, "SPELLCAST_FAILED") end,
    ["PLAYER_REGEN_DISABLED"] = function(this) HealBot_OnEvent_PlayerRegenDisabled(this) end,
    ["PLAYER_REGEN_ENABLED"] = function(this) HealBot_OnEvent_PlayerRegenEnabled(this) end,
    ["PARTY_MEMBER_DISABLE"] = function(this, arg1) HealBot_OnEvent_PartyMemberDisable(this, arg1) end,
    ["PARTY_MEMBER_ENABLE"] = function(this, arg1) HealBot_OnEvent_PartyMemberEnable(this, arg1) end,
    ["CHAT_MSG_SYSTEM"] = function(this, arg1) HealBot_OnEvent_SystemMsg(this, arg1) end,
    ["ZONE_CHANGED_NEW_AREA"] = function(this) HealBot_OnEvent_ZoneChanged(this) end,
    ["UPDATE_INVENTORY_ALERTS"] = function(this)
        HealBot_Model:NotifyObservers("EQUIPMENT_CHANGED", "player")
        HealBot_OnEvent_PlayerEquipmentChanged(this)
    end,
    ["UNIT_INVENTORY_CHANGED"] = function(this, arg1)
        if arg1 ~= "player" then return end
        HealBot_Model:NotifyObservers("EQUIPMENT_CHANGED", arg1)
        HealBot_OnEvent_PlayerEquipmentChanged2(this, arg1)
    end,
    ["UNIT_PET"] = function(this, arg1) HealBot_OnEvent_PartyMembersChanged(this) end,
    ["SPELLS_CHANGED"] = function(this, arg1) HealBot_OnEvent_SpellsChanged(this, arg1) end,
    ["UPDATE_SHAPESHIFT_FORM"] = function(this) HealBot_UpdateShapeshiftForm() end,
    ["UPDATE_SHAPESHIFT_FORMS"] = function(this) HealBot_UpdateShapeshiftForm() end
}

-- HealBot_OnEvent: Event dispatcher for WoW UI events.
function HealBot_OnEvent(this, event, arg1, arg2, arg3, arg4)
    local handler = HealBot_EventHandlers[event]
    if handler then
        handler(this, arg1, arg2, arg3, arg4)
    else
        HealBot_AddDebug("OnEvent (" .. event .. ")")
    end
end

-- HealBot_OnEvent_VariablesLoaded: Applies config defaults and initializes state.
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

    if not HealBot_PartyFrameHooked then
        local origShowPartyFrame = ShowPartyFrame;
        ShowPartyFrame = function()
            if HealBot_Config.HideParty == 1 then
                if HidePartyFrame then HidePartyFrame(); end
            elseif origShowPartyFrame then
                origShowPartyFrame();
            end
        end
        HealBot_PartyFrameHooked = true;
    end
    
    if HealBot_Config.HideParty == 1 and HidePartyFrame then
        HidePartyFrame();
    end
    
    if class == "PRIEST" or class == "DRUID" or class == "PALADIN" or class == "SHAMAN" then
        HealBot_BonusScanner:ScanEquipment();

        HealBot_Action_ShowFrame();

        this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
        this:RegisterEvent("PLAYER_REGEN_DISABLED");
        this:RegisterEvent("PLAYER_REGEN_ENABLED");
        this:RegisterEvent("PLAYER_TARGET_CHANGED");
        this:RegisterEvent("PARTY_MEMBERS_CHANGED");
        this:RegisterEvent("RAID_ROSTER_UPDATE");
        this:RegisterEvent("RAID_TARGET_UPDATE");
        this:RegisterEvent("PARTY_MEMBER_DISABLE");
        this:RegisterEvent("PARTY_MEMBER_ENABLE");
        this:RegisterEvent("UNIT_PET");
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
        this:RegisterEvent("UNIT_AURA");
        this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
        this:RegisterEvent("UNIT_INVENTORY_CHANGED");
        this:RegisterEvent("CHAT_MSG_ADDON");
        this:RegisterEvent("CHAT_MSG_SYSTEM");
        this:RegisterEvent("PLAYER_ENTERING_WORLD");
        if class == "DRUID" then
            this:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
            this:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
            HealBot_UpdateShapeshiftForm();
        end
        HealBot_SpellsInitFlag = 2;
    end
end

-- HealBot_OnEvent_UnitHealth: Internal utility: HealBot_OnEvent_UnitHealth
function HealBot_OnEvent_UnitHealth(this, unit)
    if (not HealBot_Heals[unit]) then return end
    HealBot_CheckCasting(unit);
    if unit == HealBot_Action_TooltipUnit then
        HealBot_Action_RefreshTooltip(HealBot_Action_TooltipUnit);
    end
end

-- HealBot_OnEvent_UnitMana: Internal utility: HealBot_OnEvent_UnitMana
function HealBot_OnEvent_UnitMana(this, unit)
    if (unit ~= "player") then return end
    HealBot_RecalcHeals();
end

-- HealBot_OnEvent_ZoneChanged: Internal utility: HealBot_OnEvent_ZoneChanged
function HealBot_OnEvent_ZoneChanged(this)
    HealBot_ResetRangeScale();
    HealBot_Delay_RecalcParty = 1;
end

-- HealBot_OnEvent_PlayerRegenDisabled: Internal utility: HealBot_OnEvent_PlayerRegenDisabled
function HealBot_OnEvent_PlayerRegenDisabled(this)
  -- Removed HealBot_RecalcParty();
  if (UnitIsDeadOrGhost("player")) or (UnitOnTaxi("player")) then
    if HealBot_Config.AutoClose==1 and HealBot_Config.ActionVisible~=0 then 
      HealBot_Action.ProgrammaticHide = true;
      HealBot_Action:Hide(); 
      HealBot_Action.ProgrammaticHide = nil;
    end;
  else
    HealBot_Action_ShowFrame();
    
    -- Reapply user settings to override the engine's white default
    if HealBot_Config and HealBot_Config.Current_Skin then
      local skin = HealBot_Config.Current_Skin;
      if HealBot_Config.backcolr and HealBot_Config.backcolr[skin] then
        HealBot_Action:SetBackdropColor(
          HealBot_Config.backcolr[skin],
          HealBot_Config.backcolg[skin],
          HealBot_Config.backcolb[skin],
          HealBot_Config.backcola[skin]
        );
        HealBot_Action:SetBackdropBorderColor(
          HealBot_Config.borcolr[skin],
          HealBot_Config.borcolg[skin],
          HealBot_Config.borcolb[skin],
          HealBot_Config.borcola[skin]
        );
      end
    end

    HealBot_IsFighting = true;
  end
--  HealBot_RecalcHeals();
end

-- HealBot_OnEvent_PlayerRegenEnabled: Internal utility: HealBot_OnEvent_PlayerRegenEnabled
function HealBot_OnEvent_PlayerRegenEnabled(this)
    HealBot_IsFighting = false;
    HealBot_Delay_RecalcParty = 1;
end

-- HealBot_OnEvent_PlayerTargetChanged: Internal utility: HealBot_OnEvent_PlayerTargetChanged
function HealBot_OnEvent_PlayerTargetChanged(this)
    if HealBot_Action_UnitButtons and HealBot_Action_UnitButtons["target"] then
        HealBot_View_DirtyUnits["target"] = true
        HealBot_OnEvent_UnitAura(nil, "target");
    end
end

-- HealBot_OnEvent_PartyMembersChanged: Internal utility: HealBot_OnEvent_PartyMembersChanged
function HealBot_OnEvent_PartyMembersChanged(this)
    HealBot_Model:PreserveStateByGUID()
    HealBot_Integrations_PruneNampower()
    if HealBot_IsFighting then
        HealBot_Action_PartyChanged()
    end
    HealBot_Delay_RecalcParty = 1;
end

-- HealBot_OnEvent_PartyMemberDisable: Internal utility: HealBot_OnEvent_PartyMemberDisable
function HealBot_OnEvent_PartyMemberDisable(this, unit)
    HealBot_RecalcHeals();  
end

-- HealBot_OnEvent_SystemMsg: Internal utility: HealBot_OnEvent_SystemMsg
function HealBot_OnEvent_SystemMsg(this, msg)
    if type(msg) == "string" then
        local tmpTest, tmpTest, deserter = string.find(msg, HEALBOT_HASLEFTRAID);
        if not deserter then
            local tmpTest, tmpTest, deserter = string.find(msg, HEALBOT_HASLEFTPARTY);
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
        elseif msg == HEALBOT_YOULEAVETHEGROUP or msg == HEALBOT_YOULEAVETHERAID then
            HealBot_Delay_RecalcParty = 1;
        end
    end
end

-- HealBot_OnEvent_PartyMemberEnable: Internal utility: HealBot_OnEvent_PartyMemberEnable
function HealBot_OnEvent_PartyMemberEnable(this, unit)
    HealBot_RecalcHeals();
end

-- HealBot_OnEvent_PlayerEquipmentChanged: Internal utility: HealBot_OnEvent_PlayerEquipmentChanged
function HealBot_OnEvent_PlayerEquipmentChanged(this)
    HealBot_EquipChangeTimer = 1;
end

-- HealBot_OnEvent_PlayerEquipmentChanged2: Internal utility: HealBot_OnEvent_PlayerEquipmentChanged2
function HealBot_OnEvent_PlayerEquipmentChanged2(this, unit)
    if unit == "player" then
        HealBot_EquipChangeTimer = 1;
    end
end

-- HealBot_OnEvent_SpellsChanged: Internal utility: HealBot_OnEvent_SpellsChanged
function HealBot_OnEvent_SpellsChanged(this, arg1)
    if arg1 then return; end
    HealBot_AddDebug("HB: SpellsChanged");
    HealBot_SpellsInitFlag = 2;
end

-- HealBot_OnEvent_TalentsChanged: Internal utility: HealBot_OnEvent_TalentsChanged
function HealBot_OnEvent_TalentsChanged(this, arg1)
    HealBot_AddDebug("HB: TalentsChanged");
end

-- HealBot_OnEvent_PlayerEnteringWorld: Internal utility: HealBot_OnEvent_PlayerEnteringWorld
function HealBot_OnEvent_PlayerEnteringWorld(this)
    HealBot_IsFighting = false;
    -- Re-apply the refresh hook late in case another addon overrode it during load
    if HealBot_ApplyRefreshHook then
        HealBot_ApplyRefreshHook()
    end
end

-- HealBot_OnEvent_SpellcastStart: Internal utility: HealBot_OnEvent_SpellcastStart
function HealBot_OnEvent_SpellcastStart(this, spell, duration)
    HealBot_IsCasting = true;
    HealBot_PendingShapeshiftCast = nil;
    HealBot_RecalcHeals();
    HealBot_CheckCasting();
    if spell == HEALBOT_RESURRECTION or spell == HEALBOT_ANCESTRALSPIRIT or spell == HEALBOT_REBIRTH or spell == HEALBOT_REDEMPTION then
        if UnitName("Target") then 
            HealBot_SendAddonMessage("CTRA", "RES " .. UnitName("Target"));
            HealBot_IamRessing = true;
        end
    end
end

-- HealBot_OnEvent_SpellcastStop: Internal utility: HealBot_OnEvent_SpellcastStop
function HealBot_OnEvent_SpellcastStop(this, eventName)
    HealBot_IsCasting = false;
    if eventName == "SPELLCAST_FAILED" or eventName == "SPELLCAST_INTERRUPTED" then
        HealBot_CastFailed = true;
        if HealBot_PendingShapeshiftCast then
            return;
        end
    end
    
    if HealBot_PendingShapeshiftCast and eventName == "SPELLCAST_STOP" then
        if HealBot_CastFailed or not HealBot_PendingShapeshiftCast.started then
            -- This STOP is either the trailing event of a failed/interrupted cast,
            -- or it is the STOP event from the unshift spell itself.
            -- Do not wipe the queue yet!
            return;
        end
    end

    HealBot_PendingShapeshiftCast = nil;
    HealBot_StopCasting();
    HealBot_RecalcHeals();
    if HealBot_IamRessing then
        HealBot_SendAddonMessage("CTRA", "RESNO");
        HealBot_IamRessing = false;
    end
end
