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
  HealBot_Action_ResetSkin()
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
  -- Cache the current skin configuration for performance and readability
  local skin = HealBot_Config.Current_Skin
  local btextheight = HealBot_Config.btextheight[skin] or 10
  
  -- 1. Set Status Bar Colors (Green with variations based on configuration)
  local alpha = HealBot_Config.Barcola[skin]
  local inHealAlpha = alpha * (HealBot_Config.BarcolaInHeal[skin] or 1)
  local disabledAlpha = HealBot_Config.bardisa[skin]

  HealBot_EnTextColorpick:SetStatusBarColor(0, 1, 0, alpha)
  HealBot_EnTextColorpickin:SetStatusBarColor(0, 1, 0, inHealAlpha)
  HealBot_DisTextColorpick:SetStatusBarColor(0, 1, 0, disabledAlpha)

  -- 2. Set Text Colors
  HealBot_EnTextColorpickt:SetTextColor(
    HealBot_Config.btextenabledcolr[skin], HealBot_Config.btextenabledcolg[skin], 
    HealBot_Config.btextenabledcolb[skin], HealBot_Config.btextenabledcola[skin]
  )
  HealBot_DisTextColorpickt:SetTextColor(
    HealBot_Config.btextdisbledcolr[skin], HealBot_Config.btextdisbledcolg[skin], 
    HealBot_Config.btextdisbledcolb[skin], HealBot_Config.btextdisbledcola[skin]
  )
  HealBot_DebTextColorpickt:SetTextColor(
    HealBot_Config.btextcursecolr[skin], HealBot_Config.btextcursecolg[skin], 
    HealBot_Config.btextcursecolb[skin], HealBot_Config.btextcursecola[skin]
  )

  -- 3. Set Preview Component Colors
  local bgR, bgG, bgB, bgA = HealBot_Config.backcolr[skin], HealBot_Config.backcolg[skin], HealBot_Config.backcolb[skin], HealBot_Config.backcola[skin]
  local borderR, borderG, borderB, borderA = HealBot_Config.borcolr[skin], HealBot_Config.borcolg[skin], HealBot_Config.borcolb[skin], HealBot_Config.borcola[skin]

  HealBot_BackgroundColorpick:SetStatusBarColor(bgR, bgG, bgB, bgA)
  HealBot_BorderColorpick:SetStatusBarColor(borderR, borderG, borderB, borderA)
  HealBot_AbortColorpick:SetStatusBarColor(
    HealBot_Config.babortcolr[skin], HealBot_Config.babortcolg[skin], 
    HealBot_Config.babortcolb[skin], HealBot_Config.babortcola[skin]
  )

  -- 4. Setup Main Panel Backdrop (Fixed scoping bugs)
  local borderStyle = HealBot_Config.bborder[skin] or 2
  local backdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true, 
    tileSize = 8,
  }

  if borderStyle == 0 then
    -- No border
    backdrop.edgeFile = "Interface\\Buttons\\WHITE8X8"
    backdrop.edgeSize = 1
    backdrop.insets = { left = 1, right = 1, top = 1, bottom = 1 }
    HealBot_Action:SetBackdrop(backdrop)
    HealBot_Action:SetBackdropBorderColor(0, 0, 0, 0)
    HealBot_Action:SetBackdropColor(bgR, bgG, bgB, bgA)

  elseif borderStyle == 1 then
    -- Custom flat border
    local bboffset = (HealBot_Config.bboffset and HealBot_Config.bboffset[skin]) or 1
    local bpadding = (HealBot_Config.bpadding and HealBot_Config.bpadding[skin]) or 10
    
    backdrop.edgeFile = "Interface\\Buttons\\WHITE8X8"
    backdrop.edgeSize = bboffset
    backdrop.insets = { left = bpadding, right = bpadding, top = bpadding, bottom = bpadding }
    
    HealBot_Action:SetBackdrop(backdrop)
    HealBot_Action:SetBackdropColor(bgR, bgG, bgB, bgA)
    HealBot_Action:SetBackdropBorderColor(borderR, borderG, borderB, borderA)

  else
    -- Default Blizzard Tooltip Border
    backdrop.edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"
    backdrop.edgeSize = 16
    backdrop.insets = { left = 4, right = 4, top = 4, bottom = 4 }
    
    HealBot_Action:SetBackdrop(backdrop)
    HealBot_Action:SetBackdropColor(bgR, bgG, bgB, bgA)
    HealBot_Action:SetBackdropBorderColor(borderR, borderG, borderB, borderA)
  end

  -- 5. Update Text Labels
  HealBot_EnTextColorpickt:SetTextHeight(btextheight)
  HealBot_DisTextColorpickt:SetTextHeight(btextheight)
  HealBot_DebTextColorpickt:SetTextHeight(btextheight)
  
  HealBot_EnTextColorpickt:SetText(HEALBOT_SKIN_ENTEXT)
  HealBot_DisTextColorpickt:SetText(HEALBOT_SKIN_DISTEXT)
  HealBot_DebTextColorpickt:SetText(HEALBOT_SKIN_DEBTEXT)

  -- 6. Force UI redraw (Kept the scale hack since it addresses a specific engine quirk)
  local barScale = HealBot_EnTextColorpick:GetScale()
  HealBot_EnTextColorpick:SetScale(barScale + 0.01); HealBot_EnTextColorpick:SetScale(barScale)
  HealBot_DisTextColorpick:SetScale(barScale + 0.01); HealBot_DisTextColorpick:SetScale(barScale)
  HealBot_DebTextColorpick:SetScale(barScale + 0.01); HealBot_DebTextColorpick:SetScale(barScale)
     
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

function HealBot_Options_HideParty_OnLoad(this, text)
  getglobal(this:GetName().."Text"):SetText(text);
end

function HealBot_Options_HideParty_OnClick(this)
  HealBot_Config.HideParty = this:GetChecked() or 0;
  HealBot_Options_TogglePartyFrames();
end

function HealBot_Options_TogglePartyFrames()
  if HealBot_Config.HideParty == 1 then
    if HidePartyFrame then HidePartyFrame(); end
  else
    if ShowPartyFrame then ShowPartyFrame(); end
  end
end
