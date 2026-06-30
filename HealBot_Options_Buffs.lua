-- HealBot Options panel file: HealBot_Options_Buffs.lua
-- Split from original HealBot_Options.lua

function HealBot_Options_BuffWatch_OnClick(self)
  local frame = self or this
  HealBot_Config.BuffWatch = frame:GetChecked() or 0;
  if HealBot_Config.BuffWatch == 0 then
    HealBot_Options_BuffWatchInCombat:Disable()
  else
    HealBot_Options_BuffWatchInCombat:Enable()
  end
  HealBot_RecalcParty();
end
function HealBot_Options_BuffWatchInCombat_OnClick(self)
  local frame = self or this
  HealBot_Config.BuffWatchInCombat = frame:GetChecked() or 0;
  HealBot_RecalcParty();
end
function HealBot_Options_BuffSelf_OnLoad(self)
  local frame = self or this
  getglobal(this:GetName().."Text"):SetText("Self Only")
  local id = this:GetID()
  if HealBot_Config.BuffWatchSelf and HealBot_Config.BuffWatchSelf[id] then
    this:SetChecked(HealBot_Config.BuffWatchSelf[id])
  else
    this:SetChecked(0)
  end
end
function HealBot_Options_BuffSelf_OnClick(self)
  local frame = self or this
  local id = this:GetID()
  if not HealBot_Config.BuffWatchSelf then
    HealBot_Config.BuffWatchSelf = {0,0,0,0,0,0,0,0}
  end
  if frame:GetChecked() then
    HealBot_Config.BuffWatchSelf[id] = 1
  else
    HealBot_Config.BuffWatchSelf[id] = 0
  end
  HealBot_RecalcParty();
end
function HealBot_Options_Buff_OnLoad(self)
  local frame = self or this
  UIDropDownMenu_Initialize(frame, HealBot_Options_Buff_Initialize)
  UIDropDownMenu_SetWidth(110, frame)
end
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
function HealBot_Options_Buff_OnClick()
  local frameName = UIDROPDOWNMENU_OPEN_MENU
  local frame = getglobal(frameName)
  local myClass = UnitClass("player")
  local id = frame:GetID()
  
  if not HealBot_Config.BuffDropDowns then HealBot_Config.BuffDropDowns = {} end
  if not HealBot_Config.BuffDropDowns[myClass] then HealBot_Config.BuffDropDowns[myClass] = {} end
  HealBot_Config.BuffDropDowns[myClass][id] = this.value
  
  local text = "None"
  if this.value > 0 then
    text = HealBot_Buff_Spells[myClass][this.value]
  end
  
  UIDropDownMenu_SetSelectedID(frame, this.value + 1)
  UIDropDownMenu_SetText(text, frame)
  HealBot_RecalcParty();
end
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
  
  if not HealBot_Config.BuffDropDowns then HealBot_Config.BuffDropDowns = {} end
  if not HealBot_Config.BuffDropDowns[myClass] then HealBot_Config.BuffDropDowns[myClass] = {} end
  
  for i = 1, 8 do
    local dropDown = getglobal("HealBot_Options_Buff" .. i)
    if dropDown then
      local val = HealBot_Config.BuffDropDowns[myClass][i] or 0
      UIDropDownMenu_Initialize(dropDown, HealBot_Options_Buff_Initialize)
      UIDropDownMenu_SetSelectedID(dropDown, val + 1)
    end
    
    local selfCheck = getglobal("HealBot_Options_BuffSelf" .. i)
    if selfCheck then
      if HealBot_Config.BuffWatchSelf and HealBot_Config.BuffWatchSelf[i] then
        selfCheck:SetChecked(HealBot_Config.BuffWatchSelf[i])
      else
        selfCheck:SetChecked(0)
      end
    end
  end
end
