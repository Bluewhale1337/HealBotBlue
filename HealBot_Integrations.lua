HealBot_Integrations_UnitXP_Active = false;
HealBot_Integrations_Nampower_Active = false;
HealBot_Integrations_SuperWoW_Active = false;
HealBot_Integrations_ClassicAPI_Active = false;

function HealBot_GetUnitGUID(unit)
    if not unit then return nil end
    if HealBot_Integrations_ClassicAPI_Active and UnitGUID then
        return UnitGUID(unit)
    elseif HealBot_Integrations_SuperWoW_Active and GetUnitGUID then
        return GetUnitGUID(unit)
    end
    return nil
end

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
            local spellID, caster, target, _, _, _, _, duration = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8
            if not caster or not target or duration <= 0 then return end
            
            local spellName = GetSpellRecField(spellID, "name")
            if not spellName then return end
            
            if not HealBot_Nampower_Auras[target] then
                HealBot_Nampower_Auras[target] = {}
            end
            
            local expirationTime = GetTime() + (duration / 1000)
            HealBot_Nampower_Auras[target][spellName] = expirationTime
            
            local unitID = HealBot_Model:GetUnitIDByName(target)
            if unitID then
                HealBot_OnEvent_UnitAura(nil, unitID)
            end
        end)
    end
  else
    HealBot_Integrations_Nampower_Active = false;
    HealBot_AddDebug("nampower Integration: DISABLED");
    if HealBot_Nampower_Auras then
        for k in pairs(HealBot_Nampower_Auras) do
            HealBot_Nampower_Auras[k] = nil
        end
    end
  end



function HealBot_Integrations_PruneNampower()
    if not HealBot_Integrations_Nampower_Active or not HealBot_Nampower_Auras then return end
    
    local currentTime = GetTime()
    for targetName, auras in pairs(HealBot_Nampower_Auras) do
        -- Check if target is still in the raid/party
        if not HealBot_Model:GetUnitIDByName(targetName) then
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
                HealBot_Nampower_Auras[targetName] = nil
            end
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
end
