-- HealBot Options panel file: HealBot_Options_Spells.lua
-- Split from original HealBot_Options.lua

function HealBot_ComboButtons_Button_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_ComboButtons_Button_OnClick(this,id)
  if HealBot_Options_ComboButtons_Button>0 then
    getglobal("HealBot_ComboButtons_Button"..HealBot_Options_ComboButtons_Button):SetChecked(nil);
  end
  HealBot_Options_ComboButtons_Button = id;
  if HealBot_Options_ComboButtons_Button>0 then
    getglobal("HealBot_ComboButtons_Button"..HealBot_Options_ComboButtons_Button):SetChecked(1);
  end
  HealBot_Options_ComboClass_Text()
end
function HealBot_Options_ShowTooltip_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ShowTooltip_OnClick(this)
  HealBot_Config.ShowTooltip = this:GetChecked() or 0;
end
function HealBot_Options_ShowTooltipTarget_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ShowTooltipTarget_OnClick(this)
  HealBot_Config.Tooltip_ShowTarget = this:GetChecked() or 0;
end
function HealBot_Options_ShowTooltipSpellDetail_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ShowTooltipSpellDetail_OnClick(this)
  HealBot_Config.Tooltip_ShowSpellDetail = this:GetChecked() or 0;
end
function HealBot_Options_ShowTooltipInstant_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ShowTooltipInstant_OnClick(this)
  HealBot_Config.Tooltip_Recommend = this:GetChecked() or 0;
end
local HealBot_Options_TooltipPos_List = {
  HEALBOT_TOOLTIP_POSDEFAULT,
  HEALBOT_TOOLTIP_POSLEFT,
  HEALBOT_TOOLTIP_POSRIGHT,
  HEALBOT_TOOLTIP_POSABOVE,
  HEALBOT_TOOLTIP_POSBELOW,
}

function HealBot_Options_TooltipPos_DropDown()
  for i=1, getn(HealBot_Options_TooltipPos_List), 1 do
    local info = {};
    info.text = HealBot_Options_TooltipPos_List[i];
    info.func = HealBot_Options_TooltipPos_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

function HealBot_Options_TooltipPos_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_TooltipPos,HealBot_Options_TooltipPos_DropDown)
end

function HealBot_Options_TooltipPos_Refresh(onselect)
  if not HealBot_Config.TooltipPos then return end
  if not onselect then HealBot_Options_TooltipPos_Initialize() end  -- or wrong menu may be used !
  UIDropDownMenu_SetSelectedID(HealBot_Options_TooltipPos,HealBot_Config.TooltipPos)
end

function HealBot_Options_TooltipPos_OnLoad()
  UIDropDownMenu_Initialize(this, HealBot_Options_TooltipPos_DropDown)
  UIDropDownMenu_SetWidth(128, this)
end

function HealBot_Options_TooltipPos_OnSelect()
  HealBot_Config.TooltipPos = this:GetID()
  HealBot_Options_TooltipPos_Refresh(true)
end

--------------------------------------------------------------------------------

local HealBot_Options_ComboClass_List = {
  HEALBOT_DRUID,
  HEALBOT_PALADIN,
  HEALBOT_PRIEST,
  HEALBOT_SHAMAN,
}








function HealBot_Options_ComboClass_Text()
  local class=UnitClass("Player");
  local combo = HealBot_Config.KeyCombo[class]
  local button = HealBot_Options_ComboClass_Button()
  if combo then
    HealBot_Options_Click:SetText(combo[button] or "")
    HealBot_Options_Shift:SetText(combo["Shift"..button] or "")
    HealBot_Options_Ctrl:SetText(combo["Ctrl"..button] or "")
    HealBot_Options_ShiftCtrl:SetText(combo["ShiftCtrl"..button] or "")
  end
end






function HealBot_Options_ComboClass_Button()
  local button = "Left"
  if HealBot_Options_ComboButtons_Button==2 then button = "Middle"; end
  if HealBot_Options_ComboButtons_Button==3 then button = "Right"; end
  if HealBot_Options_ComboButtons_Button==4 then button = "Button4"; end
  if HealBot_Options_ComboButtons_Button==5 then button = "Button5"; end
  return button;
end




ColorPickerFrame.func = HealBot_Returned_Colours





--------------------------------------------------------------------------------

function HealBot_Options_EditBox_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_Click_OnTextChanged(this)
  local class=UnitClass("Player");
  if not HealBot_Config.KeyCombo[class] then HealBot_Config.KeyCombo[class] = {} end
  local combo = HealBot_Config.KeyCombo[class]
  local button = HealBot_Options_ComboClass_Button()
  combo[button] = this:GetText()
  HealBot_Options_KeyCombo_Change()
end

function HealBot_Options_Shift_OnTextChanged(this)
  local class=UnitClass("Player");
  if not HealBot_Config.KeyCombo[class] then HealBot_Config.KeyCombo[class] = {} end
  local combo = HealBot_Config.KeyCombo[class]
  local button = HealBot_Options_ComboClass_Button()
  combo["Shift"..button] = this:GetText()
  HealBot_Options_KeyCombo_Change()
end

function HealBot_Options_Ctrl_OnTextChanged(this)
  local class=UnitClass("Player");
  if not HealBot_Config.KeyCombo[class] then HealBot_Config.KeyCombo[class] = {} end
  local combo = HealBot_Config.KeyCombo[class]
  local button = HealBot_Options_ComboClass_Button()
  combo["Ctrl"..button] = this:GetText()
  HealBot_Options_KeyCombo_Change()
end

function HealBot_Options_ShiftCtrl_OnTextChanged(this)
  local class=UnitClass("Player");
  if not HealBot_Config.KeyCombo[class] then HealBot_Config.KeyCombo[class] = {} end
  local combo = HealBot_Config.KeyCombo[class]
  local button = HealBot_Options_ComboClass_Button()
  combo["ShiftCtrl"..button] = this:GetText()
  HealBot_Options_KeyCombo_Change()
end

function HealBot_Options_KeyCombo_Change()
  local class=UnitClass("Player");
  HealBot_Config.KeyCombo[class]=HealBot_Config.KeyCombo[class];

end

function HealBot_Options_EnableHealthy_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_EnableHealthy_OnClick(this)
  HealBot_Config.EnableHealthy = this:GetChecked() or 0;
  HealBot_Action_EnableButtons();
end

--------------------------------------------------------------------------------









--------------------------------------------------------------------------------
-- Chat Custom Messages UI Logic
--------------------------------------------------------------------------------

