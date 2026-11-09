-- HealBot_Controller_SpellBook.lua
-- Spellbook parsing, tooltip data extraction, rank math, and equipment/talent bonuses

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

HealBot_SpellNameToId = {}

function HealBot_CacheSpellIDs()
  HealBot_SpellNameToId = {}
  local id = 1
  while true do
    local spellName, subSpellName = GetSpellName(id, BOOKTYPE_SPELL)
    if not spellName then break end
    if subSpellName and subSpellName ~= "" then
      HealBot_SpellNameToId[spellName .. " (" .. subSpellName .. ")"] = id
      HealBot_SpellNameToId[spellName .. "(" .. subSpellName .. ")"] = id
    end
    HealBot_SpellNameToId[spellName] = id
    id = id + 1
  end
end

-- HealBot_GetSpellId: Internal utility: HealBot_GetSpellId
function HealBot_GetSpellId(spell)
  if not spell then return nil end
  return HealBot_SpellNameToId[spell]
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
      if not HealBot_CastingGroupMembers then HealBot_CastingGroupMembers = {} end
      for i=1, table.getn(HealBot_CastingGroupMembers) do HealBot_CastingGroupMembers[i] = nil end
      table.setn(HealBot_CastingGroupMembers, 0)
      if HEALBOT_PRAYER_OF_HEALING and string.find(spell, HEALBOT_PRAYER_OF_HEALING) then
        if GetNumRaidMembers() > 0 then
          local targetGroup = 0
          for i = 1, GetNumRaidMembers() do
            local name, _, subgroup = GetRaidRosterInfo(i)
            if name == uname then targetGroup = subgroup; break; end
          end
          if targetGroup > 0 then
            for i = 1, GetNumRaidMembers() do
              local name, _, subgroup = GetRaidRosterInfo(i)
              if subgroup == targetGroup and name then table.insert(HealBot_CastingGroupMembers, name); end
            end
          end
        else
          table.insert(HealBot_CastingGroupMembers, UnitName("player"))
          for i = 1, GetNumPartyMembers() do
            if UnitName("party"..i) then table.insert(HealBot_CastingGroupMembers, UnitName("party"..i)); end
          end
        end
      end
      if table.getn(HealBot_CastingGroupMembers) == 0 then
        table.insert(HealBot_CastingGroupMembers, uname)
      end
      
      if table.getn(HealBot_CastingGroupMembers) > 1 then
        local commsStr = "GrpHeal/" .. HealBot_HealValue .. "/1500/"
        for _, memberName in ipairs(HealBot_CastingGroupMembers) do
          commsStr = commsStr .. memberName .. "/"
        end
        HealBot_SendAddonMessage("HealComm", commsStr)
        for _, memberName in ipairs(HealBot_CastingGroupMembers) do
          HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. memberName .. " <<=>> " .. HealBot_HealValue .. " << ")
          if not HealBot_HealsIn[memberName] then HealBot_HealsIn[memberName] = 0 end
          HealBot_HealsIn[memberName] = HealBot_HealsIn[memberName] + HealBot_HealValue
          HealBot_RecalcHeals(HealBot_FindUnitID(memberName))
        end
      else
        HealBot_SendAddonMessage("HealComm", "Heal/" .. uname .. "/" .. HealBot_HealValue .. "/1500/")
        HealBot_SendAddonMessage(HEALBOT_ADDON_ID, ">> " .. uname .. " <<=>> " .. HealBot_HealValue .. " << ")
        if not HealBot_HealsIn[uname] then HealBot_HealsIn[uname] = 0 end
        HealBot_HealsIn[uname] = HealBot_HealsIn[uname] + HealBot_HealValue
        HealBot_RecalcHeals(HealBot_FindUnitID(uname))
      end
    end
  end
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
  local targetList = HealBot_Spells[spell].Target
  if not targetList and HealBot_Spells[spell].Group and HealBot_Spells[HealBot_Spells[spell].Group] then
    targetList = HealBot_Spells[HealBot_Spells[spell].Group].Target
  end
  if not targetList then targetList = {"player", "party", "pet"} end
  table.foreachi(targetList, function (i, val)
    if not HealBot_Heals[val] then HealBot_Heals[val] = {} end
    table.insert(HealBot_Heals[val], spell);
  end);
  HealBot_Spells[spell].BagSlot = HealBot_GetBagSlot(spell);
end

-- HealBot_FindHealSpells: Maps best heal ranks to UI buttons.
function HealBot_FindHealSpells()
  local id = 1;
  if HealBot_SpellsInitFlag > 0 then NeedEquipUpdate = 1; return; end

  HealBot_Heals = { player = {}, pet = {}, party = {} };
  RealHealing = 0;
  
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
        local englishClass = HealBot_UnitClass("player");
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

  local items = HealBot_GetTable();
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
  HealBot_Heals.target = HealBot_Heals.party;
  HealBot_Heals.focus = HealBot_Heals.party;
  for i = 1, 4 do
    HealBot_Heals["party" .. i] = HealBot_Heals.party;
    HealBot_Heals["partypet" .. i] = HealBot_Heals.party;
  end
  for i = 1, 40 do
    HealBot_Heals["raid" .. i] = HealBot_Heals.party;
    HealBot_Heals["raidpet" .. i] = HealBot_Heals.party;
  end

  HealBot_ReleaseTable(items);
  if HealBot_CalcEquipBonus then
    HealBot_AddDebug("...Done Equip Bonus:" .. tostring(RealHealing or 0));
  end
  HealBot_CalcEquipBonus = false;
end

function HealBot_UpdateTalentRanks()
  HealBot_TalentRanks = {}
  for t = 1, GetNumTalentTabs() do
    for i = 1, GetNumTalents(t) do
      local nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)
      if nameTalent then
        HealBot_TalentRanks[nameTalent] = currRank
      end
    end
  end
end

-- HealBot_GetTalentRank: Internal utility: HealBot_GetTalentRank
function HealBot_GetTalentRank(talentName)
  if not next(HealBot_TalentRanks) then HealBot_UpdateTalentRanks() end
  return HealBot_TalentRanks[talentName] or 0
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
  HealBot_CacheSpellIDs()
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
  
  if not HealBot_ScanTooltip_Lines_Left then HealBot_ScanTooltip_Lines_Left = {} end
  if not HealBot_ScanTooltip_Lines_Right then HealBot_ScanTooltip_Lines_Right = {} end
  
  for lineNum = 2, 6 do
    local lText = HealBot_ScanTooltip_Lines_Left[lineNum];
    if not lText then
        lText = getglobal("HealBot_ScanTooltipTextLeft"..lineNum);
        HealBot_ScanTooltip_Lines_Left[lineNum] = lText;
    end
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
    
    local rText = HealBot_ScanTooltip_Lines_Right[lineNum];
    if not rText then
        rText = getglobal("HealBot_ScanTooltipTextRight"..lineNum);
        HealBot_ScanTooltip_Lines_Right[lineNum] = rText;
    end
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



