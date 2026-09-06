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

-- HealBot_AddDebug: Prints debug messages to internal chat channel.
function HealBot_AddDebug(msg)
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

-- HealBot_SendAddonMessage: Broadcasts data to party/raid channels.
function HealBot_SendAddonMessage(prefix, text)
    if GetNumRaidMembers() > 0 then
        SendAddonMessage(prefix, text, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(prefix, text, "PARTY")
    end
end

if not HealBot_IncomingHealers then HealBot_IncomingHealers = {} end

-- Reusable global array for gfind string splitting
if not HealBot_Comms_Args then HealBot_Comms_Args = {} end

local function ClearIncomingHeal(sender)
    local data = HealBot_IncomingHealers[sender]
    if not data then return end
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

local function SetIncomingHeal(sender, amount, protocol, t1, t2, t3, t4, t5)
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
    if sender_id == UnitName("player") then return end
    
    if addon_id == "HealComm" then
        -- Clear reusable args array
        for i=1, 10 do HealBot_Comms_Args[i] = nil end
        local argCount = 0
        for word in string.gfind(inc_msg, "[^/]+") do
            argCount = argCount + 1
            HealBot_Comms_Args[argCount] = word
        end
        local cmd = HealBot_Comms_Args[1]
        
        if cmd == "Heal" and HealBot_Comms_Args[2] and HealBot_Comms_Args[3] then
            SetIncomingHeal(sender_id, tonumber(HealBot_Comms_Args[3]) or 0, "HealComm", HealBot_Comms_Args[2])
        elseif cmd == "Healstop" then
            SetIncomingHeal(sender_id, 0, "HealComm")
        elseif cmd == "GrpHeal" and HealBot_Comms_Args[2] then
            SetIncomingHeal(sender_id, tonumber(HealBot_Comms_Args[2]) or 0, "HealComm", HealBot_Comms_Args[4], HealBot_Comms_Args[5], HealBot_Comms_Args[6], HealBot_Comms_Args[7], HealBot_Comms_Args[8])
        elseif cmd == "GrpHealstop" then
            SetIncomingHeal(sender_id, 0, "HealComm")
        elseif cmd == "Resurrection" then
            if HealBot_Comms_Args[2] == "stop" then
                HealBot_AddDebug(sender_id .. " Stopped ressing");
                for unit, resser in pairs(HealBot_Ressing) do
                    if resser == sender_id then
                        HealBot_Ressing[unit] = nil;
                        HealBot_RecalcHeals(HealBot_FindUnitID(unit));
                    end
                end
            elseif HealBot_Comms_Args[2] and HealBot_Comms_Args[3] == "start" then
                HealBot_AddDebug(sender_id .. " is ressing " .. HealBot_Comms_Args[2]);
                HealBot_Ressing[HealBot_Comms_Args[2]] = sender_id;
                HealBot_RecalcHeals(HealBot_FindUnitID(HealBot_Comms_Args[2]));
            end
        end
        
    elseif addon_id == HEALBOT_ADDON_ID then
        local tmpTest, tmpTest, unitname, heal_val = string.find(inc_msg, ">> (.-) <<=>> (.-) <<" );
        if heal_val and unitname then
            local amount = tonumber(heal_val) or 0
            if amount < 0 then amount = 0 end -- HealBot sends negative to cancel
            SetIncomingHeal(sender_id, amount, "HealBot", unitname)
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
                        HealBot_RecalcHeals(HealBot_FindUnitID(unit));
                    end
                end
            else
                local unitname, tmpTest
                tmpTest, tmpTest, unitname = string.find(inc_msg, "^RES (.+)$");
                if ( unitname ) then
                    HealBot_AddDebug(sender_id .. " is ressing " .. unitname);
                    HealBot_Ressing[unitname] = sender_id;
                    HealBot_RecalcHeals(HealBot_FindUnitID(unitname));
                end
            end
        end
    end
end
