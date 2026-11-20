-- HealBot Options panel file: HealBot_Options_Healing.lua
-- Split from original HealBot_Options.lua

-- HealBot_Options_GroupHeals_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_GroupHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_GroupHeals_OnClick: UI handler for OnClick options panel.
function HealBot_Options_GroupHeals_OnClick(this)
  HealBot_Config.GroupHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end
-- HealBot_Options_TankHeals_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_TankHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_TankHeals_OnClick: UI handler for OnClick options panel.
function HealBot_Options_TankHeals_OnClick(this)
  HealBot_Config.TankHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end
-- HealBot_Options_TargetHeals_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_TargetHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_TargetHeals_OnClick: UI handler for OnClick options panel.
function HealBot_Options_TargetHeals_OnClick(this)
  HealBot_Config.TargetHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end
-- HealBot_Options_EmergencyHeals_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_EmergencyHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_EmergencyHeals_OnClick: UI handler for OnClick options panel.
function HealBot_Options_EmergencyHeals_OnClick(this)
  HealBot_Config.EmergencyHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end
-- HealBot_Options_PetHeals_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_PetHeals_OnLoad(this,text)
  this.text = text
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_PetHeals_OnClick: UI handler for OnClick options panel.
function HealBot_Options_PetHeals_OnClick(this)
  HealBot_Config.PetHeals = this:GetChecked() or 0;
  HealBot_RecalcParty();
end
-- HealBot_Options_OverHeal_OnValueChanged: UI handler for OnValueChanged options panel.
function HealBot_Options_OverHeal_OnValueChanged(this)
  HealBot_Config.OverHeal = HealBot_Options_Pct_OnValueChanged(this);
end
-- HealBot_Options_EFClass_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_EFClass_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
-- HealBot_Options_EFClass_OnClick: UI handler for OnClick options panel.
function HealBot_Options_EFClass_OnClick(this)
    if HealBot_Config.EmergencyFClass==1 then
      HealBot_Config.EmergIncMelee[HEALBOT_DRUID] = HealBot_Options_EFClassDruid:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_HUNTER] = HealBot_Options_EFClassHunter:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_MAGE] = HealBot_Options_EFClassMage:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_PALADIN] = HealBot_Options_EFClassPaladin:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_PRIEST] = HealBot_Options_EFClassPriest:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_ROGUE] = HealBot_Options_EFClassRogue:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_SHAMAN] = HealBot_Options_EFClassShaman:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_WARLOCK] = HealBot_Options_EFClassWarlock:GetChecked() or 0;
      HealBot_Config.EmergIncMelee[HEALBOT_WARRIOR] = HealBot_Options_EFClassWarrior:GetChecked() or 0;
    elseif HealBot_Config.EmergencyFClass==2 then
      HealBot_Config.EmergIncRange[HEALBOT_DRUID] = HealBot_Options_EFClassDruid:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_HUNTER] = HealBot_Options_EFClassHunter:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_MAGE] = HealBot_Options_EFClassMage:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_PALADIN] = HealBot_Options_EFClassPaladin:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_PRIEST] = HealBot_Options_EFClassPriest:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_ROGUE] = HealBot_Options_EFClassRogue:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_SHAMAN] = HealBot_Options_EFClassShaman:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_WARLOCK] = HealBot_Options_EFClassWarlock:GetChecked() or 0;
      HealBot_Config.EmergIncRange[HEALBOT_WARRIOR] = HealBot_Options_EFClassWarrior:GetChecked() or 0;
    elseif HealBot_Config.EmergencyFClass==3 then
      HealBot_Config.EmergIncHealers[HEALBOT_DRUID] = HealBot_Options_EFClassDruid:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_HUNTER] = HealBot_Options_EFClassHunter:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_MAGE] = HealBot_Options_EFClassMage:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_PALADIN] = HealBot_Options_EFClassPaladin:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_PRIEST] = HealBot_Options_EFClassPriest:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_ROGUE] = HealBot_Options_EFClassRogue:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_SHAMAN] = HealBot_Options_EFClassShaman:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_WARLOCK] = HealBot_Options_EFClassWarlock:GetChecked() or 0;
      HealBot_Config.EmergIncHealers[HEALBOT_WARRIOR] = HealBot_Options_EFClassWarrior:GetChecked() or 0;
    elseif HealBot_Config.EmergencyFClass==4 then
      HealBot_Config.EmergIncCustom[HEALBOT_DRUID] = HealBot_Options_EFClassDruid:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_HUNTER] = HealBot_Options_EFClassHunter:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_MAGE] = HealBot_Options_EFClassMage:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_PALADIN] = HealBot_Options_EFClassPaladin:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_PRIEST] = HealBot_Options_EFClassPriest:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_ROGUE] = HealBot_Options_EFClassRogue:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_SHAMAN] = HealBot_Options_EFClassShaman:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_WARLOCK] = HealBot_Options_EFClassWarlock:GetChecked() or 0;
      HealBot_Config.EmergIncCustom[HEALBOT_WARRIOR] = HealBot_Options_EFClassWarrior:GetChecked() or 0;
    end
  if HealBot_Config.EmergIncMonitor > 1 then
     HealBot_Action_PartyChanged();
  end
end
HealBot_Options_HealthText_List = {
  "Name Only",
  "Health Percentage",
  "Real Health",
  "Health Deficit",
}

-- HealBot_Options_HealthText_DropDown: UI handler for DropDown options panel.
function HealBot_Options_HealthText_DropDown()
  for i=1, getn(HealBot_Options_HealthText_List), 1 do
    local info = {};
    info.text = HealBot_Options_HealthText_List[i];
    info.func = HealBot_Options_HealthText_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

-- HealBot_Options_HealthText_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_HealthText_OnLoad(this)
  UIDropDownMenu_Initialize(this, HealBot_Options_HealthText_DropDown);
  UIDropDownMenu_SetWidth(110, this);
end

-- HealBot_Options_HealthText_OnSelect: UI handler for OnSelect options panel.
function HealBot_Options_HealthText_OnSelect()
  HealBot_Config.ShowHealthText = this:GetID() - 1;
  HealBot_UIDropDownMenu_SetSelectedID(HealBot_Options_HealthText, this:GetID())
  HealBot_Action_RefreshButtons();
end

local HealBot_Options_EmergencyFClass_List = {
  HEALBOT_CLASSES_MELEE,
  HEALBOT_CLASSES_RANGES,
  HEALBOT_CLASSES_HEALERS,
  HEALBOT_CLASSES_CUSTOM,
}

-- HealBot_Options_EmergencyFClass_DropDown: UI handler for DropDown options panel.
function HealBot_Options_EmergencyFClass_DropDown()
  for i=1, getn(HealBot_Options_EmergencyFClass_List), 1 do
    local info = {};
    info.text = HealBot_Options_EmergencyFClass_List[i];
    info.func = HealBot_Options_EmergencyFClass_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

-- HealBot_Options_EmergencyFClass_Initialize: UI handler for Initialize options panel.
function HealBot_Options_EmergencyFClass_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_EmergencyFClass,HealBot_Options_EmergencyFClass_DropDown)
end

-- HealBot_Options_EmergencyFClass_Refresh: UI handler for Refresh options panel.
function HealBot_Options_EmergencyFClass_Refresh(onselect)
  if not HealBot_Config.EmergencyFClass then return end
  if not onselect then HealBot_Options_EmergencyFClass_Initialize() end  -- or wrong menu may be used !
  HealBot_UIDropDownMenu_SetSelectedID(HealBot_Options_EmergencyFClass,HealBot_Config.EmergencyFClass)
end

-- HealBot_Options_EmergencyFClass_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_EmergencyFClass_OnLoad()
  UIDropDownMenu_Initialize(this, HealBot_Options_EmergencyFClass_DropDown)
  UIDropDownMenu_SetWidth(100, this)
end

-- HealBot_Options_EmergencyFClass_OnSelect: UI handler for OnSelect options panel.
function HealBot_Options_EmergencyFClass_OnSelect()
  HealBot_Config.EmergencyFClass = this:GetID()
  HealBot_Options_EmergencyFClass_Refresh(true)
  HealBot_Options_EFClass_Reset()
end

-- HealBot_Options_EFClass_Reset: UI handler for Reset options panel.
function HealBot_Options_EFClass_Reset()
  if HealBot_Config.EmergencyFClass==1 then
    HealBot_Options_EFClassDruid:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_DRUID]);
    HealBot_Options_EFClassHunter:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_HUNTER]);
    HealBot_Options_EFClassMage:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_MAGE]);
    HealBot_Options_EFClassPaladin:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_PALADIN]);
    HealBot_Options_EFClassPriest:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_PRIEST]);
    HealBot_Options_EFClassRogue:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_ROGUE]);
    HealBot_Options_EFClassShaman:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_SHAMAN]);
    HealBot_Options_EFClassWarlock:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_WARLOCK]);
    HealBot_Options_EFClassWarrior:SetChecked(HealBot_Config.EmergIncMelee[HEALBOT_WARRIOR]);
  elseif HealBot_Config.EmergencyFClass==2 then
    HealBot_Options_EFClassDruid:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_DRUID]);
    HealBot_Options_EFClassHunter:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_HUNTER]);
    HealBot_Options_EFClassMage:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_MAGE]);
    HealBot_Options_EFClassPaladin:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_PALADIN]);
    HealBot_Options_EFClassPriest:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_PRIEST]);
    HealBot_Options_EFClassRogue:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_ROGUE]);
    HealBot_Options_EFClassShaman:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_SHAMAN]);
    HealBot_Options_EFClassWarlock:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_WARLOCK]);
    HealBot_Options_EFClassWarrior:SetChecked(HealBot_Config.EmergIncRange[HEALBOT_WARRIOR]);
  elseif HealBot_Config.EmergencyFClass==3 then
    HealBot_Options_EFClassDruid:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_DRUID]);
    HealBot_Options_EFClassHunter:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_HUNTER]);
    HealBot_Options_EFClassMage:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_MAGE]);
    HealBot_Options_EFClassPaladin:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_PALADIN]);
    HealBot_Options_EFClassPriest:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_PRIEST]);
    HealBot_Options_EFClassRogue:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_ROGUE]);
    HealBot_Options_EFClassShaman:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_SHAMAN]);
    HealBot_Options_EFClassWarlock:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_WARLOCK]);
    HealBot_Options_EFClassWarrior:SetChecked(HealBot_Config.EmergIncHealers[HEALBOT_WARRIOR]);
  elseif HealBot_Config.EmergencyFClass==4 then
    HealBot_Options_EFClassDruid:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_DRUID]);
    HealBot_Options_EFClassHunter:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_HUNTER]);
    HealBot_Options_EFClassMage:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_MAGE]);
    HealBot_Options_EFClassPaladin:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_PALADIN]);
    HealBot_Options_EFClassPriest:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_PRIEST]);
    HealBot_Options_EFClassRogue:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_ROGUE]);
    HealBot_Options_EFClassShaman:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_SHAMAN]);
    HealBot_Options_EFClassWarlock:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_WARLOCK]);
    HealBot_Options_EFClassWarrior:SetChecked(HealBot_Config.EmergIncCustom[HEALBOT_WARRIOR]);
  end
end

--------------------------------------------------------------------------------

local HealBot_Options_ExtraSort_List = {
  HEALBOT_SORTBY_NAME,
  HEALBOT_SORTBY_CLASS,
  HEALBOT_SORTBY_GROUP,
  HEALBOT_SORTBY_MAXHEALTH,
}

-- HealBot_Options_ExtraSort_DropDown: UI handler for DropDown options panel.
function HealBot_Options_ExtraSort_DropDown()
  for i=1, getn(HealBot_Options_ExtraSort_List), 1 do
    local info = {};
    info.text = HealBot_Options_ExtraSort_List[i];
    info.func = HealBot_Options_ExtraSort_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end

-- HealBot_Options_ExtraSort_Initialize: UI handler for Initialize options panel.
function HealBot_Options_ExtraSort_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_ExtraSort,HealBot_Options_ExtraSort_DropDown)
end

-- HealBot_Options_ExtraSort_Refresh: UI handler for Refresh options panel.
function HealBot_Options_ExtraSort_Refresh(onselect)
  if not HealBot_Config.ExtraOrder then return end
  if not onselect then HealBot_Options_ExtraSort_Initialize() end  -- or wrong menu may be used !
  HealBot_UIDropDownMenu_SetSelectedID(HealBot_Options_ExtraSort,HealBot_Config.ExtraOrder)
end

-- HealBot_Options_ExtraSort_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_ExtraSort_OnLoad()
  UIDropDownMenu_Initialize(this, HealBot_Options_ExtraSort_DropDown)
  UIDropDownMenu_SetWidth(100, this)
end

-- HealBot_Options_ExtraSort_OnSelect: UI handler for OnSelect options panel.
function HealBot_Options_ExtraSort_OnSelect()
  HealBot_Config.ExtraOrder = this:GetID()
  HealBot_Options_ExtraSort_Refresh(true)
  HealBot_Action_PartyChanged()
end

--------------------------------------------------------------------------------

-- HealBot_Options_EmergencyFilter_DropDown: UI handler for DropDown options panel.
function HealBot_Options_EmergencyFilter_DropDown()
  for i=1, getn(HealBot_Options_EmergencyFilter_List), 1 do
    local info = {};
    info.text = HealBot_Options_EmergencyFilter_List[i];
    info.func = HealBot_Options_EmergencyFilter_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end


-- HealBot_Options_EmergencyFilter_Initialize: UI handler for Initialize options panel.
function HealBot_Options_EmergencyFilter_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_EmergencyFilter,HealBot_Options_EmergencyFilter_DropDown)
end


-- HealBot_Options_EmergencyFilter_Refresh: UI handler for Refresh options panel.
function HealBot_Options_EmergencyFilter_Refresh(onselect)
  if not HealBot_Config.EmergIncMonitor then return end
  if not onselect then HealBot_Options_EmergencyFilter_Initialize() end  -- or wrong menu may be used !
  HealBot_UIDropDownMenu_SetSelectedID(HealBot_Options_EmergencyFilter,HealBot_Config.EmergIncMonitor)
end


-- HealBot_Options_EmergencyFilter_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_EmergencyFilter_OnLoad()
  UIDropDownMenu_Initialize(this, HealBot_Options_EmergencyFilter_DropDown)
  UIDropDownMenu_SetWidth(100, this)
end


-- HealBot_Options_EmergencyFilter_OnSelect: UI handler for OnSelect options panel.
function HealBot_Options_EmergencyFilter_OnSelect()
  HealBot_Config.EmergIncMonitor = this:GetID()
  HealBot_Options_EmergencyFilter_Refresh(true)
  HealBot_Options_EmergencyFilter_Reset()
end

-- HealBot_Options_EmergencyFilter_Reset: UI handler for Reset options panel.
function HealBot_Options_EmergencyFilter_Reset()
  
  HealBot_EmergInc[HEALBOT_DRUID] = 0;
  HealBot_EmergInc[HEALBOT_HUNTER] = 0;
  HealBot_EmergInc[HEALBOT_MAGE] = 0;
  HealBot_EmergInc[HEALBOT_PALADIN] = 0;
  HealBot_EmergInc[HEALBOT_PRIEST] = 0;
  HealBot_EmergInc[HEALBOT_ROGUE] = 0;
  HealBot_EmergInc[HEALBOT_SHAMAN] = 0;
  HealBot_EmergInc[HEALBOT_WARLOCK] = 0;
  HealBot_EmergInc[HEALBOT_WARRIOR] = 0;
  if HealBot_Config.EmergIncMonitor==1 then
    HealBot_EmergInc[HEALBOT_DRUID] = 1;
    HealBot_EmergInc[HEALBOT_HUNTER] = 1;
    HealBot_EmergInc[HEALBOT_MAGE] = 1;
    HealBot_EmergInc[HEALBOT_PALADIN] = 1;
    HealBot_EmergInc[HEALBOT_PRIEST] = 1;
    HealBot_EmergInc[HEALBOT_ROGUE] = 1;
    HealBot_EmergInc[HEALBOT_SHAMAN] = 1;
    HealBot_EmergInc[HEALBOT_WARLOCK] = 1;
    HealBot_EmergInc[HEALBOT_WARRIOR] = 1;
  elseif HealBot_Config.EmergIncMonitor==2 then
    HealBot_EmergInc[HEALBOT_DRUID] = HealBot_Config.EmergIncMelee[HEALBOT_DRUID];
    HealBot_EmergInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncMelee[HEALBOT_HUNTER];
    HealBot_EmergInc[HEALBOT_MAGE] = HealBot_Config.EmergIncMelee[HEALBOT_MAGE];
    HealBot_EmergInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncMelee[HEALBOT_PALADIN];
    HealBot_EmergInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncMelee[HEALBOT_PRIEST];
    HealBot_EmergInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncMelee[HEALBOT_ROGUE];
    HealBot_EmergInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncMelee[HEALBOT_SHAMAN];
    HealBot_EmergInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncMelee[HEALBOT_WARLOCK];
    HealBot_EmergInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncMelee[HEALBOT_WARRIOR];
  elseif HealBot_Config.EmergIncMonitor==3 then
    HealBot_EmergInc[HEALBOT_DRUID] = HealBot_Config.EmergIncRange[HEALBOT_DRUID];
    HealBot_EmergInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncRange[HEALBOT_HUNTER];
    HealBot_EmergInc[HEALBOT_MAGE] = HealBot_Config.EmergIncRange[HEALBOT_MAGE];
    HealBot_EmergInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncRange[HEALBOT_PALADIN];
    HealBot_EmergInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncRange[HEALBOT_PRIEST];
    HealBot_EmergInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncRange[HEALBOT_ROGUE];
    HealBot_EmergInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncRange[HEALBOT_SHAMAN];
    HealBot_EmergInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncRange[HEALBOT_WARLOCK];
    HealBot_EmergInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncRange[HEALBOT_WARRIOR];
  elseif HealBot_Config.EmergIncMonitor==4 then
    HealBot_EmergInc[HEALBOT_DRUID] = HealBot_Config.EmergIncHealers[HEALBOT_DRUID];
    HealBot_EmergInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncHealers[HEALBOT_HUNTER];
    HealBot_EmergInc[HEALBOT_MAGE] = HealBot_Config.EmergIncHealers[HEALBOT_MAGE];
    HealBot_EmergInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncHealers[HEALBOT_PALADIN];
    HealBot_EmergInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncHealers[HEALBOT_PRIEST];
    HealBot_EmergInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncHealers[HEALBOT_ROGUE];
    HealBot_EmergInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncHealers[HEALBOT_SHAMAN];
    HealBot_EmergInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncHealers[HEALBOT_WARLOCK];
    HealBot_EmergInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncHealers[HEALBOT_WARRIOR];
  elseif HealBot_Config.EmergIncMonitor==5 then
    HealBot_EmergInc[HEALBOT_DRUID] = HealBot_Config.EmergIncCustom[HEALBOT_DRUID];
    HealBot_EmergInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncCustom[HEALBOT_HUNTER];
    HealBot_EmergInc[HEALBOT_MAGE] = HealBot_Config.EmergIncCustom[HEALBOT_MAGE];
    HealBot_EmergInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncCustom[HEALBOT_PALADIN];
    HealBot_EmergInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncCustom[HEALBOT_PRIEST];
    HealBot_EmergInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncCustom[HEALBOT_ROGUE];
    HealBot_EmergInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncCustom[HEALBOT_SHAMAN];
    HealBot_EmergInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncCustom[HEALBOT_WARLOCK];
    HealBot_EmergInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncCustom[HEALBOT_WARRIOR];
  end

  HealBot_Action_PartyChanged()
end

--------------------------------------------------------------------------------
-- Custom Tanks Management
--------------------------------------------------------------------------------

HealBot_CustomTanksLookup = HealBot_CustomTanksLookup or {}
HealBot_CustomTanksList = HealBot_CustomTanksList or {}
HealBot_CachedTankNames = HealBot_CachedTankNames or {}

function HealBot_Init_CustomTanksLookup()
  if not HealBot_Config then return end
  if not HealBot_Config.CustomTanks then
    HealBot_Config.CustomTanks = ""
  end
  HealBot_ParseCustomTanksString(HealBot_Config.CustomTanks)
end

function HealBot_ParseCustomTanksString(rawText)
  rawText = rawText or ""
  HealBot_Config.CustomTanks = rawText
  for k in pairs(HealBot_CustomTanksLookup) do
    HealBot_CustomTanksLookup[k] = nil
  end
  for k in pairs(HealBot_CustomTanksList) do
    HealBot_CustomTanksList[k] = nil
  end
  for name in string.gfind(rawText, "[^,%s]+") do
    local lower = string.lower(name)
    if not HealBot_CustomTanksLookup[lower] then
      HealBot_CustomTanksLookup[lower] = true
      table.insert(HealBot_CustomTanksList, name)
    end
  end
end

function HealBot_IsTank(name)
  if not name then return false end
  if (not HealBot_CustomTanksList or table.getn(HealBot_CustomTanksList) == 0) and HealBot_Config and HealBot_Config.CustomTanks and HealBot_Config.CustomTanks ~= "" then
    HealBot_ParseCustomTanksString(HealBot_Config.CustomTanks)
  end
  local lower = string.lower(name)
  if HealBot_CustomTanksLookup and HealBot_CustomTanksLookup[lower] then
    return true
  end
  if CT_RA_MainTanks then
    for j = 1, 10 do
      if CT_RA_MainTanks[j] and string.lower(CT_RA_MainTanks[j]) == lower then
        return true
      end
    end
  end
  return false
end

function HealBot_GetTankNames()
  if (not HealBot_CustomTanksList or table.getn(HealBot_CustomTanksList) == 0) and HealBot_Config and HealBot_Config.CustomTanks and HealBot_Config.CustomTanks ~= "" then
    HealBot_ParseCustomTanksString(HealBot_Config.CustomTanks)
  end
  for k in pairs(HealBot_CachedTankNames) do
    HealBot_CachedTankNames[k] = nil
  end
  local added = HealBot_GetTable()
  if HealBot_CustomTanksList then
    for i = 1, table.getn(HealBot_CustomTanksList) do
      local name = HealBot_CustomTanksList[i]
      if name then
        local lower = string.lower(name)
        if not added[lower] then
          table.insert(HealBot_CachedTankNames, name)
          added[lower] = true
        end
      end
    end
  end
  if CT_RA_MainTanks then
    for j = 1, 10 do
      local name = CT_RA_MainTanks[j]
      if name then
        local lower = string.lower(name)
        if not added[lower] then
          table.insert(HealBot_CachedTankNames, name)
          added[lower] = true
        end
      end
    end
  end
  HealBot_ReleaseTable(added)
  return HealBot_CachedTankNames
end

function HealBot_Options_OpenTanksDialog()
  if HealBot_Options_TanksEditBox then
    HealBot_Options_TanksEditBox:SetText(HealBot_Config.CustomTanks or "")
  end
  if HealBot_Options_TanksDialog then
    HealBot_Options_TanksDialog:Show()
  end
end

function HealBot_Options_ToggleTankNameFromFrame(unitName)
  if not unitName then return end
  local raw = ""
  if HealBot_Options_TanksEditBox and HealBot_Options_TanksDialog and HealBot_Options_TanksDialog:IsVisible() then
    raw = HealBot_Options_TanksEditBox:GetText() or ""
  else
    raw = HealBot_Config.CustomTanks or ""
  end
  local names = HealBot_GetTable()
  local found = false
  local lowerUnit = string.lower(unitName)
  for name in string.gfind(raw, "[^,%s]+") do
    if string.lower(name) == lowerUnit then
      found = true
    else
      table.insert(names, name)
    end
  end
  if not found then
    table.insert(names, unitName)
  end
  local newText = table.concat(names, ", ")
  HealBot_ReleaseTable(names)
  HealBot_ParseCustomTanksString(newText)
  if HealBot_Options_TanksEditBox then
    HealBot_Options_TanksEditBox:SetText(newText)
  end
  HealBot_RecalcParty()
  if DEFAULT_CHAT_FRAME then
    if found then
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Removed " .. unitName .. " from Tanks.", 1.0, 0.8, 0.2)
    else
      DEFAULT_CHAT_FRAME:AddMessage("HealBot: Added " .. unitName .. " to Tanks.", 0.2, 1.0, 0.2)
    end
  end
end

function HealBot_Options_TanksSave_OnClick()
  if HealBot_Options_TanksEditBox then
    local text = HealBot_Options_TanksEditBox:GetText() or ""
    HealBot_ParseCustomTanksString(text)
  end
  if HealBot_Options_TanksDialog then
    HealBot_Options_TanksDialog:Hide()
  end
  HealBot_RecalcParty()
end

function HealBot_Options_TanksClear_OnClick()
  HealBot_ParseCustomTanksString("")
  if HealBot_Options_TanksEditBox then
    HealBot_Options_TanksEditBox:SetText("")
  end
  if HealBot_Options_TanksDialog then
    HealBot_Options_TanksDialog:Hide()
  end
  HealBot_RecalcParty()
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("HealBot: Cleared all custom tanks.", 1.0, 0.8, 0.2)
  end
end

function HealBot_Options_TanksCancel_OnClick()
  if HealBot_Options_TanksDialog then
    HealBot_Options_TanksDialog:Hide()
  end
end

function HealBot_Options_TanksButton_OnClick(this)
  HealBot_Options_OpenTanksDialog()
end

function HealBot_Options_TanksButton_OnEnter(this)
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
  GameTooltip:SetText("Tanks", 1, 1, 1)
  local list = HealBot_Config.CustomTanks or ""
  GameTooltip:AddLine("Tanks: " .. (list ~= "" and list or "None"), 1, 0.82, 0)
  GameTooltip:AddLine("Click to configure tanks.", 0.7, 0.7, 0.7)
  GameTooltip:Show()
end

function HealBot_Options_TanksButton_OnLeave(this)
  GameTooltip:Hide()
end
