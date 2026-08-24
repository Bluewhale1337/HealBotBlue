-- HealBot Options panel file: HealBot_Options_Chat.lua
-- Split from original HealBot_Options.lua

-- HealBot_Options_ChatMsg_Channel_OnClick: UI handler for OnClick options panel.
function HealBot_Options_ChatMsg_Channel_OnClick(id, buttonFrame)
  if not HealBot_Config.ChatMessages then HealBot_Config.ChatMessages = {} end
  if not HealBot_Config.ChatMessages[id] then 
    HealBot_Config.ChatMessages[id] = { Spell = "", Message = "Casting #Spell# on #Target#", Channel = "None" }
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

-- HealBot_Options_SetChatMessages: UI handler for SetChatMessages options panel.
function HealBot_Options_SetChatMessages()
  if not HealBot_Config.ChatMessages then
    HealBot_Config.ChatMessages = {}
  end
  for i = 1, 5 do
    if not HealBot_Config.ChatMessages[i] then
      HealBot_Config.ChatMessages[i] = { Spell = "", Message = "Casting #Spell# on #Target#", Channel = "None" }
    end
  end
  for i = 1, 5 do
    local msgConfig = HealBot_Config.ChatMessages[i]
    if msgConfig then
      local spellEdit = getglobal("HealBot_Options_ChatMsg"..i.."_Spell")
      local textEdit = getglobal("HealBot_Options_ChatMsg"..i.."_Text")
      local chanButton = getglobal("HealBot_Options_ChatMsg"..i.."_Channel")
      
      if spellEdit then
        if msgConfig.Spell == "None" then
          spellEdit:SetText("")
          msgConfig.Spell = ""
        else
          spellEdit:SetText(msgConfig.Spell or "")
        end
      end
      if textEdit then
        textEdit:SetText(msgConfig.Message or "")
      end
      if chanButton then
        chanButton:SetText(msgConfig.Channel or "None")
      end
    end
  end
end


















