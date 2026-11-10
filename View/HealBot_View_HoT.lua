-- HealBot_View_HoT.lua
-- HoT overlays, duration timers, and side list rendering

local HealBot_PlayerHoTsListFrame = nil
local HealBot_PlayerHoTFrames = {}
local HealBot_PlayerHoTs_ListCache = {}
HealBot_ActiveHoTUnitMap = HealBot_ActiveHoTUnitMap or {}

local function HealBot_PlayerHoTs_SortComparator(a, b)
    return (a.expires or 0) < (b.expires or 0)
end

-- Reposition the HoT timer list frame based on config
local function HealBot_HoTTimerList_Reanchor()
    if not HealBot_PlayerHoTsListFrame then return end
    local pos = HealBot_Config.HealBot_Integrations_HoTTimerPosition or "BELOW"
    HealBot_PlayerHoTsListFrame:ClearAllPoints()
    if pos == "ABOVE" then
        HealBot_PlayerHoTsListFrame:SetPoint("BOTTOMLEFT", HealBot_Action, "TOPLEFT", 0, 2)
    elseif pos == "RIGHT" then
        HealBot_PlayerHoTsListFrame:SetPoint("TOPLEFT", HealBot_Action, "TOPRIGHT", 2, 0)
    elseif pos == "LEFT" then
        HealBot_PlayerHoTsListFrame:SetPoint("TOPRIGHT", HealBot_Action, "TOPLEFT", -2, 0)
    else -- BELOW (default)
        HealBot_PlayerHoTsListFrame:SetPoint("TOPLEFT", HealBot_Action, "BOTTOMLEFT", 0, -2)
    end
end

-- Reposition child HoT frames for stacking direction
local function HealBot_HoTTimerList_StackChild(frame, index)
    local pos = HealBot_Config.HealBot_Integrations_HoTTimerPosition or "BELOW"
    frame:ClearAllPoints()
    if pos == "ABOVE" then
        if index == 1 then
            frame:SetPoint("BOTTOMLEFT", HealBot_PlayerHoTsListFrame, "BOTTOMLEFT", 0, 0)
        else
            frame:SetPoint("BOTTOMLEFT", HealBot_PlayerHoTFrames[index-1], "TOPLEFT", 0, 2)
        end
    else
        if index == 1 then
            frame:SetPoint("TOPLEFT", HealBot_PlayerHoTsListFrame, "TOPLEFT", 0, 0)
        else
            frame:SetPoint("TOPLEFT", HealBot_PlayerHoTFrames[index-1], "BOTTOMLEFT", 0, -2)
        end
    end
end

-- Clear all icon overlay timer texts
function HealBot_ClearHoTOverlays()
    HealBot_Overlays_Active = false
    if not HealBot_Action_UnitButtons then return end
    for unit, btnList in pairs(HealBot_Action_UnitButtons) do
        for _, button in pairs(btnList) do
            local bar = HealBot_Action_HealthBar(button)
            if bar then
                for i = 1, 10 do
                    local iconText = bar["iconText"..i]
                    if iconText and iconText:IsVisible() then
                        iconText:SetText("")
                        iconText:Hide()
                    end
                end
            end
        end
    end
end

-- Render countdown numbers directly on unit bar icons
function HealBot_RenderHoTOverlays()
    if not HealBot_Action_UnitButtons then return end
    HealBot_Overlays_Active = true
    local iconSize = HealBot_Config.biconsize[HealBot_Config.Current_Skin] or 12
    local fontSize = math.min(11, math.max(8, iconSize - 2))

    for unit, btnList in pairs(HealBot_Action_UnitButtons) do
        local unitMap = HealBot_ActiveHoTUnitMap[unit] or (UnitName(unit) and HealBot_ActiveHoTUnitMap[UnitName(unit)])
        for _, button in pairs(btnList) do
            local bar = HealBot_Action_HealthBar(button)
            if bar and bar:IsVisible() then
                for i = 1, 10 do
                    local icon = button["icon"..i] or getglobal(button:GetName() .. "BarIcon" .. i)
                    local iconText = bar["iconText"..i]
                    if icon and icon:IsVisible() then
                        local tex = icon:GetTexture()
                        local cleanTex = tex and string.lower(string.gsub(tex, "/", "\\"))
                        local shortTex = cleanTex and string.match(cleanTex, "([^\\]+)$")
                        local timeLeft = unitMap and (unitMap[tex] or (cleanTex and unitMap[cleanTex]) or (shortTex and unitMap[shortTex]))
                        if timeLeft then
                            if not iconText then
                                local overlayFrame = bar.overlayFrame
                                if not overlayFrame then
                                    overlayFrame = CreateFrame("Frame", nil, bar)
                                    overlayFrame:SetAllPoints(bar)
                                    overlayFrame:SetFrameLevel(bar:GetFrameLevel() + 5)
                                    bar.overlayFrame = overlayFrame
                                end
                                iconText = overlayFrame:CreateFontString(nil, "OVERLAY")
                                iconText:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
                                iconText:SetPoint("CENTER", icon, "CENTER", 0, 0)
                                iconText:SetTextColor(1, 1, 1, 1)
                                bar["iconText"..i] = iconText
                            end
                            if bar.overlayFrame then bar.overlayFrame:Show() end
                            iconText:SetText(timeLeft)
                            iconText:Show()
                        else
                            if iconText and iconText:IsVisible() then
                                iconText:SetText("")
                                iconText:Hide()
                            end
                        end
                    else
                        if iconText and iconText:IsVisible() then
                            iconText:Hide()
                        end
                    end
                end
            end
        end
    end
end

-- Render HoT timer list
local function HealBot_RenderHoTList(numHoTs, currentTime)
    if not HealBot_PlayerHoTsListFrame then
        HealBot_PlayerHoTsListFrame = CreateFrame("Frame", "HealBot_PlayerHoTsListFrame", HealBot_Action)
        HealBot_PlayerHoTsListFrame:SetWidth(128)
        HealBot_PlayerHoTsListFrame:SetHeight(1)
    end

    HealBot_HoTTimerList_Reanchor()
    HealBot_PlayerHoTsListFrame:Show()

    -- Sort active HoTs by expiration
    table.sort(HealBot_PlayerHoTs_ListCache, HealBot_PlayerHoTs_SortComparator)

    for i = 1, math.max(numHoTs, table.getn(HealBot_PlayerHoTFrames)) do
        local frame = HealBot_PlayerHoTFrames[i]
        if i <= numHoTs then
            if not frame then
                frame = CreateFrame("Frame", "HealBot_PlayerHoT" .. i, HealBot_PlayerHoTsListFrame)
                frame:SetWidth(128)
                frame:SetHeight(16)
                
                local icon = frame:CreateTexture(nil, "ARTWORK")
                icon:SetWidth(14)
                icon:SetHeight(14)
                icon:SetPoint("LEFT", frame, "LEFT", 2, 0)
                frame.icon = icon
                
                local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
                text:SetJustifyH("LEFT")
                frame.text = text
                
                HealBot_PlayerHoTFrames[i] = frame
            end

            HealBot_HoTTimerList_StackChild(frame, i)
            
            local hot = HealBot_PlayerHoTs_ListCache[i]
            local timeLeft = hot.timeLeft or math.floor(hot.expires - currentTime)
            
            frame.icon:SetTexture(hot.texture)
            frame.text:SetText(hot.name .. ": " .. timeLeft .. "s")
            frame.text:SetTextColor(0.8, 1, 0.8)
            frame:Show()
        else
            if frame then
                frame:Hide()
            end
        end
    end
    
    HealBot_PlayerHoTsListFrame:SetHeight(math.max(1, numHoTs * 18))
end

-- Unified HoT Timer Pipeline
function HealBot_UpdateActiveHoTTimers()
    if HealBot_Config.HealBot_Integrations_ShowHoTTimers ~= 1 then
        if HealBot_PlayerHoTsListFrame and HealBot_PlayerHoTsListFrame:IsVisible() then
            HealBot_PlayerHoTsListFrame:Hide()
        end
        HealBot_ClearHoTOverlays()
        return
    end

    local currentTime = GetTime()
    local numHoTs = 0

    -- Clear unit map (recycle)
    for _, sub in pairs(HealBot_ActiveHoTUnitMap) do
        for k in pairs(sub) do sub[k] = nil end
    end

    if HealBot_Integrations_Nampower_Active and HealBot_Nampower_Auras then
        for targetKey, auras in pairs(HealBot_Nampower_Auras) do
            local lowerKey = string.lower(targetKey)
            local unitID = HealBot_Model and (HealBot_Model:GetUnitByGUID(targetKey) or HealBot_Model:GetUnitByGUID(lowerKey))
            
            if not unitID then
                local isPlayer = (HealBot_PlayerGUID and (targetKey == HealBot_PlayerGUID or lowerKey == string.lower(HealBot_PlayerGUID)))
                                 or (UnitName("player") and (targetKey == UnitName("player") or lowerKey == string.lower(UnitName("player"))))
                                 or (HealBot_GetUnitGUID and (targetKey == HealBot_GetUnitGUID("player") or lowerKey == string.lower(HealBot_GetUnitGUID("player") or "")))
                if isPlayer then
                    unitID = "player"
                end
            end
            
            if not unitID and HealBot_Model and HealBot_Model.GetUnitIDByName then
                unitID = HealBot_Model:GetUnitIDByName(targetKey)
            end

            -- Multi-tier player name resolution
            local displayName = nil
            if unitID and unitID ~= "target" then
                if HealBot_Model and HealBot_Model.units[unitID] and HealBot_Model.units[unitID].name then
                    displayName = HealBot_Model.units[unitID].name
                end
                if not displayName then
                    displayName = UnitName(unitID)
                end
            end
            if not displayName and HealBot_Nampower_NameCache then
                displayName = HealBot_Nampower_NameCache[targetKey] or HealBot_Nampower_NameCache[lowerKey]
            end
            if not displayName and UnitExists("target") and HealBot_GetUnitGUID and (targetKey == HealBot_GetUnitGUID("target") or lowerKey == string.lower(HealBot_GetUnitGUID("target") or "")) then
                displayName = UnitName("target")
            end
            if not displayName and UnitExists("mouseover") and HealBot_GetUnitGUID and (targetKey == HealBot_GetUnitGUID("mouseover") or lowerKey == string.lower(HealBot_GetUnitGUID("mouseover") or "")) then
                displayName = UnitName("mouseover")
            end
            if not displayName then
                local uName = UnitName(targetKey)
                if uName and uName ~= targetKey and uName ~= "Unknown" then
                    displayName = uName
                end
            end
            if displayName and HealBot_Nampower_NameCache then
                HealBot_Nampower_NameCache[targetKey] = displayName
                HealBot_Nampower_NameCache[lowerKey] = displayName
            end

            -- Exclude pets
            if not (unitID and string.find(unitID, "pet")) then
                for spellName, expiration in pairs(auras) do
                    local auraInfo = HealBot_TrackedAura_Spells and HealBot_TrackedAura_Spells[spellName]
                    if not auraInfo and HealBot_TrackedAuras and HealBot_TrackedAuras[spellName] then
                        auraInfo = HealBot_TrackedAuras[spellName]
                    end
                    if auraInfo and auraInfo.showTimer and expiration > currentTime then
                        local timeLeft = math.floor(expiration - currentTime)
                        local tex = auraInfo.texture or "Interface\\Icons\\INV_Misc_QuestionMark"

                        numHoTs = numHoTs + 1
                        if not HealBot_PlayerHoTs_ListCache[numHoTs] then
                            HealBot_PlayerHoTs_ListCache[numHoTs] = {}
                        end
                        local hot = HealBot_PlayerHoTs_ListCache[numHoTs]
                        hot.unit = unitID
                        hot.name = displayName or "Unknown"
                        hot.spell = spellName
                        hot.texture = tex
                        hot.expires = expiration
                        hot.timeLeft = timeLeft

                        if unitID then
                            if not HealBot_ActiveHoTUnitMap[unitID] then
                                HealBot_ActiveHoTUnitMap[unitID] = {}
                            end
                            local cleanTex = string.lower(string.gsub(tex, "/", "\\"))
                            local shortTex = string.match(cleanTex, "([^\\]+)$")
                            HealBot_ActiveHoTUnitMap[unitID][tex] = timeLeft
                            HealBot_ActiveHoTUnitMap[unitID][cleanTex] = timeLeft
                            if shortTex then
                                HealBot_ActiveHoTUnitMap[unitID][shortTex] = timeLeft
                            end

                            -- Map to any aliased buttons (player in raid, target bar, MTs, etc.)
                            if HealBot_Action_UnitButtons then
                                for btnUnit in pairs(HealBot_Action_UnitButtons) do
                                    if btnUnit ~= unitID and not string.find(btnUnit, "^Test") and UnitExists(btnUnit) and UnitIsUnit(btnUnit, unitID) then
                                        if not HealBot_ActiveHoTUnitMap[btnUnit] then
                                            HealBot_ActiveHoTUnitMap[btnUnit] = {}
                                        end
                                        HealBot_ActiveHoTUnitMap[btnUnit][tex] = timeLeft
                                        HealBot_ActiveHoTUnitMap[btnUnit][cleanTex] = timeLeft
                                        if shortTex then
                                            HealBot_ActiveHoTUnitMap[btnUnit][shortTex] = timeLeft
                                        end
                                    end
                                end
                            end
                            if displayName and not HealBot_ActiveHoTUnitMap[displayName] then
                                HealBot_ActiveHoTUnitMap[displayName] = HealBot_ActiveHoTUnitMap[unitID]
                            end
                        elseif displayName then
                            if not HealBot_ActiveHoTUnitMap[displayName] then
                                HealBot_ActiveHoTUnitMap[displayName] = {}
                            end
                            local cleanTex = string.lower(string.gsub(tex, "/", "\\"))
                            local shortTex = string.match(cleanTex, "([^\\]+)$")
                            HealBot_ActiveHoTUnitMap[displayName][tex] = timeLeft
                            HealBot_ActiveHoTUnitMap[displayName][cleanTex] = timeLeft
                            if shortTex then
                                HealBot_ActiveHoTUnitMap[displayName][shortTex] = timeLeft
                            end
                        end
                    end
                end
            end
        end
    end

    -- Blank out remaining cache entries so sort doesn't read them
    for i = numHoTs + 1, table.getn(HealBot_PlayerHoTs_ListCache) do
        HealBot_PlayerHoTs_ListCache[i].expires = 9999999999
    end

    local displayMode = HealBot_Config.HealBot_Integrations_HoTTimerDisplayMode or 0
    if displayMode == 0 then
        -- List Mode
        HealBot_ClearHoTOverlays()
        HealBot_RenderHoTList(numHoTs, currentTime)
    elseif displayMode == 1 then
        -- Overlay Mode
        if HealBot_PlayerHoTsListFrame and HealBot_PlayerHoTsListFrame:IsVisible() then
            HealBot_PlayerHoTsListFrame:Hide()
        end
        HealBot_RenderHoTOverlays()
    else
        -- Both Mode (2)
        HealBot_RenderHoTList(numHoTs, currentTime)
        HealBot_RenderHoTOverlays()
    end
end

HealBot_Action_UpdatePlayerHoTs = HealBot_UpdateActiveHoTTimers
