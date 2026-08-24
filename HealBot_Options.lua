-- HealBot Options panel file: HealBot_Options.lua
-- Split from original HealBot_Options.lua

HealBot_Options_ComboButtons_Button=1;
HealBot_Options_CurrentPanel = 0;

HealBot_ColourObjWaiting = nil

HealBot_Options_EmergencyFilter_List = {
    HEALBOT_OPTIONS_MONITORALL,
    HEALBOT_OPTIONS_MONITORMELEE,
    HEALBOT_OPTIONS_MONITORRANGE,
    HEALBOT_OPTIONS_MONITORHEALERS,
    HEALBOT_OPTIONS_MONITORCUSTOM,
}

-- HealBot_Options_AddDebug: UI handler for AddDebug options panel.
function HealBot_Options_AddDebug(msg)
  HealBot_AddDebug("Options: " .. msg);
end

-- HealBot_Options_Pct_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_Pct_OnLoad(this,text)
  this.text = text;
  getglobal(this:GetName().."Text"):SetText(text);
  getglobal(this:GetName().."Low"):SetText("0%");
  getglobal(this:GetName().."High"):SetText("100%");
  this:SetMinMaxValues(0.00,1.00);
  this:SetValueStep(0.01);
end

-- HealBot_Options_Pct_OnLoad_MinMax: UI handler for MinMax options panel.
function HealBot_Options_Pct_OnLoad_MinMax(this,text,Min,Max)
  this.text = text;
  local MinTxt,MaxTxt

  MinTxt=(Min*100).."%";
  MaxTxt=(Max*100).."%";

  getglobal(this:GetName().."Text"):SetText(text);
  getglobal(this:GetName().."Low"):SetText(MinTxt);
  getglobal(this:GetName().."High"):SetText(MaxTxt);
  this:SetMinMaxValues(Min,Max);
  this:SetValueStep(0.01);
end

-- HealBot_Options_val_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_val_OnLoad(this,text,Min,Max)
  this.text = text;

  getglobal(this:GetName().."Text"):SetText(text);
  getglobal(this:GetName().."Low"):SetText(Min);
  getglobal(this:GetName().."High"):SetText(Max);
  this:SetMinMaxValues(Min,Max);
  this:SetValueStep(1);
end

-- HealBot_Options_Pct_OnValueChanged: UI handler for OnValueChanged options panel.
function HealBot_Options_Pct_OnValueChanged(this)
  local pct = math.floor(this:GetValue()*100+0.5);
  getglobal(this:GetName().."Text"):SetText(this.text .. " (" .. pct .. "%)");
  return this:GetValue();
end






    











































-- HealBot_Options_CastNotify_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_CastNotify_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end

-- HealBot_Options_CastNotify_OnClick: UI handler for OnClick options panel.
function HealBot_Options_CastNotify_OnClick(this,id)
  -- CastNotify UI elements were removed and replaced by Custom Chat Messages
end





























--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

-- HealBot_Returned_Colours: Internal utility: HealBot_Returned_Colours
function HealBot_Returned_Colours()
  local A = OpacitySliderFrame:GetValue();
  A = ((0-A)+1);
  if HealBot_ColourObjWaiting=="En" then
    HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin] = A;
  elseif HealBot_ColourObjWaiting=="Dis" then
    HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin] = A;
  elseif HealBot_ColourObjWaiting=="Debuff" then
    HealBot_Config.btextcursecolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextcursecolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextcursecolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.btextcursecola[HealBot_Config.Current_Skin] = A;
  elseif HealBot_ColourObjWaiting=="Back" then
    HealBot_Config.backcolr[HealBot_Config.Current_Skin],
    HealBot_Config.backcolg[HealBot_Config.Current_Skin],
    HealBot_Config.backcolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.backcola[HealBot_Config.Current_Skin] = A;
  elseif HealBot_ColourObjWaiting=="Bor" then
    HealBot_Config.borcolr[HealBot_Config.Current_Skin],
    HealBot_Config.borcolg[HealBot_Config.Current_Skin],
    HealBot_Config.borcolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.borcola[HealBot_Config.Current_Skin] = A;
  elseif HealBot_ColourObjWaiting=="Abort" then
    HealBot_Config.babortcolr[HealBot_Config.Current_Skin],
    HealBot_Config.babortcolg[HealBot_Config.Current_Skin],
    HealBot_Config.babortcolb[HealBot_Config.Current_Skin] = ColorPickerFrame:GetColorRGB();
    HealBot_Config.babortcola[HealBot_Config.Current_Skin] = A;
  else
    HealBot_Config.CDCBarColour[HealBot_ColourObjWaiting].R,
    HealBot_Config.CDCBarColour[HealBot_ColourObjWaiting].G,
    HealBot_Config.CDCBarColour[HealBot_ColourObjWaiting].B = ColorPickerFrame:GetColorRGB();
  end
  HealBot_SetSkinColours()
  HealBot_SetCDCBarColours()
end
-- HealBot_UseColourPick: Internal utility: HealBot_UseColourPick
function HealBot_UseColourPick(R, G, B, A)
  if ColorPickerFrame:IsVisible() then 
    ColorPickerFrame:Hide();
  elseif A then
    ColorPickerFrame.hasOpacity = true;
    ColorPickerFrame.opacity = A;
    ColorPickerFrame:ClearAllPoints();
    ColorPickerFrame:SetPoint("TOPLEFT","HealBot_Options","TOPRIGHT",0,-152);
    ColorPickerFrame:Show();
    OpacitySliderFrame:SetValue(1-A);
    ColorPickerFrame:SetColorRGB(R, G, B);
  else
    ColorPickerFrame.hasOpacity = false;
    ColorPickerFrame:ClearAllPoints();
    ColorPickerFrame:SetPoint("TOPLEFT","HealBot_Options","TOPRIGHT",0,-152);
    ColorPickerFrame:Show();
    ColorPickerFrame:SetColorRGB(R, G, B);
  end
  return ColorPickerFrame:GetColorRGB();
end
-- HealBot_Options_Defaults_OnClick: UI handler for OnClick options panel.
function HealBot_Options_Defaults_OnClick(this)
  HealBot_Options_CastNotify_OnClick(nil,0);
--  HealBot_Config = HealBot_ConfigDefaults;
  table.foreach(HealBot_ConfigDefaults, function (key,val)
    HealBot_Config[key] = val;
  end);
  HealBot_Options_OnShow(HealBot_Options);
  HealBot_RecalcSpells();
  HealBot_Action_Reset();
  HealBot_Config.ActionVisible = HealBot_Action:IsVisible();
end
-- HealBot_Options_OnLoad: UI handler for OnLoad options panel.
function HealBot_Options_OnLoad(this)
  table.insert(UISpecialFrames,this:GetName());

  -- Tabs
  PanelTemplates_SetNumTabs(this,9);
  this.selectedTab = 1; 
  PanelTemplates_UpdateTabs(this);
  HealBot_Options_ShowPanel(this.selectedTab);
end
-- HealBot_Options_OnShow: UI handler for OnShow options panel.
function HealBot_Options_OnShow(this)
  HealBot_Skins = HealBot_Config.Skins;
  HealBot_Options_SetSkins()
  HealBot_Options_ActionLocked:SetChecked(HealBot_Config.ActionLocked);
  HealBot_Options_AlertLevel:SetValue(HealBot_Config.AlertLevel);
  HealBot_Options_AutoShow:SetChecked(HealBot_Config.AutoClose);
  HealBot_Options_PanelSounds:SetChecked(HealBot_Config.PanelSounds);
  HealBot_Options_ShowManaBars:SetChecked(HealBot_Config.ShowManaBars);
  HealBot_Options_ManaBarsHealersOnly:SetChecked(HealBot_Config.ManaBarsHealersOnly);
  if HealBot_Config.ShowNonManaBars == nil then HealBot_Config.ShowNonManaBars = 0; end
  HealBot_Options_ShowNonManaBars:SetChecked(HealBot_Config.ShowNonManaBars);
  
  if HealBot_Config.ActionMouseover == nil then HealBot_Config.ActionMouseover = 1; end
  HealBot_Options_ActionMouseover:SetChecked(HealBot_Config.ActionMouseover);
  HealBot_Options_GroupHeals:SetChecked(HealBot_Config.GroupHeals);
  if CT_RA_MainTanks then
    HealBot_Options_TankHeals:SetChecked(HealBot_Config.TankHeals);
  else
    HealBot_Options_TankHeals:Disable();
    HealBot_Options_TankHealsText:SetTextColor(0.6,0.6,0.6,0.75);
  end
  HealBot_Options_TargetHeals:SetChecked(HealBot_Config.TargetHeals);
  HealBot_Options_EmergencyHeals:SetChecked(HealBot_Config.EmergencyHeals);
  HealBot_Options_OverHeal:SetValue(HealBot_Config.OverHeal);
  if HealBot_Config.ShowHealthText == nil then HealBot_Config.ShowHealthText = 0; end
  HealBot_UIDropDownMenu_SetSelectedID(HealBot_Options_HealthText, HealBot_Config.ShowHealthText + 1);
  UIDropDownMenu_SetText(HealBot_Options_HealthText_List[HealBot_Config.ShowHealthText + 1], HealBot_Options_HealthText);
  HealBot_Options_CastNotify_OnClick(nil,HealBot_Config.CastNotify);
  HealBot_Options_SetBuffs();
  HealBot_Options_HideOptions:SetChecked(HealBot_Config.HideOptions);
  HealBot_Options_ShowTooltip:SetChecked(HealBot_Config.ShowTooltip);
  HealBot_Options_GrowUpwards:SetChecked(HealBot_Config.GrowUpwards);
  HealBot_Options_QualityRange:SetChecked(HealBot_Config.QualityRange);
  HealBot_Options_ProtectPvP:SetChecked(HealBot_Config.ProtectPvP);
  HealBot_Options_SoundDebuffWarning:SetChecked(HealBot_Config.SoundDebuffWarning);
  HealBot_Options_ShowTooltipTarget:SetChecked(HealBot_Config.Tooltip_ShowTarget);
  HealBot_Options_ShowTooltipSpellDetail:SetChecked(HealBot_Config.Tooltip_ShowSpellDetail);
  HealBot_Options_ShowTooltipInstant:SetChecked(HealBot_Config.Tooltip_Recommend);
  HealBot_Options_HideAbort:SetChecked(HealBot_Config.HideAbort);
  HealBot_Options_HideParty:SetChecked(HealBot_Config.HideParty);
  HealBot_Options_HideSolo:SetChecked(HealBot_Config.HideSolo);
  HealBot_WarningSound_OnClick(nil,HealBot_Config.SoundDebuffPlay)
  if HealBot_Config.SoundDebuffWarning>0 then
    HealBot_WarningSound1:Enable();
    HealBot_WarningSound2:Enable();
    HealBot_WarningSound3:Enable();
  else
    HealBot_WarningSound1:Disable();
    HealBot_WarningSound2:Disable();
    HealBot_WarningSound3:Disable();
  end
  HealBot_Options_ShowDebuffWarning:SetChecked(HealBot_Config.ShowDebuffWarning);
  HealBot_Options_EmergencyFilter_Refresh()
  HealBot_Options_EmergencyFClass_Refresh();
  HealBot_Options_EFClass_Reset();
  HealBot_Options_CDCButLeft_Refresh()
  HealBot_Options_CDCButRight_Refresh()
  HealBot_SetCDCBarColours()
  HealBot_Options_CDCMonitor_Refresh()
  HealBot_ComboButtons_Button_OnClick(nil,HealBot_Options_ComboButtons_Button);
  HealBot_Options_EnableHealthy:SetChecked(HealBot_Config.EnableHealthy);
  HealBot_Options_NewSkinb:Disable();
  HealBot_Options_ExtraSort_Refresh();
  HealBot_Options_TooltipPos_Refresh();
  HealBot_Options_SetChatMessages();
  HealBot_Options_ShowPanel(this.selectedTab or 1);
end
-- HealBot_Options_SetSkins: UI handler for SetSkins options panel.
function HealBot_Options_SetSkins()
  HealBot_Options_Skins_Refresh()
  HealBot_Options_BarAlpha:SetValue(HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_Options_BarAlphaInHeal:SetValue(HealBot_Config.BarcolaInHeal[HealBot_Config.Current_Skin]);
  HealBot_Options_BarTextureS:SetValue(HealBot_Config.btexture[HealBot_Config.Current_Skin])
  HealBot_Options_BarHeightS:SetValue(HealBot_Config.bheight[HealBot_Config.Current_Skin])
  HealBot_Options_AbortBarSize:SetValue(HealBot_Config.abortsize[HealBot_Config.Current_Skin])
  HealBot_Options_FontHeight:SetValue(HealBot_Config.btextheight[HealBot_Config.Current_Skin])
  HealBot_Options_IconSizeS:SetValue(HealBot_Config.biconsize[HealBot_Config.Current_Skin] or 12)
  HealBot_Options_BarWidthS:SetValue(HealBot_Config.bwidth[HealBot_Config.Current_Skin])
  HealBot_Options_BarNumColsS:SetValue(HealBot_Config.numcols[HealBot_Config.Current_Skin])
  HealBot_Options_BarMaxRowsS:SetValue((HealBot_Config.bmaxrows and HealBot_Config.bmaxrows[HealBot_Config.Current_Skin]) or 0)
  HealBot_Options_GridOrientation:SetChecked(((HealBot_Config.GridOrientation and HealBot_Config.GridOrientation[HealBot_Config.Current_Skin]) == 2) and 1 or nil)
  HealBot_Options_BarBRSpaceS:SetValue(HealBot_Config.brspace[HealBot_Config.Current_Skin])
  HealBot_Options_BarBCSpaceS:SetValue(HealBot_Config.bcspace[HealBot_Config.Current_Skin])
  HealBot_Options_FramePaddingS:SetValue((HealBot_Config.bpadding and HealBot_Config.bpadding[HealBot_Config.Current_Skin]) or 10)
  HealBot_Options_BorderThicknessS:SetValue((HealBot_Config.bboffset and HealBot_Config.bboffset[HealBot_Config.Current_Skin]) or 1)
  HealBot_Options_FontHeight:SetValue(HealBot_Config.btextheight[HealBot_Config.Current_Skin])
  HealBot_Options_BarAlphaDis:SetValue(HealBot_Config.bardisa[HealBot_Config.Current_Skin])
  HealBot_Options_AbortBarSize:SetValue(HealBot_Config.abortsize[HealBot_Config.Current_Skin])
  local isShowHeaders = (HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1)
  HealBot_Options_ShowHeaders:SetChecked(isShowHeaders and 1 or nil)
  
  local isColorMode = (HealBot_Config.bcolormode[HealBot_Config.Current_Skin] == 2)
  HealBot_Options_BarColorMode:SetChecked(isColorMode and 1 or nil)
  
  local isFontOutline = (HealBot_Config.bfontoutline[HealBot_Config.Current_Skin] == 1)
  HealBot_Options_FontOutline:SetChecked(isFontOutline and 1 or nil)
  
  local is1pxBorder = (HealBot_Config.bborder[HealBot_Config.Current_Skin] == 1)
  HealBot_Options_1pxBorders:SetChecked(is1pxBorder and 1 or nil)

  HealBot_SetSkinColours()
  if HealBot_Config.Current_Skin==HEALBOT_SKINS_STD then
    HealBot_Options_DeleteSkin:Disable();
  else
    HealBot_Options_DeleteSkin:Enable();
  end
end
-- HealBot_Options_ShowPanel: UI handler for ShowPanel options panel.
function HealBot_Options_ShowPanel(id)
  if HealBot_Options_CurrentPanel>0 then
    local panel = getglobal("HealBot_Options_Panel"..HealBot_Options_CurrentPanel);
    if panel then
      panel:Hide();
    end
  end
  HealBot_Options_CurrentPanel = id;
  if HealBot_Options_CurrentPanel>0 then
    local panel = getglobal("HealBot_Options_Panel"..HealBot_Options_CurrentPanel);
    if panel then
      panel:Show();
    end
  end
end
