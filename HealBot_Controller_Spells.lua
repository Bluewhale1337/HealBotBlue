-- HealBot_Controller_Spells.lua
-- Centralized Spell management, calculation, and casting logic

HealBot_CastingSpell  = nil;
HealBot_CastingTarget = nil;
HealBot_TargetRestorePending = nil;
HealBot_TargetRestoreTimer = 0;

local HealBot_Health60 = {
  ["DRUID"]   = 3500,
  ["MAGE"]    = 2500,
  ["HUNTER"]  = 3500,
  ["PALADIN"] = 4000,
  ["PRIEST"]  = 2500,
  ["ROGUE"]   = 3500,
  ["SHAMAN"]  = 3800,
  ["WARLOCK"] = 3500,
  ["WARRIOR"] = 5000,
}

-- HealBot_GetSpellName: Internal utility: HealBot_GetSpellName
function HealBot_GetSpellName(id)
  if (not id) then
    return nil;
  end
  local spellName, subSpellName = GetSpellName(id, BOOKTYPE_SPELL);
  if (not spellName) then
    return nil;
  end
  if (not subSpellName or subSpellName == "") then
    return spellName;
  end
  return spellName .. " (" .. subSpellName .. ")";
end

-- HealBot_GetSpellId: Internal utility: HealBot_GetSpellId
function HealBot_GetSpellId(spell)
  local id, idd = 1, 0; 
  while true do 
    local spellName, subSpellName = GetSpellName(id, BOOKTYPE_SPELL);
    if (spellName) then
      if (spell == spellName .. " (" .. subSpellName .. ")") or (spell == spellName .. "(" .. subSpellName .. ")") then
        return id;
      end
      if (spell == spellName) then
        idd = id;
      end   
    else
      break
    end
    id = id + 1;
  end
  if idd > 0 then
    return idd
  else
    return nil;
  end
end

-- HealBot_CastSpellByName: Internal utility: HealBot_CastSpellByName
function HealBot_CastSpellByName(spell)
  if (HealBot_Spells[spell] and HealBot_Spells[spell].BagSlot) then
    HealBot_UseItem(spell);
    return;
  end
  local id;
  if not HealBot_Spells[spell] then
    id = HealBot_GetSpellId(spell);
  elseif HealBot_Spells[spell].id then
    id = HealBot_Spells[spell].id
  else
    id = HealBot_GetSpellId(spell);
  end
  if (not id) then
    return;
  end
  CastSpell(id, BOOKTYPE_SPELL);
end

-- HealBot_AnnounceCast: Internal utility: HealBot_AnnounceCast
function HealBot_AnnounceCast(spell, target)
  if not spell or not target then return end

  if UnitIsDeadOrGhost(target) then
      local spellLower = string.lower(spell)
      if not (string.find(spellLower, "resurrection") or string.find(spellLower, "ancestral spirit") or string.find(spellLower, "redemption") or string.find(spellLower, "rebirth")) then
          return
      end
  end

  if HealBot_Config.ChatMessages then
    local tName = target
    if target == "target" then tName = HealBot_TargetName() or "target" else tName = UnitName(target) end
    if not tName then tName = target end
    local baseSpell = spell
    local parenIndex = string.find(spell, " %(")
    if parenIndex then
      baseSpell = string.sub(spell, 1, parenIndex - 1)
    else
      parenIndex = string.find(spell, "%(")
      if parenIndex then
        baseSpell = string.sub(spell, 1, parenIndex - 1)
      end
    end
    
    -- Strip trailing spaces from base spell
    baseSpell = string.gsub(baseSpell, "%s+$", "")

    for i = 1, 5 do
      local msgConf = HealBot_Config.ChatMessages[i]
      local configSpell = msgConf and msgConf.Spell or ""
      -- Strip trailing spaces from config spell just in case
      configSpell = string.gsub(configSpell, "%s+$", "")
      
      if msgConf and configSpell ~= "" and msgConf.Channel ~= "None" and (configSpell == spell or configSpell == baseSpell) then
        local msg = msgConf.Message or ""
        msg = string.gsub(msg, "#Spell#", spell)
        msg = string.gsub(msg, "#Target#", tName)
        local chan = msgConf.Channel
        if chan == "Say" then
          SendChatMessage(msg, "SAY")
        elseif chan == "Party" and GetNumPartyMembers() > 0 then
          SendChatMessage(msg, "PARTY")
        elseif chan == "Raid" and GetNumRaidMembers() > 0 then
          SendChatMessage(msg, "RAID")
        elseif chan == "Whisper" and UnitIsPlayer(target) then
          SendChatMessage(msg, "WHISPER", nil, tName)
        end
      end
    end
  end
end

-- HealBot_Process_HealValue: Internal utility: HealBot_Process_HealValue
function HealBot_Process_HealValue(spell, target)
  if HealBot_Spells[spell] and (HealBot_Spells[spell].CastTime or 0) > 1 then
    HealBot_HealValue = HealBot_Spells[spell].HealsDur;
    
    -- Apply dynamic Preservation bonus
    if HEALBOT_REGROWTH and string.find(spell, HEALBOT_REGROWTH) then
      local presRank = HealBot_GetTalentRank("Preservation")
      if presRank > 0 then
        local hasRejuv = false
        for i=1,32 do
          local buff = UnitBuff(target, i)
          if not buff then break end
          if string.find(buff, "Spell_Nature_Rejuvenation") then
            hasRejuv = true
            break
          end
        end
        if hasRejuv then
           local extHeal = HealBot_Spells[spell].HealsExt or 0
           local bonus = extHeal * (presRank * 0.10)
           HealBot_HealValue = HealBot_HealValue + math.floor(bonus)
        end
      end
    end
    local uname = UnitName(target)
    if uname then
      HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. uname .. " <<=>> " .. HealBot_HealValue .. " << ");
      if not HealBot_HealsIn[uname] then
          HealBot_HealsIn[uname] = 0;
      end
      HealBot_HealsIn[uname] = HealBot_HealsIn[uname] + HealBot_HealValue;
      HealBot_RecalcHeals(HealBot_FindUnitID(uname));
    end
  end
end

-- HealBot_StartCasting: Initiates spell cast and broadcasts incoming heal.
function HealBot_StartCasting(spell, target, ttype)
  HealBot_CastFailed = false;
  HealBot_CastSpellByName(spell);
  if ( SpellCanTargetUnit(target) ) then 
    SpellTargetUnit(target);
    ttype = "fired";
  elseif SpellIsTargeting() then
    SpellTargetUnit(target);
    SpellStopTargeting()
  elseif ttype == "direct" then
    if ( UnitIsUnit(target, "player") or CheckInteractDistance(target, 4) ) then
      ttype = "fired";
    end
  end

  if ttype == "fired" and HealBot_Spells[spell] then
    if not HealBot_CastFailed then
      HealBot_CastingSpell  = spell;
      HealBot_CastingTarget = target;
      HealBot_Process_HealValue(spell, target);
      HealBot_AnnounceCast(spell, target);
    end
  end
end

-- HealBot_StopCasting: Internal utility: HealBot_StopCasting
function HealBot_StopCasting()
  if HealBot_CastingTarget then
    if HealBot_HealValue > 0 then
      local uname = UnitName(HealBot_CastingTarget)
      if uname then
        HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. uname .. " <<=>> " .. 0 - HealBot_HealValue .. " << ");
        if HealBot_HealsIn[uname] then
           HealBot_HealsIn[uname] = HealBot_HealsIn[uname] - HealBot_HealValue;
           if HealBot_HealsIn[uname] < 0 then
               HealBot_HealsIn[uname] = 0;
           end
           HealBot_RecalcHeals(HealBot_FindUnitID(uname));
        end
      end
      HealBot_HealValue = 0;
    end
  end
  HealBot_CastingSpell  = nil;
  HealBot_CastingTarget = nil;
  local bar = HealBot_Action_HealthBar(HealBot_Action_AbortButton);
  local ar = HealBot_Config.babortcolr[HealBot_Config.Current_Skin] or 0.1;
  local ag = HealBot_Config.babortcolg[HealBot_Config.Current_Skin] or 0.1;
  local ab = HealBot_Config.babortcolb[HealBot_Config.Current_Skin] or 0.5;
  local aa = HealBot_Config.babortcola[HealBot_Config.Current_Skin] or 1;
  bar.txt = getglobal(bar:GetName() .. "_text");
  bar:SetStatusBarColor(ar, ag, ab, 0);
  local sr = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin];
  local sg = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin];
  local sb = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin];
  local sa = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin];
  bar.txt:SetTextColor(sr, sg, sb, sa);
end

-- HealBot_UnitHealth: Internal utility: HealBot_UnitHealth
function HealBot_UnitHealth(unit)
  local Current, Desired = UnitHealth(unit), UnitHealthMax(unit);
  if unit == 'target' and Desired == 100 then
    local class, level = HealBot_UnitClass(unit), UnitLevel(unit);
    if HealBot_Health60[class] and level > 0 then
      Desired = math.floor(HealBot_Health60[class] / 60 * level + 0.5)
    else
      Desired = UnitHealthMax('player');
    end
    Current = Desired / 100 * Current;
  end
  return Current, Desired;
end

-- HealBot_CheckCasting: Internal utility: HealBot_CheckCasting
function HealBot_CheckCasting(unit)
  if not HealBot_CastingSpell or HealBot_AlwaysHeal() then return nil end
  if not HealBot_Spells[HealBot_CastingSpell] then return nil end
  if not unit then unit = HealBot_CastingTarget end
  if unit ~= HealBot_CastingTarget then return nil end

  local bar = HealBot_Action_HealthBar(HealBot_Action_AbortButton);
  local ar = HealBot_Config.babortcolr[HealBot_Config.Current_Skin] or 0.1;
  local ag = HealBot_Config.babortcolg[HealBot_Config.Current_Skin] or 0.1;
  local ab = HealBot_Config.babortcolb[HealBot_Config.Current_Skin] or 0.5;
  local aa = HealBot_Config.babortcola[HealBot_Config.Current_Skin] or 1;
  if not bar.txt then bar.txt = getglobal(bar:GetName() .. "_text") end
  
  if HealBot_IsCasting == false and HealBot_AbortButton == 0 then
    bar:SetStatusBarColor(ar, ag, ab, 0);
    local sr = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin];
    local sg = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin];
    local sb = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin];
    local sa = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin];  
    bar.txt:SetTextColor(sr, sg, sb, sa);
    return nil
  end

  local Current, Desired = HealBot_UnitHealth(unit)
  local Needed = Desired - Current;
  Needed = Needed * (1 + (HealBot_Config.OverHeal * 4));
  if Needed < 0 then Needed = 0 end
  if (Needed > HealBot_Spells[HealBot_CastingSpell].HealsDur) then 
    local sr = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin];
    local sg = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin];
    local sb = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin];
    local sa = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin];
    bar.txt:SetTextColor(sr, sg, sb, sa);
    bar:SetStatusBarColor(ar, ag, ab, 0);
    return nil 
  elseif HealBot_AbortButton == 1 and HealBot_IsCasting == true then
    bar:SetStatusBarColor(ar, ag, ab, aa);
    local sr = HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin];
    local sg = HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin];
    local sb = HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin];
    local sa = HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin];
    bar.txt = getglobal(bar:GetName() .. "_text");
    bar.txt:SetTextColor(sr, sg, sb, sa);
  end
end

-- HealBot_CastSpellOnFriend: Target-safe wrapper for casting spells on allies.
function HealBot_CastSpellOnFriend(spell, target)
  if (not spell or not target or not UnitName(target)) then
    return;
  end
  local targetEnemy = UnitCanAttack("player", "target");
  local oldTarget = UnitName("target");
  
  local formCancelled = false
  if HealBot_UnitClass("player") == "DRUID" and HealBot_Config.AutoUnshift == 1 then
    local currentForm = HealBot_GetShapeshiftForm()
    if currentForm then
        CastShapeshiftForm(currentForm);
        formCancelled = true
    end
  end
  
  if formCancelled then
    HealBot_PendingShapeshiftCast = { spell = spell, target = target, targetEnemy = targetEnemy, oldTarget = oldTarget, expires = GetTime() + 1.0 }
    return;
  end
  
  if oldTarget ~= UnitName(target) then
    TargetUnit(target);
  end
  
  HealBot_StartCasting(spell, target, "direct");
  
  if targetEnemy then
    HealBot_TargetRestorePending = { type = "enemy" };
  elseif oldTarget and oldTarget ~= UnitName(target) then
    HealBot_TargetRestorePending = { type = "friend" };
  elseif not oldTarget then
    HealBot_TargetRestorePending = { type = "clear" };
  end
  HealBot_TargetRestoreTimer = 0;
end

-- HealBot_SetItemDefaults: Internal utility: HealBot_SetItemDefaults
function HealBot_SetItemDefaults(spell)
  if not HealBot_Spells[spell].Target then
    HealBot_Spells[spell].Target = {"player", "party", "pet"};
  end
  if not HealBot_Spells[spell].Price then
    HealBot_Spells[spell].Price = 0;
  end
  if not HealBot_Spells[spell].CastTime then
    HealBot_Spells[spell].CastTime = 0;
  end
  if not HealBot_Spells[spell].Mana then
    HealBot_Spells[spell].Mana = 0;
  end
  if not HealBot_Spells[spell].Channel then
    HealBot_Spells[spell].Channel = HealBot_Spells[spell].CastTime;
  end
  if not HealBot_Spells[spell].Duration then
    HealBot_Spells[spell].Duration = HealBot_Spells[spell].Channel;
  end
  if not HealBot_Spells[spell].HealsMin then
    HealBot_Spells[spell].HealsMin = 0;
  end
  if not HealBot_Spells[spell].HealsMax then
    HealBot_Spells[spell].HealsMax = 0;
  end
  HealBot_Spells[spell].RealHealing = 0;
  HealBot_Spells[spell].HealsCast = (HealBot_Spells[spell].HealsMin + HealBot_Spells[spell].HealsMax) / 2;
  if not HealBot_Spells[spell].HealsExt then
    HealBot_Spells[spell].HealsExt = 0;
  end
end

-- HealBot_SetSpellDefaults: Internal utility: HealBot_SetSpellDefaults
function HealBot_SetSpellDefaults(spell)
  local baseHeal = HealBot_Spells[spell].HealsCast or 0
  local extHeal = HealBot_Spells[spell].HealsExt or 0
  local realHeal = HealBot_Spells[spell].RealHealing or 0

  local _, class = UnitClass("player")
  if class == "DRUID" then
     local giftRank = HealBot_GetTalentRank("Gift of Nature")
     local genRank = HealBot_GetTalentRank("Genesis")
     
     local mult = 1 + (giftRank * 0.02)
     baseHeal = baseHeal * mult
     extHeal = extHeal * mult
     realHeal = realHeal * mult
     
     if genRank > 0 then
       extHeal = extHeal * (1 + (genRank * 0.05))
     end
  elseif class == "PRIEST" then
     local spiritRank = HealBot_GetTalentRank("Spiritual Healing")
     local mult = 1 + (spiritRank * 0.06)
     baseHeal = baseHeal * mult
     extHeal = extHeal * mult
     realHeal = realHeal * mult
     
     if HEALBOT_RENEW and string.find(spell, HEALBOT_RENEW) then
       local renewRank = HealBot_GetTalentRank("Improved Renew")
       extHeal = extHeal * (1 + (renewRank * 0.05))
     end
  elseif class == "PALADIN" then
     local hlRank = HealBot_GetTalentRank("Healing Light")
     if (HEALBOT_HOLY_LIGHT and string.find(spell, HEALBOT_HOLY_LIGHT)) or 
        (HEALBOT_FLASH_OF_LIGHT and string.find(spell, HEALBOT_FLASH_OF_LIGHT)) or 
        (HEALBOT_HOLY_SHOCK and string.find(spell, HEALBOT_HOLY_SHOCK)) then
        local mult = 1 + (hlRank * 0.04)
        baseHeal = baseHeal * mult
        realHeal = realHeal * mult
     end
  end

  HealBot_Spells[spell].HealsDur = math.floor(baseHeal + extHeal + realHeal);
end

-- HealBot_AddHeal: Internal utility: HealBot_AddHeal
function HealBot_AddHeal(spell)
  HealBot_SetSpellDefaults(spell);
  table.foreachi(HealBot_Spells[spell].Target, function (i, val)
    table.insert(HealBot_Heals[val], spell);
  end);
  HealBot_Spells[spell].BagSlot = HealBot_GetBagSlot(spell);
end

-- HealBot_FindHealSpells: Maps best heal ranks to UI buttons.
function HealBot_FindHealSpells()
  local id = 1;
  if HealBot_SpellsInitFlag > 0 then NeedEquipUpdate = 1; return; end

  HealBot_Heals = { player = {}, pet = {}, party = {} };
  
  table.foreach(HealBot_CurrentSpells, function (index, spell)
    if (HealBot_Spells[spell]) then
      if HealBot_CalcEquipBonus then
        local healingbonus_penalty = 1;
        if HealBot_Spells[spell].Level < 20 then
          healingbonus_penalty = (1 - ((20 - HealBot_Spells[spell].Level) * 0.0375));
        end
        local temp_Spell_cast = 3.5;
        if HealBot_Spells[spell].CastTime == 0 then
          temp_Spell_cast = 3.5;
        end
        if not HealBot_Spells[spell].CastTime then
          HealBot_Spells[spell].CastTime = 1.5;
        end          
        if HealBot_Spells[spell].CastTime >= 1.5 and HealBot_Spells[spell].CastTime < 3.5 then
          temp_Spell_cast = HealBot_Spells[spell].CastTime;
        end
        RealHealing = ((HealBot_GetBonus() * healingbonus_penalty) * (temp_Spell_cast / 3.5));
        local playerClass, englishClass = UnitClass("player");
        local SpiBonus = 0;
        if (englishClass == "PRIEST") then
          SpiBonus = ((HealBot_SpiBonus(spell) * healingbonus_penalty) * (temp_Spell_cast / 3.5))
          RealHealing = RealHealing + SpiBonus;
        end
        RealHealing = math.floor(RealHealing);
        HealBot_Spells[spell].RealHealing = RealHealing;
      end
      HealBot_AddHeal(spell);
    end
  end);

  local items = {};
  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = HealBot_GetItemName(bag, slot);
      if HealBot_Spells[item] and not items[item] then
        HealBot_SetItemDefaults(item);
        HealBot_AddHeal(item);
        items[item] = 1;
      end
    end
  end
  table.foreach(HealBot_Heals, function (key, val)
    if (table.getn(val) == 0) then
      HealBot_Heals[key] = nil;
    end
  end);
  HealBot_Heals.target = HealBot_Heals.party;
  for i = 1, 4 do
    HealBot_Heals["party" .. i] = HealBot_Heals.party;
    HealBot_Heals["partypet" .. i] = HealBot_Heals.party;
  end
  for i = 1, 40 do
    HealBot_Heals["raid" .. i] = HealBot_Heals.party;
    HealBot_Heals["raidpet" .. i] = HealBot_Heals.party;
  end

  if HealBot_CalcEquipBonus then
    HealBot_AddDebug("...Done Equip Bonus:" .. RealHealing);
  end
  HealBot_CalcEquipBonus = false;
end

-- HealBot_CanCastSpell: Internal utility: HealBot_CanCastSpell
function HealBot_CanCastSpell(spell, unit)
  local this = HealBot_Spells[spell];
  -- Removed manual mana check so WoW can properly handle 0-cost buffs (Clearcasting/Inner Focus)
  -- and so tooltips can render in red instead of disappearing.
  if this.BagSlot then
    local bag, slot = HealBot_UnpackBagSlot(this.BagSlot);
    local start, duration, enable = GetContainerItemCooldown(bag, slot);
    if (start > 0 and duration > 0 and enable > 0) then
      return false;
    end
  end
  return true;
end

-- HealBot_GetHealSpell: Resolves spell rank based on health deficit.
function HealBot_GetHealSpell(unit, pattern)
  if (not UnitName(unit)) then return nil end;
  if not pattern then return nil end;
  if UnitOnTaxi("player") then return nil end;
  if HealBot_Config.ProtectPvP == 1 and UnitIsPVP(unit) and not UnitIsPVP("player") then return nil end
  if HealBot_UnitClass("player") == "DRUID" then
    if HealBot_GetShapeshiftForm() and HealBot_Config.AutoUnshift ~= 1 then return nil end; 
  end
  
  -- Handle Inline Scripts
  if string.sub(pattern, 1, 1) == "/" then
      return pattern;
  end

  -- Handle Spells
  if HealBot_Spells[pattern] or HealBot_GetSpellId(pattern) then
    local spell = HealBot_GetSpellName(HealBot_GetSpellId(pattern)) or pattern
    local range = 40;
    if HealBot_Spells[spell] then
      if not HealBot_CanCastSpell(spell, unit) then return nil end;
      range = HealBot_Spells[spell].range or 40;
    end
    if HealBot_Range_Check(unit, range) == 0 then return nil end;
    return spell;
  end

  -- Handle Named Macros
  if GetMacroIndexByName(pattern) ~= 0 then
      return pattern;
  end

  -- Handle Items
  local bag, slot = HealBot_FindBagSlot(pattern)
  if bag then
      -- optionally check item range, but skipping for now as it's complex in vanilla
      return pattern;
  end
  
  return nil;
end

-- HealBot_HealUnit: Main entry point for healing a unit.
function HealBot_HealUnit(unit, pattern)
  HealBot_CastSpellOnFriend(HealBot_GetHealSpell(unit, pattern), unit);
end

-- HealBot_RecalcHeals: Flags unit for visual refresh.
function HealBot_RecalcHeals(unit)
  HealBot_Action_Refresh(unit);
end

-- HealBot_RecalcParty: Triggers group layout rebuild.
function HealBot_RecalcParty()
  HealBot_Action_PartyChanged();
  if HealBot_Action_HealButtons then
    for _, button in ipairs(HealBot_Action_HealButtons) do
      if button and button.unit then
        HealBot_OnEvent_UnitAura(nil, button.unit);
      end
    end
  end
  HealBot_Action_RefreshButtons();
end

-- HealBot_RecalcSpells: Recalculates spells and updates layout.
function HealBot_RecalcSpells()
  HealBot_FindHealSpells();
  HealBot_RecalcParty();
end

-- HealBot_GetTalentRank: Internal utility: HealBot_GetTalentRank
function HealBot_GetTalentRank(talentName)
  for t = 1, GetNumTalentTabs() do
    for i = 1, GetNumTalents(t) do
      local nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i);
      if nameTalent == talentName then
        return currRank;
      end
    end
  end
  return 0;
end

-- HealBot_SpiBonus: Internal utility: HealBot_SpiBonus
function HealBot_SpiBonus(spell)
  local heals_modifer = 0;
  local base, stat, posBuff, negBuff = UnitStat("player", 5);
  local currRank = HealBot_GetTalentRank("Spiritual Guidance")
  if currRank > 0 then
    local spiGuideBonus = stat * 0.05;
    heals_modifer = heals_modifer + (currRank * spiGuideBonus);
  end
  return heals_modifer;
end

-- HealBot_GetBonus: Internal utility: HealBot_GetBonus
function HealBot_GetBonus()
  local HealBonus = 0;
  if HealBot_Integrations_ClassicAPI_Active and GetSpellBonusHealing then
    HealBonus = GetSpellBonusHealing() or 0;
  else
    HealBonus = HealBot_BonusScanner:GetBonus() or 0;
  end
  if UnitClass("player") == "PALADIN" then
    local ironRank = HealBot_GetTalentRank("Ironclad")
    if ironRank > 0 then
      local base, effectiveArmor = UnitArmor("player")
      HealBonus = HealBonus + (effectiveArmor * (ironRank * 0.01))
    end
  end
  return HealBonus;
end

-- HealBot_InitSpells: Scans spellbook to find available heals.
function HealBot_InitSpells()
  local id = 1
  local cnt = 0;
  local class = HealBot_UnitClass("player")
  HealBot_CurrentSpells = {};
  while true do
    local spell = HealBot_GetSpellName(id);
    if not spell then
      break
    end
    if (HealBot_Spells[spell]) then
      HealBot_Spells[spell].id = id;
      HealBot_InitGetSpellData(spell, id, class);
      table.insert(HealBot_CurrentSpells, spell);
      cnt = cnt + 1;
    end
    id = id + 1;
  end

  return cnt;
end

-- HealBot_InitGetSpellData: Extracts mana and cast time from spell tooltips.
function HealBot_InitGetSpellData(spell, id, class)
  local i, _mana, _cast, _HealsMin, _HealsMax, _HealsExt, _duration, _range, _shield, _channel;
  local tooltip = getglobal("HealBot_ScanTooltip");
  local tmpText, line, tmpTest

  if (not spell) then
    return;
  end

  HealBot_ScanTooltip:SetOwner(HealBot_ScanTooltip, "ANCHOR_NONE")
  HealBot_ScanTooltip:SetSpell(id, BOOKTYPE_SPELL);
  _mana = 0;
  _range = 40;
  _cast = 0;
  line = nil;
  
  for lineNum = 2, 6 do
    local lText = getglobal("HealBot_ScanTooltipTextLeft"..lineNum);
    if lText and lText:IsVisible() and lText:GetText() then
      local txt = lText:GetText();
      local t1, t2, match;
      t1, t2, match = string.find(txt, HEALBOT_TOOLTIP_MANA);
      if match then _mana = match; end
      
      if txt == HEALBOT_TOOLTIP_INSTANT_CAST or txt == "Instant" then
        _cast = 0;
      elseif txt == HEALBOT_TOOLTIP_CHANNELED then
        _cast = 0;
      else
        t1, t2, match = string.find(txt, HEALBOT_TOOLTIP_CAST_TIME);
        if match then _cast = match; end
      end

      t1, t2, match = string.find(txt, HEALBOT_TOOLTIP_RANGE);
      if match then _range = match; end
      
      if not string.find(txt, HEALBOT_TOOLTIP_MANA) and txt ~= HEALBOT_TOOLTIP_INSTANT_CAST and txt ~= "Instant" and txt ~= HEALBOT_TOOLTIP_CHANNELED and not string.find(txt, HEALBOT_TOOLTIP_CAST_TIME) and not string.find(txt, HEALBOT_TOOLTIP_RANGE) then
         if not line then line = txt; end
      end
    end
    
    local rText = getglobal("HealBot_ScanTooltipTextRight"..lineNum);
    if rText and rText:IsVisible() and rText:GetText() then
      local txt = rText:GetText();
      local t1, t2, match;
      t1, t2, match = string.find(txt, HEALBOT_TOOLTIP_RANGE);
      if match then _range = match; end
    end
  end

  tmpTest = nil;
  if line then
    if class == "PRIEST" then
      if string.sub(spell, 1, 14) == string.sub(HEALBOT_POWER_WORD_SHIELD, 1, 14) then
        tmpTest, tmpTest, _HealsMin, _shield = string.find(line, HEALBOT_SPELL_PATTERN_SHIELD);    
        _HealsExt = 0;
        _HealsMax = _HealsMin;
      elseif string.sub(spell, 1, 4) == string.sub(HEALBOT_RENEW, 1, 4) then
        tmpTest, tmpTest, _HealsExt, tmpTest, _duration = string.find(line, HEALBOT_SPELL_PATTERN_RENEW);  
        _HealsMin = 0;
        _HealsMax = 0;
        if (_HealsExt == nil) then
          tmpTest, tmpTest, _HealsExt, _duration = string.find(line, HEALBOT_SPELL_PATTERN_RENEW1);
        end
        if (_HealsExt == nil) then
          tmpTest, tmpTest, _duration, _HealsExt = string.find(line, HEALBOT_SPELL_PATTERN_RENEW2);
        end
        if (_HealsExt == nil) then
          tmpTest, tmpTest, _duration, _HealsExt = string.find(line, HEALBOT_SPELL_PATTERN_RENEW3);
        end
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_LESSER_HEAL, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_LESSER_HEAL); 
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_GREATER_HEAL, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_GREATER_HEAL); 
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_FLASH_HEAL, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_FLASH_HEAL); 
      elseif string.sub(spell, 1, 4) == string.sub(HEALBOT_HEAL, 1, 4) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_HEAL); 
      end
    elseif class == "DRUID" then
      if string.sub(spell, 1, 6) == string.sub(HEALBOT_REGROWTH, 1, 6) then
        tmpTest, tmpTest, _HealsMin, _HealsMax, _HealsExt = string.find(line, HEALBOT_SPELL_PATTERN_REGROWTH);
        if (tmpTest == nil) then
          tmpTest, tmpTest, _HealsMin, _HealsMax, tmpTest, _HealsExt = string.find(line, HEALBOT_SPELL_PATTERN_REGROWTH1);
        end
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_REJUVENATION, 1, 9) then
        tmpTest, tmpTest, _HealsExt, _duration = string.find(line, HEALBOT_SPELL_PATTERN_REJUVENATION);  
        _HealsMin = 0;
        _HealsMax = 0;
        if (_HealsExt == nil) then
          tmpTest, tmpTest, _HealsExt, tmpTest, _duration = string.find(line, HEALBOT_SPELL_PATTERN_REJUVENATION1);
        end
      elseif string.sub(spell, 1, 7) == string.sub(HEALBOT_HEALING_TOUCH, 1, 7) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_HEALING_TOUCH); 
      end
    elseif class == "PALADIN" then
      if string.sub(spell, 1, 9) == string.sub(HEALBOT_HOLY_LIGHT, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_HOLY_LIGHT); 
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_FLASH_OF_LIGHT, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_FLASH_OF_LIGHT); 
      end
    elseif class == "SHAMAN" then
      if string.sub(spell, 1, 9) == string.sub(HEALBOT_HEALING_WAVE, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_HEALING_WAVE); 
      elseif string.sub(spell, 1, 9) == string.sub(HEALBOT_LESSER_HEALING_WAVE, 1, 9) then
        tmpTest, _HealsMin, _HealsMax = HealBot_Generic_Patten(line, HEALBOT_SPELL_PATTERN_LESSER_HEALING_WAVE); 
      end
    end
  else
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: HealBot_ScanTooltip is lost");
    HealBot_Report_Error("ERROR: If BonusScanner is used, try disabling BonusScanner");
  end  

  if (_mana == nil) then
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: _mana is NIL");
    HealBot_Report_Error("ERROR: Spell: " .. spell);
    if HealBot_ScanTooltipTextLeft2:GetText() then
      HealBot_Report_Error("ERROR: Tooltip = >> " .. HealBot_ScanTooltipTextLeft2:GetText() .. " <<");
    end
    HealBot_Report_Error("ERROR: Patten = >> " .. HEALBOT_TOOLTIP_MANA .. " <<");
  end
  if (_range == nil) then
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: _range is NIL");
    HealBot_Report_Error("ERROR: Spell: " .. spell);
    if HealBot_ScanTooltipTextRight2:GetText() then
      HealBot_Report_Error("ERROR: Tooltip = >> " .. HealBot_ScanTooltipTextRight2:GetText() .. " <<");
    end
    HealBot_Report_Error("ERROR: Patten = >> " .. HEALBOT_TOOLTIP_RANGE .. " <<");
  end  
  if (_cast == nil) then
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: _cast is NIL");
    HealBot_Report_Error("ERROR: Spell: " .. spell);
    if HealBot_ScanTooltipTextLeft3:GetText() then
      HealBot_Report_Error("ERROR: Tooltip = >> " .. HealBot_ScanTooltipTextLeft3:GetText() .. " <<");
    end
    HealBot_Report_Error("ERROR: Patten = >> " .. HEALBOT_TOOLTIP_CAST_TIME .. " <<");
  end  
  if (tmpTest == nil) then
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: tmpTest == nil");
    HealBot_Report_Error("ERROR: spell = " .. spell);
    if line then
      HealBot_Report_Error("ERROR: Tooltip = >> " .. line .. " <<");
    end
  end  
  
  HealBot_Spells[spell].CastTime = tonumber(_cast);
  HealBot_Spells[spell].Mana = tonumber(_mana);
  HealBot_Spells[spell].Range = tonumber(_range);
  HealBot_Spells[spell].HealsMin = tonumber(_HealsMin);
  HealBot_Spells[spell].HealsMax = tonumber(_HealsMax);
  if _HealsExt then
    HealBot_Spells[spell].HealsExt = tonumber(_HealsExt);
  end
  if _duration then
    HealBot_Spells[spell].Duration = tonumber(_duration);
  end
  if _shield then
    HealBot_Spells[spell].Shield = tonumber(_shield);
  end
  if _channel then
    HealBot_Spells[spell].Channel = tonumber(_channel);
  end
  
  if not HealBot_Spells[spell].Target then
    HealBot_Spells[spell].Target = {"player", "party", "pet"};
  end
  if not HealBot_Spells[spell].Price then
    HealBot_Spells[spell].Price = 0;
  end
  if not HealBot_Spells[spell].Channel then
    HealBot_Spells[spell].Channel = HealBot_Spells[spell].CastTime;
  end
  if not HealBot_Spells[spell].Duration then
    HealBot_Spells[spell].Duration = HealBot_Spells[spell].Channel;
  end
  if not HealBot_Spells[spell].RealHealing then
    HealBot_Spells[spell].RealHealing = 0;
  end
  HealBot_Spells[spell].HealsCast = (HealBot_Spells[spell].HealsMin + HealBot_Spells[spell].HealsMax) / 2;
  if not HealBot_Spells[spell].HealsExt then
    HealBot_Spells[spell].HealsExt = 0;
  end
end

-- HealBot_Generic_Patten: Internal utility: HealBot_Generic_Patten
function HealBot_Generic_Patten(matchStr, matchPattern)
  local tmpTest, _HealsMin, _HealsMax, _HealsExt, _duration
  tmpTest, tmpTest, _HealsMin, _HealsMax = string.find(matchStr, matchPattern); 
  if (tmpTest == nil) then
    HealBot_Report_Error("================================");
    HealBot_Report_Error("ERROR: tmpTest == nil");
    HealBot_Report_Error("ERROR: pattern = " .. matchPattern);
    HealBot_Report_Error("ERROR: Tooltip = >> " .. matchStr .. " <<");
  end
  return tmpTest, _HealsMin, _HealsMax;
end

-- HealBot_UpdateShapeshiftForm: Internal utility: HealBot_UpdateShapeshiftForm
function HealBot_UpdateShapeshiftForm()
  -- Deprecated, state is pulled in real-time on cast
end

-- HealBot_GetShapeshiftForm: Detects active druid form to prevent invalid casts.
function HealBot_GetShapeshiftForm()
  local forms = GetNumShapeshiftForms();
  if forms then
    local i;
    for i=1,forms do
      local icon,name,active = GetShapeshiftFormInfo(i);
      if active then
        local icon_lower = string.lower(icon);
        if not string.find(icon_lower, "humanoidform") and not string.find(icon_lower, "treeoflife") and not string.find(icon_lower, "stoneclawtotem") then
          return i;
        end
      end
    end
  end
  return nil;
end
