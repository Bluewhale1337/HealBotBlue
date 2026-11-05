HealBot_Integrations_UnitXP_Active = false;
HealBot_Integrations_Nampower_Active = false;
HealBot_Integrations_SuperWoW_Active = false;
HealBot_Integrations_ClassicAPI_Active = false;

-- HealBot_GetUnitGUID: Internal utility: HealBot_GetUnitGUID
function HealBot_GetUnitGUID(unit)
    if not unit then return nil end
    if HealBot_Integrations_ClassicAPI_Active and UnitGUID then
        return UnitGUID(unit)
    elseif HealBot_Integrations_SuperWoW_Active and GetUnitGUID then
        return GetUnitGUID(unit)
    elseif HealBot_Integrations_Nampower_Active and GetUnitGUID then
        return GetUnitGUID(unit)
    end
    return nil
end

-- HealBot_Integrations_Toggle: Enables or disables external addon APIs on load/click.
function HealBot_Integrations_Toggle()
  -- UnitXP
  if HealBot_Config.HealBot_Integrations_UnitXP == 1 and UnitXP ~= nil then
    HealBot_Integrations_UnitXP_Active = true;
    HealBot_AddDebug("UnitXP Integration: ENABLED");
  else
    HealBot_Integrations_UnitXP_Active = false;
    HealBot_AddDebug("UnitXP Integration: DISABLED");
  end

  -- nampower
  if HealBot_Config.HealBot_Integrations_Nampower == 1 then
    HealBot_Integrations_Nampower_Active = true;
    HealBot_AddDebug("nampower Integration: ENABLED");
    if not HealBot_NampowerFrame then
        HealBot_Nampower_Auras = {}
        HealBot_NampowerFrame = CreateFrame("Frame")
        HealBot_NampowerFrame:RegisterEvent("AURA_CAST_ON_SELF")
        HealBot_NampowerFrame:RegisterEvent("AURA_CAST_ON_OTHER")
        HealBot_NampowerFrame:SetScript("OnEvent", function()
            if not HealBot_Integrations_Nampower_Active then return end
            if event == "AURA_CAST_ON_SELF" or event == "AURA_CAST_ON_OTHER" then
                local spellID, caster, target, _, _, _, _, duration = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8
                if not caster or not target or not duration or duration <= 0 then return end
                
                -- The player is ALWAYS the caster in these events for Nampower
                if not HealBot_PlayerGUID then
                    HealBot_PlayerGUID = caster
                    if HealBot_Model and HealBot_Model.unitGUIDs then
                        HealBot_Model.unitGUIDs["player"] = caster
                        HealBot_Model.guidUnits[caster] = "player"
                    end
                end
                
                local spellName = GetSpellRecField(spellID, "name")
                if not spellName then return end
                
                if not HealBot_Nampower_Auras[target] then
                    HealBot_Nampower_Auras[target] = HealBot_GetTable()
                end
                
                local expirationTime = GetTime() + (duration / 1000)
                HealBot_Nampower_Auras[target][spellName] = expirationTime
                
                if not HealBot_Nampower_NameCache then HealBot_Nampower_NameCache = HealBot_GetTable() end
                if event == "AURA_CAST_ON_SELF" then
                    HealBot_Nampower_NameCache[target] = UnitName("player")
                    HealBot_OnEvent_UnitAura(nil, "player")
                else
                    local tName = nil
                    if UnitExists("target") then
                        local curTargetGuid = HealBot_GetUnitGUID and HealBot_GetUnitGUID("target")
                        if curTargetGuid and (curTargetGuid == target or string.lower(curTargetGuid) == string.lower(target)) then
                            tName = UnitName("target")
                        end
                    end
                    local unitID = HealBot_Model and HealBot_Model:GetUnitByGUID(target)
                    if not unitID and HealBot_PlayerGUID and (target == HealBot_PlayerGUID or string.lower(target) == string.lower(HealBot_PlayerGUID)) then
                        unitID = "player"
                    end
                    if not tName and unitID then
                        tName = UnitName(unitID) or (HealBot_Model and HealBot_Model.units[unitID] and HealBot_Model.units[unitID].name)
                    end
                    if tName then
                        HealBot_Nampower_NameCache[target] = tName
                    end
                    if unitID then
                        HealBot_OnEvent_UnitAura(nil, unitID)
                    end
                end
            end
        end)
    end
  else
    HealBot_Integrations_Nampower_Active = false;
    HealBot_AddDebug("nampower Integration: DISABLED");
    if HealBot_Nampower_Auras then
        for k, v in pairs(HealBot_Nampower_Auras) do
            HealBot_ReleaseTable(v)
            HealBot_Nampower_Auras[k] = nil
        end
    end
  end

  -- SuperWoW
  if HealBot_Config.HealBot_Integrations_SuperWoW == 1 and UnitExists ~= nil then
    -- We can check if GetUnitGUID exists as a quick SuperWoW test, or UnitExists returns 2 args
    -- Actually SuperWoW adds SpellInfo, or we can just rely on GetUnitGUID if it exists in the environment
    if GetUnitGUID or (type(UnitExists) == "function") then
        -- If the client actually supports GUID tracking via SuperWoW (or a similar mod)
        HealBot_Integrations_SuperWoW_Active = true;
        HealBot_AddDebug("SuperWoW Integration: ENABLED");
    else
        HealBot_Integrations_SuperWoW_Active = false;
        HealBot_AddDebug("SuperWoW Integration: DISABLED (Mod Not Found)");
    end
  else
    HealBot_Integrations_SuperWoW_Active = false;
    HealBot_AddDebug("SuperWoW Integration: DISABLED");
  end

  -- ClassicAPI
  if HealBot_Config.HealBot_Integrations_ClassicAPI == 1 then
    if UnitGUID then 
        HealBot_Integrations_ClassicAPI_Active = true;
        HealBot_AddDebug("ClassicAPI Integration: ENABLED");
    else
        HealBot_Integrations_ClassicAPI_Active = false;
        HealBot_AddDebug("ClassicAPI Integration: DISABLED (Mod Not Found)");
    end
  else
    HealBot_Integrations_ClassicAPI_Active = false;
    HealBot_AddDebug("ClassicAPI Integration: DISABLED");
  end
  
  if HealBot_Model and HealBot_Model.PopulateAllGUIDs then
    HealBot_Model:PopulateAllGUIDs()
  end
  
  if HealBot_Options_Integrations_ShowHoTTimers then
    if HealBot_Integrations_Nampower_Active or HealBot_Integrations_SuperWoW_Active or HealBot_Integrations_ClassicAPI_Active then
      HealBot_Options_Integrations_ShowHoTTimers:Enable()
      getglobal(HealBot_Options_Integrations_ShowHoTTimers:GetName().."Text"):SetTextColor(1, 1, 1)
    else
      HealBot_Options_Integrations_ShowHoTTimers:Disable()
      getglobal(HealBot_Options_Integrations_ShowHoTTimers:GetName().."Text"):SetTextColor(0.5, 0.5, 0.5)
      HealBot_Options_Integrations_ShowHoTTimers:SetChecked(0)
      HealBot_Config.HealBot_Integrations_ShowHoTTimers = 0
    end
    if HealBot_Options_Integrations_UpdateDropdownStates then
      HealBot_Options_Integrations_UpdateDropdownStates()
    end
  end
end

function HealBot_Integrations_PruneNampower()
    if not HealBot_Integrations_Nampower_Active or not HealBot_Nampower_Auras then return end
    
    local currentTime = GetTime()
    for targetName, auras in pairs(HealBot_Nampower_Auras) do
        -- Check if target is still in the raid/party, or is the player
        local isPlayer = (HealBot_PlayerGUID and string.lower(targetName) == string.lower(HealBot_PlayerGUID))
                         or (UnitName("player") and string.lower(targetName) == string.lower(UnitName("player")))
        if not isPlayer and not HealBot_Model:GetUnitByGUID(targetName) and not HealBot_Model:GetUnitIDByName(targetName) then
            HealBot_ReleaseTable(auras)
            HealBot_Nampower_Auras[targetName] = nil
        else
            -- Prune expired auras
            local hasAuras = false
            for spellName, expiration in pairs(auras) do
                if currentTime > expiration then
                    auras[spellName] = nil
                else
                    hasAuras = true
                end
            end
            if not hasAuras then
                HealBot_ReleaseTable(auras)
                HealBot_Nampower_Auras[targetName] = nil
            end
        end
    end
end
