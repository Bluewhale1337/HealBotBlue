-- HealBot_View_Layout.lua
-- Manages skins, status bar layouts, anchoring, and grid rendering for the HealBot panel

local headerno = 0

HealBot_Action_HealGroup = {
  "player",
  "pet",
  "party1",
  "party2",
  "party3",
  "party4",
};

HealBot_Action_HealTarget = {};
HealBot_Action_HealButtons = {};
HealBot_Action_UnitButtons = {};

function HealBot_Action_SetTexture(bar, btexture)
    if not bar then return end
    if btexture == 10 then
        bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8");
    else
        bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    end
end

function HealBot_HealthColor(unit, hlth, maxhlth)
    if HealBot_UnitDebuff[unit] then
        local debuff, tmp, debuff_type = UnitDebuff(unit, 1, 1)
        if not debuff then
            HealBot_UnitDebuff[unit] = nil;
            HealBot_UnitDebuff[unit .. "_debuff_texture"] = nil
        else
            local dr = HealBot_Config.CDCBarColour[debuff_type].R
            local dg = HealBot_Config.CDCBarColour[debuff_type].G
            local db = HealBot_Config.CDCBarColour[debuff_type].B
            if HealBot_Config.btexture[HealBot_Config.Current_Skin] == 10 then
                dr = dr * 4
                dg = dg * 4
                db = db * 4
                if dr > 1 then dr = 1 end
                if dg > 1 then dg = 1 end
                if db > 1 then db = 1 end
            end
            return dr, dg, db, HealBot_Config.Barcola[HealBot_Config.Current_Skin];
        end
    end
    
    local text = UnitName(unit);
    if not HealBot_HealsIn[text] then
        HealBot_HealsIn[text] = 0;
    end
    
    local pct = hlth + HealBot_HealsIn[text];
    if maxhlth and maxhlth > 0 then
        if pct < maxhlth then
            pct = pct / maxhlth;
        else
            pct = 1;
        end
    else
        pct = 0;
    end
    
    local r, g, b = 1.0, 1.0, 0.0;
    local a = HealBot_Config.Barcola[HealBot_Config.Current_Skin];
    if pct > HealBot_Config.AlertLevel then
        a = HealBot_Config.bardisa[HealBot_Config.Current_Skin];
    end

    local colorMode = HealBot_Config.bcolormode[HealBot_Config.Current_Skin] or 1
    if colorMode == 2 and HealBot_Model and HealBot_Model.units[unit] and HealBot_Model.units[unit].englishClass then
        local engClass = HealBot_Model.units[unit].englishClass
        if RAID_CLASS_COLORS and RAID_CLASS_COLORS[engClass] then
            r = RAID_CLASS_COLORS[engClass].r
            g = RAID_CLASS_COLORS[engClass].g
            b = RAID_CLASS_COLORS[engClass].b
        end
    else
        if pct >= 0.98 then r = 0.0; end
        if pct < 0.98 and pct >= 0.65 then r = 2.94 - (pct * 3); end 
        if pct <= 0.64 and pct > 0.31 then g = (pct - 0.31) * 3; end 
        if pct <= 0.31 then g = 0.0; end
    end
    return r, g, b, a;
end

function HealBot_Action_HealthBar(button)
    local name = button:GetName();
    return getglobal(name .. "Bar");
end

function HealBot_Action_HealthBar2(button)
    local name = button:GetName();
    return getglobal(name .. "Bar2");
end

function HealBot_Action_EnableButton(button)
    local unit = button.unit;
    local state = HealBot_Model.units[unit]
    if not state then return end
    
    local hlth = state.health
    local maxhlth = state.maxHealth
    local name = state.name
    if not name then name = UnitName(unit) end -- fallback

    local bar = HealBot_Action_HealthBar(button);
    local bar2 = HealBot_Action_HealthBar2(button);
    local bar3 = getglobal(button:GetName() .. "Bar3");
    local btexture = HealBot_Config.btexture[HealBot_Config.Current_Skin];
    local bheight = HealBot_Config.bheight[HealBot_Config.Current_Skin];
    local sr = HealBot_Config.btextenabledcolr[HealBot_Config.Current_Skin];
    local sg = HealBot_Config.btextenabledcolg[HealBot_Config.Current_Skin];
    local sb = HealBot_Config.btextenabledcolb[HealBot_Config.Current_Skin];
    local sa = HealBot_Config.btextenabledcola[HealBot_Config.Current_Skin];
    local r, g, b, a = HealBot_HealthColor(button.unit, hlth, maxhlth)
    local btextheight = HealBot_Config.btextheight[HealBot_Config.Current_Skin] or 10;
    if btextheight == 0 then btextheight = 10 end
    local bwidth = HealBot_Config.bwidth[HealBot_Config.Current_Skin]
    local textlen = math.floor(5 + (((bwidth * 1.8) / btextheight) - (btextheight / 2)))

    bar:SetMinMaxValues(0, maxhlth);
    bar:SetValue(hlth);
    
    local englishClass = state.englishClass
    local isHealer = false
    if englishClass == "PALADIN" or englishClass == "DRUID" or englishClass == "SHAMAN" or englishClass == "PRIEST" then
        isHealer = true
    end
    local pt = state.powerType
    
    local showMana = false
    if HealBot_Config.ShowManaBars == 1 and state.maxMana > 0 and pt == 0 then
        if HealBot_Config.ManaBarsHealersOnly == 1 then
            if isHealer then showMana = true end
        else
            showMana = true
        end
    end

    if showMana then
        local pr, pg, pb = 0, 0, 1
        if bar3 then
            bar3:SetMinMaxValues(0, state.maxMana)
            bar3:SetValue(state.mana)
            bar3:SetStatusBarColor(pr, pg, pb, HealBot_Config.Barcola[HealBot_Config.Current_Skin])
            HealBot_Action_SetTexture(bar3, HealBot_Config.btexture[HealBot_Config.Current_Skin])
            bar3:Show()
            bar3:SetHeight(bheight * 0.2)
        end
        bar:SetHeight(bheight * 0.8)
        bar2:SetHeight(bheight * 0.8)
    else
        if bar3 then
            bar3:Hide()
        end
        bar:SetHeight(bheight)
        bar2:SetHeight(bheight)
    end
    
    if HealBot_HealsIn[name] then
        bar2:SetMinMaxValues(0, maxhlth);
        bar2:SetValue(hlth + HealBot_HealsIn[name]);
    else
        bar2:SetValue(0);
    end
    bar.txt = getglobal(bar:GetName() .. "_text");
    if (not HealBot_IsCasting and (HealBot_CanHeal(unit) or HealBot_MissingBuffs[unit])) then
        button:Enable();
        if HealBot_UnitDebuff[unit] then
            sr = HealBot_Config.btextcursecolr[HealBot_Config.Current_Skin];
            sg = HealBot_Config.btextcursecolg[HealBot_Config.Current_Skin];
            sb = HealBot_Config.btextcursecolb[HealBot_Config.Current_Skin];
            sa = HealBot_Config.btextcursecola[HealBot_Config.Current_Skin];
        elseif HealBot_MissingBuffs[unit] then
            r = r * 0.5;
            g = g * 0.5;
            b = b * 0.5;
            sr = 1.0;
            sg = 1.0;
            sb = 0.0;
        end
        bar:SetStatusBarColor(r, g, b, HealBot_Config.Barcola[HealBot_Config.Current_Skin]);
        bar2:SetStatusBarColor(r, g, b, HealBot_Config.BarcolaInHeal[HealBot_Config.Current_Skin]);
    else
        button:Disable();
        sr = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin];
        sg = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin];
        sb = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin];
        sa = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin];
        bar:SetStatusBarColor(r, g, b, HealBot_Config.bardisa[HealBot_Config.Current_Skin]);
        bar2:SetStatusBarColor(r, g, b, HealBot_Config.bardisa[HealBot_Config.Current_Skin]);
    end
    if string.len(name) > textlen then
        name = string.sub(name, 1, textlen - 3) .. '...';
    end
    bar.txt:SetText(name);
    bar.txt:SetTextColor(sr, sg, sb, sa);
    local fontName, fontHeight, fontFlags = bar.txt:GetFont()
    local fontOutline = HealBot_Config.bfontoutline[HealBot_Config.Current_Skin] or 0
    if fontOutline == 1 then
        bar.txt:SetFont(fontName, fontHeight, "OUTLINE")
    else
        bar.txt:SetFont(fontName, fontHeight, "")
    end
      
    for i = 1, 5 do
        local icon = getglobal(button:GetName() .. "BarIcon" .. i)
        if icon then
            if HealBot_UnitIcons and HealBot_UnitIcons[unit] and HealBot_UnitIcons[unit][i] then
                icon:SetTexture(HealBot_UnitIcons[unit][i])
                icon:Show()
            else
                icon:Hide()
            end
        end
    end
end

function HealBot_Action_EnableButtons()
    table.foreach(HealBot_Action_HealButtons, function (index, button)
        HealBot_Action_EnableButton(button);
    end);
end
  
function HealBot_Action_RefreshButton(button)
    if not button then return end
    local unit = button.unit;
    if HealBot_MayHeal(unit) then
        HealBot_Action_EnableButton(button)
    end
end

function HealBot_Action_ResetSkin()
    HealBot_Action_PartyChanged()
    if HealBot_Options:IsVisible() then 
        HealBot_Action_SetTexture(HealBot_DiseaseColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_MagicColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_PoisonColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_CurseColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_EnTextColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_EnTextColorpickin, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_DisTextColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_Action_SetTexture(HealBot_DebTextColorpick, HealBot_Config.btexture[HealBot_Config.Current_Skin])
        HealBot_SetSkinColours()
    end
end

function HealBot_Action_RefreshButtons(unit)
    if unit and HealBot_Action_UnitButtons[unit] then
        table.foreach(HealBot_Action_UnitButtons[unit], function (index, button)
            HealBot_Action_RefreshButton(button);
        end);
    else
        table.foreach(HealBot_Action_HealButtons, function (index, button)
            HealBot_Action_RefreshButton(button);
        end);
    end
end

function HealBot_Action_PositionButton(button, OsetX, OsetY, bwidth, bheight, checked, header)
    local brspace = HealBot_Config.brspace[HealBot_Config.Current_Skin] or 3;
    if header then
        headerno = headerno + 1;
        local headerobj = getglobal("HealBot_Action_Header" .. headerno);
        headerobj:SetText(header)
        headerobj:Show();
        headerobj:ClearAllPoints();
        headerobj:SetHeight(bheight);
        headerobj:SetWidth(bwidth);
        headerobj:SetPoint("TOPLEFT", "HealBot_Action", "TOPLEFT", OsetX, -OsetY);
        headerobj:Disable();
        OsetY = OsetY + headerobj:GetHeight() + brspace;
    else
        local unit = button.unit;
        button:SetText(" ");
        if (HealBot_MayHeal(unit)) then
            button:Show();
            button:ClearAllPoints();
            button:SetHeight(bheight);
            if checked then
                button:SetWidth(bwidth - 14);
                button:SetPoint("TOPLEFT", "HealBot_Action", "TOPLEFT", OsetX + 14, -OsetY);
            else
                button:SetWidth(bwidth);
                button:SetPoint("TOPLEFT", "HealBot_Action", "TOPLEFT", OsetX, -OsetY);
            end
            OsetY = OsetY + button:GetHeight() + brspace;
        else
            button:Hide();
        end
    end
    return OsetY;
end

function HealBot_Action_SetHeightWidth(width, height, bwidth)
    if HealBot_ActionHeight then
        HealBot_Action:SetHeight(HealBot_ActionHeight);
    end
    if HealBot_Config.GrowUpwards == 1 then
        local left, bottom = HealBot_Action:GetLeft(), HealBot_Action:GetBottom();
        if left and bottom then
            if HealBot_Config.PanelAnchorX == -1 then HealBot_Config.PanelAnchorX = left; end
            if HealBot_Config.PanelAnchorY == -1 then HealBot_Config.PanelAnchorY = bottom; end
            HealBot_Action:ClearAllPoints();
            HealBot_Action:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", HealBot_Config.PanelAnchorX, HealBot_Config.PanelAnchorY);
        end
    else
        local left, top = HealBot_Action:GetLeft(), HealBot_Action:GetTop();
        if left and top then
            HealBot_Action:ClearAllPoints();
            HealBot_Action:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", left, top);
        end
    end
    HealBot_Action:SetHeight(height);
    HealBot_ActionHeight = height;
    local bpadding = (HealBot_Config.bpadding and HealBot_Config.bpadding[HealBot_Config.Current_Skin]) or 10
    HealBot_Action:SetWidth(width + bwidth + bpadding)
end

function HealBot_Action_SetHealButton(index, unit)
    if not index then
        HealBot_Action_HealButtons = {};
        HealBot_Action_UnitButtons = {};
        return nil
    end
    local button = getglobal("HealBot_Action_HealUnit" .. index);
    button.unit = unit;
    if unit then
        table.insert(HealBot_Action_HealButtons, button);
        if not HealBot_Action_UnitButtons[unit] then HealBot_Action_UnitButtons[unit] = {} end
        table.insert(HealBot_Action_UnitButtons[unit], button);
    else
        button:Hide();
    end
    return button;
end

function HealBot_Action_PartyChanged()
    if not HealBot_IsFighting then
        local numBars = 0;
        local numHeaders = 0;
        local TempMaxH = 0;
        local HeaderPos = {};
        
        for j = 1, 15 do
            local headerobj = getglobal("HealBot_Action_Header" .. j);
            headerobj:SetText(" ")
            headerobj:Hide();
        end

        local bwidth = HealBot_Config.bwidth[HealBot_Config.Current_Skin] or 85;
        local sr = HealBot_Config.btextdisbledcolr[HealBot_Config.Current_Skin] or 0.4;
        local sg = HealBot_Config.btextdisbledcolg[HealBot_Config.Current_Skin] or 0.4;
        local sb = HealBot_Config.btextdisbledcolb[HealBot_Config.Current_Skin] or 0.4;
        local sa = HealBot_Config.btextdisbledcola[HealBot_Config.Current_Skin] or 0.6;
        local bheight = HealBot_Config.bheight[HealBot_Config.Current_Skin] or 18;
        local btexture = HealBot_Config.btexture[HealBot_Config.Current_Skin] or 5;
        local bcspace = HealBot_Config.bcspace[HealBot_Config.Current_Skin] or 4;
        local cols = HealBot_Config.numcols[HealBot_Config.Current_Skin] or 2;
        local btextheight = HealBot_Config.btextheight[HealBot_Config.Current_Skin] or 10;
        local abortsize = HealBot_Config.abortsize[HealBot_Config.Current_Skin] or 10;
        local checked_start = 0;
        local checked_end = 0;
        headerno = 0;
        
        for j = 1, 41 do
            HealBot_Action_SetHealButton(j, nil);
        end
        for j = 51, 60 do
            HealBot_Action_SetHealButton(j, nil);
        end
        HealBot_Action_SetHealButton();
        
        local i = 0;
        local last = 0;
        local GroupValid = numBars;
        last = last + 6
        if HealBot_Config.GroupHeals == 1 then
            if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
                HeaderPos[i + 1] = HEALBOT_OPTIONS_GROUPHEALS
            end
            for _, unit in ipairs(HealBot_Action_HealGroup) do
                if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                    i = i + 1;
                    HealBot_Action_SetHealButton(i, unit);
                    numBars = numBars + 1;
                end
                if i == last then break end
            end
        end
        if numBars > GroupValid and HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
            numBars = numBars + 1;
            numHeaders = numHeaders + 1;
        end
        
        last = last + 10
        local TankValid = numBars;
        if HealBot_Config.TankHeals == 1 then
            if GetNumRaidMembers() > 0 and CT_RA_MainTanks then
                if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
                    HeaderPos[i + 1] = HEALBOT_OPTIONS_TANKHEALS
                end
                for j = 1, 10 do
                    if CT_RA_MainTanks[j] then
                        for k = 1, GetNumRaidMembers() do
                            local unit = "raid" .. k;
                            local PossibleMT = 1;
                            if UnitInParty(unit) and HealBot_Config.GroupHeals == 1 then 
                                if not UnitIsUnit(unit, "player") then
                                    PossibleMT = 0;
                                end
                            end
                            if PossibleMT == 1 then 
                                if UnitName(unit) == CT_RA_MainTanks[j] then
                                    if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                                        i = i + 1;
                                        HealBot_Action_SetHealButton(i, unit);
                                        numBars = numBars + 1;
                                    end
                                end
                            end
                        end
                    end
                    if i == last then break end
                end
            end
        end
        if numBars > TankValid and HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
            numBars = numBars + 1;
            numHeaders = numHeaders + 1;
        end
        
        last = last + 10;
        local h = 50;
        local TargetValid = numBars;
        if HealBot_Config.TargetHeals == 1 then
            if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
                HeaderPos[i + 1] = HEALBOT_OPTIONS_TARGETHEALS
            end
            for _, unit in ipairs(HealBot_Action_HealTarget) do
                if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                    i = i + 1;
                    h = h + 1;
                    if checked_start == 0 then checked_start = i; end
                    checked_end = i;
                    HealBot_Action_SetHealButton(h, unit);
                    local check = getglobal("HealBot_Action_HealUnit" .. h .. "Check");
                    check.unit = unit;
                    check:SetChecked(1);
                    check:Show();
                    numBars = numBars + 1;
                end
                if i == last then break end
            end

            last = last + 1
            local unit = HealBot_TargetName()
            if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal("target") then
                i = i + 1;
                h = h + 1;
                if h < 61 then
                    HealBot_Action_SetHealButton(h, "target");
                    local check = getglobal("HealBot_Action_HealUnit" .. h .. "Check");

                    check:SetChecked(0);
                    check.unit = unit;
                    if check.unit then
                        if checked_start == 0 then checked_start = i; end
                        checked_end = i;          
                        check:Show();
                    else
                        check:Hide();
                    end
                else
                    HealBot_Action_SetHealButton(i, "target");
                end
                numBars = numBars + 1;
            end
        end
        if numBars > TargetValid and HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
            numBars = numBars + 1;
            numHeaders = numHeaders + 1;
        end

        last = last + 40
        local ExtraValid = numBars;
        if HealBot_Config.EmergencyHeals == 1 then
            local order = {};
            local units = {};
            if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 and HealBot_Config.ExtraOrder == 1 then
                HeaderPos[i + 1] = HEALBOT_OPTIONS_EMERGENCYHEALS
                numBars = numBars + 1;
                numHeaders = numHeaders + 1;
            end
            if HealBot_Config.EmergIncMonitor == 1 then
                if GetNumRaidMembers() > 0 then
                    for j = 1, 40 do
                        local PossibleEmerg = 1;
                        local unit = "raid" .. j;
                        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(j);
                        if not name then name = "not known" end
                        if not class then class = "not known" end
                        if not subgroup then subgroup = "not known" end
                        
                        if UnitInParty(unit) and HealBot_Config.GroupHeals == 1 then
                            PossibleEmerg = 0;
                        end
                        if PossibleEmerg == 1 then 
                            if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                                if HealBot_Config.ExtraOrder == 1 then
                                    order[unit] = name;
                                elseif HealBot_Config.ExtraOrder == 2 then
                                    order[unit] = class;
                                elseif HealBot_Config.ExtraOrder == 3 then
                                    order[unit] = subgroup;
                                else
                                    order[unit] = 0 - UnitHealthMax(unit);
                                    if UnitHealthMax(unit) > TempMaxH then TempMaxH = UnitHealthMax(unit); end
                                end
                                table.insert(units, unit);
                                numBars = numBars + 1;
                            end
                        end
                    end
                else
                    for _, unit in ipairs(HealBot_Action_HealGroup) do
                        if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                            if HealBot_Config.ExtraOrder == 1 then
                                order[unit] = name;
                            elseif HealBot_Config.ExtraOrder == 2 then
                                order[unit] = class;
                            elseif HealBot_Config.ExtraOrder == 3 then
                                order[unit] = subgroup;
                            else
                                order[unit] = 0 - UnitHealthMax(unit);
                                if UnitHealthMax(unit) > TempMaxH then TempMaxH = UnitHealthMax(unit); end
                            end
                            table.insert(units, unit);
                            numBars = numBars + 1;
                        end
                    end
                end
            else
                if GetNumRaidMembers() > 0 then
                    for j = 1, 40 do
                        local unit = "raid" .. j;
                        local Class = UnitClass(unit);
                        local ProcessUnit = 0;
                        local PossibleEmerg = 1;
                        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(j);
                        if not name then name = "not known" end
                        if not class then class = "not known" end
                        if not subgroup then subgroup = "not known" end
                        
                        if HealBot_EmergInc[Class] == 1 then 
                            ProcessUnit = 1;
                        end
                        if UnitInParty(unit) and HealBot_Config.GroupHeals == 1 then
                            PossibleEmerg = 0;
                        end

                        if ProcessUnit == 1 and PossibleEmerg == 1 then
                            if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                                if HealBot_Config.ExtraOrder == 1 then
                                    order[unit] = name;
                                elseif HealBot_Config.ExtraOrder == 2 then
                                    order[unit] = class;
                                elseif HealBot_Config.ExtraOrder == 3 then
                                    order[unit] = subgroup;
                                else
                                    order[unit] = 0 - UnitHealthMax(unit);
                                    if UnitHealthMax(unit) > TempMaxH then TempMaxH = UnitHealthMax(unit); end
                                end
                                table.insert(units, unit);
                                numBars = numBars + 1;
                            end
                        end
                    end
                else
                    for _, unit in ipairs(HealBot_Action_HealGroup) do
                        if not HealBot_Action_UnitButtons[unit] and HealBot_MayHeal(unit) then
                            if HealBot_Config.ExtraOrder == 1 then
                                order[unit] = name;
                            elseif HealBot_Config.ExtraOrder == 2 then
                                order[unit] = class;
                            elseif HealBot_Config.ExtraOrder == 3 then
                                order[unit] = subgroup;
                            else
                                order[unit] = 0 - UnitHealthMax(unit);
                                if UnitHealthMax(unit) > TempMaxH then TempMaxH = UnitHealthMax(unit); end
                            end
                            table.insert(units, unit);
                            numBars = numBars + 1;
                        end
                    end
                end
            end
            table.sort(units, function (a, b)
                if order[a] < order[b] then return true end
                if order[a] > order[b] then return false end
                return a < b
            end)
            local TempSort = "init"
            TempMaxH = math.ceil(TempMaxH / 1000) * 1000;
            
            if GetNumRaidMembers() > 0 then
                for j = 1, 40 do
                    if not units[j] then break end
                    local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(string.sub(units[j], 5));
                    if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 and HealBot_Config.ExtraOrder == 2 and TempSort ~= class then 
                        TempSort = class
                        HeaderPos[i + 1] = class
                        numBars = numBars + 1;
                        numHeaders = numHeaders + 1;
                    end
                    if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 and HealBot_Config.ExtraOrder == 3 and TempSort ~= subgroup then
                        TempSort = subgroup
                        HeaderPos[i + 1] = HEALBOT_OPTIONS_GROUPHEALS .. subgroup
                        numBars = numBars + 1;
                        numHeaders = numHeaders + 1;
                    end
                    if HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 and HealBot_Config.ExtraOrder == 4 and TempMaxH > UnitHealthMax(units[j]) then
                        TempMaxH = TempMaxH - 1000
                        HeaderPos[i + 1] = ">" .. tostring(TempMaxH / 1000) .. "k"
                        numBars = numBars + 1;
                        numHeaders = numHeaders + 1;
                    end
                    i = i + 1;
                    HealBot_Action_SetHealButton(i, units[j]);
                    if i == last then break end
                end
            end
        end
        if numBars == ExtraValid + 1 and HealBot_Config.ShowHeader[HealBot_Config.Current_Skin] == 1 then
            HeaderPos[i + 1] = nil;
            numBars = numBars - 1;
        end
      
        local bpadding = (HealBot_Config.bpadding and HealBot_Config.bpadding[HealBot_Config.Current_Skin]) or 10
        local OffsetY = bpadding;
        local OffsetX = bpadding;
        local MaxOffsetY = 0;
        
        if cols > (numBars - numHeaders) then
            cols = numBars - numHeaders;
        end
        if cols <= 0 then cols = 1 end

        local h = 1;
        local i = 0;
        local z = 1;
        
        table.foreach(HealBot_Action_HealButtons, function (index, button)
            i = i + 1;
            local checked = false;
            local header;

            if HeaderPos[i] then
                header = HeaderPos[i];
                OffsetY = HealBot_Action_PositionButton(nil, OffsetX, OffsetY, bwidth, bheight, checked, header);
                if h == math.ceil((numBars) / cols) and z < numBars then
                    h = 0;
                    if MaxOffsetY < OffsetY then MaxOffsetY = OffsetY; end
                    OffsetY = bpadding;
                    OffsetX = OffsetX + bwidth + bcspace; 
                end
                h = h + 1;
                z = z + 1;
            end

            if checked_start <= i and checked_end >= i then checked = true; end
            OffsetY = HealBot_Action_PositionButton(button, OffsetX, OffsetY, bwidth, bheight, checked, nil);
            if h == math.ceil((numBars) / cols) and z < numBars then
                h = 0;
                if MaxOffsetY < OffsetY then MaxOffsetY = OffsetY; end
                OffsetY = bpadding;
                OffsetX = OffsetX + bwidth + bcspace; 
            end
            z = z + 1;
            h = h + 1;
            local bar = HealBot_Action_HealthBar(button);
            local bar2 = HealBot_Action_HealthBar2(button);
            bar.txt = getglobal(bar:GetName() .. "_text");
            bar:SetHeight(bheight);
            HealBot_Action_SetTexture(bar, btexture);
            bar.txt:SetTextHeight(btextheight);
            local barScale = bar:GetScale();
            bar:SetScale(barScale + 0.01);
            bar:SetScale(barScale);
            bar2:SetHeight(bheight);
            HealBot_Action_SetTexture(bar2, btexture);
        end);

        if MaxOffsetY < OffsetY then MaxOffsetY = OffsetY; end

        if HealBot_Config.HideOptions == 1 then
            HealBot_Action_OptionsButton:Hide();
        else
            HealBot_Action_OptionsButton:SetPoint("BOTTOM", "HealBot_Action", "BOTTOM", 0, bpadding);
            HealBot_Action_OptionsButton:Show();
            MaxOffsetY = MaxOffsetY + 30;
        end  
        
        if HealBot_Config.HideAbort == 1 then
            HealBot_Action_AbortButton:Hide();
        else
            local bar = HealBot_Action_HealthBar(HealBot_Action_AbortButton);
            local denom = 6 - (abortsize / 3)
            if denom == 0 then denom = 1 end
            local width = (bwidth - 12) + (OffsetX / denom);

            bar.txt = getglobal(bar:GetName() .. "_text");
            bar.txt:SetTextColor(sr, sg, sb, sa);
            bar.txt:SetText(HEALBOT_ACTION_ABORT);
            HealBot_Action_SetTexture(bar, btexture);
            bar:SetMinMaxValues(0, 100);
            bar:SetValue(100);
            bar:ClearAllPoints();
            bar:SetHeight(bheight + abortsize);
            bar:SetWidth(width);
            bar:SetStatusBarColor(0.1, 0.1, 0.4, 0);
            MaxOffsetY = MaxOffsetY + 30 + abortsize;
            HealBot_Action_AbortButton:ClearAllPoints();
            HealBot_Action_AbortButton:SetWidth(width)
            HealBot_Action_AbortButton:SetHeight(bheight + abortsize);
            if HealBot_Config.HideOptions == 1 then
                HealBot_Action_AbortButton:SetPoint("BOTTOM", "HealBot_Action", "BOTTOM", 0, bpadding);
                bar:SetPoint("BOTTOM", "HealBot_Action", "BOTTOM", 0, bpadding);
            else
                HealBot_Action_AbortButton:SetPoint("BOTTOM", "HealBot_Action_OptionsButton", "TOP", 0, 10);
                bar:SetPoint("BOTTOM", "HealBot_Action_OptionsButton", "TOP", 0, 10);
            end    
            HealBot_Action_AbortButton:Show();
        end

        HealBot_Action_SetHeightWidth(OffsetX, MaxOffsetY + bpadding, bwidth);
    end
    HealBot_Action_RefreshButtons();
end

function HealBot_Action_Reset()
    HealBot_Action:ClearAllPoints();
    HealBot_Action:SetPoint("TOP", "MinimapCluster", "BOTTOM", 7, 10);
    HealBot_Action_HealTarget = {};
    HealBot_Action_PartyChanged();
end

function HealBot_Action_Refresh(unit)
    if (UnitIsDeadOrGhost("player")) or (UnitOnTaxi("player")) then
        if HealBot_Config.AutoClose == 1 and HealBot_Config.ActionVisible ~= 0 then 
            HealBot_Action:Hide(); 
        else
            HealBot_Action_RefreshButtons(unit);
        end
        return;
    end
    HealBot_Action_RefreshButtons(unit);
    if not HealBot_IsFighting then
        if (HealBot_Action_MustHealSome()) then
            HealBot_Action:Show();
        elseif HealBot_AbortButton == 0 then
            HealBot_Action:Show();
        elseif (not HealBot_Action_ShouldHealSome()) then
            if HealBot_AbortButton == 1 and HealBot_Config.AutoClose == 1 and HealBot_Config.ActionVisible ~= 0 then 
                HealBot_Action:Hide();
            end
        end
    end
end
