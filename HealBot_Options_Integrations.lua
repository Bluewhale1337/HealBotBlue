-- HealBot_Options_Integrations.lua

local function HealBot_Options_SetDropDownState(frame, enabled)
  if not frame then return end
  local button = getglobal(frame:GetName() .. "Button")
  local text = getglobal(frame:GetName() .. "Text")
  if button then
    if enabled then
      button:Enable()
    else
      button:Disable()
    end
  end
  if text then
    if enabled then
      text:SetTextColor(1, 1, 1)
    else
      text:SetTextColor(0.5, 0.5, 0.5)
    end
  end
end

-- Update enabled/disabled state of dropdowns based on current config
function HealBot_Options_Integrations_UpdateDropdownStates()
  local timersEnabled = HealBot_Config.HealBot_Integrations_ShowHoTTimers == 1
  local displayMode = HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode or 0

  HealBot_Options_SetDropDownState(HealBot_Options_Integrations_DisplayModeDropdown, timersEnabled)
  HealBot_Options_SetDropDownState(HealBot_Options_Integrations_PositionDropdown, timersEnabled and (displayMode == 0 or displayMode == 2))
end

-- HealBot_Options_Integrations_OnShow: UI handler for OnShow options panel.
function HealBot_Options_Integrations_OnShow(this)
  HealBot_Options_Integrations_UnitXP:SetChecked(HealBot_Config.HealBot_Integrations_UnitXP);
  HealBot_Options_Integrations_Nampower:SetChecked(HealBot_Config.HealBot_Integrations_Nampower);
  HealBot_Options_Integrations_SuperWoW:SetChecked(HealBot_Config.HealBot_Integrations_SuperWoW);
  HealBot_Options_Integrations_ClassicAPI:SetChecked(HealBot_Config.HealBot_Integrations_ClassicAPI);
  HealBot_Options_Integrations_ShowHoTTimers:SetChecked(HealBot_Config.HealBot_Integrations_ShowHoTTimers);

  -- Set display mode dropdown text
  local displayMode = HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode or 0
  if displayMode == 1 then
    UIDropDownMenu_SetText("Icon Overlay", HealBot_Options_Integrations_DisplayModeDropdown)
  elseif displayMode == 2 then
    UIDropDownMenu_SetText("Both", HealBot_Options_Integrations_DisplayModeDropdown)
  else
    UIDropDownMenu_SetText("List", HealBot_Options_Integrations_DisplayModeDropdown)
  end

  -- Set position dropdown text
  local pos = HealBot_Config.HealBot_Integrations_HoTTimerPosition or "BELOW"
  local posLabels = { BELOW = "Below", ABOVE = "Above", LEFT = "Left", RIGHT = "Right" }
  UIDropDownMenu_SetText(posLabels[pos] or "Below", HealBot_Options_Integrations_PositionDropdown)

  -- Update enabled/disabled state
  HealBot_Options_Integrations_UpdateDropdownStates()
end

-- Display Mode dropdown click handler (relying on global this)
function HealBot_Options_Integrations_DisplayModeDropdown_OnClick()
  UIDropDownMenu_SetSelectedID(HealBot_Options_Integrations_DisplayModeDropdown, this:GetID())
  HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode = this.value
  UIDropDownMenu_SetText(this:GetText(), HealBot_Options_Integrations_DisplayModeDropdown)
  HealBot_Options_Integrations_UpdateDropdownStates()
  if HealBot_Action_UnitButtons then
    for u in pairs(HealBot_Action_UnitButtons) do
      HealBot_View_DirtyUnits[u] = true
    end
  end
  if HealBot_Action_UpdatePlayerHoTs then
    HealBot_Action_UpdatePlayerHoTs()
  end
end

-- Display Mode dropdown init
function HealBot_Options_Integrations_DisplayModeDropdown_Init()
  local mode = HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode or 0
  local info

  info = {}
  info.text = "List"
  info.value = 0
  info.func = HealBot_Options_Integrations_DisplayModeDropdown_OnClick
  if mode == 0 then
    info.checked = 1
  end
  UIDropDownMenu_AddButton(info)

  info = {}
  info.text = "Icon Overlay"
  info.value = 1
  info.func = HealBot_Options_Integrations_DisplayModeDropdown_OnClick
  if mode == 1 then
    info.checked = 1
  end
  UIDropDownMenu_AddButton(info)

  info = {}
  info.text = "Both"
  info.value = 2
  info.func = HealBot_Options_Integrations_DisplayModeDropdown_OnClick
  if mode == 2 then
    info.checked = 1
  end
  UIDropDownMenu_AddButton(info)
end

-- Position dropdown click handler (relying on global this)
function HealBot_Options_Integrations_PositionDropdown_OnClick()
  UIDropDownMenu_SetSelectedID(HealBot_Options_Integrations_PositionDropdown, this:GetID())
  HealBot_Config.HealBot_Integrations_HoTTimerPosition = this.value
  UIDropDownMenu_SetText(this:GetText(), HealBot_Options_Integrations_PositionDropdown)
  if HealBot_Action_UpdatePlayerHoTs then
    HealBot_Action_UpdatePlayerHoTs()
  end
end

-- Position dropdown init
function HealBot_Options_Integrations_PositionDropdown_Init()
  local positions = {
    { value = "BELOW", label = "Below" },
    { value = "ABOVE", label = "Above" },
    { value = "LEFT",  label = "Left" },
    { value = "RIGHT", label = "Right" },
  }
  local currentPos = HealBot_Config.HealBot_Integrations_HoTTimerPosition or "BELOW"

  for _, p in ipairs(positions) do
    local info = {}
    info.text = p.label
    info.value = p.value
    info.func = HealBot_Options_Integrations_PositionDropdown_OnClick
    if currentPos == p.value then
      info.checked = 1
    end
    UIDropDownMenu_AddButton(info)
  end
end
