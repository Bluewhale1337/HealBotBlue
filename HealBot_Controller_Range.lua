-- HealBot_Controller_Range.lua
-- Handles periodic range checking for units

local _scale = 0

function HealBot_ResetRangeScale()
    _scale = 0
end

function HealBot_Range_Check(unit, range)
    local return_val = 0;
    if not range then 
        range = 40;
    end
    if ( unit == "player" ) then 
        return_val = 1;
    elseif HealBot_Integrations_ClassicAPI_Active and UnitDistanceSquared and UnitInLineOfSight then
        local inSight = UnitInLineOfSight("player", unit)
        if inSight then
            local distSq = UnitDistanceSquared(unit)
            if distSq and distSq <= (range * range) then
                return_val = 1;
            end
        end
    elseif HealBot_Integrations_UnitXP_Active then
        local inSight = UnitXP("inSight", "player", unit)
        if inSight then
            local dist = UnitXP("distanceBetween", "player", unit, "Gaussian")
            if dist and dist <= range then
                return_val = 1;
            end
        end
    elseif ( UnitIsVisible(unit) == 1 ) then
        local tx, ty = GetPlayerMapPosition(unit)
        local dist
        if tx > 0 or ty > 0 then
            local px, py = GetPlayerMapPosition("player")
            dist = math.sqrt((px - tx)^2 + (py - ty)^2)
            if dist > _scale and (px > 0 or py > 0) then
                if ( CheckInteractDistance(unit, 4) ) then
                    _scale = dist
                end
            end
            if dist <= (_scale * range / 27) then
                return_val = 1
            end
        else
            if ( HealBot_Config.QualityRange == 1 ) or range <= 27 then
                if ( CheckInteractDistance(unit, 4) ) then
                    return_val = 1;
                end                    
            else
                return_val = 1;
            end
        end
    end
    return return_val;
end
