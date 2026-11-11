-- HealBot_Controller_Casting.lua
-- Combat casting engine, target-safe wrappers, casting state, and shapeshift handling

HealBot_CastingSpell  = nil;
HealBot_CastingTarget = nil;
HealBot_CastingGroupMembers = nil;
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

local function HealBot_StripSpellRank(spellName)
  if not spellName then return "" end
  local parenIndex = string.find(spellName, "%s*%(")
  if parenIndex then
    spellName = string.sub(spellName, 1, parenIndex - 1)
  end
  spellName = string.gsub(spellName, "^%s+", "")
  spellName = string.gsub(spellName, "%s+$", "")
  return spellName
end

local function HealBot_GetSpellRank(spellName)
  if not spellName then return "" end
  local _, _, r = string.find(spellName, "%s*%((.-)%)")
  return r or ""
end

local function HealBot_NormalizeSpellName(name)
  if not name then return "" end
  name = HealBot_StripSpellRank(name)
  name = string.lower(name)
  name = string.gsub(name, "ss", "s")
  name = string.gsub(name, "rr", "r")
  return name
end

local function HealBot_IsRezSpell(s)
  if not s then return false end
  local base = string.lower(HealBot_StripSpellRank(s))
  if base == "resurrection" or base == "ancestral spirit" or base == "redemption" or base == "rebirth" then
    return true
  end
  if (HEALBOT_RESURRECTION and base == string.lower(HEALBOT_RESURRECTION)) or
     (HEALBOT_ANCESTRALSPIRIT and base == string.lower(HEALBOT_ANCESTRALSPIRIT)) or
     (HEALBOT_REDEMPTION and base == string.lower(HEALBOT_REDEMPTION)) or
     (HEALBOT_REBIRTH and base == string.lower(HEALBOT_REBIRTH)) then
    return true
  end
  local norm = HealBot_NormalizeSpellName(s)
  if norm == HealBot_NormalizeSpellName("resurrection") then
    return true
  end
  return false
end

-- HealBot_AnnounceCast: Internal utility: HealBot_AnnounceCast
function HealBot_AnnounceCast(spell, target)
  if not spell or not target then return end

  if UnitIsDeadOrGhost(target) then
    if not HealBot_IsRezSpell(spell) then
      return
    end
  end

  if HealBot_Config.ChatMessages then
    local tName = UnitName(target)
    if not tName and target == "target" then
      tName = UnitName("target")
    end
    if not tName then
      tName = target
    end

    local baseSpell = HealBot_StripSpellRank(spell)
    local spellRank = HealBot_GetSpellRank(spell)
    local normSpell = HealBot_NormalizeSpellName(spell)

    for i = 1, 5 do
      local msgConf = HealBot_Config.ChatMessages[i]
      local configSpell = msgConf and msgConf.Spell or ""
      configSpell = string.gsub(configSpell, "^%s+", "")
      configSpell = string.gsub(configSpell, "%s+$", "")
      
      if msgConf and configSpell ~= "" and configSpell ~= "None" and msgConf.Channel and msgConf.Channel ~= "None" then
        local configBase = HealBot_StripSpellRank(configSpell)
        local normConfig = HealBot_NormalizeSpellName(configSpell)
        
        local match = false
        if string.lower(configSpell) == string.lower(spell) or
           string.lower(configBase) == string.lower(baseSpell) or
           normConfig == normSpell then
          match = true
        end

        if match then
          local msg = msgConf.Message or ""
          -- Strip rank by substituting baseSpell for spell tokens
          -- Support #Spell#, #spell#, #SPELL#, #Spell, #spell, #SPELL
          msg = string.gsub(msg, "#[sS][pP][eE][lL][lL]#?", baseSpell)
          -- Support #Rank#, #rank#, #RANK#, #Rank, #rank, #RANK
          msg = string.gsub(msg, "#[rR][aA][nN][kK]#?", spellRank)
          -- Support #Target#, #target#, #TARGET#, #Target, #target, #TARGET
          msg = string.gsub(msg, "#[tT][aA][rR][gG][eE][tT]#?", tName)
          
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
    if ( UnitIsUnit(target, "player") or CheckInteractDistance(target, 4) or UnitIsDeadOrGhost(target) ) then
      ttype = "fired";
    end
  end

  if ttype == "fired" then
    if not HealBot_CastFailed then
      HealBot_CastingSpell  = spell;
      HealBot_CastingTarget = target;
      HealBot_Process_HealValue(spell, target);
      HealBot_AnnounceCast(spell, target);
    end
  end
  
  return ttype == "fired"
end

-- HealBot_StopCasting: Internal utility: HealBot_StopCasting
function HealBot_StopCasting()
  HealBot_IsCasting = false;
  if HealBot_CastingTarget then
    if HealBot_HealValue > 0 then
      local uname = UnitName(HealBot_CastingTarget)
      if uname then
        if HealBot_CastingGroupMembers and table.getn(HealBot_CastingGroupMembers) > 1 then
          HealBot_SendAddonMessage("HealComm", "GrpHealstop");
          for _, memberName in ipairs(HealBot_CastingGroupMembers) do
            HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. memberName .. " <<=>> " .. 0 - HealBot_HealValue .. " << ")
            if HealBot_HealsIn[memberName] then
               HealBot_HealsIn[memberName] = HealBot_HealsIn[memberName] - HealBot_HealValue;
               if HealBot_HealsIn[memberName] < 0 then HealBot_HealsIn[memberName] = 0; end
               HealBot_RecalcHeals(HealBot_FindUnitID(memberName));
            end
          end
        else
          HealBot_SendAddonMessage("HealComm", "Healstop");
          HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. uname .. " <<=>> " .. 0 - HealBot_HealValue .. " << ");
          if HealBot_HealsIn[uname] then
             HealBot_HealsIn[uname] = HealBot_HealsIn[uname] - HealBot_HealValue;
             if HealBot_HealsIn[uname] < 0 then HealBot_HealsIn[uname] = 0; end
             HealBot_RecalcHeals(HealBot_FindUnitID(uname));
          end
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
  if not bar.txt then bar.txt = getglobal(bar:GetName() .. "_text") end
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
    if not bar.txt then bar.txt = getglobal(bar:GetName() .. "_text") end
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
    -- ALWAYS put the cast into the Pending queue so the OnUpdate loop can wait for the server
    -- to process the unshift before attempting the cast, otherwise we get "You are in shapeshift form".
    if not HealBot_PendingShapeshiftCast then HealBot_PendingShapeshiftCast = {} end
    HealBot_PendingShapeshiftCast.spell = spell
    HealBot_PendingShapeshiftCast.target = target
    HealBot_PendingShapeshiftCast.targetEnemy = targetEnemy
    HealBot_PendingShapeshiftCast.oldTarget = oldTarget
    HealBot_PendingShapeshiftCast.fireTime = GetTime() + 0.05
    HealBot_PendingShapeshiftCast.expires = GetTime() + 2.0
    HealBot_PendingShapeshiftCast.started = nil
    HealBot_PendingShapeshiftCast.nextSpam = nil
    return;
  end
  
  if oldTarget ~= UnitName(target) then
    TargetUnit(target);
  end
  
  HealBot_StartCasting(spell, target, "direct");
  
  if targetEnemy then
    HealBot_TargetRestorePending = "enemy";
  elseif oldTarget and oldTarget ~= UnitName(target) then
    HealBot_TargetRestorePending = "friend";
  elseif not oldTarget then
    HealBot_TargetRestorePending = "clear";
  end
  HealBot_TargetRestoreTimer = 0;
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
  if not string.find(unit, "^Test") then
      if (not UnitName(unit)) then return nil end;
  end
  if not pattern then return nil end;
  if UnitOnTaxi("player") then return nil end;
  if not string.find(unit, "^Test") then
      if HealBot_Config.ProtectPvP == 1 and UnitIsPVP(unit) and not UnitIsPVP("player") then return nil end
  end
  if HealBot_UnitClass("player") == "DRUID" then
    if HealBot_GetShapeshiftForm() and HealBot_Config.AutoUnshift ~= 1 then return nil end; 
  end
  
  -- Handle Inline Scripts
  if string.sub(pattern, 1, 1) == "/" then
      if HealBot_Range_Check(unit, 40) == 0 then return nil end;
      return pattern;
  end

  -- Handle Special Targeting Pattern
  if string.lower(pattern) == "target" then
      if HealBot_Range_Check(unit, 40) == 0 then return nil end;
      return pattern;
  end

  -- Handle Spells
  if HealBot_Spells[pattern] or HealBot_GetSpellId(pattern) then
    local spell = HealBot_GetSpellName(HealBot_GetSpellId(pattern)) or pattern
    local range = 40;
    if HealBot_Spells[spell] then
      if not HealBot_CanCastSpell(spell, unit) then return nil end;
      range = HealBot_Spells[spell].Range or HealBot_Spells[spell].range or 40;
    else
      local parenIdx = string.find(spell, "%s*%(")
      if parenIdx then
        local baseSpell = string.sub(spell, 1, parenIdx - 1)
        baseSpell = string.gsub(baseSpell, "%s+$", "")
        if HealBot_Spells[baseSpell] then
          if not HealBot_CanCastSpell(baseSpell, unit) then return nil end;
          range = HealBot_Spells[baseSpell].Range or HealBot_Spells[baseSpell].range or 40;
        end
      end
    end
    if HealBot_Range_Check(unit, range) == 0 then return nil end;
    return spell;
  end

  -- Handle Named Macros
  if GetMacroIndexByName(pattern) ~= 0 then
      if HealBot_Range_Check(unit, 40) == 0 then return nil end;
      return pattern;
  end

  -- Handle Items
  local bag, slot = HealBot_FindBagSlot(pattern)
  if bag then
      local range = 40;
      if HealBot_Spells[pattern] then
          range = HealBot_Spells[pattern].Range or HealBot_Spells[pattern].range or 40;
      end
      if HealBot_Range_Check(unit, range) == 0 then return nil end;
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
  if unit then
    HealBot_View_DirtyUnits[unit] = true;
  else
    if HealBot_Action_UnitButtons then
        for u, _ in pairs(HealBot_Action_UnitButtons) do
            HealBot_View_DirtyUnits[u] = true;
        end
    end
  end
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
end

-- HealBot_RecalcSpells: Recalculates spells and updates layout.
function HealBot_RecalcSpells()
  HealBot_FindHealSpells();
  HealBot_RecalcParty();
end

HealBot_TalentRanks = {}

-- HealBot_GetShapeshiftForm: Detects active druid form to prevent invalid casts.
function HealBot_GetShapeshiftForm()
  local forms = GetNumShapeshiftForms();
  if forms then
    local i;
    for i=1,forms do
      local icon,name,active = GetShapeshiftFormInfo(i);
      if active then
        if icon then
          local icon_lower = string.lower(icon)
          -- Exclude non-standard/custom forms like Tree of Life from unshifting
          if not string.find(icon_lower, "humanoidform") and not string.find(icon_lower, "treeoflife") and not string.find(icon_lower, "healingway") and not string.find(icon_lower, "stoneclawtotem") then
            return nil;
          end
        else
          return i;
        end
      end
    end
  end
  return nil;
end

