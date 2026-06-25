-- HealBot_Controller_Comms.lua
-- Handles network sync (addon messaging), errors, and chat debugging

function HealBot_Get_DebugChan()
    local index = GetChannelName("HBmsg");
    if (index > 0) then
        return index;
    else
        return nil;
    end
end

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

function HealBot_Report_Error(msg)
    if HealBot_ErrorCnt < 28 then
        HealBot_ErrorCnt = HealBot_ErrorCnt + 1;
        ShowUIPanel(HealBot_Error);
        HealBot_ErrorsIn(msg, HealBot_ErrorCnt);
    end
end

function HealBot_AddError(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
    HealBot_AddDebug(msg);
end

function HealBot_SendAddonMessage(prefix, text)
    if GetNumRaidMembers() > 0 then
        SendAddonMessage(prefix, text, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(prefix, text, "PARTY")
    end
end

function HealBot_OnEvent_AddonMsg(this, addon_id, inc_msg, dist_target, sender_id)
    if addon_id == HEALBOT_ADDON_ID then
        local tmpTest, unitname, heal_val
        tmpTest, tmpTest, unitname, heal_val = string.find(inc_msg, ">> (%a+) <<=>> (.%d+) <<" );
        if heal_val then
            if not HealBot_HealsIn[unitname] then
                HealBot_HealsIn[unitname] = 0;
            end
            HealBot_Healers[sender_id] = ">> " .. unitname .. " <<=>> " .. heal_val .. " <<";
            HealBot_HealsIn[unitname] = HealBot_HealsIn[unitname] + tonumber(heal_val);
            if tonumber(heal_val) > 0 then
                HealBot_RecalcHeals(HealBot_FindUnitID(unitname))
            elseif HealBot_HealsIn[unitname] < 0 then
                HealBot_HealsIn[unitname] = 0;
            end
        end
    elseif addon_id == "HealBot" then
        local tmpTest, datatype, datamsg, sender
        local PName = UnitName("player");
        tmpTest, tmpTest, datatype, sender, datamsg = string.find(inc_msg, ">> (%a+) <<=>> (%a+) <<=>> (.+)");
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
