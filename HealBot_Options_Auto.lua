function HealBot_Options_AutoSwap_OnClick(this)
  if this:GetChecked() then
    HealBot_Config.AutoSwap_Enabled = 1
  else
    HealBot_Config.AutoSwap_Enabled = 0
  end
  HealBot_Action_PartyChanged()
end

function HealBot_Options_Auto_Initialize()
  local dropdownName = UIDROPDOWNMENU_OPEN_MENU
  if not dropdownName then return end
  local dropdownFrame = getglobal(dropdownName)
  if not dropdownFrame then return end
  local id = dropdownFrame:GetID()
  if not id then return end
  
  for i=1, getn(HealBot_Config.Skins), 1 do
    local info = {}
    info.text = HealBot_Config.Skins[i]
    info.func = HealBot_Options_Auto_OnSelect
    info.value = id
    if HealBot_Config.AutoSwap_Profiles[id] == HealBot_Config.Skins[i] then
      info.checked = 1
    else
      info.checked = nil
    end
    UIDropDownMenu_AddButton(info)
  end
end

function HealBot_Options_Auto_OnSelect()
  local skin = this:GetText()
  local id = this.value
  if not id or not skin then return end
  
  HealBot_Config.AutoSwap_Profiles[id] = skin
  
  local dropdowns = {
    "HealBot_Options_Auto_Solo",
    "HealBot_Options_Auto_Party",
    "HealBot_Options_Auto_Raid15",
    "HealBot_Options_Auto_Raid25",
    "HealBot_Options_Auto_Raid40"
  }
  local dropdownName = dropdowns[id]
  local dropdownFrame = getglobal(dropdownName)
  UIDropDownMenu_SetSelectedValue(dropdownFrame, skin)
  UIDropDownMenu_SetText(skin, dropdownFrame)
  
  HealBot_Action_PartyChanged()
end

function HealBot_Options_Auto_OnShow(this)
  if HealBot_Config.AutoSwap_Enabled == 1 then
    HealBot_Options_AutoSwap:SetChecked(1)
  else
    HealBot_Options_AutoSwap:SetChecked(nil)
  end
  
  local dropdowns = {
    "HealBot_Options_Auto_Solo",
    "HealBot_Options_Auto_Party",
    "HealBot_Options_Auto_Raid15",
    "HealBot_Options_Auto_Raid25",
    "HealBot_Options_Auto_Raid40"
  }
  for id, name in ipairs(dropdowns) do
    local dropdownFrame = getglobal(name)
    if dropdownFrame then
        UIDropDownMenu_SetWidth(150, dropdownFrame)
        local skin = HealBot_Config.AutoSwap_Profiles[id]
        if skin then
            UIDropDownMenu_SetSelectedValue(dropdownFrame, skin)
            UIDropDownMenu_SetText(skin, dropdownFrame)
        end
    end
  end
end
