-- HealBot Options panel file: HealBot_Options_Skins.lua
-- Split from original HealBot_Options.lua

function HealBot_Options_NewSkin_OnTextChanged(this)
  local text= this:GetText()
  if string.len(text)>0 then
    HealBot_Options_NewSkinb:Enable();
  else
    HealBot_Options_NewSkinb:Disable();
  end
end
function HealBot_Options_NewSkinb_OnClick(this)
  HealBot_Config.numcols[HealBot_Options_NewSkin:GetText()] = HealBot_Config.numcols[HealBot_Config.Current_Skin]
  HealBot_Config.btexture[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btexture[HealBot_Config.Current_Skin]
  HealBot_Config.bcspace[HealBot_Options_NewSkin:GetText()] = HealBot_Config.bcspace[HealBot_Config.Current_Skin]
  HealBot_Config.brspace[HealBot_Options_NewSkin:GetText()] = HealBot_Config.brspace[HealBot_Config.Current_Skin]
  HealBot_Config.bwidth[HealBot_Options_NewSkin:GetText()] = HealBot_Config.bwidth[HealBot_Config.Current_Skin]
  HealBot_Config.bheight[HealBot_Options_NewSkin:GetText()] = HealBot_Config.bheight[HealBot_Config.Current_Skin]
  HealBot_Config.btextenabledcolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin]
  HealBot_Config.btextenabledcolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin]
  HealBot_Config.btextenabledcolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin]
  HealBot_Config.btextenabledcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin]
  HealBot_Config.btextdisbledcolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin]
  HealBot_Config.btextdisbledcolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin]
  HealBot_Config.btextdisbledcolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin]
  HealBot_Config.btextdisbledcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin]
  HealBot_Config.btextcursecolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextcursecolr[HealBot_Config.Current_Skin]
  HealBot_Config.btextcursecolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextcursecolg[HealBot_Config.Current_Skin]
  HealBot_Config.btextcursecolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextcursecolb[HealBot_Config.Current_Skin]
  HealBot_Config.btextcursecola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextcursecola[HealBot_Config.Current_Skin]
  HealBot_Config.backcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.backcola[HealBot_Config.Current_Skin]
  HealBot_Config.Barcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.Barcola[HealBot_Config.Current_Skin]
  HealBot_Config.BarcolaInHeal[HealBot_Options_NewSkin:GetText()] = HealBot_Config.BarcolaInHeal[HealBot_Config.Current_Skin]
  HealBot_Config.backcolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.backcolr[HealBot_Config.Current_Skin]
  HealBot_Config.backcolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.backcolg[HealBot_Config.Current_Skin]
  HealBot_Config.backcolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.backcolb[HealBot_Config.Current_Skin]
  HealBot_Config.borcolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.borcolr[HealBot_Config.Current_Skin]
  HealBot_Config.borcolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.borcolg[HealBot_Config.Current_Skin]
  HealBot_Config.borcolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.borcolb[HealBot_Config.Current_Skin]
  HealBot_Config.borcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.borcola[HealBot_Config.Current_Skin]
  HealBot_Config.btextheight[HealBot_Options_NewSkin:GetText()] = HealBot_Config.btextheight[HealBot_Config.Current_Skin]
  HealBot_Config.bardisa[HealBot_Options_NewSkin:GetText()] = HealBot_Config.bardisa[HealBot_Config.Current_Skin]
  HealBot_Config.abortsize[HealBot_Options_NewSkin:GetText()] = HealBot_Config.abortsize[HealBot_Config.Current_Skin]
  HealBot_Config.babortcolr[HealBot_Options_NewSkin:GetText()] = HealBot_Config.babortcolr[HealBot_Config.Current_Skin]
  HealBot_Config.babortcolg[HealBot_Options_NewSkin:GetText()] = HealBot_Config.babortcolg[HealBot_Config.Current_Skin]
  HealBot_Config.babortcolb[HealBot_Options_NewSkin:GetText()] = HealBot_Config.babortcolb[HealBot_Config.Current_Skin]
  HealBot_Config.babortcola[HealBot_Options_NewSkin:GetText()] = HealBot_Config.babortcola[HealBot_Config.Current_Skin]
  HealBot_Config.ShowHeader[HealBot_Options_NewSkin:GetText()] = HealBot_Config.ShowHeader[HealBot_Config.Current_Skin]

  table.insert(HealBot_Skins,2,HealBot_Options_NewSkin:GetText())
  HealBot_Config.Skin_ID = 2;
  HealBot_Config.Skins = HealBot_Skins;  HealBot_Config.Current_Skin = HealBot_Options_NewSkin:GetText();
  HealBot_Options_SetSkins()
  HealBot_Options_NewSkin:SetText("")
end
function HealBot_Options_DeleteSkin_OnClick(this)
  if HealBot_Config.Current_Skin~=HEALBOT_SKINS_STD then
    HealBot_Config.numcols[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btexture[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.bcspace[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.brspace[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.bwidth[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.bheight[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextenabledcolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextenabledcolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextenabledcolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextenabledcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextdisbledcolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextdisbledcolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextdisbledcolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextdisbledcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextcursecolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextcursecolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextcursecolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextcursecola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.backcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.Barcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.BarcolaInHeal[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.backcolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.backcolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.backcolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.borcolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.borcolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.borcolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.borcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.btextheight[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.bardisa[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.abortsize[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.babortcolr[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.babortcolg[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.babortcolb[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.babortcola[HealBot_Options_SkinsText:GetText()] = nil
    HealBot_Config.ShowHeader[HealBot_Options_SkinsText:GetText()] = nil
    table.remove(HealBot_Skins,HealBot_Config.Skin_ID)
    HealBot_Config.Skin_ID = 1;
    HealBot_Config.Skins = HealBot_Skins;  
    HealBot_Config.Current_Skin = HEALBOT_SKINS_STD;
    HealBot_Options_SetSkins()
  end
end
function HealBot_Options_Skins_DropDown()
  for i=1, getn(HealBot_Skins), 1 do
    local info = {};
    info.text = HealBot_Skins[i];
    info.func = HealBot_Options_Skins_OnSelect;
    UIDropDownMenu_AddButton(info);
  end
end
function HealBot_Options_Skins_Initialize()
  UIDropDownMenu_Initialize(HealBot_Options_Skins,HealBot_Options_Skins_DropDown)
end
function HealBot_Options_Skins_Refresh(onselect)
  if not HealBot_Config.Skin_ID then return end
  if not onselect then HealBot_Options_Skins_Initialize() end  -- or wrong menu may be used !
  UIDropDownMenu_SetSelectedID(HealBot_Options_Skins,HealBot_Config.Skin_ID)
end
function HealBot_Options_Skins_OnLoad()
  UIDropDownMenu_Initialize(this, HealBot_Options_Skins_DropDown)
  UIDropDownMenu_SetWidth(100, this)
end
function HealBot_Options_Skins_OnSelect()
  HealBot_Config.Skin_ID = this:GetID()
  HealBot_Options_Skins_Refresh(true)
  if this:GetID()>=1 then
    HealBot_Config.Current_Skin = this:GetText()
    HealBot_Options_SetSkins()
  end
end
