-- HealBot_Controller_Aura.lua
-- Handles tracking buffs/debuffs (auras) on group/raid units

HealBot_MissingBuffs = {}

function HealBot_UnitAffected(unit, effect)
    if not effect then return nil; end
    local i = 1
    while true do
        local buff = UnitBuff(unit, i)
        if not buff then
            break
        end
        if buff == effect then
            return buff
        end
        i = i + 1
    end
    i = 1
    while true do
        local debuff = UnitDebuff(unit, i)
        if not debuff then
            break
        end
        if debuff == effect then
            return debuff
        end
        i = i + 1
    end
    return nil;
end

function HealBot_CheckShamanWeaponBuff(spellName)
    local hasMainHandEnchant, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
    if hasMainHandEnchant or hasOffHandEnchant then
        return true
    end
    return false
end

function HealBot_CheckBuffs(unit)
    if HealBot_Config.BuffWatch ~= 1 then
        HealBot_MissingBuffs[unit] = nil
        return
    end
    
    local inCombat = UnitAffectingCombat("player") or UnitAffectingCombat(unit)
    if inCombat and HealBot_Config.BuffWatchInCombat ~= 1 then
        HealBot_MissingBuffs[unit] = nil
        return
    end
    
    local myClass = UnitClass("player")
    if not HealBot_Buff_Spells[myClass] then return end
    
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        HealBot_MissingBuffs[unit] = nil
        return
    end
    
    -- Group Buff Equivalents
    local HealBot_Buff_Equivalents = {
        [HEALBOT_POWER_WORD_FORTITUDE] = HEALBOT_PRAYER_OF_FORTITUDE,
        [HEALBOT_DIVINE_SPIRIT] = HEALBOT_PRAYER_OF_SPIRIT,
        [HEALBOT_SHADOW_PROTECTION] = HEALBOT_PRAYER_OF_SHADOW_PROTECTION,
        [HEALBOT_ARCANE_INTELLECT] = HEALBOT_ARCANE_BRILLIANCE,
        [HEALBOT_MARK_OF_THE_WILD] = HEALBOT_GIFT_OF_THE_WILD,
    }
    
    -- Gather buffs on unit
    local hasBuff = {}
    local i = 1
    while true do
        local buffTexture = UnitBuff(unit, i)
        if not buffTexture then break end
        HealBot_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        HealBot_ScanTooltip:ClearLines()
        HealBot_ScanTooltip:SetUnitBuff(unit, i)
        local buffName = HealBot_ScanTooltipTextLeft1:GetText()
        if buffName then
            hasBuff[buffName] = true
        end
        i = i + 1
    end
    HealBot_ScanTooltip:Hide()

    HealBot_MissingBuffs[unit] = nil
    
    if HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] then
        for j = 1, 8 do
            local val = HealBot_Config.BuffDropDowns[myClass][j]
            if val and val > 0 then
                local isSelfOnly = (HealBot_Config.BuffWatchSelf and HealBot_Config.BuffWatchSelf[j] == 1)
                if not (isSelfOnly and unit ~= "player") then
                    local spellName = HealBot_Buff_Spells[myClass][val]
                    
                    local hasIt = hasBuff[spellName]
                    if not hasIt and HealBot_Buff_Equivalents[spellName] then
                        hasIt = hasBuff[HealBot_Buff_Equivalents[spellName]]
                    end
                    
                    if not hasIt then
                        if myClass == "SHAMAN" and unit == "player" and string.find(spellName, " Weapon") then
                            hasIt = HealBot_CheckShamanWeaponBuff(spellName)
                        end
                    end
                    
                    if not hasIt then
                        HealBot_MissingBuffs[unit] = spellName
                        break
                    end
                end
            end
        end
    end
end

function HealBot_OnEvent_UnitAura(this, unit)
    local DebuffType;
    
    if HealBot_Heals[unit] and unit ~= "target" then
        HealBot_UnitIcons[unit] = {}
        local iconCount = 0
        
        local HealBot_TrackedHoTs = {
            ["Interface\\Icons\\Spell_Holy_Renew"] = true,
            ["Interface\\Icons\\Spell_Nature_Rejuvenation"] = true,
            ["Interface\\Icons\\Spell_Nature_ResistNature"] = true,
            ["Interface\\Icons\\Spell_Holy_PowerWordShield"] = true,
            ["Interface\\Icons\\Spell_Holy_SealOfProtection"] = true,
            ["Interface\\Icons\\Spell_Holy_Excorcism"] = true,
        }
        
        local i = 1;
        while true do
            local debuff, tmp, debuff_type = UnitDebuff(unit, i, 1)
            if debuff then
                if iconCount < 5 then
                    iconCount = iconCount + 1
                    HealBot_UnitIcons[unit][iconCount] = debuff
                end
                if HealBot_CDCInc[UnitClass(unit)] == 1 and HealBot_DebuffWatch[debuff_type] == "YES" then
                    HealBot_UnitDebuff[unit] = debuff_type
                    DebuffType = debuff_type;
                    if HealBot_DebuffPriority[debuff_type] then
                        break
                    end
                end
                i = i + 1;
            else
                if i == 1 then HealBot_UnitDebuff[unit] = nil; end
                break
            end 
        end
        
        local b = 1
        while true do
            local buff = UnitBuff(unit, b)
            if not buff then break end
            if HealBot_TrackedHoTs[buff] and iconCount < 5 then
                iconCount = iconCount + 1
                HealBot_UnitIcons[unit][iconCount] = buff
            end
            b = b + 1
        end
        
        if HealBot_UnitDebuff[unit] then
            if DebuffType and HealBot_Range_Check(unit, 27) == 1 then
                if HealBot_Config.ShowDebuffWarning == 1 then
                    UIErrorsFrame:AddMessage(UnitName(unit) .. " suffers from " .. DebuffType, 
                                             HealBot_Config.CDCBarColour[DebuffType].R,
                                             HealBot_Config.CDCBarColour[DebuffType].G,
                                             HealBot_Config.CDCBarColour[DebuffType].B,
                                             1, UIERRORS_HOLD_TIME);
                end
                if HealBot_Config.SoundDebuffWarning == 1 then HealBot_PlaySound(HealBot_Config.SoundDebuffPlay); end
            end
        end
        HealBot_CheckBuffs(unit);
        HealBot_RecalcHeals(unit);
    end
end
