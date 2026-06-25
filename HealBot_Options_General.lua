-- HealBot Options panel file: HealBot_Options_General.lua
-- Split from original HealBot_Options.lua

function HealBot_Options_ShowHeaders_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_SHOWHEADERS);
end
function HealBot_Options_ShowHeaders_OnClick(this)
  HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] = this:GetChecked();
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarTextureS_OnValueChanged(this)
  HealBot_Config.btexture[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarHeightS_OnValueChanged(this)
  HealBot_Config.bheight[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarWidthS_OnValueChanged(this)
  HealBot_Config.bwidth[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarNumColsS_OnValueChanged(this)
  HealBot_Config.numcols[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarBRSpaceS_OnValueChanged(this)
  HealBot_Config.brspace[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarBCSpaceS_OnValueChanged(this)
  HealBot_Config.bcspace[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_FontHeight_OnValueChanged(this)
  HealBot_Config.btextheight[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_AbortBarSize_OnValueChanged(this)
  HealBot_Config.abortsize[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_ActionAlpha_OnValueChanged(this)
  HealBot_Config.backcola[HealBot_Config.Current_Skin] = HealBot_Options_Pct_OnValueChanged(this);
end
function HealBot_Options_BarAlpha_OnValueChanged(this)
  HealBot_Config.Barcola[HealBot_Config.Current_Skin] = HealBot_Options_Pct_OnValueChanged(this);
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarAlphaInHeal_OnValueChanged(this)
  HealBot_Config.BarcolaInHeal[HealBot_Config.Current_Skin] = HealBot_Options_Pct_OnValueChanged(this);
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BarAlphaDis_OnValueChanged(this)
  HealBot_Config.bardisa[HealBot_Config.Current_Skin] = HealBot_Options_Pct_OnValueChanged(this);
  HealBot_Action_ResetSkin()
end
function HealBot_SkinColorpick_OnClick(SkinType)
  HealBot_ColourObjWaiting=SkinType;

  if SkinType=="En" then
    HealBot_UseColourPick(HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin],
                          HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin],
                          HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin],
                          HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin]);
  elseif SkinType=="Dis" then
    HealBot_UseColourPick(HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin],
                          HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin],
                          HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin],
                          HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin])
  elseif SkinType=="Debuff" then
    HealBot_UseColourPick(HealBot_Config.btextcursecolr[HealBot_Config.Current_Skin],
                          HealBot_Config.btextcursecolg[HealBot_Config.Current_Skin],
                          HealBot_Config.btextcursecolb[HealBot_Config.Current_Skin],
                          HealBot_Config.btextcursecola[HealBot_Config.Current_Skin])
  elseif SkinType=="Back" then
    HealBot_UseColourPick(HealBot_Config.backcolr[HealBot_Config.Current_Skin],
                          HealBot_Config.backcolg[HealBot_Config.Current_Skin],
                          HealBot_Config.backcolb[HealBot_Config.Current_Skin],
                          HealBot_Config.backcola[HealBot_Config.Current_Skin])
  elseif SkinType=="Bor" then
    HealBot_UseColourPick(HealBot_Config.borcolr[HealBot_Config.Current_Skin],
                          HealBot_Config.borcolg[HealBot_Config.Current_Skin],
                          HealBot_Config.borcolb[HealBot_Config.Current_Skin],
                          HealBot_Config.borcola[HealBot_Config.Current_Skin])
  elseif SkinType=="Abort" then
    HealBot_UseColourPick(HealBot_Config.babortcolr[HealBot_Config.Current_Skin],
                          HealBot_Config.babortcolg[HealBot_Config.Current_Skin],
                          HealBot_Config.babortcolb[HealBot_Config.Current_Skin],
                          HealBot_Config.babortcola[HealBot_Config.Current_Skin])
  end
end
function HealBot_SetSkinColours()
  local btextheight=HealBot_Config.btextheight[HealBot_Config.Current_Skin] or 10;
  
  HealBot_EnTextColorpick:SetStatusBarColor(0,1,0,HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
  HealBot_EnTextColorpickin:SetStatusBarColor(0,1,0,HealBot_Config.Barcola[HealBot_Config.Current_Skin]*HealBot_Config.BarcolaInHeal[HealBot_Config.Current_Skin]);
  HealBot_DisTextColorpick:SetStatusBarColor(0,1,0,HealBot_Config.bardisa[HealBot_Config.Current_Skin]);
  HealBot_EnTextColorpickt:SetTextColor(
    HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin],
    HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin]);
  HealBot_DisTextColorpickt:SetTextColor(
    HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin],
    HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin]);
  HealBot_DebTextColorpickt:SetTextColor(
    HealBot_Config.btextcursecolr[HealBot_Config.Current_Skin],
    HealBot_Config.btextcursecolg[HealBot_Config.Current_Skin],
    HealBot_Config.btextcursecolb[HealBot_Config.Current_Skin],
    HealBot_Config.btextcursecola[HealBot_Config.Current_Skin]);
  HealBot_BackgroundColorpick:SetStatusBarColor(
    HealBot_Config.backcolr[HealBot_Config.Current_Skin],
    HealBot_Config.backcolg[HealBot_Config.Current_Skin],
    HealBot_Config.backcolb[HealBot_Config.Current_Skin],
    HealBot_Config.backcola[HealBot_Config.Current_Skin]);
  HealBot_BorderColorpick:SetStatusBarColor(
    HealBot_Config.borcolr[HealBot_Config.Current_Skin],
    HealBot_Config.borcolg[HealBot_Config.Current_Skin],
    HealBot_Config.borcolb[HealBot_Config.Current_Skin],
    HealBot_Config.borcola[HealBot_Config.Current_Skin]);
  HealBot_AbortColorpick:SetStatusBarColor(
    HealBot_Config.babortcolr[HealBot_Config.Current_Skin],
    HealBot_Config.babortcolg[HealBot_Config.Current_Skin],
    HealBot_Config.babortcolb[HealBot_Config.Current_Skin],
    HealBot_Config.babortcola[HealBot_Config.Current_Skin]);

    local borderStyle = HealBot_Config.bborder[HealBot_Config.Current_Skin] or 2
  if borderStyle == 0 then
    HealBot_Action:SetBackdropBorderColor(0,0,0,0);
  elseif borderStyle == 1 then
    local bboffset = (HealBot_Config.bboffset and HealBot_Config.bboffset[HealBot_Config.Current_Skin]) or 1
    local bpadding = (HealBot_Config.bpadding and HealBot_Config.bpadding[HealBot_Config.Current_Skin]) or 10
    HealBot_Action:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      tile = true, tileSize = 8, edgeSize = bboffset,
      insets = { left = bpadding, right = bpadding, top = bpadding, bottom = bpadding }
    })
    HealBot_Action:SetBackdropColor(
      HealBot_Config.backcolr[HealBot_Config.Current_Skin],
      HealBot_Config.backcolg[HealBot_Config.Current_Skin],
      HealBot_Config.backcolb[HealBot_Config.Current_Skin],
      HealBot_Config.backcola[HealBot_Config.Current_Skin]);
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
    HealBot_Action:SetBackdropColor(
      HealBot_Config.backcolr[HealBot_Config.Current_Skin],
      HealBot_Config.backcolg[HealBot_Config.Current_Skin],
      HealBot_Config.backcolb[HealBot_Config.Current_Skin],
      HealBot_Config.backcola[HealBot_Config.Current_Skin]);
    HealBot_Action:SetBackdropBorderColor(
      HealBot_Config.borcolr[HealBot_Config.Current_Skin],
      HealBot_Config.borcolg[HealBot_Config.Current_Skin],
      HealBot_Config.borcolb[HealBot_Config.Current_Skin],
      HealBot_Config.borcola[HealBot_Config.Current_Skin]);
  end

    HealBot_EnTextColorpickt:SetTextHeight(btextheight);
    HealBot_DisTextColorpickt:SetTextHeight(btextheight);
    HealBot_DebTextColorpickt:SetTextHeight(btextheight);
    HealBot_EnTextColorpickt:SetText(HEALBOT_SKIN_ENTEXT);
    HealBot_DisTextColorpickt:SetText(HEALBOT_SKIN_DISTEXT);
    HealBot_DebTextColorpickt:SetText(HEALBOT_SKIN_DEBTEXT);
    local barScale = HealBot_EnTextColorpick:GetScale();
    HealBot_EnTextColorpick:SetScale(barScale + 0.01);
    HealBot_EnTextColorpick:SetScale(barScale);
    HealBot_DisTextColorpick:SetScale(barScale + 0.01);
    HealBot_DisTextColorpick:SetScale(barScale);
    HealBot_DebTextColorpick:SetScale(barScale + 0.01);
    HealBot_DebTextColorpick:SetScale(barScale);
   
  HealBot_Action_PartyChanged()
end
function HealBot_Options_AlertLevel_OnValueChanged(this)
  HealBot_Config.AlertLevel = HealBot_Options_Pct_OnValueChanged(this);
  HealBot_Action_Refresh();
end
function HealBot_Options_AutoShow_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_AUTOSHOW);
end
function HealBot_Options_AutoShow_OnClick(this)
  HealBot_Config.AutoClose = this:GetChecked() or 0;
  HealBot_Action_Refresh();
end
function HealBot_Options_PanelSounds_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_PANELSOUNDS);
end
function HealBot_Options_PanelSounds_OnClick(this)
  HealBot_Config.PanelSounds = this:GetChecked() or 0;
end
function HealBot_Options_ActionMouseover_OnLoad(this, text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ActionMouseover_OnClick(this)
  HealBot_Config.ActionMouseover = this:GetChecked() or 0;
end
function HealBot_Options_ActionLocked_OnLoad(this)
  getglobal(this:GetName().."Text"):SetText(HEALBOT_OPTIONS_ACTIONLOCKED);
end
function HealBot_Options_ActionLocked_OnClick(this)
  HealBot_Config.ActionLocked = this:GetChecked() or 0;
end
function HealBot_Options_HideOptions_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_HideOptions_OnClick(this)
  HealBot_Config.HideOptions = this:GetChecked() or 0;
  HealBot_Action_PartyChanged();
end
function HealBot_Options_HideAbort_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_HideAbort_OnClick(this)
  HealBot_Config.HideAbort = this:GetChecked() or 0;
  HealBot_Action_PartyChanged();
end
function HealBot_Options_GrowUpwards_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_GrowUpwards_OnClick(this)
  HealBot_Config.GrowUpwards = this:GetChecked() or 0;
  HealBot_Action_PartyChanged();
end
function HealBot_Options_QualityRange_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_QualityRange_OnClick(this)
  HealBot_Config.QualityRange = this:GetChecked() or 0;
  HealBot_Action_PartyChanged();
end
function HealBot_Options_ProtectPvP_OnLoad(this,text)
  getglobal(this:GetName().."Text"):SetText(text);
end
function HealBot_Options_ProtectPvP_OnClick(this)
  HealBot_Config.ProtectPvP = this:GetChecked() or 0;
  HealBot_Action_Refresh();
end
function HealBot_Options_FramePaddingS_OnValueChanged(this)
  if not HealBot_Config.bpadding then HealBot_Config.bpadding = {} end
  HealBot_Config.bpadding[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
function HealBot_Options_BorderThicknessS_OnValueChanged(this)
  if not HealBot_Config.bboffset then HealBot_Config.bboffset = {} end
  HealBot_Config.bboffset[HealBot_Config.Current_Skin] = this:GetValue();
  getglobal(this:GetName().."Text"):SetText(this.text .. ": " .. this:GetValue());
  HealBot_Action_ResetSkin()
end
