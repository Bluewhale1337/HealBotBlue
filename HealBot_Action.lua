-- Status bar layout functions and tables moved to HealBot_View_Layout.lua

-- HealBot_AlwaysHeal: Returns true if healthy units should be shown.
function HealBot_AlwaysHeal()
  return HealBot_Config.EnableHealthy==1
end

-- HealBot_MayHeal: Checks if unit is eligible for healing UI.
function HealBot_MayHeal(unit)
  if not UnitName(unit) or not HealBot_Heals[unit] then return false end
  if unit ~= 'target' then return true end
  if not HealBot_Config.TargetHeals or UnitCanAttack("player",unit) then return false end
  return true;
end

-- HealBot_ShouldHeal: Checks if unit needs immediate healing.
function HealBot_ShouldHeal(unit)
  if HealBot_UnitDebuff[unit] and not UnitIsDeadOrGhost(unit) then
    if HealBot_Range_Check(unit, 30)==1 then
      return true;
    end
  end
  return HealBot_MayHeal(unit) and UnitHealth(unit)>0 and not UnitIsDeadOrGhost(unit)
    and (UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.AlertLevel or HealBot_AlwaysHeal());
end

-- HealBot_Action_ShouldHealSome: Alias for checking if any unit needs healing.
function HealBot_Action_ShouldHealSome()
  for index, button in pairs(HealBot_Action_HealButtons) do
    if (HealBot_ShouldHeal(button.unit)) then return button.unit; end
  end
end

-- HealBot_MustHeal: Internal utility: HealBot_MustHeal
function HealBot_MustHeal(unit)
  return HealBot_ShouldHeal(unit) and UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.AlertLevel
end

-- HealBot_Action_MustHealSome: Checks if emergency healing is required.
function HealBot_Action_MustHealSome()
  for index, button in pairs(HealBot_Action_HealButtons) do
    if (HealBot_MustHeal(button.unit)) then return button.unit; end
  end
end

-- HealBot_GetRezSpellForClass: Internal utility: HealBot_GetRezSpellForClass
function HealBot_GetRezSpellForClass()
  local _, class = UnitClass("player");
  if class == "PRIEST" then return HEALBOT_RESURRECTION;
  elseif class == "DRUID" then return HEALBOT_REBIRTH;
  elseif class == "PALADIN" then return HEALBOT_REDEMPTION;
  elseif class == "SHAMAN" then return HEALBOT_ANCESTRALSPIRIT;
  end
  return nil;
end

-- HealBot_CanHeal: Internal utility: HealBot_CanHeal
function HealBot_CanHeal(unit)
  if UnitIsDeadOrGhost(unit) then
    local rezSpell = HealBot_GetRezSpellForClass();
    if rezSpell and HealBot_GetHealSpell(unit, rezSpell) then
      return true;
    end
    return false;
  end

  local SHeal = HealBot_ShouldHeal(unit)
  if SHeal then
    local spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Left"))
    if not spell then spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Middle")) end
    if not spell then spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Right")) end
    if not spell then spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Button4")) end
    if not spell then spell = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Button5")) end
    if not spell then
      return false
    else
      return true
    end
  end
  return false
end

-- Status bar layout and grid rendering functions moved to HealBot_View_Layout.lua

-- Refresh and reset functions moved to HealBot_View_Layout.lua

-- HealBot_Action_SpellPattern: Resolves spell string based on click modifiers.
function HealBot_Action_SpellPattern(button)
  local combos = HealBot_Config.KeyCombo[UnitClass("player")]
  if not combos then return nil end
  local press = button;
  if IsAltKeyDown() then press = "Alt"..press end
  if IsControlKeyDown() then press = "Ctrl"..press end
  if IsShiftKeyDown() then press = "Shift"..press end
  return combos[press]
end

-- HealBot_Decode_Button: Decodes click action to spell pattern.
function HealBot_Decode_Button(button)
  if button=="RightButton" then
    button="Right";
  elseif button=="MiddleButton" then
    button="Middle";
  elseif button=="Button4" then
    button="Button4";
  elseif button=="Button5" then
    button="Button5";
  else
    button="Left";
  end
  return button
end

--------------------------------------------------------------------------------------------------
-- Widget_OnFoo functions
--------------------------------------------------------------------------------------------------

-- HealBot_Action_HealUnit_OnLoad: Internal utility: HealBot_Action_HealUnit_OnLoad
function HealBot_Action_HealUnit_OnLoad(this)
  this:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up");
end

-- HealBot_Action_HealUnit_OnEnter: Internal utility: HealBot_Action_HealUnit_OnEnter
function HealBot_Action_HealUnit_OnEnter(this)
  HealBot_Action_ShowTooltip(this);
end

-- HealBot_Action_HealUnit_OnLeave: Internal utility: HealBot_Action_HealUnit_OnLeave
function HealBot_Action_HealUnit_OnLeave(this)
  HealBot_Action_HideTooltip(this);
end

--------------------------------------------------------------------------------------------------
-- Puppeteer Utility Ports for Macro and Item Execution
--------------------------------------------------------------------------------------------------

-- HealBot_SplitString: Internal utility: HealBot_SplitString
function HealBot_SplitString(str, delimiter)
    local result = {}
    if not delimiter or delimiter == "" then
        return {str}
    end
    local start_pos = 1
    while true do
        local end_pos = string.find(str, delimiter, start_pos, true)
        if not end_pos then
            table.insert(result, string.sub(str, start_pos))
            break
        end
        table.insert(result, string.sub(str, start_pos, end_pos - 1))
        start_pos = end_pos + string.len(delimiter)
    end
    return result
end

-- HealBot_RunMacroText: Internal utility: HealBot_RunMacroText
function HealBot_RunMacroText(body)
    local commands = HealBot_SplitString(body, "\n")
    for i = 1, table.getn(commands) do
        ChatFrameEditBox:SetText(commands[i])
        ChatEdit_SendText(ChatFrameEditBox)
    end
end

-- HealBot_RunMacro: Internal utility: HealBot_RunMacro
function HealBot_RunMacro(name)
    if GetMacroIndexByName(name) == 0 then return end
    local _, _, body = GetMacroInfo(GetMacroIndexByName(name))
    HealBot_RunMacroText(body)
end

-- HealBot_GetBagSlotInfo: Internal utility: HealBot_GetBagSlotInfo
function HealBot_GetBagSlotInfo(bag, slot)
    local link = GetContainerItemLink(bag, slot)
    if not link then return end
    local _, _, name = string.find(link, "%[(.*)%]")
    local _, count = GetContainerItemInfo(bag, slot)
    return name, count
end

-- HealBot_FindBagSlot: Internal utility: HealBot_FindBagSlot
function HealBot_FindBagSlot(itemName)
    local bestBag, bestSlot, lowestStackSize
    for bag = 0, NUM_BAG_FRAMES do
        for slot = 1, GetContainerNumSlots(bag) do
            local name, count = HealBot_GetBagSlotInfo(bag, slot)
            if itemName == name then
                if not lowestStackSize or lowestStackSize > count then
                    bestBag = bag
                    bestSlot = slot
                    lowestStackSize = count
                end
            end
        end
    end
    return bestBag, bestSlot
end

-- HealBot_UseItem: Uses an item from inventory.
function HealBot_UseItem(itemName)
    local bag, slot = HealBot_FindBagSlot(itemName)
    if not bag then return false end
    UseContainerItem(bag, slot)
    return true
end

-- HealBot_Action_HealUnit_OnClick: Click event handler.
function HealBot_Action_HealUnit_OnClick(this,button)
    local decode_button = HealBot_Decode_Button(button);
    local pattern = HealBot_Action_SpellPattern(decode_button);
    
    if not pattern then return end
    
    -- Buff casting override (Spells only)
    if HealBot_Config.BuffWatch == 1 then
      local inCombat = UnitAffectingCombat("player")
      if (not inCombat) or (HealBot_Config.BuffWatchInCombat == 1) then
        if HealBot_MissingBuffs[this.unit] then
          local missingBuff = HealBot_MissingBuffs[this.unit]
          if decode_button == "Left" or decode_button == "Right" then
            HealBot_CastSpellOnFriend(missingBuff, this.unit)
            return
          end
        end
      end
    end

    -- Special cases for targeting
    if string.lower(pattern) == "target" or string.lower(pattern) == "/target" then
        TargetUnit(this.unit)
        return
    end

    -- Priority 1: Inline Scripts (starts with /)
    if string.sub(pattern, 1, 1) == "/" then
        local oldTarget = nil
        if UnitExists("target") then oldTarget = UnitName("target") end
        TargetUnit(this.unit)
        HealBot_RunMacroText(pattern)
        if oldTarget then
            TargetByName(oldTarget)
        else
            ClearTarget()
        end
        return
    end
    
    -- Priority 2: Spells
    -- Resurrection override on dead target first
    if UnitIsDeadOrGhost(this.unit) then
      local rezSpell = HealBot_GetRezSpellForClass();
      if rezSpell then
        HealBot_CastSpellOnFriend(rezSpell, this.unit);
        return
      end
    end

    if HealBot_Spells[pattern] or HealBot_GetSpellId(pattern) then
        HealBot_HealUnit(this.unit, pattern);
        return
    end

    -- Priority 3: Named Macros
    if GetMacroIndexByName(pattern) ~= 0 then
        local oldTarget = nil
        if UnitExists("target") then oldTarget = UnitName("target") end
        TargetUnit(this.unit)
        HealBot_RunMacro(pattern)
        if oldTarget then
            TargetByName(oldTarget)
        else
            ClearTarget()
        end
        return
    end

    -- Priority 4: Items
    local bag, slot = HealBot_FindBagSlot(pattern)
    if bag then
        local oldTarget = nil
        if UnitExists("target") then oldTarget = UnitName("target") end
        TargetUnit(this.unit)
        UseContainerItem(bag, slot)
        if SpellIsTargeting() then SpellTargetUnit(this.unit) end
        if oldTarget then TargetByName(oldTarget) else ClearTarget() end
        return
    end
    
    -- Fallback attempt
    HealBot_HealUnit(this.unit, pattern);
end

-- HealBot_Action_HealUnitCheck_OnClick: Click event handler.
function HealBot_Action_HealUnitCheck_OnClick(this)
  if not this.unit then return end
  if this:GetChecked() then
    table.insert(HealBot_Action_HealTarget,this.unit)
  else
    for i=1,table.getn(HealBot_Action_HealTarget) do
      if HealBot_Action_HealTarget[i]==this.unit then
        table.remove(HealBot_Action_HealTarget,i);
        break;
      end
    end
  end
  HealBot_Action_PartyChanged();
end

-- HealBot_Action_OptionsButton_OnClick: Click event handler.
function HealBot_Action_OptionsButton_OnClick(this)
    HealBot_TogglePanel(HealBot_Options);
end

-- HealBot_Action_AbortButton_OnClick: Click event handler.
function HealBot_Action_AbortButton_OnClick(this)
  SpellStopCasting();
end

local HealBot_CT_RA_UpdateMTs_Old;
-- HealBot_CT_RA_UpdateMTs: Internal utility: HealBot_CT_RA_UpdateMTs
function HealBot_CT_RA_UpdateMTs()
  local value = HealBot_CT_RA_UpdateMTs_Old();
  return value;
end

-- HealBot_CT_RaidAssist_DEAD: Internal utility: HealBot_CT_RaidAssist_DEAD
function HealBot_CT_RaidAssist_DEAD()
--  if (type(CT_RA_MemberFrame_OnClick)=="function") then
--    HealBot_CT_RA_CustomOnClickFunction_Old = CT_RA_CustomOnClickFunction;
--    CT_RA_CustomOnClickFunction = HealBot_CT_RA_CustomOnClickFunction;
--  end
--  if (type(CT_RA_UpdateMTs)=="function") then
--    HealBot_CT_RA_UpdateMTs_Old = CT_RA_UpdateMTs;
--    CT_RA_UpdateMTs = HealBot_CT_RA_UpdateMTs;
--  end
end

--------------------------------------------------------------------------------------------------
-- Frame_OnFoo functions
--------------------------------------------------------------------------------------------------

-- HealBot_Action_OnLoad: Internal utility: HealBot_Action_OnLoad
function HealBot_Action_OnLoad(this)
--  HealBot_CT_RaidAssist();
end

-- HealBot_Action_OnShow: Show event handler.
function HealBot_Action_OnShow(this)
  if HealBot_Config.PanelSounds==1 then
    PlaySound("igAbilityOpen");
  end
  HealBot_Config.ActionVisible = 1
  local borderStyle = HealBot_Config.bborder[HealBot_Config.Current_Skin] or 2
  if borderStyle == 0 then
    HealBot_Action:SetBackdropBorderColor(0,0,0,0);
  elseif borderStyle == 1 then
    HealBot_Action:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      tile = true, tileSize = 8, edgeSize = 1,
      insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    HealBot_Action:SetBackdropBorderColor(
      HealBot_Config.borcolr[HealBot_Config.Current_Skin],
      HealBot_Config.borcolg[HealBot_Config.Current_Skin],
      HealBot_Config.borcolb[HealBot_Config.Current_Skin],
      HealBot_Config.borcola[HealBot_Config.Current_Skin]);
  else
    HealBot_Action:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 8, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    HealBot_Action:SetBackdropBorderColor(
      HealBot_Config.borcolr[HealBot_Config.Current_Skin],
      HealBot_Config.borcolg[HealBot_Config.Current_Skin],
      HealBot_Config.borcolb[HealBot_Config.Current_Skin],
      HealBot_Config.borcola[HealBot_Config.Current_Skin]);
  end
  HealBot_Action:SetBackdropColor(
    HealBot_Config.backcolr[HealBot_Config.Current_Skin],
    HealBot_Config.backcolg[HealBot_Config.Current_Skin],
    HealBot_Config.backcolb[HealBot_Config.Current_Skin], 
    HealBot_Config.backcola[HealBot_Config.Current_Skin]);
end

-- HealBot_Action_OnHide: Hide event handler.
function HealBot_Action_OnHide(this)
  HealBot_StopMoving(this);
  if not this.ProgrammaticHide then
    HealBot_Config.ActionVisible = 0
  end
end

-- HealBot_Action_OnMouseDown: Internal utility: HealBot_Action_OnMouseDown
function HealBot_Action_OnMouseDown(this,button)
  if button~="RightButton" then
    if HealBot_Config.ActionLocked==0 then
      HealBot_StartMoving(this);
    end
  end
end

-- HealBot_Action_OnMouseUp: Internal utility: HealBot_Action_OnMouseUp
function HealBot_Action_OnMouseUp(this,button)
  if button~="RightButton" then
    HealBot_StopMoving(this);
  elseif not HealBot_IsFighting then
    HealBot_Action_OptionsButton_OnClick();
  end
end

-- HealBot_Action_OnClick: Handles click events on heal buttons.
function HealBot_Action_OnClick(this,button)
--  HealBot_Action_AddDebug("OnClick("..button..")");
end

-- HealBot_Action_OnDragStart: Internal utility: HealBot_Action_OnDragStart
function HealBot_Action_OnDragStart(this,button)
  if HealBot_Config.ActionLocked==0 then
    HealBot_StartMoving(this);
  end
end

-- HealBot_Action_OnDragStop: Internal utility: HealBot_Action_OnDragStop
function HealBot_Action_OnDragStop(this)
  HealBot_StopMoving(this);
end

-- http://www.flexbarforums.com/viewtopic.php?t=66
-- no idea what it was link is dead
function HealBot_Action_OnKey(this,key,state)
  local command = GetBindingAction(key); 
  if command then 
    DEFAULT_CHAT_FRAME:AddMessage(key.." "..state.." "..(command or "nil"));
    keystate = state
    RunBinding(command,keystate)
  end 
  DEFAULT_CHAT_FRAME:AddMessage("HealBot_Action_OnKey - "..key);
  if key=="SHIFT" or key=="CTRL" or key=="ALT" then
    DEFAULT_CHAT_FRAME:AddMessage((IsShiftKeyDown() or 0).." "..(IsControlKeyDown() or 0).." "..(IsAltKeyDown() or 0));
    HealBot_Action_Refresh();
  end
end






