-- ====================================
-- RDE | SKILLS SYSTEM - CONFIG (Enhanced Production Version)
-- ====================================
Config = {}

-- Language Settings (English Default)
Config.Language = 'en'

-- Debug Mode
Config.Debug = false

-- XP Settings
Config.XPGainInterval = 10000 -- Check interval in ms for automatic XP gain
Config.XPNotifyThreshold = 10 -- Notify after gaining X XP at once
Config.NotificationCooldown = 5000 -- Cooldown between XP notifications (ms)

-- HUD Settings
Config.HUD = {
    enabled = true,
    position = { x = 0.85, y = 0.75 },
    barWidth = 0.15,
    barHeight = 0.015,
    spacing = 0.03,
    hideAtZero = true,
    showLevelOnly = false,
    colors = {
        low = { r = 52, g = 211, b = 153 },      -- Green
        medium = { r = 251, g = 191, b = 36 },   -- Yellow
        high = { r = 239, g = 68, b = 68 }       -- Red
    }
}

-- Notification Settings
Config.Notifications = {
    enabled = true,
    levelUp = true,
    xpGain = false, -- Set to false to prevent spam
    reputation = true
}

-- Native GTA Skills Integration
-- These skills will affect native GTA V stats
Config.NativeSkillsEnabled = true
Config.NativeSkills = {
    driving = 'MP0_DRIVING_ABILITY',
    shooting = 'MP0_SHOOTING_ABILITY',
    fitness = 'MP0_STAMINA',
    strength = 'MP0_STRENGTH',
    flying = 'MP0_FLYING_ABILITY',
    stealth = 'MP0_STEALTH_ABILITY'
}

-- Localization
Config.Languages = {
    ['en'] = {
        ['skills_title'] = '📊 Skills',
        ['skills_description'] = 'Your abilities and progress',
        ['reputation_title'] = '⭐ Reputation',
        ['reputation_description'] = 'Your reputation with different groups',
        ['skill_level'] = 'Level: %s | Progress: %s%%',
        ['reputation_value'] = 'Reputation: %s',
        ['menu_already_open'] = 'Menu is already open!',
        ['hud_toggled_on'] = 'Skill HUD activated',
        ['hud_toggled_off'] = 'Skill HUD deactivated',
        ['skill_driving'] = '🚗 Driving',
        ['skill_shooting'] = '🎯 Shooting',
        ['skill_fitness'] = '🏃 Fitness',
        ['skill_strength'] = '💪 Strength',
        ['skill_flying'] = '✈️ Flying',
        ['skill_stealth'] = '🥷 Stealth',
        ['skill_hacking'] = '💻 Hacking',
        ['skill_mechanics'] = '🔧 Mechanics',
        ['skill_cooking'] = '🍳 Cooking',
        ['skill_charisma'] = '💬 Charisma',
        ['faction_police'] = 'Police',
        ['faction_gangs'] = 'Gangs',
        ['faction_medics'] = 'Medics',
        ['faction_mechanics'] = 'Mechanics',
        ['faction_civilians'] = 'Civilians',
        ['notify_skill_up'] = '🎯 Level Up! %s reached Level %s',
        ['notify_reputation'] = '⭐ Reputation: %s %s%s',
        ['notify_xp_gain'] = '+%s XP | %s',
        ['max_level'] = 'MAX',
    },
    ['de'] = {
        ['skills_title'] = '📊 Fähigkeiten',
        ['skills_description'] = 'Deine Fähigkeiten und Fortschritt',
        ['reputation_title'] = '⭐ Reputation',
        ['reputation_description'] = 'Dein Ruf bei verschiedenen Gruppen',
        ['skill_level'] = 'Level: %s | Fortschritt: %s%%',
        ['reputation_value'] = 'Reputation: %s',
        ['menu_already_open'] = 'Menü ist bereits geöffnet!',
        ['hud_toggled_on'] = 'Skill HUD aktiviert',
        ['hud_toggled_off'] = 'Skill HUD deaktiviert',
        ['skill_driving'] = '🚗 Fahren',
        ['skill_shooting'] = '🎯 Schießen',
        ['skill_fitness'] = '🏃 Fitness',
        ['skill_strength'] = '💪 Kraft',
        ['skill_flying'] = '✈️ Fliegen',
        ['skill_stealth'] = '🥷 Schleichen',
        ['skill_hacking'] = '💻 Hacken',
        ['skill_mechanics'] = '🔧 Mechanik',
        ['skill_cooking'] = '🍳 Kochen',
        ['skill_charisma'] = '💬 Charisma',
        ['faction_police'] = 'Polizei',
        ['faction_gangs'] = 'Gangs',
        ['faction_medics'] = 'Sanitäter',
        ['faction_mechanics'] = 'Mechaniker',
        ['faction_civilians'] = 'Zivilisten',
        ['notify_skill_up'] = '🎯 Level Up! %s hat Level %s erreicht',
        ['notify_reputation'] = '⭐ Reputation: %s %s%s',
        ['notify_xp_gain'] = '+%s XP | %s',
        ['max_level'] = 'MAX',
    }
}

-- Skill Configuration
Config.Skills = {
    driving = {
        label = 'skill_driving',
        maxLevel = 100,
        xpPerLevel = 100,
        xpMultiplier = 1.0,
        nativeSkill = 'MP0_DRIVING_ABILITY',
        icon = 'fa-solid fa-car',
        color = '#3498db',
        boostMultiplier = 0.05 -- 5% boost per 10 levels
    },
    shooting = {
        label = 'skill_shooting',
        maxLevel = 100,
        xpPerLevel = 120,
        xpMultiplier = 1.2,
        nativeSkill = 'MP0_SHOOTING_ABILITY',
        icon = 'fa-solid fa-bullseye',
        color = '#e74c3c',
        boostMultiplier = 0.05
    },
    fitness = {
        label = 'skill_fitness',
        maxLevel = 100,
        xpPerLevel = 120,
        xpMultiplier = 1.2,
        nativeSkill = 'MP0_STAMINA',
        icon = 'fa-solid fa-person-running',
        color = '#2ecc71',
        boostMultiplier = 0.05
    },
    strength = {
        label = 'skill_strength',
        maxLevel = 100,
        xpPerLevel = 130,
        xpMultiplier = 1.3,
        nativeSkill = 'MP0_STRENGTH',
        icon = 'fa-solid fa-dumbbell',
        color = '#f39c12',
        boostMultiplier = 0.05
    },
    flying = {
        label = 'skill_flying',
        maxLevel = 100,
        xpPerLevel = 150,
        xpMultiplier = 1.5,
        nativeSkill = 'MP0_FLYING_ABILITY',
        icon = 'fa-solid fa-plane',
        color = '#9b59b6',
        boostMultiplier = 0.05
    },
    stealth = {
        label = 'skill_stealth',
        maxLevel = 100,
        xpPerLevel = 110,
        xpMultiplier = 1.1,
        nativeSkill = 'MP0_STEALTH_ABILITY',
        icon = 'fa-solid fa-user-ninja',
        color = '#34495e',
        boostMultiplier = 0.05
    },
    hacking = {
        label = 'skill_hacking',
        maxLevel = 100,
        xpPerLevel = 150,
        xpMultiplier = 1.5,
        icon = 'fa-solid fa-laptop-code',
        color = '#1abc9c',
        boostMultiplier = 0.05
    },
    mechanics = {
        label = 'skill_mechanics',
        maxLevel = 100,
        xpPerLevel = 130,
        xpMultiplier = 1.3,
        icon = 'fa-solid fa-wrench',
        color = '#95a5a6',
        boostMultiplier = 0.05
    },
    cooking = {
        label = 'skill_cooking',
        maxLevel = 100,
        xpPerLevel = 110,
        xpMultiplier = 1.1,
        icon = 'fa-solid fa-bowl-food',
        color = '#e67e22',
        boostMultiplier = 0.05
    },
    charisma = {
        label = 'skill_charisma',
        maxLevel = 100,
        xpPerLevel = 140,
        xpMultiplier = 1.4,
        icon = 'fa-solid fa-comments',
        color = '#f1c40f',
        boostMultiplier = 0.05
    }
}

-- Faction Configuration
Config.Factions = {
    police = {
        label = 'faction_police',
        icon = 'fa-solid fa-shield-halved',
        color = '#3498db'
    },
    gangs = {
        label = 'faction_gangs',
        icon = 'fa-solid fa-people-group',
        color = '#e74c3c'
    },
    medics = {
        label = 'faction_medics',
        icon = 'fa-solid fa-user-doctor',
        color = '#2ecc71'
    },
    mechanics = {
        label = 'faction_mechanics',
        icon = 'fa-solid fa-screwdriver-wrench',
        color = '#f39c12'
    },
    civilians = {
        label = 'faction_civilians',
        icon = 'fa-solid fa-user',
        color = '#95a5a6'
    }
}

---------------------------
-- RDE | Update System
---------------------------

-- 🌐 Remote version file (hosted on your server)
Config.RemoteVersionURL = 'https://github.com/rde_skills/version.txt'

-- 📦 Download link for updates
Config.DownloadLink = 'https://github.com/rde_skills/'

-- 🎨 Console icons (Lucide-inspired)
Config.ConsoleIcons = {
    update_available = '🔄',  -- Update icon
    up_to_date = '✅',        -- Checkmark
    error = '❌',             -- Error icon
    rde_logo = '⚡'           -- RDE branding
}

-- 🎨 ANSI color codes for console
Config.ConsoleColors = {
    header = '^5',           -- Purple (RDE branding)
    update_available = '^3',  -- Yellow (warning)
    up_to_date = '^2',        -- Green (success)
    error = '^1',             -- Red (error)
    reset = '^7'              -- Default
}

-- 📢 Admin notification settings (optional)
Config.AdminNotification = true  -- Enable/disable in-game admin alerts


-- Localization Helper
function _U(key, ...)
    local translation = Config.Languages[Config.Language] and Config.Languages[Config.Language][key] or key
    if ... then
        return string.format(translation, ...)
    end
    return translation
end

-- Export config for client/server
AddEventHandler('rde_skills:getConfig', function(cb)
    cb(Config)
end)