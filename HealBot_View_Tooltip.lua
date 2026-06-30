-- HealBot_View_Tooltip.lua
-- Handles rendering of unit and spell tooltips in the HealBot UI

HealBot_Action_TooltipUnit = nil

function HealBot_Action_RefreshTooltip(unit)
  if HealBot_Config.ShowTooltip==0 then return end
  if not unit then unit = HealBot_Action_TooltipUnit end
  if not unit then return end;

  local hlth=UnitHealth(unit);
  local maxhlth=UnitHealthMax(unit);

  local spellLeft = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Left"));
  local spellMiddle = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Middle"));
  local spellRight = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Right"));
  local spellButton4 = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Button4"));
  local spellButton5 = HealBot_GetHealSpell(unit,HealBot_Action_SpellPattern("Button5"));
  local linenum = 1
  
  HealBot_Action_Tooltip_ClearLines();
  
  if HealBot_Config.Tooltip_ShowTarget==1 then
    if UnitName(unit) then
      HealBot_Action_Tooltip_SetLineLeft(UnitName(unit),0,1,0,linenum)  
      if hlth and maxhlth then
        local r,g,b,a=HealBot_HealthColor(unit,hlth,maxhlth);
        HealBot_Action_Tooltip_SetLineRight(hlth.."/"..maxhlth.." (-"..maxhlth-hlth..")",r,g,b,linenum) 
      end
    end
  end
    
  if HealBot_Config.Tooltip_ShowSpellDetail==1 then
    if spellLeft then
      linenum=linenum+2
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONLEFT.." "..HEALBOT_OPTIONS_COMBOBUTTON..": "..spellLeft,1,1,0,linenum) 
      linenum=HealBot_Action_Tooltip_SpellInfo(spellLeft,linenum);
    end
    if spellMiddle then
      linenum=linenum+2
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONMIDDLE.." "..HEALBOT_OPTIONS_COMBOBUTTON..": "..spellMiddle,1,1,0,linenum) 
      linenum=HealBot_Action_Tooltip_SpellInfo(spellMiddle,linenum);
    end
    if spellRight then
      linenum=linenum+2
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONRIGHT.." "..HEALBOT_OPTIONS_COMBOBUTTON..": "..spellRight,1,1,0,linenum) 
      linenum=HealBot_Action_Tooltip_SpellInfo(spellRight,linenum);
    end
    if spellButton4 then
      linenum=linenum+2
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTON4.." "..HEALBOT_OPTIONS_COMBOBUTTON..": "..spellButton4,1,1,0,linenum) 
      linenum=HealBot_Action_Tooltip_SpellInfo(spellButton4,linenum);
    end
    if spellButton5 then
      linenum=linenum+2
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTON5.." "..HEALBOT_OPTIONS_COMBOBUTTON..": "..spellButton5,1,1,0,linenum) 
      linenum=HealBot_Action_Tooltip_SpellInfo(spellButton5,linenum);
    end
  else
    if spellLeft then 
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONLEFT..":",1,1,0,linenum) 
      HealBot_Action_Tooltip_SetLineRight(HealBot_Action_Tooltip_SpellSummary(spellLeft),1,1,1,linenum) 
    end
    if spellMiddle then 
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONMIDDLE..":",1,1,0,linenum) 
      HealBot_Action_Tooltip_SetLineRight(HealBot_Action_Tooltip_SpellSummary(spellMiddle),1,1,1,linenum) 
    end
    if spellRight then 
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTONRIGHT..":",1,1,0,linenum) 
      HealBot_Action_Tooltip_SetLineRight(HealBot_Action_Tooltip_SpellSummary(spellRight),1,1,1,linenum) 
    end
    if spellButton4 then 
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTON4..":",1,1,0,linenum) 
      HealBot_Action_Tooltip_SetLineRight(HealBot_Action_Tooltip_SpellSummary(spellButton4),1,1,1,linenum) 
    end
    if spellButton5 then 
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_OPTIONS_BUTTON5..":",1,1,0,linenum) 
      HealBot_Action_Tooltip_SetLineRight(HealBot_Action_Tooltip_SpellSummary(spellButton5),1,1,1,linenum) 
    end
  end      
  if HealBot_Config.Tooltip_Recommend==1 then
    local Instant_check=0;
    if HealBot_Config.Tooltip_ShowSpellDetail==1 then linenum=linenum+1; end
    linenum=linenum+1
    HealBot_Action_Tooltip_SetLineLeft(HEALBOT_TOOLTIP_RECOMMENDTEXT,0.8,0.8,0,linenum) 
    Instant_check=0;
    Instant_check,linenum=HealBot_Action_Tooltip_CheckForInstant(unit,spellLeft,"upd",linenum,Instant_check);
    Instant_check,linenum=HealBot_Action_Tooltip_CheckForInstant(unit,spellMiddle,"upd",linenum,Instant_check);
    Instant_check,linenum=HealBot_Action_Tooltip_CheckForInstant(unit,spellRight,"upd",linenum,Instant_check);
    Instant_check,linenum=HealBot_Action_Tooltip_CheckForInstant(unit,spellButton4,"upd",linenum,Instant_check);
    Instant_check,linenum=HealBot_Action_Tooltip_CheckForInstant(unit,spellButton5,"upd",linenum,Instant_check);
    if Instant_check==0 then
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft("  None",0.4,0.4,0.4,linenum) 
    end
  end

  local height = 20 
  local width = 0
  for i = 1, linenum do
    local txtL = getglobal("HealBot_TooltipTextL" .. i)
    local txtR = getglobal("HealBot_TooltipTextR" .. i)
    height = height + txtL:GetHeight() + 2
    if (txtL:GetWidth() + txtR:GetWidth() + 25 > width) then
      width = txtL:GetWidth() + txtR:GetWidth() + 25
    end
  end
  HealBot_Tooltip:SetWidth(width)
  HealBot_Tooltip:SetHeight(height)
  HealBot_Tooltip:ClearAllPoints();
  if HealBot_Config.TooltipPos>1 then
    if HealBot_Config.TooltipPos==2 then
      HealBot_Tooltip:SetPoint("TOPRIGHT","HealBot_Action","TOPLEFT",0,0);
    elseif HealBot_Config.TooltipPos==3 then
      HealBot_Tooltip:SetPoint("TOPLEFT","HealBot_Action","RIGHT",0,0);
    elseif HealBot_Config.TooltipPos==4 then
      HealBot_Tooltip:SetPoint("BOTTOM","HealBot_Action","TOP",0,0);
    else
      HealBot_Tooltip:SetPoint("TOP","HealBot_Action","BOTTOM",0,0);
    end
  else
    HealBot_Tooltip:SetPoint("BOTTOMRIGHT","WorldFrame","BOTTOMRIGHT",-105,105);
  end
  HealBot_Tooltip:Show();
end

function HealBot_Action_Tooltip_SpellInfo(spell,linenum)
  local text
  if HealBot_Spells[spell] then
    if HealBot_Spells[spell].HealsDur>0 then
      linenum=linenum+1
      HealBot_Action_Tooltip_SetLineLeft(HEALBOT_WORDS_CAST..": "..HealBot_Spells[spell].CastTime.." "..HEALBOT_WORDS_SEC..".",0.8,0.8,0.8,linenum) 
      HealBot_Action_Tooltip_SetLineRight("Mana: "..HealBot_Spells[spell].Mana,0.5,0.5,1,linenum) 
      if HealBot_Spells[spell].HealsMax>0 then
        local Heals = HEALBOT_HEAL.." "
        if HealBot_Spells[spell].Shield then
          Heals = HEALBOT_TOOLTIP_SHIELD.." "
        end
        if HealBot_Spells[spell].HealsMin<HealBot_Spells[spell].HealsMax then
          text=Heals..format("%d", HealBot_Spells[spell].HealsMin + HealBot_Spells[spell].RealHealing) .." "..HEALBOT_WORDS_TO.." "..format("%d",HealBot_Spells[spell].HealsMax + HealBot_Spells[spell].RealHealing)
        else
          text=Heals..format("%d", HealBot_Spells[spell].HealsMax + HealBot_Spells[spell].RealHealing)
        end
        linenum=linenum+1
        HealBot_Action_Tooltip_SetLineLeft(text,1,1,1,linenum)
      end
      if HealBot_Spells[spell].HealsExt>0 then
        text=HEALBOT_HEAL.." "..HealBot_Spells[spell].HealsDur.." "..HEALBOT_WORDS_OVER.." "..HealBot_Spells[spell].Duration-HealBot_Spells[spell].CastTime.." sec."
        linenum=linenum+1
        HealBot_Action_Tooltip_SetLineLeft(text,1,1,1,linenum)
      end
      if not HealBot_Spells[spell].Shield then
        text=HEALBOT_TOOLTIP_ITEMBONUS.." +"..HealBot_GetBonus().." | "..HEALBOT_TOOLTIP_ACTUALBONUS.." +"..HealBot_Spells[spell].RealHealing.." "
        linenum=linenum+1
        HealBot_Action_Tooltip_SetLineLeft(text,0.8,0.8,0.8,linenum)
      end
    end
  end
  return linenum
end

function HealBot_Action_Tooltip_SpellSummary(spell)
  local ret_val = "  ";
  if HealBot_Spells[spell] then
    if HealBot_Spells[spell].HealsDur and HealBot_Spells[spell].HealsDur>0 then
      if HealBot_Spells[spell].HealsMax and HealBot_Spells[spell].HealsMax>0 then
        local Heals = " "..HEALBOT_HEAL.." ";
        if HealBot_Spells[spell].Shield then
          Heals = " "..HEALBOT_TOOLTIP_SHIELD.." ";
        end
        if (HealBot_Spells[spell].HealsMin or 0)<(HealBot_Spells[spell].HealsMax or 0) then
          ret_val=ret_val..Heals..format("%d", (((HealBot_Spells[spell].HealsMin or 0)+(HealBot_Spells[spell].HealsMax or 0))/2) + (HealBot_Spells[spell].RealHealing or 0)); 
        else
          ret_val=ret_val..Heals..format("%d", (HealBot_Spells[spell].HealsMax or 0) + (HealBot_Spells[spell].RealHealing or 0));
        end
      end
      if HealBot_Spells[spell].HealsExt and HealBot_Spells[spell].HealsExt>0 then
        ret_val=ret_val.." HoT "..HealBot_Spells[spell].HealsDur;
      end
      if HealBot_Spells[spell].Mana then
        ret_val=ret_val.." "..HEALBOT_WORDS_FOR.." "..HealBot_Spells[spell].Mana.." Mana";
      end
    end
  end
  if string.len(ret_val)<5 then ret_val = " - "..spell; end
  return ret_val
end

function HealBot_Action_Tooltip_CheckForInstant(unit,spell,upd,linenum,check)
  if HealBot_Spells[spell] then
    if HealBot_Spells[spell].CastTime == 0 then
      if HealBot_UnitAffected(unit,HealBot_Spells[spell].Buff) then return check,linenum end;  
      if HealBot_UnitAffected(unit,HealBot_Spells[spell].Debuff) then return check,linenum end;
      if upd=="upd" then
        linenum=linenum+1
        HealBot_Action_Tooltip_SetLineLeft("  "..spell,1,1,1,linenum)
      end
    else
      return check,linenum;
    end
  else
    return check,linenum
  end
  return check+1,linenum;
end

function HealBot_Action_Tooltip_SetLineLeft(Text,R,G,B,linenum)
  local txtL = getglobal("HealBot_TooltipTextL" .. linenum)
  txtL:SetTextColor(R,G,B)
  txtL:SetText(Text)
  txtL:Show()
end

function HealBot_Action_Tooltip_SetLineRight(Text,R,G,B,linenum)
  local txtR = getglobal("HealBot_TooltipTextR" .. linenum)
  txtR:SetTextColor(R,G,B)
  txtR:SetText(Text)
  txtR:Show()
end

function HealBot_Action_Tooltip_ClearLines()
  for j=1,30 do
    local txtL = getglobal("HealBot_TooltipTextL" .. j)
    local txtR = getglobal("HealBot_TooltipTextR" .. j)
    txtL:SetText(" ")
    txtR:SetText(" ")
    txtL:Hide()
    txtR:Hide()
  end
end

function HealBot_Action_ShowTooltip(this)
  if HealBot_Config.ShowTooltip==0 then return end
  if not this.unit then return end;
  if not this:IsEnabled() then return end;
  
  HealBot_Action_TooltipUnit = this.unit;
  HealBot_Action_RefreshTooltip(this.unit);
end

function HealBot_Action_HideTooltip(this)
  if HealBot_Config.ShowTooltip==0 then return end
  HealBot_Tooltip:Hide();
  HealBot_Action_TooltipUnit = nil;
end
