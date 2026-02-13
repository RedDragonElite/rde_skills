-- ====================================
-- RDE | SKILLS SYSTEM - SERVER (Enhanced Production Version)
-- ====================================
local Config = {}
local playerCache = {} -- Performance cache
local lastNotification = {} -- Notification cooldown tracking
local activePlayers = {} -- Track active players for optimization

-- ============================================
-- 🔧 INITIALIZATION
-- ============================================
CreateThread(function()
    TriggerEvent('rde_skills:getConfig', function(config)
        Config = config or {}
    end)
end)

-- ============================================
-- 🛡️ TRIPLE ADMIN VERIFICATION SYSTEM
-- ============================================
local function IsPlayerAdmin(source)
    local player = Ox.GetPlayer(source)
    if not player then return false end
    
    local adminConfig = Config.AdminSystem
    local identifier = GetPlayerIdentifierByType(source, 'steam')
    
    -- 🔍 Check in configured order
    for _, method in ipairs(adminConfig.checkOrder) do
        if method == 'ace' then
            -- ✅ Method 1: ACE Permissions
            if IsPlayerAceAllowed(source, adminConfig.acePermission) then
                print(('🔐 [ADMIN] %s verified via ACE: %s'):format(player.name, adminConfig.acePermission))
                return true
            end
        elseif method == 'oxcore' then
            -- ✅ Method 2: ox_core Groups
            local groups = player.getGroups()
            for groupName, minGrade in pairs(adminConfig.oxGroups) do
                if groups[groupName] and groups[groupName] >= minGrade then
                    print(('🔐 [ADMIN] %s verified via ox_core group: %s (grade %s)'):format(player.name, groupName, groups[groupName]))
                    return true
                end
            end
        elseif method == 'steam' then
            -- ✅ Method 3: Steam ID Whitelist
            if identifier then
                for _, allowedId in ipairs(adminConfig.steamIds) do
                    if identifier == allowedId then
                        print(('🔐 [ADMIN] %s verified via Steam ID'):format(player.name))
                        return true
                    end
                end
            end
        end
    end
    
    -- ❌ Access denied - log security attempt
    print(('⚠️ [SECURITY] Unauthorized admin action by %s [%s]'):format(player.name, identifier or 'unknown'))
    return false
end

-- ============================================
-- 🛠️ UTILITY FUNCTIONS
-- ============================================
local function debugPrint(...)
    if Config.Debug then
        print('^3[SKILL SYSTEM]^7', ...)
    end
end

local function canNotify(source, notifType)
    if not Config.NotificationCooldown then return true end
    
    local currentTime = GetGameTimer()
    local key = source .. '_' .. notifType
    
    if not lastNotification[key] or (currentTime - lastNotification[key]) >= Config.NotificationCooldown then
        lastNotification[key] = currentTime
        return true
    end
    
    return false
end

local function getSkillLevel(xp)
    return math.floor(xp / 100)
end

local function getSkillProgress(xp)
    return xp % 100
end

local function getTotalLevel(skills)
    local total = 0
    for skillName, xp in pairs(skills) do
        if skillName ~= 'charid' and skillName ~= 'updated_at' and skillName ~= 'prestige' then
            total = total + getSkillLevel(xp)
        end
    end
    return total
end

-- ============================================
-- 💾 DATABASE SETUP WITH AUTO-CREATION
-- ============================================
MySQL.ready(function()
    -- ⚙️ Create enhanced skills table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS rde_player_skills (
            charid INT PRIMARY KEY,
            driving INT DEFAULT 0,
            shooting INT DEFAULT 0,
            fitness INT DEFAULT 0,
            strength INT DEFAULT 0,
            flying INT DEFAULT 0,
            stealth INT DEFAULT 0,
            hacking INT DEFAULT 0,
            mechanics INT DEFAULT 0,
            cooking INT DEFAULT 0,
            charisma INT DEFAULT 0,
            fishing INT DEFAULT 0,
            prestige INT DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_charid (charid),
            INDEX idx_prestige (prestige)
        )
    ]])

    -- ⭐ Create reputation table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS rde_player_reputation (
            charid INT PRIMARY KEY,
            police INT DEFAULT 0,
            gangs INT DEFAULT 0,
            medics INT DEFAULT 0,
            mechanics INT DEFAULT 0,
            civilians INT DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_charid (charid)
        )
    ]])

    -- 🏆 Create achievements table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS rde_player_achievements (
            id INT AUTO_INCREMENT PRIMARY KEY,
            charid INT NOT NULL,
            achievement_id VARCHAR(50) NOT NULL,
            unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_achievement (charid, achievement_id),
            INDEX idx_charid (charid)
        )
    ]])

    -- 💎 Create perks table (tracks unlocked perks)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS rde_player_perks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            charid INT NOT NULL,
            skill VARCHAR(50) NOT NULL,
            perk_level INT NOT NULL,
            unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_perk (charid, skill, perk_level),
            INDEX idx_charid (charid)
        )
    ]])

    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^2[RDE | SKILL SYSTEM]^7 Database initialized successfully!")
    print("^2[RDE | SKILL SYSTEM]^7 Tables: skills, reputation, achievements, perks")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
end)

-- ============================================
-- 📡 STATEBAG SYNC FUNCTIONS (REAL-TIME!)
-- ============================================
local function updatePlayerStatebag(source, data)
    local player = Player(source)
    if not player or not player.state then return end
    
    -- 🔥 Real-time statebag update!
    player.state:set('skills', data.skills, true)
    player.state:set('reputation', data.reputation, true)
    player.state:set('prestige', data.prestige or 0, true)
    player.state:set('totalLevel', data.totalLevel or 0, true)
    player.state:set('achievements', data.achievements or {}, true)
    
    debugPrint('Statebag updated for player', source)
end

local function getPlayerFromStatebag(source)
    local player = Player(source)
    if not player or not player.state then return nil end
    
    return {
        skills = player.state.skills or {},
        reputation = player.state.reputation or {},
        prestige = player.state.prestige or 0,
        totalLevel = player.state.totalLevel or 0,
        achievements = player.state.achievements or {}
    }
end

-- ============================================
-- 💾 CORE DATABASE FUNCTIONS
-- ============================================
local function loadPlayerSkills(charid)
    -- Check cache first for performance
    if playerCache[charid] and playerCache[charid].skills then
        debugPrint('Loading skills from cache for charid:', charid)
        return playerCache[charid].skills
    end
    
    local result = MySQL.single.await('SELECT * FROM rde_player_skills WHERE charid = ?', {charid})

    if not result then
        -- Create default skills
        local defaultSkills = {charid}
        local columns = 'charid'
        local values = '?'

        if Config.Skills then
            for skill, _ in pairs(Config.Skills) do
                columns = columns .. ', ' .. skill
                values = values .. ', ?'
                table.insert(defaultSkills, 0)
            end
        end
        
        -- Add prestige column
        columns = columns .. ', prestige'
        values = values .. ', ?'
        table.insert(defaultSkills, 0)

        MySQL.insert('INSERT INTO rde_player_skills (' .. columns .. ') VALUES (' .. values .. ')', defaultSkills)

        local data = {charid = charid, prestige = 0}
        if Config.Skills then
            for skill, _ in pairs(Config.Skills) do
                data[skill] = 0
            end
        end
        
        -- Cache it
        if not playerCache[charid] then playerCache[charid] = {} end
        playerCache[charid].skills = data
        
        return data
    end

    -- Cache it
    if not playerCache[charid] then playerCache[charid] = {} end
    playerCache[charid].skills = result
    
    return result
end

local function loadPlayerReputation(charid)
    -- Check cache first
    if playerCache[charid] and playerCache[charid].reputation then
        debugPrint('Loading reputation from cache for charid:', charid)
        return playerCache[charid].reputation
    end
    
    local result = MySQL.single.await('SELECT * FROM rde_player_reputation WHERE charid = ?', {charid})

    if not result then
        local defaultRep = {charid}
        local columns = 'charid'
        local values = '?'

        if Config.Factions then
            for faction, _ in pairs(Config.Factions) do
                columns = columns .. ', ' .. faction
                values = values .. ', ?'
                table.insert(defaultRep, 0)
            end
        end

        MySQL.insert('INSERT INTO rde_player_reputation (' .. columns .. ') VALUES (' .. values .. ')', defaultRep)

        local data = {charid = charid}
        if Config.Factions then
            for faction, _ in pairs(Config.Factions) do
                data[faction] = 0
            end
        end
        
        -- Cache it
        if not playerCache[charid] then playerCache[charid] = {} end
        playerCache[charid].reputation = data
        
        return data
    end

    -- Cache it
    if not playerCache[charid] then playerCache[charid] = {} end
    playerCache[charid].reputation = result
    
    return result
end

local function loadPlayerAchievements(charid)
    local result = MySQL.query.await('SELECT achievement_id FROM rde_player_achievements WHERE charid = ?', {charid})
    local achievements = {}
    
    if result then
        for _, row in ipairs(result) do
            table.insert(achievements, row.achievement_id)
        end
    end
    
    return achievements
end

-- ============================================
-- 🎯 SKILL XP SYSTEM WITH ENHANCEMENTS
-- ============================================
local function addSkillXP(source, skill, amount, skipNotification)
    local player = Ox.GetPlayer(source)
    if not player then return false, "Player not found" end

    local charid = player.charId
    if not charid then return false, "Character not found" end

    if not Config.Skills or not Config.Skills[skill] then return false, "Invalid skill" end

    local skills = loadPlayerSkills(charid)
    local currentXP = skills[skill] or 0
    local currentLevel = getSkillLevel(currentXP)
    local maxLevel = Config.Skills[skill].maxLevel or 100

    if currentLevel >= maxLevel then return false, "Max level reached" end

    -- Apply prestige bonus
    local prestige = skills.prestige or 0
    local prestigeBonus = Config.Prestige.enabled and (prestige * Config.Prestige.bonusPerPrestige) or 0
    
    local xpGained = math.floor(amount * (Config.Skills[skill].xpMultiplier or 1.0) * (1 + prestigeBonus))
    local newXP = math.min(currentXP + xpGained, maxLevel * 100)
    local newLevel = getSkillLevel(newXP)

    -- Update database (with cache invalidation)
    MySQL.update.await('UPDATE rde_player_skills SET '..skill..' = ? WHERE charid = ?', {newXP, charid})
    
    -- Invalidate cache
    if playerCache[charid] then
        playerCache[charid].skills = nil
    end

    -- 🔥 Update statebag in real-time!
    local updatedSkills = loadPlayerSkills(charid)
    local playerData = {
        skills = updatedSkills,
        reputation = loadPlayerReputation(charid),
        prestige = prestige,
        totalLevel = getTotalLevel(updatedSkills)
    }
    updatePlayerStatebag(source, playerData)

    -- Check for level up
    if newLevel > currentLevel then
        -- 🎉 Level up notification
        if Config.Notifications.levelUp and not skipNotification then
            TriggerClientEvent('ox_lib:notify', source, {
                title = '🎉 Level Up!',
                description = _U('notify_skill_up', _U(Config.Skills[skill].label), newLevel),
                type = 'success',
                icon = Config.Skills[skill].icon,
                iconColor = Config.Skills[skill].color,
                duration = 5000
            })
        end
        
        -- Check for milestones
        if Config.Skills[skill].milestones and Config.Skills[skill].milestones[newLevel] then
            local milestone = Config.Skills[skill].milestones[newLevel]
            if Config.Notifications.milestones and not skipNotification then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = '🎯 Milestone Unlocked!',
                    description = _U('notify_milestone', milestone.name, milestone.reward),
                    type = 'success',
                    icon = milestone.icon,
                    iconColor = '#8b5cf6',
                    duration = 7000
                })
            end
        end
        
        -- Check for perks
        if Config.Skills[skill].perks then
            for _, perk in ipairs(Config.Skills[skill].perks) do
                if newLevel == perk.level then
                    -- Unlock perk in database
                    MySQL.insert('INSERT IGNORE INTO rde_player_perks (charid, skill, perk_level) VALUES (?, ?, ?)', 
                        {charid, skill, perk.level})
                    
                    if Config.Notifications.perks and not skipNotification then
                        TriggerClientEvent('ox_lib:notify', source, {
                            title = '💎 New Perk!',
                            description = perk.name .. ': ' .. perk.desc,
                            type = 'success',
                            icon = 'gem',
                            iconColor = '#8b5cf6',
                            duration = 7000
                        })
                    end
                end
            end
        end
        
        -- Update native GTA skills
        TriggerClientEvent('rde_skills:updateNativeSkill', source, skill, newLevel)
        
        -- Check achievements
        checkAchievements(source, charid)
        
        -- Check synergies
        checkSynergies(source, updatedSkills)
    end

    -- XP gain notification (with cooldown)
    if Config.Notifications.xpGain and xpGained >= Config.XPNotifyThreshold and not skipNotification then
        if canNotify(source, 'xp_' .. skill) then
            TriggerClientEvent('ox_lib:notify', source, {
                description = _U('notify_xp_gain', xpGained, _U(Config.Skills[skill].label)),
                type = 'info',
                icon = Config.Skills[skill].icon,
                iconColor = Config.Skills[skill].color,
                duration = 2000
            })
        end
    end

    return true, newXP, newLevel
end

-- ============================================
-- ⭐ REPUTATION SYSTEM
-- ============================================
local function modifyReputation(source, faction, amount)
    local player = Ox.GetPlayer(source)
    if not player then return false, "Player not found" end

    local charid = player.charId
    if not charid then return false, "Character not found" end

    if not Config.Factions or not Config.Factions[faction] then return false, "Invalid faction" end

    local rep = loadPlayerReputation(charid)
    local currentRep = rep[faction] or 0
    local factionConfig = Config.Factions[faction]
    local newRep = math.max(factionConfig.minRep, math.min(factionConfig.maxRep, currentRep + amount))

    MySQL.update.await('UPDATE rde_player_reputation SET '..faction..' = ? WHERE charid = ?', {newRep, charid})
    
    -- Invalidate cache
    if playerCache[charid] then
        playerCache[charid].reputation = nil
    end

    -- 🔥 Update statebag
    local updatedRep = loadPlayerReputation(charid)
    local playerData = {
        skills = loadPlayerSkills(charid),
        reputation = updatedRep,
        prestige = loadPlayerSkills(charid).prestige or 0
    }
    updatePlayerStatebag(source, playerData)

    if Config.Notifications.reputation then
        -- Determine tier
        local tier = 'neutral'
        for _, tierData in ipairs(factionConfig.tiers) do
            if newRep >= tierData.min and newRep <= tierData.max then
                tier = tierData.name
                break
            end
        end
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = '⭐ ' .. _U('faction_' .. faction),
            description = _U('notify_reputation', '', amount > 0 and '+' or '', amount) .. '\n' .. _U('reputation_tier', tier),
            type = amount > 0 and 'success' or 'error',
            icon = Config.Factions[faction].icon,
            iconColor = Config.Factions[faction].color,
            duration = 3000
        })
    end

    return true, newRep
end

-- ============================================
-- 🏆 ACHIEVEMENT SYSTEM
-- ============================================
function checkAchievements(source, charid)
    if not Config.Achievements then return end
    
    local skills = loadPlayerSkills(charid)
    local reputation = loadPlayerReputation(charid)
    local unlockedAchievements = loadPlayerAchievements(charid)
    local totalLevel = getTotalLevel(skills)
    
    local skillsData = {}
    for skillName, xp in pairs(skills) do
        if skillName ~= 'charid' and skillName ~= 'updated_at' and skillName ~= 'prestige' then
            skillsData[skillName] = {
                xp = xp,
                level = getSkillLevel(xp)
            }
        end
    end
    
    local data = {
        skills = skillsData,
        reputation = reputation,
        totalLevel = totalLevel
    }
    
    for _, achievement in ipairs(Config.Achievements) do
        -- Check if already unlocked
        local alreadyUnlocked = false
        for _, unlockedId in ipairs(unlockedAchievements) do
            if unlockedId == achievement.id then
                alreadyUnlocked = true
                break
            end
        end
        
        if not alreadyUnlocked and achievement.condition(data) then
            -- Unlock achievement!
            MySQL.insert('INSERT INTO rde_player_achievements (charid, achievement_id) VALUES (?, ?)', 
                {charid, achievement.id})
            
            -- Notify player
            if Config.Notifications.achievements then
                local player = Ox.GetPlayer(source)
                if player then
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = '🏆 Achievement Unlocked!',
                        description = _U('notify_achievement', _U(achievement.name)),
                        type = 'success',
                        icon = achievement.icon,
                        iconColor = '#fbbf24',
                        duration = 8000
                    })
                    
                    -- Give reward
                    if achievement.reward and achievement.reward.money then
                        player.addMoney('bank', achievement.reward.money)
                        TriggerClientEvent('ox_lib:notify', source, {
                            description = '💰 Reward: $' .. achievement.reward.money,
                            type = 'success',
                            icon = 'dollar-sign',
                            duration = 5000
                        })
                    end
                end
            end
            
            table.insert(unlockedAchievements, achievement.id)
        end
    end
    
    return unlockedAchievements
end

-- ============================================
-- ✨ SYNERGY SYSTEM
-- ============================================
function checkSynergies(source, skills)
    if not Config.Synergies then return end
    
    for _, synergy in ipairs(Config.Synergies) do
        local hasAll = true
        
        for _, skillName in ipairs(synergy.skills) do
            local level = getSkillLevel(skills[skillName] or 0)
            if level < synergy.minLevel then
                hasAll = false
                break
            end
        end
        
        if hasAll and Config.Notifications.enabled then
            if canNotify(source, 'synergy_' .. synergy.name) then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = '✨ Synergy Active!',
                    description = _U('notify_synergy', synergy.description, math.floor(synergy.bonus * 100)),
                    type = 'success',
                    icon = synergy.icon,
                    iconColor = '#8b5cf6',
                    duration = 5000
                })
            end
        end
    end
end

-- ============================================
-- 👑 PRESTIGE SYSTEM
-- ============================================
local function prestigeSkills(source)
    local player = Ox.GetPlayer(source)
    if not player then return false, "Player not found" end
    
    if not Config.Prestige.enabled then return false, "Prestige system disabled" end

    local charid = player.charId
    if not charid then return false, "Character not found" end

    local skills = loadPlayerSkills(charid)
    local prestige = skills.prestige or 0
    
    -- Check if max prestige reached
    if prestige >= Config.Prestige.maxPrestige then
        return false, _U('max_prestige')
    end
    
    -- Check if player has at least one maxed skill
    local hasMaxSkill = false
    for skillName, xp in pairs(skills) do
        if skillName ~= 'charid' and skillName ~= 'updated_at' and skillName ~= 'prestige' then
            if getSkillLevel(xp) >= 100 then
                hasMaxSkill = true
                break
            end
        end
    end
    
    if not hasMaxSkill then
        return false, _U('min_level_prestige')
    end
    
    -- Reset all skills to 0
    local resetQuery = 'UPDATE rde_player_skills SET '
    local updates = {}
    for skillName, _ in pairs(Config.Skills) do
        table.insert(updates, skillName .. ' = 0')
    end
    resetQuery = resetQuery .. table.concat(updates, ', ')
    resetQuery = resetQuery .. ', prestige = prestige + 1 WHERE charid = ?'
    
    MySQL.update.await(resetQuery, {charid})
    
    -- Keep reputation if configured
    if not Config.Prestige.keepReputation then
        local resetRep = 'UPDATE rde_player_reputation SET '
        local repUpdates = {}
        for factionName, _ in pairs(Config.Factions) do
            table.insert(repUpdates, factionName .. ' = 0')
        end
        resetRep = resetRep .. table.concat(repUpdates, ', ') .. ' WHERE charid = ?'
        MySQL.update.await(resetRep, {charid})
    end
    
    -- Invalidate cache
    playerCache[charid] = nil
    
    local newPrestige = prestige + 1
    
    -- 🔥 Update statebag
    local updatedSkills = loadPlayerSkills(charid)
    local playerData = {
        skills = updatedSkills,
        reputation = loadPlayerReputation(charid),
        prestige = newPrestige
    }
    updatePlayerStatebag(source, playerData)
    
    -- Give prestige reward
    if Config.Prestige.prestigeRewards[newPrestige] then
        local reward = Config.Prestige.prestigeRewards[newPrestige]
        if reward.money then
            player.addMoney('bank', reward.money)
        end
    end
    
    -- Notify
    if Config.Notifications.prestige then
        TriggerClientEvent('ox_lib:notify', source, {
            title = '👑 Prestige!',
            description = _U('notify_prestige', newPrestige),
            type = 'success',
            icon = 'crown',
            iconColor = '#8b5cf6',
            duration = 10000
        })
    end
    
    return true, newPrestige
end

-- ============================================
-- 📤 EXPORTS FOR OTHER RESOURCES
-- ============================================
exports('getPlayerSkillLevel', function(source, skill)
    local player = Ox.GetPlayer(source)
    if not player then return 0 end
    
    local skills = loadPlayerSkills(player.charId)
    return getSkillLevel(skills[skill] or 0)
end)

exports('getPlayerSkillXP', function(source, skill)
    local player = Ox.GetPlayer(source)
    if not player then return 0 end
    
    local skills = loadPlayerSkills(player.charId)
    return skills[skill] or 0
end)

exports('addSkillXP', function(source, skill, amount)
    return addSkillXP(source, skill, amount, false)
end)

exports('setSkillXP', function(source, skill, xp)
    local player = Ox.GetPlayer(source)
    if not player then return false end

    if not Config.Skills or not Config.Skills[skill] then return false end

    MySQL.update.await('UPDATE rde_player_skills SET '..skill..' = ? WHERE charid = ?', {xp, player.charId})
    
    -- Invalidate cache
    if playerCache[player.charId] then
        playerCache[player.charId].skills = nil
    end
    
    -- Update statebag
    local updatedSkills = loadPlayerSkills(player.charId)
    local playerData = {
        skills = updatedSkills,
        reputation = loadPlayerReputation(player.charId),
        prestige = updatedSkills.prestige or 0
    }
    updatePlayerStatebag(source, playerData)
    
    local level = getSkillLevel(xp)
    TriggerClientEvent('rde_skills:updateNativeSkill', source, skill, level)
    return true
end)

exports('getPlayerReputation', function(source, faction)
    local player = Ox.GetPlayer(source)
    if not player then return 0 end
    
    local rep = loadPlayerReputation(player.charId)
    return rep[faction] or 0
end)

exports('modifyReputation', function(source, faction, amount)
    return modifyReputation(source, faction, amount)
end)

exports('getPlayerPrestige', function(source)
    local player = Ox.GetPlayer(source)
    if not player then return 0 end
    
    local skills = loadPlayerSkills(player.charId)
    return skills.prestige or 0
end)

-- ============================================
-- 🎮 EVENT HANDLERS
-- ============================================
RegisterNetEvent('rde_skills:requestData', function()
    local src = source
    local player = Ox.GetPlayer(src)

    if not player or not player.charId then 
        debugPrint('Request data failed: No player or charId')
        return 
    end

    local skills = loadPlayerSkills(player.charId)
    local reputation = loadPlayerReputation(player.charId)
    local achievements = loadPlayerAchievements(player.charId)
    local prestige = skills.prestige or 0
    local totalLevel = getTotalLevel(skills)

    debugPrint('Sending data to player:', player.name, 'CharID:', player.charId)
    
    -- 🔥 Update statebag
    local playerData = {
        skills = skills,
        reputation = reputation,
        prestige = prestige,
        totalLevel = totalLevel,
        achievements = achievements
    }
    updatePlayerStatebag(src, playerData)
    
    -- Also send via event for initial load
    TriggerClientEvent('rde_skills:receiveData', src, skills, reputation, achievements, prestige)
end)

RegisterNetEvent('rde_skills:addSkillXP', function(skill, amount)
    addSkillXP(source, skill, amount, false)
end)

RegisterNetEvent('rde_skills:modifyReputation', function(faction, amount)
    modifyReputation(source, faction, amount)
end)

RegisterNetEvent('rde_skills:requestPrestige', function()
    local success, result = prestigeSkills(source)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = result,
            type = 'error',
            icon = 'alert-circle',
            duration = 5000
        })
    end
end)

-- ============================================
-- 🎮 AUTOMATIC XP GAIN (Server-Side Tracking)
-- ============================================

-- Driving XP (server-side calculation for security)
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        
        for _, playerId in ipairs(activePlayers) do
            local ped = GetPlayerPed(playerId)
            if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == ped then
                    local speed = GetEntitySpeed(vehicle) * 3.6
                    if speed > 30 then
                        local xpGain = math.min(math.floor(speed / 40), 5)
                        addSkillXP(playerId, 'driving', xpGain, true)
                    end
                end
            end
        end
    end
end)

-- Combat XP (weapon damage tracking)
AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        local weaponHash = data[7]

        if attacker and attacker > 0 and DoesEntityExist(attacker) then
            local attackerPed = attacker
            local attackerPlayer = NetworkGetPlayerIndexFromPed(attackerPed)

            if attackerPlayer and attackerPlayer >= 0 then
                local attackerServerId = GetPlayerServerId(attackerPlayer)

                if attackerServerId and attackerServerId > 0 then
                    if weaponHash and weaponHash ~= 0 then
                        local weaponType = GetWeapontypeGroup(weaponHash)

                        -- Shooting XP
                        if weaponType == 416676503 or weaponType == 860033945 or weaponType == 970310034 then
                            addSkillXP(attackerServerId, 'shooting', math.random(2, 3), true)
                        -- Strength XP
                        elseif weaponHash == `WEAPON_UNARMED` or weaponType == 2685387236 then
                            addSkillXP(attackerServerId, 'strength', math.random(1, 2), true)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 💾 AUTO-SAVE SYSTEM
-- ============================================
if Config.AutoSaveInterval and Config.AutoSaveInterval > 0 then
    CreateThread(function()
        while true do
            Wait(Config.AutoSaveInterval)
            
            debugPrint('Auto-saving player data...')
            local count = 0
            
            for charid, data in pairs(playerCache) do
                -- Cache is already synced with DB via our update functions
                count = count + 1
            end
            
            debugPrint('Auto-save complete for', count, 'players')
        end
    end)
end

-- ============================================
-- 👑 ADMIN COMMANDS
-- ============================================
lib.addCommand('giveskillxp', {
    help = 'Give skill XP to a player (Admin only)',
    params = {
        {name = 'player', type = 'playerId', help = 'Player ID'},
        {name = 'skill', type = 'string', help = 'Skill name'},
        {name = 'amount', type = 'number', help = 'XP amount'}
    },
    restricted = false -- We handle admin check manually for triple verification
}, function(source, args)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('admin_only'),
            type = 'error',
            icon = 'shield-alert',
            duration = 5000
        })
        return
    end
    
    local success, result, level = addSkillXP(args.player, args.skill, args.amount, false)

    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = '✅ Admin',
            description = ('Gave %d XP to %s (Level %d) for player %d'):format(args.amount, args.skill, level, args.player),
            type = 'success',
            icon = 'check-circle',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Failed: ' .. (result or 'Unknown error'),
            type = 'error',
            icon = 'alert-circle',
            duration = 5000
        })
    end
end)

lib.addCommand('setskill', {
    help = 'Set player skill level (Admin only)',
    params = {
        {name = 'player', type = 'playerId', help = 'Player ID'},
        {name = 'skill', type = 'string', help = 'Skill name'},
        {name = 'level', type = 'number', help = 'Level (0-100)'}
    },
    restricted = false
}, function(source, args)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('admin_only'),
            type = 'error',
            icon = 'shield-alert',
            duration = 5000
        })
        return
    end
    
    local xp = args.level * 100
    local success = exports.rde_skills_ultimate:setSkillXP(args.player, args.skill, xp)

    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = '✅ Admin',
            description = ('Set %s to level %d for player %d'):format(args.skill, args.level, args.player),
            type = 'success',
            icon = 'check-circle',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Failed to set skill',
            type = 'error',
            icon = 'alert-circle',
            duration = 5000
        })
    end
end)

lib.addCommand('giverep', {
    help = 'Give reputation to a player (Admin only)',
    params = {
        {name = 'player', type = 'playerId', help = 'Player ID'},
        {name = 'faction', type = 'string', help = 'Faction name'},
        {name = 'amount', type = 'number', help = 'Reputation amount'}
    },
    restricted = false
}, function(source, args)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('admin_only'),
            type = 'error',
            icon = 'shield-alert',
            duration = 5000
        })
        return
    end
    
    local success, result = modifyReputation(args.player, args.faction, args.amount)

    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = '✅ Admin',
            description = ('Gave %d reputation to %s for player %d'):format(args.amount, args.faction, args.player),
            type = 'success',
            icon = 'check-circle',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = 'Failed: ' .. (result or 'Unknown error'),
            type = 'error',
            icon = 'alert-circle',
            duration = 5000
        })
    end
end)

lib.addCommand('resetskills', {
    help = 'Reset all skills for a player (Admin only)',
    params = {
        {name = 'player', type = 'playerId', help = 'Player ID'}
    },
    restricted = false
}, function(source, args)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('admin_only'),
            type = 'error',
            icon = 'shield-alert',
            duration = 5000
        })
        return
    end
    
    local player = Ox.GetPlayer(args.player)
    if not player then
        TriggerClientEvent('ox_lib:notify', source, {
            title = _U('error'),
            description = _U('player_not_found'),
            type = 'error'
        })
        return
    end
    
    local resetQuery = 'UPDATE rde_player_skills SET '
    local updates = {}
    for skillName, _ in pairs(Config.Skills) do
        table.insert(updates, skillName .. ' = 0')
    end
    resetQuery = resetQuery .. table.concat(updates, ', ') .. ' WHERE charid = ?'
    
    MySQL.update.await(resetQuery, {player.charId})
    
    -- Invalidate cache
    playerCache[player.charId] = nil
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = '✅ Admin',
        description = ('Reset all skills for player %d'):format(args.player),
        type = 'success',
        icon = 'refresh-cw',
        duration = 5000
    })
    
    TriggerClientEvent('rde_skills:requestData', args.player)
end)

-- ============================================
-- 🔄 OX_CORE EVENT HANDLERS
-- ============================================
AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    debugPrint('Player loaded:', playerId, 'CharID:', charId)
    
    -- Add to active players
    table.insert(activePlayers, playerId)
    
    -- Pre-load and cache data
    loadPlayerSkills(charId)
    loadPlayerReputation(charId)
    
    -- Initialize statebag
    Wait(1000)
    TriggerEvent('rde_skills:requestData', playerId)
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    debugPrint('Player logout:', playerId, 'CharID:', charId)
    
    -- Remove from active players
    for i, id in ipairs(activePlayers) do
        if id == playerId then
            table.remove(activePlayers, i)
            break
        end
    end
    
    -- Clear cache
    if playerCache[charId] then
        playerCache[charId] = nil
    end
    
    -- Clean up notification cache
    for key in pairs(lastNotification) do
        if key:match('^' .. playerId .. '_') then
            lastNotification[key] = nil
        end
    end
end)

-- ============================================
-- 🚀 INITIALIZATION
-- ============================================
CreateThread(function()
    -- Build active players list
    Wait(5000)
    local players = Ox.GetPlayers()
    for _, playerId in pairs(players) do
        table.insert(activePlayers, playerId)
    end
    
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^2[RDE | SKILL SYSTEM]^7 🚀 RDE |  SKILL SYSTEM")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^3[RDE | SKILL SYSTEM]^7 Features:")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Real-time statebag sync")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ 11 Skills with perks & milestones")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ 5 Faction reputations")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Achievement system")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Prestige system")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Skill synergies")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Triple admin verification")
    print("^3[RDE | SKILL SYSTEM]^7 ✅ Performance optimized")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^3[RDE | SKILL SYSTEM]^7 Player Commands:")
    print("^3[RDE | SKILL SYSTEM]^7 - /skills (Open skills menu)")
    print("^3[RDE | SKILL SYSTEM]^7 - /toggleskillhud (Toggle HUD)")
    print("^3[RDE | SKILL SYSTEM]^7 - /prestige (Reset skills for bonuses)")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^3[RDE | SKILL SYSTEM]^7 Admin Commands:")
    print("^3[RDE | SKILL SYSTEM]^7 - /giveskillxp [player] [skill] [amount]")
    print("^3[RDE | SKILL SYSTEM]^7 - /setskill [player] [skill] [level]")
    print("^3[RDE | SKILL SYSTEM]^7 - /giverep [player] [faction] [amount]")
    print("^3[RDE | SKILL SYSTEM]^7 - /resetskills [player]")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
    print("^2[RDE | SKILL SYSTEM]^7 Author: RDE | SerpentsByte")
    print("^2[RDE | SKILL SYSTEM]^7 AAA+++ Production Quality")
    print("^2[RDE | SKILL SYSTEM]^7 ========================================")
end)

---------------------------
-- RDE | Update System
---------------------------

-- ⚡ RDE | Update Checker ⚡
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

-- 🎨 Print a styled header
local function printHeader()
    print('\n' ..
        Config.ConsoleColors.header ..
        '╔════════════════════════════════════════════╗\n' ..
        '║ ' .. Config.ConsoleIcons.rde_logo .. '          RDE UPDATE CHECKER          ' .. Config.ConsoleIcons.rde_logo .. ' ║\n' ..
        '║            by SerpentsByte               ║\n' ..
        '╚════════════════════════════════════════════╝' ..
        Config.ConsoleColors.reset
    )
end

-- 📡 Fetch remote version
local function fetchRemoteVersion()
    PerformHttpRequest(Config.RemoteVersionURL, function(status, response)
        if status ~= 200 then
            print(('%s [%sUPDATE CHECK%s] Error fetching remote version: HTTP %d'):format(
                Config.ConsoleIcons.error,
                Config.ConsoleColors.error,
                Config.ConsoleColors.reset,
                status
            ))
            return
        end

        local remoteVersion = response:gsub('%s+', '')  -- Remove whitespace
        if remoteVersion ~= currentVersion then
            -- 🔥 New version available!
            print('\n' ..
                Config.ConsoleColors.update_available ..
                Config.ConsoleIcons.update_available ..
                ' NEW VERSION AVAILABLE!' ..
                Config.ConsoleColors.reset ..
                '\nCurrent: ' .. currentVersion ..
                ' | Latest: ' .. remoteVersion ..
                '\nDownload: ' .. Config.DownloadLink ..
                '\n----------------------------------------'
            )

            -- 📢 Notify admins in-game (optional)
            if Config.AdminNotification then
                TriggerEvent('rde:notifyAdminUpdate', remoteVersion)
            end
        else
            -- ✅ Up to date
            print(('%s %sScript is up to date (%s)%s'):format(
                Config.ConsoleIcons.up_to_date,
                Config.ConsoleColors.up_to_date,
                currentVersion,
                Config.ConsoleColors.reset
            ))
        end
    end, 'GET')
end

-- 🕒 Check version on resource start
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        printHeader()
        print('Checking for updates...')
        fetchRemoteVersion()
    end
end)

function _U(key, ...)
    if Config.Languages and Config.Languages[Config.Language] then
        local translation = Config.Languages[Config.Language][key] or key
        if ... then
            return string.format(translation, ...)
        end
        return translation
    end
    return key
end