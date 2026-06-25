-- HealBot_Model.lua
-- Centralized Data Store and Observer System for HealBotBlue

HealBot_Model = {
    observers = {},
    units = {},
    
    -- Expose common lists for iteration
    partyMembers = {},
    raidMembers = {},
    playerPet = nil,
    target = nil
}

--------------------------------------------------------------------------------
-- Observer Pattern Implementation
--------------------------------------------------------------------------------

-- Supported Events:
-- "UNIT_HEALTH_CHANGED"
-- "UNIT_POWER_CHANGED"
-- "UNIT_AURA_CHANGED"
-- "UNIT_STATUS_CHANGED" (dead/ghost/offline)
-- "ROSTER_CHANGED"
-- "EQUIPMENT_CHANGED"
-- "INCOMING_HEAL_CHANGED"

function HealBot_Model:RegisterObserver(event, callback)
    if not self.observers[event] then
        self.observers[event] = {}
    end
    table.insert(self.observers[event], callback)
end

function HealBot_Model:NotifyObservers(event, unitID, ...)
    if self.observers[event] then
        local len = table.getn(self.observers[event])
        for i = 1, len do
            self.observers[event][i](unitID, ...)
        end
    end
end

--------------------------------------------------------------------------------
-- Model Initialization
--------------------------------------------------------------------------------

function HealBot_Model:Initialize()
    self:InitUnitState("player")
    self:InitUnitState("target")
    self:InitUnitState("pet")
    
    for i = 1, 4 do
        self:InitUnitState("party"..i)
        self:InitUnitState("partypet"..i)
        table.insert(self.partyMembers, "party"..i)
    end
    
    for i = 1, 40 do
        self:InitUnitState("raid"..i)
        self:InitUnitState("raidpet"..i)
        table.insert(self.raidMembers, "raid"..i)
    end
end

function HealBot_Model:InitUnitState(unit)
    if not self.units[unit] then
        self.units[unit] = {
            -- Base properties
            name = nil,
            class = nil,
            englishClass = nil,
            
            -- State tracking
            health = 0,
            maxHealth = 0,
            mana = 0,
            maxMana = 0,
            powerType = 0,
            
            -- Status tracking
            isDead = false,
            isGhost = false,
            isConnected = true,
            inRange = false,
            
            -- Buffs/Debuffs (Auras)
            debuffType = nil,
            debuffTexture = nil,
            missingBuff = false,
            icons = {},
            
            -- Integration
            incomingHeal = 0
        }
    end
end

--------------------------------------------------------------------------------
-- Model Updaters (Called by Controller)
--------------------------------------------------------------------------------

-- Updates base unit info (Name, Class)
function HealBot_Model:UpdateUnitIdentity(unit)
    if not self.units[unit] then return false end
    
    local oldName = self.units[unit].name
    local name = UnitName(unit)
    local _, englishClass = UnitClass(unit)
    
    if oldName ~= name then
        self.units[unit].name = name
        self.units[unit].englishClass = englishClass
        self.units[unit].class = UnitClass(unit)
        return true -- Identity changed
    end
    return false
end

-- Updates health/maxHealth values. Returns true if changed.
function HealBot_Model:UpdateUnitHealth(unit)
    if not self.units[unit] then return false end
    
    local oldHealth = self.units[unit].health
    local oldMax = self.units[unit].maxHealth
    
    local currentHealth = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    
    if oldHealth ~= currentHealth or oldMax ~= maxHealth then
        self.units[unit].health = currentHealth
        self.units[unit].maxHealth = maxHealth
        return true -- Value changed
    end
    
    return false
end

-- Updates power values (mana, rage, energy). Returns true if changed.
function HealBot_Model:UpdateUnitPower(unit)
    if not self.units[unit] then return false end
    
    local oldMana = self.units[unit].mana
    local oldMax = self.units[unit].maxMana
    local oldType = self.units[unit].powerType
    
    local currentMana = UnitMana(unit)
    local maxMana = UnitManaMax(unit)
    local powerType = UnitPowerType(unit)
    
    if oldMana ~= currentMana or oldMax ~= maxMana or oldType ~= powerType then
        self.units[unit].mana = currentMana
        self.units[unit].maxMana = maxMana
        self.units[unit].powerType = powerType
        return true -- Value changed
    end
    
    return false
end

-- Updates status flags (Dead, Ghost, Offline). Returns true if changed.
function HealBot_Model:UpdateUnitStatus(unit)
    if not self.units[unit] then return false end
    
    local oldDead = self.units[unit].isDead
    local oldGhost = self.units[unit].isGhost
    local oldConn = self.units[unit].isConnected
    
    local isDead = UnitIsDead(unit)
    local isGhost = UnitIsGhost(unit)
    local isConnected = UnitIsConnected(unit)
    
    -- Note: Vanilla API for UnitIsConnected sometimes returns nil instead of false
    if isConnected == nil then isConnected = false end
    if isDead == nil then isDead = false end
    if isGhost == nil then isGhost = false end
    
    if oldDead ~= isDead or oldGhost ~= isGhost or oldConn ~= isConnected then
        self.units[unit].isDead = isDead
        self.units[unit].isGhost = isGhost
        self.units[unit].isConnected = isConnected
        return true -- Value changed
    end
    
    return false
end

-- Updates incoming heals. Returns true if changed.
function HealBot_Model:UpdateIncomingHeal(unit, amount)
    if not self.units[unit] then return false end
    
    if self.units[unit].incomingHeal ~= amount then
        self.units[unit].incomingHeal = amount
        return true
    end
    return false
end

-- Manually mark auras as changed. 
function HealBot_Model:MarkAuraChanged(unit)
    -- We don't cache all auras in the model natively because it's too expensive
    -- to poll every buff/debuff. The controller tells the model an aura changed,
    -- and the view will resolve it if the unit is rendered.
    return true
end

-- Force a full refresh of a unit's API data
function HealBot_Model:RefreshUnit(unit)
    self:UpdateUnitIdentity(unit)
    self:UpdateUnitHealth(unit)
    self:UpdateUnitPower(unit)
    self:UpdateUnitStatus(unit)
    
    -- Force observers to render the initial state
    self:NotifyObservers("UNIT_HEALTH_CHANGED", unit)
    self:NotifyObservers("UNIT_POWER_CHANGED", unit)
end

-- Initialize the model state
HealBot_Model:Initialize()
