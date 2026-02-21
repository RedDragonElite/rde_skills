# 🎯 RDE Skills — Next-Generation Skill Progression System
![dl_1771639784566](https://github.com/user-attachments/assets/1bf2704a-225b-436b-ae46-da310d356e6e)

<div align="center">

![Version](https://img.shields.io/badge/version-3.0.0-red?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-RDE%20Black%20Flag%20v6.66-black?style=for-the-badge)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=for-the-badge)
![ox_core](https://img.shields.io/badge/ox__core-Required-blue?style=for-the-badge)
![Free](https://img.shields.io/badge/price-FREE%20FOREVER-brightgreen?style=for-the-badge)

**11+ customizable skills, faction reputation, achievements, prestige system, and native GTA skill integration.**
Built on ox_core · ox_lib · oxmysql · Statebag sync · Triple admin verification

*Built by [Red Dragon Elite](https://rd-elite.com) | SerpentsByte*

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Dependencies](#-dependencies)
- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Skills System](#-skills-system)
- [Reputation System](#-reputation-system)
- [Exports & API](#-exports--api)
- [Admin System](#-admin-system)
- [Commands](#-commands)
- [Performance](#-performance)
- [Changelog](#-changelog)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

**RDE Skills** is a production-grade skill progression system for FiveM servers running ox_core. Real-time statebag synchronization, automatic XP gain through player activities, native GTA V stat integration, faction reputation, a full achievement system, and a prestige layer — all in one resource, free forever.

### Why RDE Skills?

| Feature | Generic Skill Scripts | RDE Skills |
|---|---|---|
| Real-time sync | Polling / delayed | ✅ Statebag — instant |
| Native GTA integration | ❌ | ✅ 6 native stat hooks |
| Faction reputation | ❌ | ✅ 5 factions |
| Prestige system | ❌ | ✅ Permanent bonuses |
| Achievement tracking | ❌ | ✅ Full system |
| Skill synergies | ❌ | ✅ Combined bonuses |
| Triple admin verification | ❌ | ✅ ACE + ox_core + Steam |
| Performance (200+ players) | ❌ | ✅ Tested & benchmarked |

---

## ✨ Features

### 🎮 Core Gameplay

**11 Customizable Skills** — Driving, Shooting, Fitness, Strength, Flying, Stealth, Hacking, Mechanics, Cooking, Charisma, Fishing

**Real-Time XP Progression** — Automatic XP gain from player activities: running, driving, shooting, flying, sneaking — no manual triggers needed for the core skills

**Native GTA Skill Integration** — Syncs directly with GTA V's native skill stats (`MP0_DRIVING_ABILITY`, `MP0_STAMINA`, etc.) for tangible gameplay effects

**Skill Perks & Milestones** — Unlock special abilities and bonuses at levels 25, 50, 75, and 100

**Prestige System** — Reset all skills for permanent stat bonuses and elite status markers

**Faction Reputation** — Build or destroy relationships with Police, Gangs, Medics, Mechanics, and Civilians — affects prices, access, and interactions

**Achievement System** — Track and reward player accomplishments automatically

**Skill Synergies** — Combine multiple high-level skills for powerful stacking bonuses

**Interactive HUD** — Toggle-able skill display with live progress bars and real-time updates

### 🔧 Technical

- Statebag sync — real-time skill updates broadcast to all clients without polling
- Cache system — reduces database queries by ~70%
- Triple admin verification — ACE + ox_core groups + Steam ID whitelist
- Auto table creation — no manual SQL import on first run
- Notification cooldown system — no spam, clean UX
- Built-in debug mode for development
- Built-in version checker with admin notifications

---

## 📦 Dependencies

| Resource | Required | Notes |
|---|---|---|
| [oxmysql](https://github.com/communityox/oxmysql) | ✅ Required | Database layer |
| [ox_core](https://github.com/communityox/ox_core) | ✅ Required | Player/character framework |
| [ox_lib](https://github.com/communityox/ox_lib) | ✅ Required | UI, callbacks, notifications |
| [ox_inventory](https://github.com/communityox/ox_inventory) | ⚠️ Optional | Item-based skill boosts |
| [ox_target](https://github.com/communityox/ox_target) | ⚠️ Optional | Interaction system |

---

## 🚀 Installation

### 1. Clone the repository

```bash
cd resources
git clone https://github.com/RedDragonElite/rde_skills.git
```

### 2. Add to `server.cfg`

```cfg
ensure oxmysql
ensure ox_core
ensure ox_lib
ensure ox_target      # optional
ensure ox_inventory   # optional
ensure rde_skills
```

> **Order matters.** `rde_skills` must start **after** all its dependencies.

### 3. Database

Tables are created automatically on first run. No manual SQL import needed. Four tables are created:

```
rde_player_skills       — skill XP and levels per character
rde_player_reputation   — faction relationship values
rde_player_achievements — achievement tracking
rde_player_perks        — unlocked perk storage
```

### 4. Configure (Optional)

Edit `config.lua` to adjust skill rates, XP amounts, admin permissions, language, and HUD position.

### 5. Restart

```
restart rde_skills
```

Test with `/skills` in-game.

---

## ⚙️ Configuration

### Basic

```lua
Config = {
    Debug               = false,   -- verbose console output
    Language            = 'en',    -- 'en' or 'de'
    NativeSkillsEnabled = true,    -- sync with GTA native stats
    NotificationCooldown = 5000,   -- ms between notifications
    XPGainInterval      = 10000,   -- ms between auto XP checks
    CacheEnabled        = true,    -- reduces DB queries
}
```

### Skill Definition Example

```lua
Config.Skills = {
    driving = {
        label        = 'skill_driving',
        icon         = 'fa-solid fa-car',
        color        = '#3498db',
        maxLevel     = 100,
        xpMultiplier = 1.0,
        boostMultiplier = 0.05,           -- 5% boost per 10 levels
        nativeSkill  = 'MP0_DRIVING_ABILITY',
        perks = {
            [25]  = 'Unlock: Faster acceleration',
            [50]  = 'Unlock: Reduced vehicle damage',
            [75]  = 'Unlock: Improved handling',
            [100] = 'Master: Perfect control',
        }
    }
}
```

### Admin System

```lua
Config.AdminSystem = {
    checkOrder    = {'ace', 'oxcore', 'steam'},
    acePermission = 'rde.skills.admin',
    oxGroups      = { admin = 0, moderator = 1 },
    steamIds      = { 'steam:110000xxxxxxxx' },
}
```

### ACE Permissions (server.cfg)

```cfg
add_ace group.admin rde.skills.admin allow
add_principal identifier.steam:110000xxxxxxxx group.admin
```

---

## 🎮 Skills System

### Available Skills

| Skill | Auto XP Source | Native Stat |
|---|---|---|
| Driving | Driving vehicles | ✅ MP0_DRIVING_ABILITY |
| Shooting | Using firearms | ✅ MP0_SHOOTING_ABILITY |
| Fitness | Running / sprinting | ✅ MP0_STAMINA |
| Strength | Physical activities | ✅ MP0_STRENGTH |
| Flying | Planes / helicopters | ✅ MP0_FLYING_ABILITY |
| Stealth | Crouching / sneaking | ✅ MP0_STEALTH_ABILITY |
| Hacking | Manual trigger | — |
| Mechanics | Manual trigger | — |
| Cooking | Manual trigger | — |
| Charisma | Manual trigger | — |
| Fishing | Manual trigger | — |

### Progression

- **100 XP = 1 Level** — configurable per skill
- **Max Level** — 100 by default, adjustable per skill
- **Perks** — unlock at levels 25, 50, 75, 100

### Auto XP Rates (defaults)

- Fitness: 1–2 XP per interval while sprinting
- Flying: 2–4 XP per 30 seconds airborne
- Stealth: 1 XP per 15 seconds while crouching
- Driving / Shooting: via manual trigger or custom events

### Manual XP (from other resources)

```lua
-- Server-side
TriggerEvent('rde_skills:addSkillXP', playerId, 'driving', 10)

-- Client-side
TriggerServerEvent('rde_skills:addSkillXP', 'shooting', 5)
```

---

## ⭐ Reputation System

### Factions

| Faction | Effect |
|---|---|
| Police | Affects wanted level interactions and police cooldowns |
| Gangs | Territory access, black market pricing |
| Medics | Hospital costs, priority treatment |
| Mechanics | Repair costs, upgrade access |
| Civilians | Job availability, general store pricing |

### Reputation Scale

```
-1000 to -500  →  Hostile
 -499 to -100  →  Unfriendly
   -99 to  99  →  Neutral
  100 to  499  →  Friendly
  500 to 1000  →  Allied
```

### Managing Reputation

```lua
-- From client
TriggerServerEvent('rde_skills:addReputation', 'police', 10)

-- Read via statebag
local rep = Player(source).state.reputation.police
```

---

## 🔧 Exports & API

### Server-Side

```lua
-- Get all skills for a player
local skills = exports.rde_skills:getPlayerSkills(source)

-- Get a specific skill level
local level = exports.rde_skills:getSkillLevel(source, 'driving')

-- Get faction reputation
local rep = exports.rde_skills:getPlayerReputation(source, 'police')

-- Add XP programmatically
exports.rde_skills:addSkillXP(source, 'shooting', 50)

-- Add reputation
exports.rde_skills:addReputation(source, 'police', 25)

-- Skill requirement check
local canUse = exports.rde_skills:hasSkillLevel(source, 'hacking', 50)
```

### Client-Side

```lua
-- Open skills menu
exports.rde_skills:openSkillsMenu()

-- Get locally cached skills
local skills = exports.rde_skills:getLocalSkills()

-- Toggle HUD
exports.rde_skills:toggleHUD()
```

### Statebag Access (any resource)

```lua
-- Server-side
local player   = Player(source)
local skills   = player.state.skills
local total    = player.state.totalLevel
local prestige = player.state.prestige

-- Client-side
local player  = Player(GetPlayerServerId(PlayerId()))
local driving = player.state.skills.driving or 0
```

---

## 🛡️ Admin System

Triple-layer verification runs in configurable order — `ace` → `oxcore` → `steam`. All three must fail before access is denied.

```lua
Config.AdminSystem = {
    checkOrder    = {'ace', 'oxcore', 'steam'},
    acePermission = 'rde.skills.admin',
    oxGroups      = {
        admin     = 0,   -- any grade
        moderator = 1,   -- grade 1+
    },
    steamIds = {
        'steam:110000xxxxxxxx',
    },
}
```

---

## 📋 Commands

### Player

| Command | Description |
|---|---|
| `/skills` | Open the skills menu |
| `/toggleskillhud` | Toggle the HUD overlay |
| `/prestige` | Reset skills for permanent prestige bonuses |

### Admin

| Command | Usage | Description |
|---|---|---|
| `/giveskillxp` | `[id] [skill] [amount]` | Give XP to a player |
| `/setskill` | `[id] [skill] [level]` | Set a skill to a specific level |
| `/giverep` | `[id] [faction] [amount]` | Adjust faction reputation |
| `/resetskills` | `[id]` | Reset all skills for a player |

---

## ⚡ Performance

### Benchmarks

| Players | RAM | CPU | SQL Queries/min |
|---|---|---|---|
| 32 | ~15 MB | <1% | ~20 |
| 64 | ~28 MB | ~1% | ~35 |
| 128 | ~52 MB | ~2% | ~65 |
| 256 | ~95 MB | ~3% | ~120 |

### Optimization Tips

- Keep `Config.CacheEnabled = true` — reduces DB queries by ~70%
- Increase `XPGainInterval` for lower CPU on busy servers
- Use 5000ms+ for `NotificationCooldown` to minimize UI spam
- Tables ship with optimized indexes — don't remove them

---

## 📝 Changelog

### v3.0.0 — Current
- Real-time statebag synchronization
- Native GTA V skill stat integration
- Prestige system
- Achievement tracking
- Triple admin verification
- Auto table creation
- Performance optimizations

### v2.0.0
- Reputation system
- Skill perks & milestones
- HUD display
- Localization (EN/DE)

### v1.0.0
- Initial release
- Basic skill progression
- ox_core integration

---

## 🐛 Troubleshooting

**Skills not syncing to other resources?**
Access via statebag: `Player(source).state.skills`. Make sure you're reading after `ox:playerLoaded` fires.

**Auto XP not triggering?**
Enable `Config.Debug = true` and check console output during player activity. Verify `XPGainInterval` isn't set too high.

**Native GTA stats not applying?**
Ensure `Config.NativeSkillsEnabled = true` and that the player's ped is fully loaded before the sync fires. Check console for native stat errors.

**Admin commands not working?**
Verify your ACE setup in `server.cfg` and that your Steam ID in `Config.AdminSystem.steamIds` is the correct hex format (`steam:110000xxxxxxxxx`).

**Tables not created on first run?**
Make sure `oxmysql` is fully started before `rde_skills`. Adjust the `ensure` order in `server.cfg` if needed.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m 'Add your feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

Guidelines: follow existing Lua conventions, comment complex logic, test on a live server before PR, update docs if adding features.

---

## 📜 License

```
###################################################################################
#                                                                                 #
#      .:: RED DRAGON ELITE (RDE)  -  BLACK FLAG SOURCE LICENSE v6.66 ::.         #
#                                                                                 #
#   PROJECT:    RDE_SKILLS v3.0.0 (NEXT-GEN FIVEM SKILL PROGRESSION SYSTEM)       #
#   ARCHITECT:  .:: RDE ⧌ Shin [△ ᛋᛅᚱᛒᛅᚾᛏᛋ ᛒᛁᛏᛅ ▽] ::. | https://rd-elite.com     #
#   ORIGIN:     https://github.com/RedDragonElite                                 #
#                                                                                 #
#   WARNING: THIS CODE IS PROTECTED BY DIGITAL VOODOO AND PURE HATRED FOR LEAKERS #
#                                                                                 #
#   [ THE RULES OF THE GAME ]                                                     #
#                                                                                 #
#   1. // THE "FUCK GREED" PROTOCOL (FREE USE)                                    #
#      You are free to use, edit, and abuse this code on your server.             #
#      Learn from it. Break it. Fix it. That is the hacker way.                   #
#      Cost: 0.00€. If you paid for this, you got scammed by a rat.               #
#                                                                                 #
#   2. // THE TEBEX KILL SWITCH (COMMERCIAL SUICIDE)                              #
#      Listen closely, you parasites:                                             #
#      If I find this script on Tebex, Patreon, or in a paid "Premium Pack":      #
#      > I will DMCA your store into oblivion.                                    #
#      > I will publicly shame your community.                                    #
#      > I hope your server lag spikes to 9999ms every time you blink.            #
#      SELLING FREE WORK IS THEFT. AND I AM THE JUDGE.                            #
#                                                                                 #
#   3. // THE CREDIT OATH                                                         #
#      Keep this header. If you remove my name, you admit you have no skill.      #
#      You can add "Edited by [YourName]", but never erase the original creator.  #
#      Don't be a skid. Respect the architecture.                                 #
#                                                                                 #
#   4. // THE CURSE OF THE COPY-PASTE                                             #
#      This code uses statebags, native stat hooks, and layered caching.          #
#      If you just copy-paste without reading, it WILL break.                     #
#      Don't come crying to my DMs. RTFM or learn to code.                        #
#                                                                                 #
#   --------------------------------------------------------------------------    #
#   "We build the future on the graves of paid resources."                        #
#   "REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY."                          #
#   --------------------------------------------------------------------------    #
###################################################################################
```

**TL;DR:**
- ✅ Free forever — use it, edit it, learn from it
- ✅ Keep the header — credit where it's due
- ❌ Don't sell it — commercial use = instant DMCA
- ❌ Don't be a skid — copy-paste without reading won't work anyway

---

## 🌐 Community & Support

| | |
|---|---|
| 🐙 GitHub | [RedDragonElite](https://github.com/RedDragonElite) |
| 🌍 Website | [rd-elite.com](https://rd-elite.com) |
| 🔵 Nostr (RDE) | [RedDragonElite](https://primal.net/p/nprofile1qqsv8km2w8yr0sp7mtk3t44qfw7wmvh8caqpnrd7z6ll6mn9ts03teg9ha4rl) |
| 🔵 Nostr (Shin) | [SerpentsByte](https://primal.net/p/nprofile1qqs8p6u423fappfqrrmxful5kt95hs7d04yr25x88apv7k4vszf4gcqynchct) |
| 🚪 RDE Doors | [rde_doors](https://github.com/RedDragonElite/rde_doors) |
| 🚗 RDE Car Service | [rde_carservice](https://github.com/RedDragonElite/rde_carservice) |
| 📡 RDE Nostr Log | [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) |

**When asking for help, always include:**
- Full error from server console or txAdmin
- Your `server.cfg` resource start order
- ox_core / ox_lib versions in use

---

<div align="center">

*"We build the future on the graves of paid resources."*

**REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY.**

🐉 Made with 🔥 by [Red Dragon Elite](https://rd-elite.com)

[⬆ Back to Top](#-rde-skills--next-generation-skill-progression-system)

</div>
