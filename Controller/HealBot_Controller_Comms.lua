-- HealBot_Controller_Comms.lua
-- Handles network sync (addon messaging), errors, and chat debugging

-- HealBot_Get_DebugChan: Internal utility: HealBot_Get_DebugChan
function HealBot_Get_DebugChan()
    local index = GetChannelName("HBmsg");
    if (index > 0) then
        return index;
    else
        return nil;
    end
end

-- HealBot_AddChat: Prints standard messages to default chat frame.
function HealBot_AddChat(msg)
    local chanid = HealBot_Get_DebugChan();
    if chanid and HealBot_SpamCnt < 3 then
        HealBot_SpamCnt = HealBot_SpamCnt + 1;
        local hour, minute = GetGameTime();
        if minute == 0 then
            msg = "[" .. hour .. ":00] " .. msg;
        elseif minute < 10 then
            msg = "[" .. hour .. ":0" .. minute .. "] " .. msg; 
        else
            msg = "[" .. hour .. ":" .. minute .. "] " .. msg; 
        end
        SendChatMessage(msg, "CHANNEL", nil, chanid); 
    elseif ( DEFAULT_CHAT_FRAME ) then
        DEFAULT_CHAT_FRAME:AddMessage(msg);
    end
end

-- HealBot_AddDebug: Prints debug messages to chat or internal debug channel.
function HealBot_AddDebug(msg)
    if HealBot_Config and HealBot_Config.DebugMode == 1 then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD100[HB Debug]|r " .. msg);
        end
        return;
    end

    local chanid = HealBot_Get_DebugChan();
    if chanid and HealBot_SpamCnt < 3 then
        HealBot_SpamCnt = HealBot_SpamCnt + 1;
        local hour, minute = GetGameTime();
        if minute == 0 then
            msg = "[" .. hour .. ":00] DEBUG: " .. msg;
        elseif minute < 10 then
            msg = "[" .. hour .. ":0" .. minute .. "] DEBUG: " .. msg; 
        else
            msg = "[" .. hour .. ":" .. minute .. "] DEBUG: " .. msg; 
        end
        SendChatMessage(msg, "CHANNEL", nil, chanid);
    end
end

-- HealBot_Report_Error: Formats and prints error logs.
function HealBot_Report_Error(msg)
    if HealBot_ErrorCnt < 28 then
        HealBot_ErrorCnt = HealBot_ErrorCnt + 1;
        ShowUIPanel(HealBot_Error);
        HealBot_ErrorsIn(msg, HealBot_ErrorCnt);
    end
end

-- HealBot_AddError: Displays error text in the UI frame.
function HealBot_AddError(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
    HealBot_AddDebug(msg);
end

-- HealBot_SendAddonMessage: Broadcasts data to party/raid channels or battlegrounds.
function HealBot_SendAddonMessage(prefix, text)
    local inBG = false
    for i = 1, 3 do
        local status = GetBattlefieldStatus(i)
        if status == "active" then
            inBG = true
            break
        end
    end
    if inBG then
        SendAddonMessage(prefix, text, "BATTLEGROUND")
    elseif GetNumRaidMembers() > 0 then
        SendAddonMessage(prefix, text, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(prefix, text, "PARTY")
    end
end

if not HealBot_IncomingHealers then HealBot_IncomingHealers = {} end
if not HealBot_Ressing_Expires then HealBot_Ressing_Expires = {} end
if not HealBot_Comms_HoTs then HealBot_Comms_HoTs = {} end

-- Reusable global array for gfind string splitting
if not HealBot_Comms_Args then HealBot_Comms_Args = {} end

local function ClearIncomingHeal(sender)
    local data = HealBot_IncomingHealers[sender]
    if not data then return end
    data.expireTime = nil
    local oldAmount = data.amount
    for i=1, 5 do
        local oldTarget = data.targets[i]
        if oldTarget then
            if HealBot_HealsIn[oldTarget] then
                HealBot_HealsIn[oldTarget] = HealBot_HealsIn[oldTarget] - oldAmount
                if HealBot_HealsIn[oldTarget] < 0 then HealBot_HealsIn[oldTarget] = 0 end
                HealBot_RecalcHeals(HealBot_FindUnitID(oldTarget))
            end
            data.targets[i] = nil
        end
    end
    data.amount = 0
end

local function SetIncomingHeal(sender, amount, protocol, expireTime, t1, t2, t3, t4, t5)
    -- prioritize HealComm over HealBot protocol to avoid double-counting
    if HealBot_IncomingHealers[sender] and HealBot_IncomingHealers[sender].protocol == "HealComm" and protocol == "HealBot" then
        return
    end
    
    if not HealBot_IncomingHealers[sender] then
        HealBot_IncomingHealers[sender] = { targets = {}, amount = 0, protocol = protocol }
    end
    
    ClearIncomingHeal(sender)
    
    local data = HealBot_IncomingHealers[sender]
    data.protocol = protocol
    data.expireTime = expireTime
    
    if amount > 0 and t1 then
        data.amount = amount
        data.targets[1] = t1
        data.targets[2] = t2
        data.targets[3] = t3
        data.targets[4] = t4
        data.targets[5] = t5
        
        for i=1, 5 do
            local target = data.targets[i]
            if target then
                if not HealBot_HealsIn[target] then HealBot_HealsIn[target] = 0 end
                HealBot_HealsIn[target] = HealBot_HealsIn[target] + amount
                HealBot_RecalcHeals(HealBot_FindUnitID(target))
            end
        end
    end
end

-- HealBot_OnEvent_AddonMsg: Parses incoming heal data from other clients.
function HealBot_OnEvent_AddonMsg(this, addon_id, inc_msg, dist_target, sender_id)
    local cleanSender = sender_id and string.gsub(sender_id, "%-.*", "")
    if cleanSender == UnitName("player") then return end
    
    if addon_id == "HealComm" then
        -- Clear reusable args array
        for i=1, 10 do HealBot_Comms_Args[i] = nil end
        local argCount = 0
        local start_pos = 1
        local next_pos = string.find(inc_msg, "/", start_pos, true)
        while next_pos do
            argCount = argCount + 1
            HealBot_Comms_Args[argCount] = string.sub(inc_msg, start_pos, next_pos - 1)
            start_pos = next_pos + 1
            next_pos = string.find(inc_msg, "/", start_pos, true)
        end
        if start_pos <= string.len(inc_msg) then
            argCount = argCount + 1
            HealBot_Comms_Args[argCount] = string.sub(inc_msg, start_pos)
        end
        local cmd = HealBot_Comms_Args[1]
        
        if cmd == "Heal" and HealBot_Comms_Args[2] and HealBot_Comms_Args[3] then
            local castTime = tonumber(HealBot_Comms_Args[4]) or 1500
            local expireTime = GetTime() + (castTime / 1000) + 0.3
            SetIncomingHeal(sender_id, tonumber(HealBot_Comms_Args[3]) or 0, "HealComm", expireTime, HealBot_Comms_Args[2])
        elseif cmd == "Healstop" then
            SetIncomingHeal(sender_id, 0, "HealComm", nil)
        elseif cmd == "Healdelay" or cmd == "GrpHealdelay" then
            local delayMs = tonumber(HealBot_Comms_Args[2]) or 0
            if HealBot_IncomingHealers[sender_id] and HealBot_IncomingHealers[sender_id].expireTime then
                HealBot_IncomingHealers[sender_id].expireTime = HealBot_IncomingHealers[sender_id].expireTime + (delayMs / 1000)
            end
        elseif cmd == "GrpHeal" and HealBot_Comms_Args[2] then
            local castTime = tonumber(HealBot_Comms_Args[3]) or 3000
            local expireTime = GetTime() + (castTime / 1000) + 0.3
            SetIncomingHeal(sender_id, tonumber(HealBot_Comms_Args[2]) or 0, "HealComm", expireTime, HealBot_Comms_Args[4], HealBot_Comms_Args[5], HealBot_Comms_Args[6], HealBot_Comms_Args[7], HealBot_Comms_Args[8])
        elseif cmd == "GrpHealstop" then
            SetIncomingHeal(sender_id, 0, "HealComm", nil)
        elseif cmd == "Resurrection" then
            if HealBot_Comms_Args[2] == "stop" then
                HealBot_AddDebug(sender_id .. " Stopped ressing");
                for unit, resser in pairs(HealBot_Ressing) do
                    if resser == sender_id then
                        HealBot_Ressing[unit] = nil;
                        HealBot_Ressing_Expires[unit] = nil;
                        HealBot_RecalcHeals(HealBot_FindUnitID(unit));
                    end
                end
            elseif HealBot_Comms_Args[2] and HealBot_Comms_Args[3] == "start" then
                local rezTarget = HealBot_Comms_Args[2]
                HealBot_AddDebug(sender_id .. " is ressing " .. rezTarget);
                HealBot_Ressing[rezTarget] = sender_id;
                HealBot_Ressing_Expires[rezTarget] = GetTime() + 70;
                HealBot_RecalcHeals(HealBot_FindUnitID(rezTarget));
            end
        elseif cmd == "Renew" or cmd == "Reju" or cmd == "Regr" then
            local target = HealBot_Comms_Args[2]
            local fallbackDur = (cmd == "Regr" and 21) or (cmd == "Reju" and 12) or 15
            local dur = tonumber(HealBot_Comms_Args[3]) or fallbackDur
            if target then
                if not HealBot_Comms_HoTs[target] then HealBot_Comms_HoTs[target] = {} end
                local hotSpell = (cmd == "Renew" and "Renew") or (cmd == "Reju" and "Rejuvenation") or (cmd == "Regr" and "Regrowth")
                if not HealBot_Comms_HoTs[target][hotSpell] then HealBot_Comms_HoTs[target][hotSpell] = {} end
                HealBot_Comms_HoTs[target][hotSpell].expires = GetTime() + dur
                HealBot_Comms_HoTs[target][hotSpell].start = GetTime()
                HealBot_Comms_HoTs[target][hotSpell].dur = dur
                local u = HealBot_FindUnitID(target)
                if u and HealBot_View_DirtyUnits then HealBot_View_DirtyUnits[u] = true end
            end
        end
        
    elseif addon_id == HEALBOT_ADDON_ID then
        local tmpTest, tmpTest, unitname, heal_val = string.find(inc_msg, ">> (.-) <<=>> (.-) <<" );
        if heal_val and unitname then
            local amount = tonumber(heal_val) or 0
            if amount < 0 then amount = 0 end -- HealBot sends negative to cancel
            SetIncomingHeal(sender_id, amount, "HealBot", nil, unitname)
        end
        
    elseif addon_id == "HealBot" then
        local tmpTest, datatype, datamsg, sender
        local PName = UnitName("player");
        tmpTest, tmpTest, datatype, sender, datamsg = string.find(inc_msg, ">> (.-) <<=>> (.-) <<=>> (.+)");
        if datatype == "RequestVersion" then
            HealBot_SendAddonMessage("HealBot", ">> SendVersion <<=>> " .. sender .. " <<=>> Version=" .. HEALBOT_VERSION);
        elseif datatype == "SendVersion" and PName == sender then
            HealBot_AddChat(sender_id .. ":  " .. datamsg);
        end
        
    elseif addon_id == "CTRA" then
        if ( string.sub(inc_msg, 1, 3) == "RES" ) then
            if ( inc_msg == "RESNO" ) then
                HealBot_AddDebug(sender_id .. " Stopped ressing");
                for unit, resser in pairs(HealBot_Ressing) do
                    if resser == sender_id then
                        HealBot_Ressing[unit] = nil;
                        HealBot_Ressing_Expires[unit] = nil;
                        HealBot_RecalcHeals(HealBot_FindUnitID(unit));
                    end
                end
            else
                local unitname, tmpTest
                tmpTest, tmpTest, unitname = string.find(inc_msg, "^RES (.+)$");
                if ( unitname ) then
                    HealBot_AddDebug(sender_id .. " is ressing " .. unitname);
                    HealBot_Ressing[unitname] = sender_id;
                    HealBot_Ressing_Expires[unitname] = GetTime() + 70;
                    HealBot_RecalcHeals(HealBot_FindUnitID(unitname));
                end
            end
        end
    end
end

local HealBot_Comms_UpdateTimer = 0
-- HealBot_Comms_OnUpdate: Periodic cleanup of expired incoming heals, resurrections, and HoTs
function HealBot_Comms_OnUpdate(elapsed)
    HealBot_Comms_UpdateTimer = HealBot_Comms_UpdateTimer + (elapsed or 0.05)
    if HealBot_Comms_UpdateTimer < 0.1 then return end
    HealBot_Comms_UpdateTimer = 0
    local now = GetTime()
    if HealBot_IncomingHealers then
        for sender, data in pairs(HealBot_IncomingHealers) do
            if data.expireTime and data.amount > 0 and now >= data.expireTime then
                ClearIncomingHeal(sender)
            end
        end
    end
    if HealBot_Ressing_Expires then
        for target, expireTime in pairs(HealBot_Ressing_Expires) do
            if now >= expireTime then
                HealBot_Ressing_Expires[target] = nil
                HealBot_Ressing[target] = nil
                local unitID = HealBot_FindUnitID(target)
                if unitID then HealBot_RecalcHeals(unitID) end
            end
        end
    end
    if HealBot_Comms_HoTs then
        for target, spells in pairs(HealBot_Comms_HoTs) do
            for spell, info in pairs(spells) do
                if info.expires and now >= info.expires then
                    info.expires = nil
                    local unitID = HealBot_FindUnitID(target)
                    if unitID and HealBot_View_DirtyUnits then HealBot_View_DirtyUnits[unitID] = true end
                end
            end
        end
    end
end
