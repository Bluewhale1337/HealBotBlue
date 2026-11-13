-- HealBot_View_Bars.lua
-- Status bar rendering, color calculations, button styling, and debuff pulsing

local HealBot_AnimTimer = 0
local HealBot_BarFrame_Backdrop = {
    tile = false,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- HealBot_Action_SetTexture: Internal utility: HealBot_Action_SetTexture
function HealBot_Action_SetTexture(bar, btexture)
    if not bar then return end
    if btexture == 10 then
        bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8");
    else
        bar:SetStatusBarTexture("Interface\\AddOns\\HealBotBlue\\Images\\bar" .. tostring(btexture) .. ".tga");
    end
end

-- HealBot_HealthColor: Computes health bar RGBA based on debuffs and class.
function HealBot_HealthColor(unit, hlth, maxhlth)
    local cached_debuff = HealBot_UnitDebuff[unit]
    local overlayMode = HealBot_Config.CDCOverlay or 1
    if cached_debuff and overlayMode == 1 then
        local color = HealBot_Config.CDCBarColour[cached_debuff]
        if color then
            local dr = color.R
            local dg = color.G
            local db = color.B
            return dr, dg, db, HealBot_Config.Barcola[HealBot_Config.Current_Skin];
        end
        return dr, dg, db, HealBot_Config.Barcola[HealBot_Config.Current_Skin];
    end
    
    local text
    if string.find(unit, "^Test") then
        text = HealBot_Model.units[unit] and HealBot_Model.units[unit].name or unit
    else
        text = UnitName(unit) or unit
    end
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
    local engClass = nil
    if colorMode == 2 and not string.find(unit, "pet") then
        engClass = HealBot_Model and HealBot_Model.units[unit] and HealBot_Model.units[unit].englishClass
        if not engClass then
            engClass = HealBot_UnitClass(unit)
            if engClass and HealBot_Model and HealBot_Model.units[unit] then
                HealBot_Model.units[unit].englishClass = engClass
            end
        end
    end

    if colorMode == 2 and string.find(unit, "pet") then
        r, g, b = 0.4, 0.9, 0.6 -- Mint color
    elseif colorMode == 2 and engClass and RAID_CLASS_COLORS and RAID_CLASS_COLORS[engClass] then
        r = RAID_CLASS_COLORS[engClass].r
        g = RAID_CLASS_COLORS[engClass].g
        b = RAID_CLASS_COLORS[engClass].b
    else
        local skin = HealBot_Config.Current_Skin
        local maxR = HealBot_Config.bcolormaxr and HealBot_Config.bcolormaxr[skin] or 0.0
        local maxG = HealBot_Config.bcolormaxg and HealBot_Config.bcolormaxg[skin] or 1.0
        local maxB = HealBot_Config.bcolormaxb and HealBot_Config.bcolormaxb[skin] or 0.0

        local minR = HealBot_Config.bcolorminr and HealBot_Config.bcolorminr[skin] or 1.0
        local minG = HealBot_Config.bcolorming and HealBot_Config.bcolorming[skin] or 0.0
        local minB = HealBot_Config.bcolorminb and HealBot_Config.bcolorminb[skin] or 0.0

        if maxR == 0 and maxG == 1 and maxB == 0 and minR == 1 and minG == 0 and minB == 0 then
            if pct >= 0.98 then r = 0.0; end
            if pct < 0.98 and pct >= 0.65 then r = 2.94 - (pct * 3); end 
            if pct <= 0.64 and pct > 0.31 then g = (pct - 0.31) * 3; end 
            if pct <= 0.31 then g = 0.0; end
        else
            r = minR + (maxR - minR) * pct
            g = minG + (maxG - minG) * pct
            b = minB + (maxB - minB) * pct
        end
    end
    return r, g, b, a;
end

-- HealBot_Action_HealthBar: Internal utility: HealBot_Action_HealthBar
function HealBot_Action_HealthBar(button)
    if not button.bar then
        button.bar = getglobal(button:GetName() .. "Bar")
    end
    return button.bar;
end

-- HealBot_Action_HealthBar2: Internal utility: HealBot_Action_HealthBar2
function HealBot_Action_HealthBar2(button)
    if not button.bar2 then
        button.bar2 = getglobal(button:GetName() .. "Bar2")
    end
    return button.bar2;
end

-- HealBot_Action_EnableButton: Updates a button's health, color, text, and debuffs.
function HealBot_Action_EnableButton(button)
    local unit = button.unit;
    local state = HealBot_Model.units[unit]
    if not state then return end
    
    if not state.englishClass then
        HealBot_Model:UpdateUnitIdentity(unit)
    end
    
    local hlth = state.health
    local maxhlth = state.maxHealth
    local name = state.name
    if not name then name = UnitName(unit) end -- fallback
    
    if not name or name == "Unknown" then
        button:Hide()
        return
    end

    local bar = HealBot_Action_HealthBar(button);
    local bar2 = HealBot_Action_HealthBar2(button);
    if not button.bar3 then button.bar3 = getglobal(button:GetName() .. "Bar3") end
    local bar3 = button.bar3;
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
    local pr, pg, pb = 0, 0, 1 -- Default Blue for Mana
    
    if HealBot_Config.ShowManaBars == 1 and state.maxMana > 0 then
        if pt == 0 then
            if HealBot_Config.ManaBarsHealersOnly == 1 then
                if isHealer then showMana = true end
            else
                showMana = true
            end
        elseif HealBot_Config.ShowNonManaBars == 1 then
            showMana = true
            if pt == 1 then pr, pg, pb = 1, 0, 0 -- Rage (Red)
            elseif pt == 3 then pr, pg, pb = 1, 1, 0 -- Energy (Yellow)
            elseif pt == 2 then pr, pg, pb = 1, 0.5, 0 -- Focus (Orange)
            end
        end
    end

    if showMana then
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
    if not bar.txt then bar.txt = getglobal(bar:GetName() .. "_text") end
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

    if not button.debuffOverlay then
        button.debuffOverlay = getglobal(button:GetName() .. "DebuffOverlay")
    end
    if not button.debuffGlow then
        button.debuffGlow = getglobal(button:GetName() .. "DebuffOverlayGlow")
    end

    if button.debuffOverlay then
        local debuffType = HealBot_UnitDebuff[unit]
        local isDead = state.isDead or state.isGhost or (not string.find(unit, "^Test") and UnitIsDeadOrGhost(unit))
        local overlayMode = HealBot_Config.CDCOverlay or 1
        local skin = HealBot_Config.Current_Skin
        local hasBarFrame = (HealBot_Config.bframe and HealBot_Config.bframe[skin] == 1)
        local bfr = (HealBot_Config.bframecolr and HealBot_Config.bframecolr[skin]) or 1.0
        local bfg = (HealBot_Config.bframecolg and HealBot_Config.bframecolg[skin]) or 1.0
        local bfb = (HealBot_Config.bframecolb and HealBot_Config.bframecolb[skin]) or 1.0
        local bfa = (HealBot_Config.bframecola and HealBot_Config.bframecola[skin]) or 1.0

        local alphaBorder = 1.0
        local alphaOverlay = 1.0
        if not button:IsEnabled() then
            local disAlpha = HealBot_Config.bardisa[skin] or 0.4
            alphaBorder = disAlpha
            alphaOverlay = disAlpha
            bfa = bfa * disAlpha
        end

        if debuffType and not isDead and overlayMode > 1 and overlayMode < 7 then
            local color = HealBot_Config.CDCBarColour[debuffType]
            local cr, cg, cb = 1, 0, 0
            if color then
                cr, cg, cb = color.R, color.G, color.B
            end

            button.debuffOverlay:SetFrameLevel(bar:GetFrameLevel() + 2)
            button.debuffOverlay:Show()

            if overlayMode == 2 then
                button.isAnimatedDebuff = false
                button.debuffOverlay:SetBackdropBorderColor(cr, cg, cb, alphaBorder)
                if button.debuffGlow then
                    button.debuffGlow:Hide()
                    button.debuffGlow:SetTexCoord(0, 1, 0, 1)
                end
            elseif overlayMode == 3 then
                button.isAnimatedDebuff = false
                if hasBarFrame then
                    button.debuffOverlay:SetBackdropBorderColor(bfr, bfg, bfb, bfa)
                else
                    button.debuffOverlay:SetBackdropBorderColor(0, 0, 0, 0)
                end
                if button.debuffGlow then
                    local glowTex = HealBot_Config.CDCOverlayTexture or "Interface\\AddOns\\HealBotBlue\\Images\\glow1.tga"
                    button.debuffGlow:SetTexture(glowTex)
                    button.debuffGlow:SetBlendMode("BLEND")
                    button.debuffGlow:SetTexCoord(0, 1, 0, 1)
                    button.debuffGlow:SetVertexColor(cr, cg, cb, alphaOverlay)
                    button.debuffGlow:Show()
                end
            elseif overlayMode == 4 then
                button.isAnimatedDebuff = false
                button.debuffOverlay:SetBackdropBorderColor(cr, cg, cb, alphaBorder)
                if button.debuffGlow then
                    local glowTex = HealBot_Config.CDCOverlayTexture or "Interface\\AddOns\\HealBotBlue\\Images\\glow1.tga"
                    button.debuffGlow:SetTexture(glowTex)
                    button.debuffGlow:SetBlendMode("BLEND")
                    button.debuffGlow:SetTexCoord(0, 1, 0, 1)
                    button.debuffGlow:SetVertexColor(cr, cg, cb, alphaOverlay)
                    button.debuffGlow:Show()
                end
            elseif overlayMode == 5 then -- Animated
                if hasBarFrame then
                    button.debuffOverlay:SetBackdropBorderColor(bfr, bfg, bfb, bfa)
                else
                    button.debuffOverlay:SetBackdropBorderColor(0, 0, 0, 0)
                end
                if button.debuffGlow then
                    local glowTex
                    if debuffType == HEALBOT_POISON_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_poison.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_CURSE_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_curse.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_DISEASE_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_disease.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_MAGIC_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_magic.tga"
                        button.isAnimatedDebuff = true
                    else
                        glowTex = HealBot_Config.CDCOverlayTexture or "Interface\\AddOns\\HealBotBlue\\Images\\glow1.tga"
                        button.isAnimatedDebuff = false
                        button.debuffGlow:SetTexCoord(0, 1, 0, 1)
                    end
                    button.debuffGlow:SetTexture(glowTex)
                    button.debuffGlow:SetBlendMode("BLEND")
                    button.debuffGlow:SetVertexColor(cr, cg, cb, alphaOverlay)
                    button.debuffGlow:Show()
                end
            elseif overlayMode == 6 then -- Animated + Frame
                button.debuffOverlay:SetBackdropBorderColor(cr, cg, cb, alphaBorder)
                if button.debuffGlow then
                    local glowTex
                    if debuffType == HEALBOT_POISON_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_poison.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_CURSE_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_curse.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_DISEASE_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_disease.tga"
                        button.isAnimatedDebuff = true
                    elseif debuffType == HEALBOT_MAGIC_en then
                        glowTex = "Interface\\AddOns\\HealBotBlue\\Images\\debuff_magic.tga"
                        button.isAnimatedDebuff = true
                    else
                        glowTex = HealBot_Config.CDCOverlayTexture or "Interface\\AddOns\\HealBotBlue\\Images\\glow1.tga"
                        button.isAnimatedDebuff = false
                        button.debuffGlow:SetTexCoord(0, 1, 0, 1)
                    end
                    button.debuffGlow:SetTexture(glowTex)
                    button.debuffGlow:SetBlendMode("BLEND")
                    button.debuffGlow:SetVertexColor(cr, cg, cb, alphaOverlay)
                    button.debuffGlow:Show()
                end
            end
        else
            button.isAnimatedDebuff = false
            if button.debuffGlow then
                button.debuffGlow:Hide()
                button.debuffGlow:SetTexCoord(0, 1, 0, 1)
            end
            if hasBarFrame and not isDead then
                button.debuffOverlay:SetFrameLevel(bar:GetFrameLevel() + 2)
                button.debuffOverlay:SetBackdropBorderColor(bfr, bfg, bfb, bfa)
                button.debuffOverlay:Show()
            else
                button.debuffOverlay:Hide()
            end
        end
    end

    local healthTextOpt = HealBot_Config.ShowHealthText or 0
    local displayText = name
    if healthTextOpt == 1 then
        local pct = 0
        if maxhlth > 0 then pct = math.floor((hlth / maxhlth) * 100) end
        displayText = name .. " - " .. pct .. "%"
    elseif healthTextOpt == 2 then
        displayText = name .. " - " .. hlth .. "/" .. maxhlth
    elseif healthTextOpt == 3 then
        local deficit = maxhlth - hlth
        if deficit > 0 then
            displayText = name .. " - -" .. deficit
        end
    end

    if string.len(displayText) > textlen then
        if healthTextOpt > 0 then
            -- If we have numbers, just truncate the name part so the numbers still show.
            -- Find where " - " starts.
            local dashIndex = string.find(displayText, " %- ")
            if dashIndex then
                local numbersPart = string.sub(displayText, dashIndex)
                local namePart = string.sub(name, 1, math.max(1, textlen - string.len(numbersPart) - 3)) .. "..."
                displayText = namePart .. numbersPart
            end
        else
            displayText = string.sub(name, 1, textlen - 3) .. '...';
        end
    end
    bar.txt:SetText(displayText);
    bar.txt:SetTextColor(sr, sg, sb, sa);
    local fontName, fontHeight, fontFlags = bar.txt:GetFont()
    local btextheight = (HealBot_Config.btextheight and HealBot_Config.btextheight[HealBot_Config.Current_Skin]) or 10
    local fontHeightToUse = (fontHeight and fontHeight >= 6) and fontHeight or btextheight
    local fontOutline = HealBot_Config.bfontoutline[HealBot_Config.Current_Skin] or 0
    local expectedFlags = fontOutline == 1 and "OUTLINE" or ""
    local expectedFont = (HealBot_Config.bfont and HealBot_Config.bfont[HealBot_Config.Current_Skin]) or fontName
    if fontFlags ~= expectedFlags or fontName ~= expectedFont or (fontHeight and fontHeight < 6) then
        bar.txt:SetFont(expectedFont, fontHeightToUse, expectedFlags)
    end
      
    local iconSize = HealBot_Config.biconsize[HealBot_Config.Current_Skin] or 12
    local dMode = HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode or 0
    local overlayMode = (HealBot_Config.HealBot_Integrations_ShowHoTTimers == 1) and (dMode == 1 or dMode == 2)
    local unitMap = overlayMode and HealBot_ActiveHoTUnitMap and (HealBot_ActiveHoTUnitMap[unit] or (name and HealBot_ActiveHoTUnitMap[name]))
    
    for i = 1, 10 do
        local icon = button["icon"..i]
        if not icon then
            icon = getglobal(button:GetName() .. "BarIcon" .. i)
            button["icon"..i] = icon
        end
        if icon then
            if button["iconText"..i] then
                button["iconText"..i]:Hide()
                button["iconText"..i] = nil
            end

            local iconText = bar["iconText"..i]

            if HealBot_UnitIcons and HealBot_UnitIcons[unit] and HealBot_UnitIcons[unit][i] then
                local currentTexture = icon:GetTexture()
                local newTexture = HealBot_UnitIcons[unit][i]
                if currentTexture ~= newTexture then
                    icon:SetTexture(newTexture)
                end
                
                if icon:GetWidth() ~= iconSize then
                    icon:SetWidth(iconSize)
                    icon:SetHeight(iconSize)
                    if iconText then
                        iconText:SetFont("Fonts\\ARIALN.TTF", math.min(11, math.max(8, iconSize - 2)), "OUTLINE")
                    end
                end
                
                if not icon:IsVisible() then
                    icon:Show()
                end

                if overlayMode then
                    if not iconText then
                        local overlayFrame = bar.overlayFrame
                        if not overlayFrame then
                            overlayFrame = CreateFrame("Frame", nil, bar)
                            overlayFrame:SetAllPoints(bar)
                            overlayFrame:SetFrameLevel(bar:GetFrameLevel() + 5)
                            bar.overlayFrame = overlayFrame
                        end
                        iconText = overlayFrame:CreateFontString(nil, "OVERLAY")
                        iconText:SetFont("Fonts\\ARIALN.TTF", math.min(11, math.max(8, iconSize - 2)), "OUTLINE")
                        iconText:SetPoint("CENTER", icon, "CENTER", 0, 0)
                        iconText:SetTextColor(1, 1, 1, 1)
                        bar["iconText"..i] = iconText
                    end
                    local cleanTex = newTexture and string.lower(string.gsub(newTexture, "/", "\\"))
                    local shortTex = cleanTex and string.match(cleanTex, "([^\\]+)$")
                    local timeLeft = unitMap and (unitMap[newTexture] or (cleanTex and unitMap[cleanTex]) or (shortTex and unitMap[shortTex]))
                    if timeLeft then
                        if bar.overlayFrame then bar.overlayFrame:Show() end
                        iconText:SetText(timeLeft)
                        iconText:Show()
                    else
                        if iconText and iconText:IsVisible() then
                            iconText:SetText("")
                            iconText:Hide()
                        end
                    end
                elseif iconText and iconText:IsVisible() then
                    iconText:SetText("")
                    iconText:Hide()
                end
            else
                if icon:IsVisible() then
                    icon:Hide()
                end
                if iconText and iconText:IsVisible() then
                    iconText:Hide()
                end
            end
        end
    end
    
    local raidIcon = getglobal(button:GetName() .. "BarRaidIcon")
    if raidIcon then
        local index
        if not string.find(unit, "^Test") then
            index = GetRaidTargetIndex(unit)
        end
        if index then
            SetRaidTargetIconTexture(raidIcon, index)
            raidIcon:Show()
        else
            raidIcon:Hide()
        end
    end
end

local HealBot_AnimTimer = 0
local HealBot_AnimFrame = 0

-- HealBot_Action_UpdateDebuffAnimation: Advances animated overlay frames on active debuffed buttons.
function HealBot_Action_UpdateDebuffAnimation(elapsed)
    if not HealBot_Config or (HealBot_Config.CDCOverlay ~= 5 and HealBot_Config.CDCOverlay ~= 6) then return end

    HealBot_AnimTimer = HealBot_AnimTimer + elapsed
    if HealBot_AnimTimer < 0.066 then return end -- ~15 FPS
    HealBot_AnimTimer = 0

    HealBot_AnimFrame = math.mod(HealBot_AnimFrame + 1, 16)
    local col = math.mod(HealBot_AnimFrame, 2)
    local row = math.floor(HealBot_AnimFrame / 2)
    local left = col * 0.5
    local right = left + 0.5
    local top = row * 0.125
    local bottom = top + 0.125

    for _, button in pairs(HealBot_Action_HealButtons) do
        if button and button.isAnimatedDebuff and button.debuffOverlay and button.debuffOverlay:IsVisible() and button.debuffGlow and button.debuffGlow:IsVisible() then
            button.debuffGlow:SetTexCoord(left, right, top, bottom)
        end
    end
end

-- HealBot_Action_EnableButtons: Internal utility: HealBot_Action_EnableButtons
function HealBot_Action_EnableButtons()
    for index, button in pairs(HealBot_Action_HealButtons) do
        HealBot_Action_EnableButton(button)
    end
end
  
-- HealBot_Action_RefreshButton: Calls EnableButton if unit is valid.
function HealBot_Action_RefreshButton(button)
    if not button then return end
    local unit = button.unit;
    if HealBot_MayHeal(unit) then
        HealBot_Action_EnableButton(button)
    end
end

-- HealBot_Action_ResetSkin: Internal utility: HealBot_Action_ResetSkin
function HealBot_Action_ResetSkin()
    HealBot_Action_PartyChanged()
    local skin = HealBot_Config.Current_Skin
    local bfont = (HealBot_Config.bfont and HealBot_Config.bfont[skin]) or "Fonts\\FRIZQT__.TTF"
    local btextheight = (HealBot_Config.btextheight and HealBot_Config.btextheight[skin]) or 10
    local fontOutline = (HealBot_Config.bfontoutline and HealBot_Config.bfontoutline[skin]) or 0
    local expectedFlags = fontOutline == 1 and "OUTLINE" or ""

    local borderStyle = (HealBot_Config.bborder and HealBot_Config.bborder[skin]) or 2
    local width = (HealBot_Config.bframewidth and HealBot_Config.bframewidth[skin]) or 10
    local edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"
    if borderStyle == 1 then
        edgeFile = "Interface\\Buttons\\WHITE8X8"
    end
    HealBot_BarFrame_Backdrop.edgeFile = edgeFile
    HealBot_BarFrame_Backdrop.edgeSize = width

    for i = 1, 84 do
        local btn = getglobal("HealBot_Action_HealUnit" .. i)
        if btn then
            if not btn.debuffOverlay then
                btn.debuffOverlay = getglobal(btn:GetName() .. "DebuffOverlay")
            end
            if btn.debuffOverlay then
                btn.debuffOverlay:SetBackdrop(HealBot_BarFrame_Backdrop)
            end
        end
    end

    if HealBot_Action_OptionsButton and HealBot_Action_OptionsButton:GetFontString() then
        HealBot_Action_OptionsButton:GetFontString():SetFont(bfont, btextheight, expectedFlags)
    end
    if HealBot_Action_AbortButton and HealBot_Action_AbortButton:GetFontString() then
        HealBot_Action_AbortButton:GetFontString():SetFont(bfont, btextheight, expectedFlags)
    end
    for j = 1, 20 do
        local headerobj = getglobal("HealBot_Action_Header" .. j)
        if headerobj and headerobj:GetFontString() then
            headerobj:GetFontString():SetFont(bfont, btextheight, expectedFlags)
        end
    end

    if HealBot_Options:IsVisible() then 
        HealBot_Action_SetTexture(HealBot_DiseaseColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_MagicColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_PoisonColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_CurseColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_EnTextColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_EnTextColorpickin, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_DisTextColorpick, HealBot_Config.btexture[skin])
        HealBot_Action_SetTexture(HealBot_DebTextColorpick, HealBot_Config.btexture[skin])
        if HealBot_BarFrameColorpick then
            HealBot_Action_SetTexture(HealBot_BarFrameColorpick, HealBot_Config.btexture[skin])
        end
        HealBot_SetSkinColours()
    end
    HealBot_Action_EnableButtons()
end

-- HealBot_Action_RefreshButtons: Refreshes all active unit buttons.
function HealBot_Action_RefreshButtons(unit)
    if unit and HealBot_Action_UnitButtons[unit] then
        for index, button in pairs(HealBot_Action_UnitButtons[unit]) do
            HealBot_Action_RefreshButton(button)
        end
    else
        for index, button in pairs(HealBot_Action_HealButtons) do
            HealBot_Action_RefreshButton(button)
        end
    end
end

-- HealBot_Action_RefreshPower: Fast path: updates only mana bar textures.
function HealBot_Action_RefreshPower(unit)
    if not unit or not HealBot_Action_UnitButtons[unit] then return end
    local state = HealBot_Model.units[unit]
    if not state then return end
    
    for index, button in pairs(HealBot_Action_UnitButtons[unit]) do
        if not button.bar3 then button.bar3 = getglobal(button:GetName() .. "Bar3") end
        local bar3 = button.bar3
        if bar3 and bar3:IsVisible() then
            bar3:SetMinMaxValues(0, state.maxMana)
            bar3:SetValue(state.mana)
        end
    end
end

