--[[

  HealBot Contined
	
]]

-- local _scale=0; -- moved to HealBot_Controller_Range.lua
CalcEquipBonus=false;
HealBot_EquipChangeTimer = 0;
HealValue=0;
InitSpells=1;
local DebugDebuff=false;
Delay_RecalcParty=0;


-- Debugging and Error functions moved to HealBot_Controller_Comms.lua

function HealBot_TogglePanel(panel)
  if (not panel) then return end
  if ( panel:IsVisible() ) then
    HideUIPanel(panel);
  else
    ShowUIPanel(panel);
  end
end

function HealBot_StartMoving(frame)
  if ( not frame.isMoving ) and ( frame.isLocked ~= 1 ) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function HealBot_StopMoving(frame)
  if ( frame.isMoving ) then
    frame:StopMovingOrSizing();
    frame.isMoving = false;
  end
  if HealBot_Config.GrowUpwards==1 then
    local left,bottom = HealBot_Action:GetLeft(),HealBot_Action:GetBottom();
    if left and bottom then
      HealBot_Config.PanelAnchorX=left;
      HealBot_Config.PanelAnchorY=bottom;
    end
--    HealBot_AddDebug("Pos X="..HealBot_Config.PanelAnchorX.."  Pos Y="..HealBot_Config.PanelAnchorY)
  end

end

function HealBot_SlashCmd(cmd)
  if (cmd=="") then
    HealBot_TogglePanel(HealBot_Action);
    return
  end
  if (cmd=="options" or cmd=="opt" or cmd=="config" or cmd=="cfg") then
    HealBot_TogglePanel(HealBot_Options);
    return
  end

  if (cmd=="reset" or cmd=="recalc" or cmd=="defaults") then
    InitSpells=2;
    HealBot_Options_Defaults_OnClick(HealBot_Options_Defaults);
    return
  end
  if (cmd=="ui") then
    ReloadUI();
    return;
  end
  if (cmd=="init") then
  	HealBot_RegisterThis(this);
  end
  if (cmd=="x") then
    InitSpells=2;
	NeedEquipUpdate=1
  	HealBot_RecalcSpells();
    return;
  end
  if (cmd=="ver") then
    local text=UnitName("player");
    HealBot_SendAddonMessage( "HealBot", ">> RequestVersion <<=>> "..text.." <<=>> nil <<" );
    return;
  end
  if (cmd=="chan") then
    HealBot_AddDebug( "Channel active" );
    return;
  end
end

-- HealBot_SendAddonMessage moved to HealBot_Controller_Comms.lua

function HealBot_TargetName()
  if UnitIsEnemy("target","player") then return nil end
--  if not UnitPlayerControlled("target") then return nil end
  if (UnitIsPlayer("target")) then
    if UnitIsUnit("target","player") then return "player" end
    if (UnitInParty("target")) then 
      for i=1,4 do
        if UnitIsUnit("target","party"..i) then return "party"..i end
      end
    end
    if (UnitInRaid("target")) then 
      for i=1,40 do
        if UnitIsUnit("target","raid"..i) then return "raid"..i end
      end
    end
  else
    if UnitIsUnit("target","pet") then return "pet" end
    if (UnitInParty("player")) then 
      for i=1,4 do
        if UnitIsUnit("target","partypet"..i) then return "partypet"..i end
      end
    end
    if (UnitInRaid("player")) then 
      for i=1,40 do
        if UnitIsUnit("target","raidpet"..i) then return "raidpet"..i end
      end
    end
  end
  return nil
end



function HealBot_PackBagSlot(bag,slot)
  return bag*100+slot;
end

function HealBot_UnpackBagSlot(bagslot)
  return math.floor(bagslot/100),math.mod(bagslot,100);
end

function HealBot_GetItemName(bag,slot)
  local link = GetContainerItemLink(bag,slot);
  if not link then return nil end;
  local _,_,item = string.find(link,"%[(.*)%]");
  local _,count = GetContainerItemInfo(bag,slot);
  return item,count;
end

function HealBot_GetBagSlot(item)
  local BagSlot,BestCount;
  for bag=0,NUM_BAG_FRAMES do
    for slot=1,GetContainerNumSlots(bag) do
      local bagitem,count = HealBot_GetItemName(bag,slot);
      if (item==bagitem) then
        if not BestCount or BestCount>count then
          BagSlot = HealBot_PackBagSlot(bag,slot);
          BestCount = count;
        end
      end
    end
  end
  return BagSlot;
end

function HealBot_UseItem(item)
  local bagslot = HealBot_GetBagSlot(item);
  if not bagslot then return end;
  local bag,slot = HealBot_UnpackBagSlot(bagslot);
  local Link = GetContainerItemLink(bag,slot);
  UseContainerItem(bag,slot);
end

-- Spell parsing and casting functions moved to HealBot_Controller_Spells.lua

function HealBot_UnitClass(unit)
  local playerClass, englishClass = UnitClass(unit);
  return englishClass;
end

---- HealBot_UnitAffected moved to HealBot_Controller_Aura.lua
-- safer to use GameTooltip:SetUnitBuff and read the lines in the tooltip ...
-- maybe make an additional GameTooltip frame if possible ?

-- Spell parsing, default setup, finding, casting, and recalculating functions moved to HealBot_Controller_Spells.lua

--------------------------------------------------------------------------------------------------
-- OnFoo functions
--------------------------------------------------------------------------------------------------

-- Event loop handlers and event dispatcher moved to HealBot_Controller_Events.lua

-- SpiBonus and GetBonus functions moved to HealBot_Controller_Spells.lua

function HealBot_FindUnitID(unitname)
  local text;
  for _,unit in ipairs(HealBot_Action_HealGroup) do
    text = UnitName(unit);
	if text then
	  if text==unitname then
	    return unit;
	  end
	end
  end
  for i=1,40 do
    local unit = "raid"..i;
	text = UnitName(unit);
	if text then
      if text==unitname then
        return unit;
      end
	end
  end
  return nil;
end

function HealBot_PlaySound(id)
  if id==1 then
    PlaySoundFile("Sound\\Doodad\\BellTollTribal.wav");
  elseif id==2 then
    PlaySoundFile("Sound\\Spells\\Thorns.wav");
  elseif id==3 then
    PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
  end
end

-- HealBot_InitSpells moved to HealBot_Controller_Spells.lua

function HealBot_InitData() 
  HealBot_Skins = HealBot_Config.Skins;
  if(CT_RegisterMod) then
    CT_RegisterMod(HEALBOT_ADDON,"HealBot Options",5,"Interface\\AddOns\\HealBotBlue\\Images\\HealBot","Opens HealBot Options","off",nil,HealBot_ToggleOptions);
  end

--  remove after 1.126
  local tmp=HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] or 0
  HealBot_Config.ShowHeader[HealBot_Config.Current_Skin]=tmp
  
  HealBot_Options_CDCMonitor_Reset()
  HealBot_Options_EmergencyFilter_Reset()
  HealBot_Options_Debuff_Reset()
end

function HealBot_ToggleOptions()
  HealBot_TogglePanel(HealBot_Options)
end
  
-- HealBot_InitGetSpellData and HealBot_Generic_Patten moved to HealBot_Controller_Spells.lua

-- HealBot_Get_DebugChan moved to HealBot_Controller_Comms.lua

-- HealBot_Range_Check moved to HealBot_Controller_Range.lua

--------------------------------------------------------------------------------
-- Native Action Bar Hovercasting (Mouseover Hook)
--------------------------------------------------------------------------------
do
  local pass = function() end
  local orig = UseAction
  function UseAction(slot, checkCursor, onSelf)
    if HealBot_Config.ActionMouseover == 1 then
      local mouseover = HealBot_Action_TooltipUnit
      if mouseover and mouseover ~= 'target' then
        local _PlaySound = PlaySound
        local target = UnitName("target")
        
        PlaySound = pass
        ClearTarget()
        PlaySound = _PlaySound
        
        do
          local autoSelfCast = GetCVar("autoSelfCast")
          SetCVar("autoSelfCast", "0") -- Ensure disabled
          orig(slot, checkCursor, onSelf)
          if autoSelfCast then
            SetCVar("autoSelfCast", autoSelfCast)
          end
        end
        
        SpellTargetUnit(mouseover)
        
        if target then
          PlaySound = pass
          TargetLastTarget()
          PlaySound = _PlaySound
        end
        
        return
      end
    end
    orig(slot, checkCursor, onSelf)
  end
end


