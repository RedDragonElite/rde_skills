-- ============================================
-- 🎯 RDE ULTIMATE SKILL SYSTEM - MANIFEST
-- Author: RDE | SerpentsByte
-- Version: 3.0.0 - AAA+++ PRODUCTION
-- ============================================

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'RDE | SKILLS'
author 'RDE | SerpentsByte'
version '1.0.0'
description 'RDE | Skill System - Statebag Sync | Real-Time | ox_core Elite'

-- ============================================
-- 🔧 SHARED SCRIPTS
-- ============================================
shared_scripts {
    '@ox_lib/init.lua',
    '@ox_core/lib/init.lua',
    'config.lua'
}

-- ============================================
-- 🎮 CLIENT SCRIPTS
-- ============================================
client_scripts {
    'client.lua'
}

-- ============================================
-- 🧠 SERVER SCRIPTS
-- ============================================
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

-- ============================================
-- 📦 DEPENDENCIES
-- ============================================
dependencies {
    'ox_core',      -- Framework foundation
    'ox_lib',       -- UI & utilities
    'ox_inventory', -- Item integration
    'ox_target',    -- Interaction system
    'oxmysql'       -- Database
}

-- ============================================
-- 📝 NOTES
-- ============================================
-- Features:
-- ✅ Real-time statebag synchronization
-- ✅ 10+ Skills with native GTA integration
-- ✅ Reputation system with 5+ factions
-- ✅ Skill perks & milestones
-- ✅ Prestige system for endgame
-- ✅ Achievement tracking
-- ✅ Beautiful UI with lucide icons
-- ✅ Triple admin verification (ACE + Steam + ox_core)
-- ✅ Performance optimized (200+ players)
-- ✅ Full localization (EN + DE)
-- ✅ Activity-based XP gain
-- ✅ Skill synergies & bonuses
-- ============================================