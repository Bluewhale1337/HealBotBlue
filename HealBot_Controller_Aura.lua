-- HealBot_Controller_Aura.lua
-- Handles tracking buffs/debuffs (auras) on group/raid units

HealBot_MissingBuffs = {}
local StaticHasBuff = {}

-- HealBot_UnitAffected: Checks if a specific buff/debuff exists on a unit.
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

-- HealBot_CheckShamanWeaponBuff: Checks for Shaman weapon enchants via API.
function HealBot_CheckShamanWeaponBuff(spellName)
    local hasMainHandEnchant, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
    if not (hasMainHandEnchant or hasOffHandEnchant) then return false end
    
    local firstWord = string.match(spellName, "^(%w+)")
    if not firstWord then return false end

    HealBot_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    local slots = HealBot_GetTable()
    if hasMainHandEnchant then table.insert(slots, 16) end
    if hasOffHandEnchant then table.insert(slots, 17) end
    
    for _, slot in ipairs(slots) do
        HealBot_ScanTooltip:ClearLines()
        HealBot_ScanTooltip:SetInventoryItem("player", slot)
        for i = 1, HealBot_ScanTooltip:NumLines() do
            local textObj = getglobal("HealBot_ScanTooltipTextLeft" .. i)
            if textObj then
                local text = textObj:GetText()
                if text and string.find(text, firstWord) then
                    HealBot_ScanTooltip:Hide()
                    HealBot_ReleaseTable(slots)
                    return true
                end
            end
        end
    end
    
    HealBot_ScanTooltip:Hide()
    HealBot_ReleaseTable(slots)
    return false
end

-- HealBot_CheckBuffs: Scans unit for missing tracked buffs.
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
    local hasBuff = StaticHasBuff
    for k in pairs(hasBuff) do
        hasBuff[k] = nil
    end
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
                if not (isSelfOnly and not UnitIsUnit(unit, "player")) then
                    local spellName = HealBot_Buff_Spells[myClass][val]
                    
                    local hasIt = hasBuff[spellName]
                    if not hasIt and HealBot_Buff_Equivalents[spellName] then
                        hasIt = hasBuff[HealBot_Buff_Equivalents[spellName]]
                    end
                    
                    if not hasIt then
                        if myClass == HEALBOT_SHAMAN and UnitIsUnit(unit, "player") and string.find(spellName, " Weapon") then
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

local HealBot_TrackedHoTs = {
    ["Interface\\Icons\\Spell_Holy_Renew"] = true,
    ["Interface\\Icons\\Spell_Nature_Rejuvenation"] = true,
    ["Interface\\Icons\\Spell_Nature_ResistNature"] = true,
    ["Interface\\Icons\\Spell_Holy_PowerWordShield"] = true,
    ["Interface\\Icons\\Spell_Holy_SealOfProtection"] = true,
    ["Interface\\Icons\\Spell_Holy_Excorcism"] = true,
    ["Interface\\Icons\\btnholyscriptures"] = true,
    ["Interface\\Icons\\Spell_Holy_AshesToAshes"] = true,
}

local HealBot_DebuffTypeMap = nil

-- HealBot_OnEvent_UnitAura: Updates debuff lists and icon textures on aura change.
function HealBot_OnEvent_UnitAura(this, unit)
    if not HealBot_DebuffTypeMap then
        HealBot_DebuffTypeMap = {
            [HEALBOT_DISEASE] = HEALBOT_DISEASE_en,
            [HEALBOT_MAGIC] = HEALBOT_MAGIC_en,
            [HEALBOT_POISON] = HEALBOT_POISON_en,
            [HEALBOT_CURSE] = HEALBOT_CURSE_en
        }
    end
    
    local DebuffType;
    
    if HealBot_Heals[unit] then
        if not HealBot_UnitIcons[unit] then
            HealBot_UnitIcons[unit] = {}
        end
        for j = 1, 10 do
            HealBot_UnitIcons[unit][j] = nil
        end
        local iconCount = 0
        local i = 1;
        HealBot_UnitDebuff[unit] = nil;
        
        while true do
            local debuff, tmp, debuff_type = UnitDebuff(unit, i)
            if debuff then
                local mapped_type = nil
                if debuff_type then
                    mapped_type = HealBot_DebuffTypeMap[debuff_type] or debuff_type
                end
                
                local unitClass = HealBot_Model.units[unit] and HealBot_Model.units[unit].class or UnitClass(unit)
                local shouldTrack = false
                if unit == "target" then
                    shouldTrack = true
                elseif HealBot_CDCInc[unitClass] == 1 then
                    shouldTrack = true
                elseif not unitClass or HealBot_CDCInc[unitClass] == nil then
                    shouldTrack = true
                end

                if iconCount < 10 then
                    iconCount = iconCount + 1
                    HealBot_UnitIcons[unit][iconCount] = debuff
                end

                if shouldTrack and mapped_type and HealBot_DebuffWatch[mapped_type] then
                    HealBot_UnitDebuff[unit] = mapped_type
                    DebuffType = mapped_type;
                    
                    local isPriority = false
                    if HealBot_DebuffPriority then
                        for _, pType in ipairs(HealBot_DebuffPriority) do
                            if pType == mapped_type then
                                isPriority = true
                                break
                            end
                        end
                    end
                    if isPriority then
                        break
                    end
                end
                i = i + 1;
            else
                break
            end 
        end
        
        local b = 1
        while true do
            local buff = UnitBuff(unit, b)
            if not buff then break end
            if HealBot_TrackedHoTs[buff] and iconCount < 10 then
                iconCount = iconCount + 1
                HealBot_UnitIcons[unit][iconCount] = buff
            end
            b = b + 1
        end

        local d = 1
        while true do
            local debuff = UnitDebuff(unit, d)
            if not debuff then break end
            if HealBot_TrackedHoTs[debuff] and iconCount < 10 then
                iconCount = iconCount + 1
                HealBot_UnitIcons[unit][iconCount] = debuff
            end
            d = d + 1
        end
        
        if HealBot_UnitDebuff[unit] then
            if DebuffType and HealBot_Range_Check(unit, 27) == 1 then
                if HealBot_Config.ShowDebuffWarning == 1 then
                    local color = HealBot_Config.CDCBarColour[DebuffType]
                    local r, g, b = 1, 0, 0
                    if color then
                        r, g, b = color.R, color.G, color.B
                    end
                    UIErrorsFrame:AddMessage(UnitName(unit) .. " suffers from " .. DebuffType, 
                                             r, g, b,
                                             1, UIERRORS_HOLD_TIME);
                end
                if HealBot_Config.SoundDebuffWarning == 1 then HealBot_PlaySound(HealBot_Config.SoundDebuffPlay); end
            end
        end
        -- Check buffs synchronously because tooltip scanning fails in OnUpdate
        HealBot_CheckBuffs(unit)
        
        -- Defer UI updates
        HealBot_View_DirtyUnits[unit] = true
    end
end
