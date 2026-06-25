-- Status bar layout functions and tables moved to HealBot_View_Layout.lua

function HealBot_AlwaysHeal()
  return HealBot_Config.EnableHealthy==1
end

function HealBot_MayHeal(unit)
  if not UnitName(unit) or not HealBot_Heals[unit] then return false end
  if unit ~= 'target' then return true end
  if not HealBot_Config.TargetHeals or UnitCanAttack("player",unit) then return false end
  return true;
end

function HealBot_ShouldHeal(unit)
  if HealBot_UnitDebuff[unit] and not UnitIsDeadOrGhost(unit) then
    if HealBot_Range_Check(unit, 30)==1 then
      return true;
    end
  end
  return HealBot_MayHeal(unit) and UnitHealth(unit)>0 and not UnitIsDeadOrGhost(unit)
    and (UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.AlertLevel or HealBot_AlwaysHeal());
end

function HealBot_Action_ShouldHealSome()
  return table.foreach(HealBot_Action_HealButtons, function (index,button)
    if (HealBot_ShouldHeal(button.unit)) then return button.unit; end
  end);
end

function HealBot_MustHeal(unit)
  return HealBot_ShouldHeal(unit) and UnitHealth(unit)<UnitHealthMax(unit)*HealBot_Config.AlertLevel
end

function HealBot_Action_MustHealSome()
  return table.foreach(HealBot_Action_HealButtons, function (index,button)
    if (HealBot_MustHeal(button.unit)) then return button.unit; end
  end);
end

function HealBot_CanHeal(unit)
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

function HealBot_Action_SpellPattern(button)
  local combos = HealBot_Config.KeyCombo[UnitClass("player")]
  if not combos then return nil end
  local press = button;
  if IsAltKeyDown() then press = "Alt"..press end
  if IsControlKeyDown() then press = "Ctrl"..press end
  if IsShiftKeyDown() then press = "Shift"..press end
  return combos[press]
end

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

function HealBot_Action_HealUnit_OnLoad(this)
  this:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up");
end

function HealBot_Action_HealUnit_OnEnter(this)
  HealBot_Action_ShowTooltip(this);
end

function HealBot_Action_HealUnit_OnLeave(this)
  HealBot_Action_HideTooltip(this);
end

function HealBot_Action_HealUnit_OnClick(this,button)
    local decode_button = HealBot_Decode_Button(button);
    local pattern = HealBot_Action_SpellPattern(decode_button);
    
    -- Buff casting override
    if HealBot_Config.BuffWatch == 1 then
      local inCombat = UnitAffectingCombat("player")
        if (not inCombat) or (HealBot_Config.BuffWatchInCombat == 1) then
          local myClass = UnitClass("player")
          if HealBot_MissingBuffs[this.unit] then
            local missingBuff = HealBot_MissingBuffs[this.unit]
            if decode_button == "Left" or decode_button == "Right" then
              HealBot_CastSpellOnFriend(missingBuff, this.unit)
              return
            end
          end
        end
      end
    
    HealBot_HealUnit(this.unit,pattern);
  end

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

function HealBot_Action_OptionsButton_OnClick(this)
    HealBot_TogglePanel(HealBot_Options);
end

function HealBot_Action_AbortButton_OnClick(this)
  SpellStopCasting();
end

local HealBot_CT_RA_UpdateMTs_Old;
function HealBot_CT_RA_UpdateMTs()
  local value = HealBot_CT_RA_UpdateMTs_Old();
  return value;
end

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

function HealBot_Action_OnLoad(this)
--  HealBot_CT_RaidAssist();
end

function HealBot_Action_OnShow(this)
  if HealBot_Config.PanelSounds==1 then
    PlaySound("igAbilityOpen");
  end
  HealBot_Config.ActionVisible = 1
  HealBot_Action:SetBackdropColor(
    HealBot_Config.backcolr[HealBot_Config.Current_Skin],
    HealBot_Config.backcolg[HealBot_Config.Current_Skin],
    HealBot_Config.backcolb[HealBot_Config.Current_Skin], 
    HealBot_Config.backcola[HealBot_Config.Current_Skin]);
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
end

function HealBot_Action_OnHide(this)
  HealBot_StopMoving(this);
  HealBot_Config.ActionVisible = 0
end

function HealBot_Action_OnMouseDown(this,button)
  if button~="RightButton" then
    if HealBot_Config.ActionLocked==0 then
      HealBot_StartMoving(this);
    end
  end
end

function HealBot_Action_OnMouseUp(this,button)
  if button~="RightButton" then
    HealBot_StopMoving(this);
  elseif not HealBot_IsFighting then
    HealBot_Action_OptionsButton_OnClick();
  end
end

function HealBot_Action_OnClick(this,button)
--  HealBot_Action_AddDebug("OnClick("..button..")");
end

function HealBot_Action_OnDragStart(this,button)
  if HealBot_Config.ActionLocked==0 then
    HealBot_StartMoving(this);
  end
end

function HealBot_Action_OnDragStop(this)
  HealBot_StopMoving(this);
end

-- http://www.flexbarforums.com/viewtopic.php?t=66
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






