-- HealBot Options panel file: HealBot_Options_Buffs.lua
-- Split from original HealBot_Options.lua

HealBot_Current_Override_Spell = nil
HealBot_BuffFilter_PickingSpell = nil

function HealBot_Options_UpdateBuffExcludeButton(id, spellName)
  local btn = getglobal("HealBot_Options_Buff" .. id .. "Exclude")
  if btn then
    btn:SetText("Override")
    if spellName then
      btn:Enable()
    else
      btn:Disable()
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

function HealBot_Options_OpenBuffOverrideDialog(spellName)
  if not spellName then return end
  HealBot_Current_Override_Spell = spellName
  if HealBot_Options_BuffOverrideTitleText then
    HealBot_Options_BuffOverrideTitleText:SetText("Overrides: " .. spellName)
  end
  if HealBot_Options_BuffOverrideModeExcludeText then
    HealBot_Options_BuffOverrideModeExcludeText:SetText("Exclude")
  end
  if HealBot_Options_BuffOverrideModeIncludeText then
    HealBot_Options_BuffOverrideModeIncludeText:SetText("Track Only")
  end
  local mode = "EXCLUDE"
  if HealBot_Config.BuffFilterMode and HealBot_Config.BuffFilterMode[spellName] then
    mode = HealBot_Config.BuffFilterMode[spellName]
  end
  if HealBot_Options_BuffOverrideModeExclude and HealBot_Options_BuffOverrideModeInclude then
    if mode == "INCLUDE" then
      HealBot_Options_BuffOverrideModeExclude:SetChecked(nil)
      HealBot_Options_BuffOverrideModeInclude:SetChecked(1)
    else
      HealBot_Options_BuffOverrideModeExclude:SetChecked(1)
      HealBot_Options_BuffOverrideModeInclude:SetChecked(nil)
    end
  end
  local currentText = ""
  if HealBot_Config.BuffExclude and HealBot_Config.BuffExclude[spellName] then
    currentText = HealBot_Config.BuffExclude[spellName]
  end
  if HealBot_Options_BuffOverrideEditBox then
    HealBot_Options_BuffOverrideEditBox:SetText(currentText)
  end
  if HealBot_Options_BuffOverrideDialog then
    HealBot_Options_BuffOverrideDialog:Show()
  end
end

function HealBot_Options_BuffOverrideMode_OnClick(mode)
  if mode == "INCLUDE" then
    if HealBot_Options_BuffOverrideModeInclude then
      HealBot_Options_BuffOverrideModeInclude:SetChecked(1)
    end
    if HealBot_Options_BuffOverrideModeExclude then
      HealBot_Options_BuffOverrideModeExclude:SetChecked(nil)
    end
  else
    if HealBot_Options_BuffOverrideModeExclude then
      HealBot_Options_BuffOverrideModeExclude:SetChecked(1)
    end
    if HealBot_Options_BuffOverrideModeInclude then
      HealBot_Options_BuffOverrideModeInclude:SetChecked(nil)
    end
  end
end

function HealBot_Options_ToggleOverrideNameFromFrame(unitName)
  if not unitName or not HealBot_Options_BuffOverrideEditBox then return end
  local raw = HealBot_Options_BuffOverrideEditBox:GetText() or ""
  local names = {}
  local found = false
  for name in string.gfind(raw, "[^,%s]+") do
    if string.lower(name) == string.lower(unitName) then
      found = true
    else
      table.insert(names, name)
    end
  end
  if not found then
    table.insert(names, unitName)
  end

  local newText = ""
  local count = table.getn(names)
  for i = 1, count do
    if i == 1 then
      newText = names[i]
    else
      newText = newText .. ", " .. names[i]
    end
  end

  HealBot_Options_BuffOverrideEditBox:SetText(newText)

  if found then
    PlaySound("igMiniMapClose")
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Removed " .. unitName .. " from overrides.", 1.0, 0.8, 0.2)
    end
  else
    PlaySound("igMiniMapOpen")
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Added " .. unitName .. " to overrides.", 0.2, 1.0, 0.4)
    end
  end
end

function HealBot_Options_BuffOverrideSave_OnClick()
  local spellName = HealBot_Current_Override_Spell
  if not spellName then
    if HealBot_Options_BuffOverrideDialog then
      HealBot_Options_BuffOverrideDialog:Hide()
    end
    return
  end

  local mode = "EXCLUDE"
  if HealBot_Options_BuffOverrideModeInclude and HealBot_Options_BuffOverrideModeInclude:GetChecked() then
    mode = "INCLUDE"
  end

  local text = ""
  if HealBot_Options_BuffOverrideEditBox then
    text = HealBot_Options_BuffOverrideEditBox:GetText() or ""
  end

  if not HealBot_Config.BuffFilterMode then
    HealBot_Config.BuffFilterMode = {}
  end
  HealBot_Config.BuffFilterMode[spellName] = mode

  if not HealBot_Config.BuffExclude then
    HealBot_Config.BuffExclude = {}
  end
  HealBot_Config.BuffExclude[spellName] = text

  HealBot_ParseBuffExcludeString(spellName, text)
  HealBot_RecheckAllBuffs()

  local myClass = UnitClass("player")
  if HealBot_Buff_Spells[myClass] and HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] then
    for i = 1, 8 do
      local val = HealBot_Config.BuffDropDowns[myClass][i] or 0
      if val > 0 and HealBot_Buff_Spells[myClass][val] == spellName then
        HealBot_Options_UpdateBuffExcludeButton(i, spellName)
      end
    end
  end

  if HealBot_Options_BuffOverrideDialog then
    HealBot_Options_BuffOverrideDialog:Hide()
  end
end

function HealBot_Options_BuffOverrideClear_OnClick()
  local spellName = HealBot_Current_Override_Spell
  if spellName then
    if not HealBot_Config.BuffExclude then
      HealBot_Config.BuffExclude = {}
    end
    HealBot_Config.BuffExclude[spellName] = ""

    if not HealBot_Config.BuffFilterMode then
      HealBot_Config.BuffFilterMode = {}
    end
    HealBot_Config.BuffFilterMode[spellName] = "EXCLUDE"

    if not HealBot_BuffExcludeLookup then
      HealBot_BuffExcludeLookup = {}
    end
    HealBot_BuffExcludeLookup[spellName] = {}

    HealBot_ParseBuffExcludeString(spellName, "")
    HealBot_RecheckAllBuffs()

    local myClass = UnitClass("player")
    if HealBot_Buff_Spells[myClass] and HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] then
      for i = 1, 8 do
        local val = HealBot_Config.BuffDropDowns[myClass][i] or 0
        if val > 0 and HealBot_Buff_Spells[myClass][val] == spellName then
          HealBot_Options_UpdateBuffExcludeButton(i, spellName)
        end
      end
    end
  end

  if HealBot_Options_BuffOverrideEditBox then
    HealBot_Options_BuffOverrideEditBox:SetText("")
  end
  if HealBot_Options_BuffOverrideDialog then
    HealBot_Options_BuffOverrideDialog:Hide()
  end
end

function HealBot_Options_BuffOverrideCancel_OnClick()
  if HealBot_Options_BuffOverrideDialog then
    HealBot_Options_BuffOverrideDialog:Hide()
  end
end

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

function HealBot_StartBuffFilterPicker(spellName)
  if not spellName then return end
  HealBot_BuffFilter_PickingSpell = spellName
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("HealBot: Frame picker ACTIVE for " .. spellName .. ". Left-click frames to add/remove, Right-click frame or Shift-click button to finish.", 1.0, 0.8, 0.2)
  end
  PlaySound("igMiniMapOpen")
end

function HealBot_StopBuffFilterPicker()
  if HealBot_BuffFilter_PickingSpell then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Frame picker stopped.", 1.0, 0.8, 0.2)
    end
    HealBot_BuffFilter_PickingSpell = nil
    PlaySound("igMiniMapClose")
  end
end

function HealBot_ToggleBuffFilterName(spellName, unitName)
  if not spellName or not unitName then return end
  if not HealBot_Config.BuffExclude then
    HealBot_Config.BuffExclude = {}
  end
  local rawText = HealBot_Config.BuffExclude[spellName] or ""
  local names = {}
  local found = false
  for name in string.gfind(rawText, "[^,%s]+") do
    if string.lower(name) == string.lower(unitName) then
      found = true
    else
      table.insert(names, name)
    end
  end
  if not found then
    table.insert(names, unitName)
  end

  local newRaw = ""
  for i = 1, table.getn(names) do
    if i == 1 then
      newRaw = names[i]
    else
      newRaw = newRaw .. ", " .. names[i]
    end
  end

  HealBot_Config.BuffExclude[spellName] = newRaw
  HealBot_ParseBuffExcludeString(spellName, newRaw)
  HealBot_RecheckAllBuffs()

  if DEFAULT_CHAT_FRAME then
    if found then
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Removed " .. unitName .. " from " .. spellName .. " filter.", 1.0, 0.8, 0.2)
    else
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Added " .. unitName .. " to " .. spellName .. " filter.", 0.2, 1.0, 0.4)
    end
  end

  if HealBot_Options_BuffOverrideDialog and HealBot_Options_BuffOverrideDialog:IsVisible() and HealBot_Current_Override_Spell == spellName then
    if HealBot_Options_BuffOverrideEditBox then
      HealBot_Options_BuffOverrideEditBox:SetText(newRaw)
    end
  end
end

function HealBot_Options_BuffExclude_OnClick(self)
  local frame = self or this
  local id = frame:GetID()
  local myClass = UnitClass("player")
  local val = (HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] and HealBot_Config.BuffDropDowns[myClass][id]) or 0
  if val > 0 and HealBot_Buff_Spells[myClass] and HealBot_Buff_Spells[myClass][val] then
    local spellName = HealBot_Buff_Spells[myClass][val]
    HealBot_Options_OpenBuffOverrideDialog(spellName)
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
    GameTooltip:SetText(spellName .. " Target Overrides", 1, 1, 1)
    local mode = (HealBot_Config.BuffFilterMode and HealBot_Config.BuffFilterMode[spellName]) or "EXCLUDE"
    if mode == "INCLUDE" then
      GameTooltip:AddLine("Mode: Track ONLY on target(s) (Whitelist)", 0.2, 1.0, 0.2)
    else
      GameTooltip:AddLine("Mode: Exclude target(s) (Blacklist)", 1.0, 0.6, 0.2)
    end
    local list = (HealBot_Config.BuffExclude and HealBot_Config.BuffExclude[spellName]) or ""
    GameTooltip:AddLine("Targets: " .. (list ~= "" and list or "None"), 1, 0.82, 0)
    GameTooltip:AddLine("Click to configure overrides.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end
end

function HealBot_Options_BuffExclude_OnLeave(self)
  GameTooltip:Hide()
end

function HealBot_Options_ClearBuffOverrides_OnClick(self)
  HealBot_Config.BuffExclude = {}
  HealBot_Config.BuffFilterMode = {}
  HealBot_BuffExcludeLookup = {}
  HealBot_StopBuffFilterPicker()
  local myClass = UnitClass("player")
  for i = 1, 8 do
    local val = (HealBot_Config.BuffDropDowns and HealBot_Config.BuffDropDowns[myClass] and HealBot_Config.BuffDropDowns[myClass][i]) or 0
    local spellName = nil
    if val > 0 and HealBot_Buff_Spells[myClass] and HealBot_Buff_Spells[myClass][val] then
      spellName = HealBot_Buff_Spells[myClass][val]
    end
    HealBot_Options_UpdateBuffExcludeButton(i, spellName)
  end
  HealBot_RecheckAllBuffs()
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("HealBot: Cleared all buff target overrides.", 1.0, 0.8, 0.2)
  end
  PlaySound("igMiniMapClose")
end

function HealBot_Options_ClearBuffOverrides_OnEnter(self)
  local frame = self or this
  GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
  GameTooltip:SetText("Clear Buff Overrides", 1, 1, 1)
  GameTooltip:AddLine("Reset all whitelist and blacklist target filters across all buff slots.", 0.8, 0.8, 0.8)
  GameTooltip:Show()
end

function HealBot_Options_ClearBuffOverrides_OnLeave(self)
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
  UIDropDownMenu_SetWidth(75, frame)
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
