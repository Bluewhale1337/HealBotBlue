-- HealBot Options panel file: HealBot_Options_Buffs.lua
-- Split from original HealBot_Options.lua

local HealBot_Current_Exclude_Spell = nil

function HealBot_Options_UpdateBuffExcludeButton(id, spellName)
  local btn = getglobal("HealBot_Options_Buff" .. id .. "Exclude")
  if btn then
    if spellName then
      btn:Enable()
      btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      local mode = (HealBot_Config.BuffFilterMode and HealBot_Config.BuffFilterMode[spellName]) or "EXCLUDE"
      if mode == "INCLUDE" then
        btn:SetText("Only")
      else
        btn:SetText("Exclude")
      end
    else
      btn:Disable()
      btn:SetText("Filter")
    end
  end
end

function HealBot_RecheckAllBuffs()
  if HealBot_Action_HealButtons and HealBot_CheckBuffs then
    for _, button in pairs(HealBot_Action_HealButtons) do
      if button.unit then
        HealBot_CheckBuffs(button.unit)
      end
    end
  end
  HealBot_Action_RefreshButtons(nil)
end

local function HealBot_Options_SaveBuffExcludeFromDialog(text)
  if not HealBot_Current_Exclude_Spell then return end
  local spellName = HealBot_Current_Exclude_Spell
  if not HealBot_Config.BuffFilterMode then
    HealBot_Config.BuffFilterMode = {}
  end
  if text and string.len(text) > 0 then
    local firstChar = string.sub(text, 1, 1)
    if firstChar == "+" then
      HealBot_Config.BuffFilterMode[spellName] = "INCLUDE"
      text = string.sub(text, 2)
    elseif firstChar == "-" then
      HealBot_Config.BuffFilterMode[spellName] = "EXCLUDE"
      text = string.sub(text, 2)
    end
  end
  HealBot_ParseBuffExcludeString(spellName, text)
  local myClass = UnitClass("player")
  if HealBot_Buff_Spells[myClass] and HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] then
    for i = 1, 8 do
      local val = HealBot_Config.BuffDropDowns[myClass][i] or 0
      if val > 0 and HealBot_Buff_Spells[myClass][val] == spellName then
        HealBot_Options_UpdateBuffExcludeButton(i, spellName)
      end
    end
  end
  HealBot_RecheckAllBuffs()
end

StaticPopupDialogs["HEALBOT_OPTIONS_BUFF_EXCLUDE"] = {
  text = "Filter targets for %s:\n(prefix '+' for Track Only, '-' for Exclude)\nNames separated by comma or space:",
  button1 = "Save",
  button2 = "Cancel",
  hasEditBox = 1,
  maxLetters = 255,
  OnShow = function()
    local editBox = getglobal(this:GetName() .. "EditBox")
    local current = ""
    if HealBot_Current_Exclude_Spell and HealBot_Config.BuffExclude then
      current = HealBot_Config.BuffExclude[HealBot_Current_Exclude_Spell] or ""
    end
    local mode = (HealBot_Config.BuffFilterMode and HealBot_Config.BuffFilterMode[HealBot_Current_Exclude_Spell]) or "EXCLUDE"
    if mode == "INCLUDE" and current ~= "" then
      current = "+" .. current
    end
    editBox:SetText(current)
    editBox:HighlightText()
  end,
  OnAccept = function()
    local editBox = getglobal(this:GetParent():GetName() .. "EditBox")
    local text = editBox:GetText()
    HealBot_Options_SaveBuffExcludeFromDialog(text)
  end,
  EditBoxOnEnterPressed = function()
    local editBox = getglobal(this:GetParent():GetName() .. "EditBox")
    local text = editBox:GetText()
    HealBot_Options_SaveBuffExcludeFromDialog(text)
    this:GetParent():Hide()
  end,
  EditBoxOnEscapePressed = function()
    this:GetParent():Hide()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
}

function HealBot_ParseBuffExcludeString(spellName, rawText)
  if not spellName then return end
  if not HealBot_Config.BuffExclude then
    HealBot_Config.BuffExclude = {}
  end
  HealBot_Config.BuffExclude[spellName] = rawText or ""
  if not HealBot_BuffExcludeLookup then
    HealBot_BuffExcludeLookup = {}
  end
  HealBot_BuffExcludeLookup[spellName] = {}
  if rawText and type(rawText) == "string" then
    for name in string.gfind(rawText, "[^,%s]+") do
      if string.len(name) > 0 then
        local cleanName = string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
        HealBot_BuffExcludeLookup[spellName][cleanName] = true
        HealBot_BuffExcludeLookup[spellName][name] = true
      end
    end
  end
end

function HealBot_Init_BuffExcludeLookup()
  HealBot_BuffExcludeLookup = {}
  if not HealBot_Config.BuffExclude then
    HealBot_Config.BuffExclude = {}
  end
  for spellName, rawText in pairs(HealBot_Config.BuffExclude) do
    if type(rawText) == "string" and spellName then
      HealBot_ParseBuffExcludeString(spellName, rawText)
    end
  end
end

function HealBot_Options_BuffExclude_OnClick(self, button)
  local frame = self or this
  local clickType = button or arg1
  local id = frame:GetID()
  local myClass = UnitClass("player")
  local val = (HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] and HealBot_Config.BuffDropDowns[myClass][id]) or 0
  if val > 0 and HealBot_Buff_Spells[myClass] and HealBot_Buff_Spells[myClass][val] then
    local spellName = HealBot_Buff_Spells[myClass][val]
    if clickType == "RightButton" then
      if not HealBot_Config.BuffFilterMode then
        HealBot_Config.BuffFilterMode = {}
      end
      local currentMode = HealBot_Config.BuffFilterMode[spellName] or "EXCLUDE"
      if currentMode == "INCLUDE" then
        HealBot_Config.BuffFilterMode[spellName] = "EXCLUDE"
      else
        HealBot_Config.BuffFilterMode[spellName] = "INCLUDE"
      end
      HealBot_Options_UpdateBuffExcludeButton(id, spellName)
      HealBot_Options_BuffExclude_OnEnter(frame)
      HealBot_RecheckAllBuffs()
    else
      HealBot_Current_Exclude_Spell = spellName
      StaticPopup_Show("HEALBOT_OPTIONS_BUFF_EXCLUDE", spellName)
    end
  end
end

function HealBot_Options_BuffExclude_OnEnter(self)
  local frame = self or this
  local id = frame:GetID()
  local myClass = UnitClass("player")
  local val = (HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] and HealBot_Config.BuffDropDowns[myClass][id]) or 0
  if val > 0 and HealBot_Buff_Spells[myClass] and HealBot_Buff_Spells[myClass][val] then
    local spellName = HealBot_Buff_Spells[myClass][val]
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetText(spellName .. " Target Filter", 1, 1, 1)
    local mode = (HealBot_Config.BuffFilterMode and HealBot_Config.BuffFilterMode[spellName]) or "EXCLUDE"
    if mode == "INCLUDE" then
      GameTooltip:AddLine("Mode: Track ONLY on target(s) (Whitelist)", 0.2, 1.0, 0.2)
    else
      GameTooltip:AddLine("Mode: Exclude target(s) (Blacklist)", 1.0, 0.6, 0.2)
    end
    local list = (HealBot_Config.BuffExclude and HealBot_Config.BuffExclude[spellName]) or ""
    GameTooltip:AddLine("Targets: " .. (list ~= "" and list or "None"), 1, 0.82, 0)
    GameTooltip:AddLine("Left-Click to edit names (prefix '+' for Track Only).", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Right-Click to toggle Exclude / Track Only.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end
end

function HealBot_Options_BuffExclude_OnLeave(self)
  GameTooltip:Hide()
end

-- HealBot_Options_BuffWatch_OnClick: UI handler for OnClick options panel.
function HealBot_Options_BuffWatch_OnClick(self)
  local frame = self or this
  HealBot_Config.BuffWatch = frame:GetChecked() or 0;
  if HealBot_Config.BuffWatch == 0 then
    HealBot_Options_BuffWatchInCombat:Disable()
  else
    HealBot_Options_BuffWatchInCombat:Enable()
  end
  HealBot_RecheckAllBuffs();
end
-- HealBot_Options_BuffWatchInCombat_OnClick: UI handler for OnClick options panel.
function HealBot_Options_BuffWatchInCombat_OnClick(self)
  local frame = self or this
  HealBot_Config.BuffWatchInCombat = frame:GetChecked() or 0;
  HealBot_RecheckAllBuffs();
end
-- HealBot_Options_BuffSelf_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_BuffSelf_OnLoad(self)
  local frame = self or this
  getglobal(frame:GetName().."Text"):SetText("Self Only")
  local id = frame:GetID()
  if HealBot_Config.BuffWatchSelf and HealBot_Config.BuffWatchSelf[id] then
    local isSelf = (HealBot_Config.BuffWatchSelf[id] == 1)
    frame:SetChecked(isSelf and 1 or nil)
  else
    frame:SetChecked(nil)
  end
end
-- HealBot_Options_BuffSelf_OnClick: UI handler for OnClick options panel.
function HealBot_Options_BuffSelf_OnClick(self)
  local frame = self or this
  local id = frame:GetID()
  if not HealBot_Config.BuffWatchSelf then
    HealBot_Config.BuffWatchSelf = {0,0,0,0,0,0,0,0}
  end
  if frame:GetChecked() then
    HealBot_Config.BuffWatchSelf[id] = 1
  else
    HealBot_Config.BuffWatchSelf[id] = 0
  end
  HealBot_RecheckAllBuffs();
end
-- HealBot_Options_Buff_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_Buff_OnLoad(self)
  local frame = self or this
  UIDropDownMenu_Initialize(frame, HealBot_Options_Buff_Initialize)
  UIDropDownMenu_SetWidth(85, frame)
end
-- HealBot_Options_Buff_Initialize: UI handler for Initialize options panel.
function HealBot_Options_Buff_Initialize()
  local myClass = UnitClass("player")
  local info
  
  info = { text = "None", func = HealBot_Options_Buff_OnClick, value = 0 }
  UIDropDownMenu_AddButton(info)
  
  if HealBot_Buff_Spells[myClass] then
    for i, spellName in ipairs(HealBot_Buff_Spells[myClass]) do
      info = {
        text = spellName,
        func = HealBot_Options_Buff_OnClick,
        value = i
      }
      UIDropDownMenu_AddButton(info)
    end
  end
end
-- HealBot_Options_Buff_OnClick: UI handler for OnClick options panel.
function HealBot_Options_Buff_OnClick()
  local frameName = UIDROPDOWNMENU_OPEN_MENU
  local frame = getglobal(frameName)
  local myClass = UnitClass("player")
  local id = frame:GetID()
  
  if not HealBot_Config.BuffDropDowns then HealBot_Config.BuffDropDowns = {} end
  if not HealBot_Config.BuffDropDowns[myClass] then HealBot_Config.BuffDropDowns[myClass] = {} end
  HealBot_Config.BuffDropDowns[myClass][id] = this.value
  
  local text = "None"
  local spellName = nil
  if this.value > 0 then
    text = HealBot_Buff_Spells[myClass][this.value]
    spellName = text
  end
  
  HealBot_UIDropDownMenu_SetSelectedID(frame, this.value + 1)
  UIDropDownMenu_SetText(text, frame)

  HealBot_Options_UpdateBuffExcludeButton(id, spellName)

  HealBot_RecheckAllBuffs();
end
-- HealBot_Options_SetBuffs: UI handler for SetBuffs options panel.
function HealBot_Options_SetBuffs()
  local myClass = UnitClass("player")
  if HealBot_Options_BuffWatch then
    HealBot_Options_BuffWatch:SetChecked(HealBot_Config.BuffWatch)
    HealBot_Options_BuffWatchInCombat:SetChecked(HealBot_Config.BuffWatchInCombat)
    if HealBot_Config.BuffWatch == 0 then
      HealBot_Options_BuffWatchInCombat:Disable()
    else
      HealBot_Options_BuffWatchInCombat:Enable()
    end
  end
  
  HealBot_Init_BuffExcludeLookup()

  if not HealBot_Config.BuffDropDowns then HealBot_Config.BuffDropDowns = {} end
  if not HealBot_Config.BuffDropDowns[myClass] then HealBot_Config.BuffDropDowns[myClass] = {} end
  
  for i = 1, 8 do
    local val = HealBot_Config.BuffDropDowns[myClass][i] or 0
    local dropDown = getglobal("HealBot_Options_Buff" .. i)
    local spellName = nil
    if val > 0 and HealBot_Buff_Spells[myClass] and HealBot_Buff_Spells[myClass][val] then
      spellName = HealBot_Buff_Spells[myClass][val]
    end
    if dropDown then
      UIDropDownMenu_Initialize(dropDown, HealBot_Options_Buff_Initialize)
      HealBot_UIDropDownMenu_SetSelectedID(dropDown, val + 1)
      local text = spellName or "None"
      UIDropDownMenu_SetText(text, dropDown)
    end

    HealBot_Options_UpdateBuffExcludeButton(i, spellName)
    
    local selfCheck = getglobal("HealBot_Options_Buff" .. i .. "Self")
    if selfCheck then
      if HealBot_Config.BuffWatchSelf and HealBot_Config.BuffWatchSelf[i] then
        local isSelf = (HealBot_Config.BuffWatchSelf[i] == 1)
        selfCheck:SetChecked(isSelf and 1 or nil)
      else
        selfCheck:SetChecked(nil)
      end
    end
  end
end
