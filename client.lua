-- ====================================
-- RDE | SKILLS SYSTEM - CLIENT (Enhanced Production)
-- ====================================
local Config = {}
local playerSkills = {}
local playerReputation = {}
local uiOpen = false
local showSkillHUD = false
local dataLoaded = false
local nativeSkillsUpdated = {}

-- ====================================
-- UTILITY FUNCTIONS
-- ====================================
local function initializeTables()
    playerSkills = {}
    playerReputation = {}
    nativeSkillsUpdated = {}

    if Config.Skills then
        for skill, _ in pairs(Config.Skills) do
            playerSkills[skill] = { level = 0, xp = 0 }
        end
    end

    if Config.Factions then
        for faction, _ in pairs(Config.Factions) do
            playerReputation[faction] = 0
        end
    end
end

local function getSkillLevel(xp)
    return math.floor(xp / 100)
end

local function getSkillProgress(xp)
    return xp % 100
end

local function getSkillColor(progress)
    if progress >= 75 then
        return Config.HUD.colors.high
    elseif progress >= 50 then
        return Config.HUD.colors.medium
    else
        return Config.HUD.colors.low
    end
end

local function debugPrint(...)
    if Config.Debug then
        print('^3[SKILL SYSTEM DEBUG]^7', ...)
    end
end

-- ====================================
-- NATIVE GTA SKILLS SYSTEM
-- ====================================
local function updateNativeGTASkill(skill, level)
    if not Config.NativeSkillsEnabled then return end
    if not Config.Skills[skill] or not Config.Skills[skill].nativeSkill then return end
    
    local statName = Config.Skills[skill].nativeSkill
    if not statName then return end
    
    -- Convert level (0-100) to stat value (0-100)
    local statValue = math.min(level, 100)
    
    -- Set the stat
    StatSetInt(GetHashKey(statName), statValue, true)
    
    debugPrint('Updated native skill:', statName, 'to level:', statValue)
end

local function updateAllNativeSkills()
    if not Config.NativeSkillsEnabled or not dataLoaded then return end
    
    for skillName, skillData in pairs(playerSkills) do
        updateNativeGTASkill(skillName, skillData.level)
    end
end

-- ====================================
-- INITIALIZATION
-- ====================================
CreateThread(function()
    TriggerEvent('rde_skills:getConfig', function(config)
        Config = config or {}
        initializeTables()
        debugPrint('Config loaded')
    end)
end)

-- ====================================
-- UI FUNCTIONS
-- ====================================
local function openSkillsMenu()
    if uiOpen then
        lib.notify({
            title = 'Skill System',
            description = _U('menu_already_open'),
            type = 'error'
        })
        return
    end

    if not dataLoaded then
        lib.notify({
            title = 'Skill System',
            description = 'Loading data...',
            type = 'info'
        })
        TriggerServerEvent('rde_skills:requestData')
        return
    end

    uiOpen = true
    local options = {}

    -- Skills Header
    table.insert(options, {
        title = _U('skills_title'),
        description = _U('skills_description'),
        icon = 'chart-simple',
        iconColor = '#3498db',
        disabled = true
    })

    -- Skills
    if Config.Skills then
        for skillName, skillData in pairs(playerSkills) do
            if Config.Skills[skillName] then
                local cfg = Config.Skills[skillName]
                local level = skillData.level
                local progress = getSkillProgress(skillData.xp)
                local isMaxLevel = level >= cfg.maxLevel

                table.insert(options, {
                    title = _U(cfg.label),
                    description = isMaxLevel and _U('max_level') or _U('skill_level', level, progress),
                    icon = cfg.icon:gsub('fa%-solid fa%-', ''),
                    iconColor = cfg.color,
                    progress = isMaxLevel and 100 or progress,
                    metadata = {
                        {label = 'Level', value = level},
                        {label = 'XP', value = skillData.xp},
                        {label = 'Progress', value = progress .. '%'}
                    }
                })
            end
        end
    end

    -- Reputation Header
    table.insert(options, {
        title = _U('reputation_title'),
        description = _U('reputation_description'),
        icon = 'star',
        iconColor = '#f1c40f',
        disabled = true
    })

    -- Reputation
    if Config.Factions then
        for factionName, rep in pairs(playerReputation) do
            if Config.Factions[factionName] then
                local cfg = Config.Factions[factionName]
                local repColor = rep >= 0 and '#2ecc71' or '#e74c3c'

                table.insert(options, {
                    title = _U(cfg.label),
                    description = _U('reputation_value', rep),
                    icon = cfg.icon:gsub('fa%-solid fa%-', ''),
                    iconColor = repColor,
                    metadata = {
                        {label = 'Reputation', value = rep}
                    }
                })
            end
        end
    end

    lib.registerContext({
        id = 'rde_skills_menu',
        title = '🎯 Skill System',
        options = options,
        onExit = function()
            uiOpen = false
        end
    })

    lib.showContext('rde_skills_menu')
end

-- ====================================
-- EVENT HANDLERS
-- ====================================
RegisterNetEvent('rde_skills:openUI', function()
    TriggerServerEvent('rde_skills:requestData')
    Wait(500)
    openSkillsMenu()
end)

RegisterNetEvent('rde_skills:receiveData', function(skills, reputation)
    debugPrint('Received data from server')

    if skills then
        for skill, xp in pairs(skills) do
            if skill ~= 'charid' and skill ~= 'updated_at' and playerSkills[skill] then
                playerSkills[skill] = {
                    xp = xp or 0,
                    level = getSkillLevel(xp or 0)
                }
            end
        end
        dataLoaded = true
        debugPrint('Skills loaded:', json.encode(playerSkills))
        
        -- Update all native GTA skills on data load
        updateAllNativeSkills()
    end

    if reputation then
        for faction, rep in pairs(reputation) do
            if faction ~= 'charid' and faction ~= 'updated_at' and playerReputation[faction] then
                playerReputation[faction] = rep or 0
            end
        end
        debugPrint('Reputation loaded:', json.encode(playerReputation))
    end
end)

RegisterNetEvent('rde_skills:updateSkill', function(skill, newXP)
    if playerSkills[skill] then
        playerSkills[skill].xp = newXP
        playerSkills[skill].level = getSkillLevel(newXP)
        debugPrint('Updated skill:', skill, 'XP:', newXP, 'Level:', playerSkills[skill].level)
    end
end)

RegisterNetEvent('rde_skills:updateNativeSkill', function(skill, level)
    updateNativeGTASkill(skill, level)
end)

RegisterNetEvent('rde_skills:updateReputation', function(faction, newRep)
    if playerReputation[faction] then
        playerReputation[faction] = newRep
        debugPrint('Updated reputation:', faction, 'Rep:', newRep)
    end
end)

-- ====================================
-- SKILL BOOST SYSTEM
-- ====================================
local function applySkillBoosts()
    if not dataLoaded or not Config.Skills then return end
    
    local playerPed = PlayerPedId()
    local playerId = PlayerId()

    for skillName, skillData in pairs(playerSkills) do
        local level = skillData.level
        if level and level > 0 and Config.Skills[skillName] then
            local boostMult = Config.Skills[skillName].boostMultiplier or 0.05
            local boost = math.floor(level / 10) * boostMult

            if skillName == 'driving' and IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    SetVehicleEnginePowerMultiplier(vehicle, 1.0 + boost)
                    SetVehicleEngineTorqueMultiplier(vehicle, 1.0 + boost)
                end

            elseif skillName == 'shooting' then
                SetPlayerWeaponDamageModifier(playerId, 1.0 + boost)

            elseif skillName == 'fitness' then
                SetRunSprintMultiplierForPlayer(playerId, 1.0 + boost)
                SetSwimMultiplierForPlayer(playerId, 1.0 + boost)
                RestorePlayerStamina(playerId, 1.0)

            elseif skillName == 'strength' then
                SetPlayerMeleeWeaponDamageModifier(playerId, 1.0 + boost)

            elseif skillName == 'stealth' then
                SetPlayerSneakingNoiseMultiplier(playerId, math.max(0.3, 1.0 - boost))
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if dataLoaded then
            applySkillBoosts()
        end
    end
end)

-- ====================================
-- AUTOMATIC XP GAIN
-- ====================================

-- Fitness: Running/Sprinting
CreateThread(function()
    while true do
        Wait(Config.XPGainInterval or 10000)
        if not dataLoaded then goto continue end
        
        local playerPed = PlayerPedId()
        if IsPedRunning(playerPed) or IsPedSprinting(playerPed) then
            TriggerServerEvent('rde_skills:addSkillXP', 'fitness', math.random(1, 2))
        end
        
        ::continue::
    end
end)

-- Flying: Aircraft
CreateThread(function()
    while true do
        Wait(30000)
        if not dataLoaded then goto continue end
        
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local vehicleClass = GetVehicleClass(vehicle)

            -- Aircraft: helicopters and planes
            if vehicleClass == 15 or vehicleClass == 16 then
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    TriggerServerEvent('rde_skills:addSkillXP', 'flying', math.random(2, 4))
                end
            end
        end
        
        ::continue::
    end
end)

-- Stealth: Crouching
CreateThread(function()
    while true do
        Wait(15000)
        if not dataLoaded then goto continue end
        
        local playerPed = PlayerPedId()
        -- Check if player is crouching/stealthing using proper native
        if GetPedStealthMovement(playerPed) then
            TriggerServerEvent('rde_skills:addSkillXP', 'stealth', 1)
        end
        
        ::continue::
    end
end)

-- ====================================
-- SKILL HUD DISPLAY
-- ====================================
local function drawSkillBar(skillName, skillData, x, y)
    local barWidth = Config.HUD.barWidth
    local barHeight = Config.HUD.barHeight
    local progress = getSkillProgress(skillData.xp)
    local level = skillData.level
    local progressDecimal = progress / 100

    -- Background
    DrawRect(x, y, barWidth, barHeight, 30, 30, 30, 180)

    -- Progress bar
    local color = getSkillColor(progress)
    DrawRect(
        x - (barWidth/2) + (barWidth * progressDecimal / 2),
        y,
        barWidth * progressDecimal,
        barHeight,
        color.r, color.g, color.b, 220
    )

    -- Border
    DrawRect(x, y, barWidth + 0.002, barHeight + 0.002, 255, 255, 255, 100)

    -- Text
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextEntry("STRING")

    local label = _U(Config.Skills[skillName].label)
    local text = string.format("%s: Lvl %d (%d%%)", label, level, progress)

    AddTextComponentString(text)
    DrawText(x - barWidth/2, y - 0.013)
end

RegisterCommand('toggleskillhud', function()
    showSkillHUD = not showSkillHUD
    lib.notify({
        title = 'Skill HUD',
        description = showSkillHUD and _U('hud_toggled_on') or _U('hud_toggled_off'),
        type = showSkillHUD and 'success' or 'info'
    })
end)

CreateThread(function()
    while true do
        if showSkillHUD and dataLoaded and Config.HUD.enabled and next(playerSkills) ~= nil then
            local x = Config.HUD.position.x
            local yStart = Config.HUD.position.y
            local spacing = Config.HUD.spacing
            local index = 0

            for skillName, skillData in pairs(playerSkills) do
                if Config.Skills and Config.Skills[skillName] then
                    if not Config.HUD.hideAtZero or skillData.xp > 0 then
                        drawSkillBar(skillName, skillData, x, yStart + (index * spacing))
                        index = index + 1
                    end
                end
            end
        end
        Wait(0)
    end
end)

-- ====================================
-- COMMANDS
-- ====================================
RegisterCommand('skills', function()
    TriggerEvent('rde_skills:openUI')
end, false)

-- ====================================
-- RESOURCE LIFECYCLE
-- ====================================
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(2000)
        TriggerServerEvent('rde_skills:requestData')
    end	
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Reset all skill boosts
        local playerId = PlayerId()
        SetPlayerWeaponDamageModifier(playerId, 1.0)
        SetRunSprintMultiplierForPlayer(playerId, 1.0)
        SetSwimMultiplierForPlayer(playerId, 1.0)
        SetPlayerMeleeWeaponDamageModifier(playerId, 1.0)
        SetPlayerSneakingNoiseMultiplier(playerId, 1.0)
    end
end)

-- ====================================
-- OX_CORE INTEGRATION
-- ====================================
AddEventHandler('ox:playerLoaded', function()
    Wait(2000)
    TriggerServerEvent('rde_skills:requestData')
    debugPrint('Player loaded, requesting data')
end)

AddEventHandler('ox:playerLogout', function()
    dataLoaded = false
    initializeTables()
    debugPrint('Player logout, clearing data')
end)

-- Legacy support for other resources
AddEventHandler('playerSpawned', function()
    Wait(2000)
    if not dataLoaded then
        TriggerServerEvent('rde_skills:requestData')
    end
end)

print("^2[RDE | SKILL SYSTEM]^7 Client loaded successfully!")
print("^3[RDE | SKILL SYSTEM]^7 Commands: /skills | /toggleskillhud")

print("^3[RDE | SKILL SYSTEM]^7 Native GTA skills:", Config.NativeSkillsEnabled and "ENABLED" or "DISABLED")
