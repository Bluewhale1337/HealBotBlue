-- HealBot Options panel file: HealBot_Options_CDC.lua
-- Split from original HealBot_Options.lua

function HealBot_Options_ShowDebuffWarning_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ShowDebuffWarning_OnClick(this)
  HealBot_Config.ShowDebuffWarning = this:GetChecked() or 0;
end
function HealBot_Options_SoundDebuffWarning_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_SoundDebuffWarning_OnClick(this)
  HealBot_Config.SoundDebuffWarning = this:GetChecked() or 0;
  if HealBot_Config.SoundDebuffWarning==0 then
    HealBot_WarningSound1:Disable();
    HealBot_WarningSound2:Disable();
    HealBot_WarningSound3:Disable();
  else
    HealBot_WarningSound1:Enable();
    HealBot_WarningSound2:Enable();
    HealBot_WarningSound3:Enable();
  end
end
function HealBot_WarningSound_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_WarningSound_OnClick(this,id)
  if HealBot_Config.SoundDebuffPlay>0 then
    getglobal("HealBot_WarningSound"..HealBot_Config.SoundDebuffPlay):SetChecked(nil);
  end
  HealBot_Config.SoundDebuffPlay = id;
  if HealBot_Config.SoundDebuffPlay>0 then
    getglobal("HealBot_WarningSound"..HealBot_Config.SoundDebuffPlay):SetChecked(1);
    if this then
      HealBot_PlaySound(HealBot_Config.SoundDebuffPlay)
    end
  end
end
function HealBot_Options_CDCMonitor_DropDown()
  for i=1, getn(HealBot_Options_EmergencyFilter_List), 1 do
    local info = {};
    info.text = HealBot_Options_EmergencyFilter_List[i];
    info.func = HealBot_Options_CDCMonitor_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end
function HealBot_Options_CDCMonitor_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_CDCMonitor,HealBot_Options_CDCMonitor_DropDown)
end
function HealBot_Options_CDCMonitor_Refresh(onselect)
  if not HealBot_Config.CDCMonitor then return end
  if not onselect then HealBot_Options_CDCMonitor_Initialize() end  -- or wrong menu may be used !
  UIDropDownMenu_SetSelectedID(HealBot_Options_CDCMonitor,HealBot_Config.CDCMonitor)
end
function HealBot_Options_CDCMonitor_OnLoad(this)
  HealBot_Options_CDCMonitor_Initialize()
  UIDropDownMenu_SetWidth(100)
end
function HealBot_Options_CDCMonitor_OnSelect()
  HealBot_Config.CDCMonitor = this:GetID()
  HealBot_Options_CDCMonitor_Refresh(true)
  HealBot_Options_CDCMonitor_Reset()
end
function HealBot_Options_CDCMonitor_Reset()

  HealBot_CDCInc[HEALBOT_DRUID] = 0;
  HealBot_CDCInc[HEALBOT_HUNTER] = 0;
  HealBot_CDCInc[HEALBOT_MAGE] = 0;
  HealBot_CDCInc[HEALBOT_PALADIN] = 0;
  HealBot_CDCInc[HEALBOT_PRIEST] = 0;
  HealBot_CDCInc[HEALBOT_ROGUE] = 0;
  HealBot_CDCInc[HEALBOT_SHAMAN] = 0;
  HealBot_CDCInc[HEALBOT_WARLOCK] = 0;
  HealBot_CDCInc[HEALBOT_WARRIOR] = 0;
  if HealBot_Config.CDCMonitor==1 then
    HealBot_CDCInc[HEALBOT_DRUID] = 1;
    HealBot_CDCInc[HEALBOT_HUNTER] = 1;
    HealBot_CDCInc[HEALBOT_MAGE] = 1;
    HealBot_CDCInc[HEALBOT_PALADIN] = 1;
    HealBot_CDCInc[HEALBOT_PRIEST] = 1;
    HealBot_CDCInc[HEALBOT_ROGUE] = 1;
    HealBot_CDCInc[HEALBOT_SHAMAN] = 1;
    HealBot_CDCInc[HEALBOT_WARLOCK] = 1;
    HealBot_CDCInc[HEALBOT_WARRIOR] = 1;
  elseif HealBot_Config.CDCMonitor==2 then
    HealBot_CDCInc[HEALBOT_DRUID] = 1;
  elseif HealBot_Config.CDCMonitor==3 then
    HealBot_CDCInc[HEALBOT_HUNTER] = 1;
  elseif HealBot_Config.CDCMonitor==4 then
    HealBot_CDCInc[HEALBOT_MAGE] = 1;
  elseif HealBot_Config.CDCMonitor==5 then
    HealBot_CDCInc[HEALBOT_PALADIN] = 1;
  elseif HealBot_Config.CDCMonitor==6 then
    HealBot_CDCInc[HEALBOT_PRIEST] = 1;
  elseif HealBot_Config.CDCMonitor==7 then
    HealBot_CDCInc[HEALBOT_ROGUE] = 1;
  elseif HealBot_Config.CDCMonitor==8 then
    HealBot_CDCInc[HEALBOT_SHAMAN] = 1;
  elseif HealBot_Config.CDCMonitor==9 then
    HealBot_CDCInc[HEALBOT_WARLOCK] = 1;
  elseif HealBot_Config.CDCMonitor==10 then
    HealBot_CDCInc[HEALBOT_WARRIOR] = 1;
  elseif HealBot_Config.CDCMonitor==11 then
    HealBot_CDCInc[HEALBOT_DRUID] = HealBot_Config.EmergIncMelee[HEALBOT_DRUID];
    HealBot_CDCInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncMelee[HEALBOT_HUNTER];
    HealBot_CDCInc[HEALBOT_MAGE] = HealBot_Config.EmergIncMelee[HEALBOT_MAGE];
    HealBot_CDCInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncMelee[HEALBOT_PALADIN];
    HealBot_CDCInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncMelee[HEALBOT_PRIEST];
    HealBot_CDCInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncMelee[HEALBOT_ROGUE];
    HealBot_CDCInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncMelee[HEALBOT_SHAMAN];
    HealBot_CDCInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncMelee[HEALBOT_WARLOCK];
    HealBot_CDCInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncMelee[HEALBOT_WARRIOR];
  elseif HealBot_Config.CDCMonitor==12 then
    HealBot_CDCInc[HEALBOT_DRUID] = HealBot_Config.EmergIncRange[HEALBOT_DRUID];
    HealBot_CDCInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncRange[HEALBOT_HUNTER];
    HealBot_CDCInc[HEALBOT_MAGE] = HealBot_Config.EmergIncRange[HEALBOT_MAGE];
    HealBot_CDCInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncRange[HEALBOT_PALADIN];
    HealBot_CDCInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncRange[HEALBOT_PRIEST];
    HealBot_CDCInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncRange[HEALBOT_ROGUE];
    HealBot_CDCInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncRange[HEALBOT_SHAMAN];
    HealBot_CDCInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncRange[HEALBOT_WARLOCK];
    HealBot_CDCInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncRange[HEALBOT_WARRIOR];
  elseif HealBot_Config.CDCMonitor==13 then
    HealBot_CDCInc[HEALBOT_DRUID] = HealBot_Config.EmergIncHealers[HEALBOT_DRUID];
    HealBot_CDCInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncHealers[HEALBOT_HUNTER];
    HealBot_CDCInc[HEALBOT_MAGE] = HealBot_Config.EmergIncHealers[HEALBOT_MAGE];
    HealBot_CDCInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncHealers[HEALBOT_PALADIN];
    HealBot_CDCInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncHealers[HEALBOT_PRIEST];
    HealBot_CDCInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncHealers[HEALBOT_ROGUE];
    HealBot_CDCInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncHealers[HEALBOT_SHAMAN];
    HealBot_CDCInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncHealers[HEALBOT_WARLOCK];
    HealBot_CDCInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncHealers[HEALBOT_WARRIOR];
  elseif HealBot_Config.CDCMonitor==14 then
    HealBot_CDCInc[HEALBOT_DRUID] = HealBot_Config.EmergIncCustom[HEALBOT_DRUID];
    HealBot_CDCInc[HEALBOT_HUNTER] = HealBot_Config.EmergIncCustom[HEALBOT_HUNTER];
    HealBot_CDCInc[HEALBOT_MAGE] = HealBot_Config.EmergIncCustom[HEALBOT_MAGE];
    HealBot_CDCInc[HEALBOT_PALADIN] = HealBot_Config.EmergIncCustom[HEALBOT_PALADIN];
    HealBot_CDCInc[HEALBOT_PRIEST] = HealBot_Config.EmergIncCustom[HEALBOT_PRIEST];
    HealBot_CDCInc[HEALBOT_ROGUE] = HealBot_Config.EmergIncCustom[HEALBOT_ROGUE];
    HealBot_CDCInc[HEALBOT_SHAMAN] = HealBot_Config.EmergIncCustom[HEALBOT_SHAMAN];
    HealBot_CDCInc[HEALBOT_WARLOCK] = HealBot_Config.EmergIncCustom[HEALBOT_WARLOCK];
    HealBot_CDCInc[HEALBOT_WARRIOR] = HealBot_Config.EmergIncCustom[HEALBOT_WARRIOR];
  end

  HealBot_Action_PartyChanged()
end
function HealBot_Options_GetDebuffSpells_List(class)
  local DebuffSpells = HealBot_Debuff_Spells[class];
  return DebuffSpells;
end
function HealBot_Options_CDCButLeft_DropDown()
  local classEN=HealBot_UnitClass("player")
  if classEN=="PRIEST" or classEN=="DRUID" or classEN=="PALADIN" or classEN=="SHAMAN" then
    local class=UnitClass("Player");
    local DebuffSpells_List = HealBot_Options_GetDebuffSpells_List(class)
    local info = {};
    info.text = "None";
    info.func = HealBot_Options_CDCButLeft_OnSelect;
    UIDropDownMenu_AddButton(info);
    for i=1, getn(DebuffSpells_List), 1 do
      local spell=HealBot_GetSpellName(HealBot_GetSpellId(DebuffSpells_List[i]));
      if spell then
        local info = {};
        info.text = spell;
        info.func = HealBot_Options_CDCButLeft_OnSelect;
        UIDropDownMenu_AddButton(info);
      end
    end
  end
end
function HealBot_Options_CDCButRight_DropDown()
  local classEN=HealBot_UnitClass("player")
  if classEN=="PRIEST" or classEN=="DRUID" or classEN=="PALADIN" or classEN=="SHAMAN" then
    local class=UnitClass("Player");
    local DebuffSpells_List = HealBot_Options_GetDebuffSpells_List(class)
    local info = {};
    info.text = "None";
    info.func = HealBot_Options_CDCButRight_OnSelect;
    UIDropDownMenu_AddButton(info);
    for i=1, getn(DebuffSpells_List), 1 do
      local spell=HealBot_GetSpellName(HealBot_GetSpellId(DebuffSpells_List[i]));
      if spell then
        local info = {};
        info.text = spell;
        info.func = HealBot_Options_CDCButRight_OnSelect;
        UIDropDownMenu_AddButton(info);
      end
    end
  end
end
function HealBot_Options_CDCButLeft_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_CDCButLeft,HealBot_Options_CDCButLeft_DropDown)
end
function HealBot_Options_CDCButRight_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_CDCButRight,HealBot_Options_CDCButRight_DropDown)
end
function HealBot_Options_CDCButLeft_Refresh(onselect)
  local set_id=1;
  local class=UnitClass("Player");
  if not onselect then HealBot_Options_CDCButLeft_Initialize() end 
  set_id = HealBot_Config.Debuff_Left[class];
  UIDropDownMenu_SetSelectedID(HealBot_Options_CDCButLeft,set_id)
end
function HealBot_Options_CDCButRight_Refresh(onselect)
  local set_id;
  local class=UnitClass("Player");
  if not onselect then HealBot_Options_CDCButRight_Initialize() end 
  set_id = HealBot_Config.Debuff_Right[class];
  UIDropDownMenu_SetSelectedID(HealBot_Options_CDCButRight,set_id)
end
function HealBot_Options_CDCButLeft_OnLoad(this)
  HealBot_Options_CDCButLeft_Initialize()
  UIDropDownMenu_SetWidth(140)
end
function HealBot_Options_CDCButRight_OnLoad(this)
  HealBot_Options_CDCButRight_Initialize()
  UIDropDownMenu_SetWidth(140)
end
function HealBot_Options_CDCButLeft_OnSelect()
  local class=UnitClass("Player");
  HealBot_Config.Debuff_Left[class] = this:GetID();
  HealBot_Options_CDCButLeft_Refresh(true)
  HealBot_Config.CDCLeftText[class]=HealBot_Options_CDCButLeftText:GetText();
  if this:GetID()>1 then
    HealBot_Options_CDC_SetCombo(HealBot_Options_CDCButLeftText:GetText(), "Left", class)
  end    
  HealBot_DebuffPriority = HealBot_Debuff_Types[HealBot_Options_CDCButLeftText:GetText()];
  HealBot_Options_Debuff_Reset()
end
function HealBot_Options_CDCButRight_OnSelect()
  local class=UnitClass("Player");
  HealBot_Config.Debuff_Right[class] = this:GetID();
  HealBot_Options_CDCButRight_Refresh(true)
  HealBot_Config.CDCRightText[class]=HealBot_Options_CDCButRightText:GetText();
  if this:GetID()>1 then
    HealBot_Options_CDC_SetCombo(HealBot_Options_CDCButRightText:GetText(), "Right", class)
  end    
  HealBot_Options_Debuff_Reset()
end
function HealBot_Options_CDC_SetCombo(spell, button, class)
  local combo = HealBot_Config.KeyCombo[class]
  combo["Alt"..button] = spell
  HealBot_Options_KeyCombo_Change()
end
function HealBot_Options_Debuff_Reset()
  local classEN=HealBot_UnitClass("player")
  if classEN=="PRIEST" or classEN=="DRUID" or classEN=="PALADIN" or classEN=="SHAMAN" then
    local spell = HealBot_Config.CDCLeftText[UnitClass("player")];
    HealBot_DebuffWatch = {[HEALBOT_DISEASE_en]="NO", [HEALBOT_MAGIC_en]="NO", [HEALBOT_POISON_en]="NO", [HEALBOT_CURSE_en]="NO" }
    if spell ~= "None" then
      table.foreach(HealBot_Debuff_Types[spell], function (index,debuff)
        HealBot_DebuffWatch[debuff]="YES";
      end)
    end
    spell = HealBot_Config.CDCRightText[UnitClass("player")];
    if spell ~= "None" then
      table.foreach(HealBot_Debuff_Types[spell], function (index,debuff)
        HealBot_DebuffWatch[debuff]="YES";
      end)
    end
  end
end
function HealBot_Colorpick_OnClick(CDCType)
  HealBot_ColourObjWaiting=CDCType;
  HealBot_UseColourPick(HealBot_Config.CDCBarColour[CDCType].R,HealBot_Config.CDCBarColour[CDCType].G,HealBot_Config.CDCBarColour[CDCType].B, nil)
end
function HealBot_SetCDCBarColours()
  HealBot_DiseaseColorpick:SetStatusBarColor(HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].R,
                                             HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].G,
                                             HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].B,
                                             HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_MagicColorpick:SetStatusBarColor(HealBot_Config.CDCBarColour[HEALBOT_MAGIC_en].R,
                                           HealBot_Config.CDCBarColour[HEALBOT_MAGIC_en].G,
                                           HealBot_Config.CDCBarColour[HEALBOT_MAGIC_en].B,
                                           HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_PoisonColorpick:SetStatusBarColor(HealBot_Config.CDCBarColour[HEALBOT_POISON_en].R,
                                            HealBot_Config.CDCBarColour[HEALBOT_POISON_en].G,
                                            HealBot_Config.CDCBarColour[HEALBOT_POISON_en].B,
                                            HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_CurseColorpick:SetStatusBarColor(HealBot_Config.CDCBarColour[HEALBOT_CURSE_en].R,
                                           HealBot_Config.CDCBarColour[HEALBOT_CURSE_en].G,
                                           HealBot_Config.CDCBarColour[HEALBOT_CURSE_en].B,
                                           HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_DebTextColorpick:SetStatusBarColor(HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].R,
                                             HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].G,
                                             HealBot_Config.CDCBarColour[HEALBOT_DISEASE_en].B,
                                             HealBot_Config.Barcola[HealBot_Config.Current_Skin])
end
