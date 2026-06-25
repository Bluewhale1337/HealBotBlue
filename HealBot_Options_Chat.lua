-- HealBot Options panel file: HealBot_Options_Chat.lua
-- Split from original HealBot_Options.lua

local HealBot_PlayerSpells = nil

function HealBot_GetPlayerSpells()
  if HealBot_PlayerSpells then return HealBot_PlayerSpells end
  local spellSet = {}
  local i = 1
  while true do
    local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
    if not spellName then
      break
    end
    spellSet[spellName] = true
    i = i + 1
  end
  local sortedSpells = {}
  for k, _ in pairs(spellSet) do
    table.insert(sortedSpells, k)
  end
  table.sort(sortedSpells)
  HealBot_PlayerSpells = sortedSpells
  return sortedSpells
end

function HealBot_Options_ChatMsg_Spell_Initialize()
  local info
  
  info = { text = "None", func = HealBot_Options_ChatMsg_Spell_OnClick, value = "None" }
  UIDropDownMenu_AddButton(info)
  
  local spells = HealBot_GetPlayerSpells()
  for _, spellName in ipairs(spells) do
    info = {
      text = spellName,
      func = HealBot_Options_ChatMsg_Spell_OnClick,
      value = spellName
    }
    UIDropDownMenu_AddButton(info)
  end
end

function HealBot_Options_ChatMsg_Spell_OnClick()
  local frameName = UIDROPDOWNMENU_OPEN_MENU
  local frame = getglobal(frameName)
  local id = frame:GetID()
  
  if not HealBot_Config.ChatMessages then HealBot_Config.ChatMessages = {} end
  if not HealBot_Config.ChatMessages[id] then 
    HealBot_Config.ChatMessages[id] = { Spell = "None", Message = "Casting #Spell# on #Target#", Channel = "None" }
  end
  
  HealBot_Config.ChatMessages[id].Spell = this.value
  
  local text = this.value
  if text == "None" then text = "None" end
  
  UIDropDownMenu_SetSelectedValue(frame, this.value)
  UIDropDownMenu_SetText(text, frame)
end

function HealBot_Options_ChatMsg_Channel_OnClick(id, buttonFrame)
  if not HealBot_Config.ChatMessages then HealBot_Config.ChatMessages = {} end
  if not HealBot_Config.ChatMessages[id] then 
    HealBot_Config.ChatMessages[id] = { Spell = "None", Message = "Casting #Spell# on #Target#", Channel = "None" }
  end
  
  local current = HealBot_Config.ChatMessages[id].Channel
  local nextChan = "None"
  
  if current == "None" then
    nextChan = "Say"
  elseif current == "Say" then
    nextChan = "Party"
  elseif current == "Party" then
    nextChan = "Raid"
  elseif current == "Raid" then
    nextChan = "Whisper"
  elseif current == "Whisper" then
    nextChan = "None"
  end
  
  HealBot_Config.ChatMessages[id].Channel = nextChan
  buttonFrame:SetText(nextChan)
end

function HealBot_Options_SetChatMessages()
  if not HealBot_Config.ChatMessages then
    HealBot_Config.ChatMessages = {}
  end
  for i = 1, 5 do
    if not HealBot_Config.ChatMessages[i] then
      HealBot_Config.ChatMessages[i] = { Spell = "None", Message = "Casting #Spell# on #Target#", Channel = "None" }
    end
  end
  for i = 1, 5 do
    local msgConfig = HealBot_Config.ChatMessages[i]
    if msgConfig then
      local dropDown = getglobal("HealBot_Options_ChatMsg"..i)
      local editBox = getglobal("HealBot_Options_ChatMsg"..i.."_Text")
      local chanButton = getglobal("HealBot_Options_ChatMsg"..i.."_Channel")
      
      if dropDown then
        UIDropDownMenu_Initialize(dropDown, HealBot_Options_ChatMsg_Spell_Initialize)
        UIDropDownMenu_SetSelectedValue(dropDown, msgConfig.Spell)
        UIDropDownMenu_SetWidth(110, dropDown)
        UIDropDownMenu_SetText(msgConfig.Spell, dropDown)
      end
      if editBox then
        editBox:SetText(msgConfig.Message or "")
      end
      if chanButton then
        chanButton:SetText(msgConfig.Channel or "None")
      end
    end
  end
end


















