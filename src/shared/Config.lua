--!strict
-- Villains Evolved — single source of truth for all balancing
-- Mirrors +1 Superhero Evolution curve, villain reskin with adjacent parody names
-- ponytail: one table drives everything, split stores if >5k DAU

local Config = {}

-- Rebirth: reset Infamy but keep Heists + multiply Infamy gain
Config.Rebirth = {
	HeistsRequired = 100,
	InfamyRequired = 10000,
	MultiplierPerRebirth = 0.15, -- +15% per rebirth, stacks
	MaxRebirths = 1000,
}

-- Training
Config.Training = {
	ClickBase = 1, -- +1 before villain/henchmen/rebirth
	AutoPadPerSecond = 5, -- auto-train pad gives 5 * powerPerClick per tick
	ClickCooldown = 0.05, -- anti-exploit
}

-- Worlds: gate by Heists (wins) or Infamy power
Config.Worlds = {
	{ Id = 1, Name = "Slums", GateHeists = 0, GateInfamy = 0, Color = Color3.fromRGB(90, 90, 90) },
	{ Id = 2, Name = "Neon Undercity", GateHeists = 350000, GateInfamy = 500000, Color = Color3.fromRGB(255, 0, 128) },
	{ Id = 3, Name = "Sky Citadel", GateHeists = 500000000, GateInfamy = 1000000000, Color = Color3.fromRGB(0, 170, 255) }, -- 500M/1B
	{ Id = 4, Name = "Volcanic Lair", GateHeists = 500000000000, GateInfamy = 1000000000000, Color = Color3.fromRGB(255, 85, 0) }, -- 500B/1T
	{ Id = 5, Name = "Shadow Dimension", GateHeists = 500000000000000, GateInfamy = 1000000000000000, Color = Color3.fromRGB(85, 0, 127) }, -- 500T/1Q
}

-- Villains: 66 entries (Starter + ~13 per world) — adjacent descriptive names, NOT trademarked
-- CostHeists = Heists needed; PowerPerClick = Infamy per click; Robux = optional purchase
-- Powers mirror source exponential curve (W1 1→60k, W3 15B→400T)
Config.Villains = {
	-- World 1 — Slums (mirrors source W1 1..300k)
	{ Name = "Goon", World = 1, CostHeists = 0, PowerPerClick = 1, Desc = "Starter thug", Palette = "Gray", Robux = nil },
	{ Name = "Arachnid Stalker", World = 1, CostHeists = 1, PowerPerClick = 2, Desc = "Web-crawler foe", Palette = "RedBlack", Robux = nil },
	{ Name = "Widow's Shadow", World = 1, CostHeists = 5, PowerPerClick = 5, Desc = "Assassin shade", Palette = "BlackRed", Robux = nil },
	{ Name = "Madman", World = 1, CostHeists = 25, PowerPerClick = 10, Desc = "Joker-adjacent", Palette = "PurpleGreen", Robux = nil },
	{ Name = "Gamma Brute", World = 1, CostHeists = 100, PowerPerClick = 25, Desc = "Hulk foe", Palette = "GreenPurple", Robux = nil },
	{ Name = "Clawed Berserker", World = 1, CostHeists = 250, PowerPerClick = 60, Desc = "Sabretooth-adjacent", Palette = "OrangeBrown", Robux = nil },
	{ Name = "Crimson Merc", World = 1, CostHeists = 750, PowerPerClick = 150, Desc = "Merc with mouth (evil)", Palette = "RedBlack", Robux = nil },
	{ Name = "Storm Herald", World = 1, CostHeists = 2000, PowerPerClick = 400, Desc = "Thor foe", Palette = "SilverBlue", Robux = nil },
	{ Name = "Void Sage", World = 1, CostHeists = 5000, PowerPerClick = 1000, Desc = "Doom-adjacent Doc Tyrant variant", Palette = "GreenSilver", Robux = nil },
	{ Name = "Swift Phantom", World = 1, CostHeists = 15000, PowerPerClick = 3000, Desc = "Speedster villain", Palette = "YellowRed", Robux = nil },
	{ Name = "Patriot Crusher", World = 1, CostHeists = 40000, PowerPerClick = 8000, Desc = "Red Skull-adjacent", Palette = "RedBlack", Robux = nil },
	{ Name = "Emerald Tyrant", World = 1, CostHeists = 100000, PowerPerClick = 22000, Desc = "Sinestro-adjacent", Palette = "YellowGreen", Robux = nil },
	{ Name = "Iron Tyrant", World = 1, CostHeists = 300000, PowerPerClick = 60000, Desc = "Ultron-adjacent", Palette = "RedGold", Robux = nil },
	{ Name = "Fallen Paragon", World = 1, CostHeists = nil, PowerPerClick = 500, Desc = "Evil Superman-adjacent", Palette = "BlueRed", Robux = 119 }, -- Robux
	{ Name = "Mad Titan", World = 1, CostHeists = nil, PowerPerClick = nil, Desc = "Thanos-adjacent +100% best", Palette = "PurpleGold", Robux = 149, IsBestMultiplier = true }, -- 100% better than best

	-- World 2 — Neon Undercity (1M → 2.5B Heists)
	{ Name = "Glider Fiend", World = 2, CostHeists = 1000000, PowerPerClick = 250000, Desc = "Goblin-adjacent", Palette = "GreenPurple", Robux = nil },
	{ Name = "Symbiote", World = 2, CostHeists = 5000000, PowerPerClick = 700000, Desc = "Venom-adjacent", Palette = "BlackWhite", Robux = nil },
	{ Name = "Frost Giant", World = 2, CostHeists = 25000000, PowerPerClick = 2000000, Desc = "Ice villain", Palette = "IceBlue", Robux = nil },
	{ Name = "Electro Tyrant", World = 2, CostHeists = 75000000, PowerPerClick = 6000000, Desc = "Lightning villain", Palette = "YellowBlue", Robux = nil },
	{ Name = "Trickster King", World = 2, CostHeists = 200000000, PowerPerClick = 18000000, Desc = "Loki-adjacent", Palette = "GreenGold", Robux = nil },
	{ Name = "Doc Tyrant", World = 2, CostHeists = 500000000, PowerPerClick = 50000000, Desc = "Doctor Doom-adjacent", Palette = "GreenSilver", Robux = nil },
	{ Name = "Abyss Leech", World = 2, CostHeists = 1000000000, PowerPerClick = 150000000, Desc = "Abyss villain", Palette = "BlackGreen", Robux = nil },
	{ Name = "Crimson Carnage", World = 2, CostHeists = 2500000000, PowerPerClick = 400000000, Desc = "Carnage-adjacent", Palette = "RedBlack", Robux = nil },
	{ Name = "Neon Overlord", World = 2, CostHeists = 5000000000, PowerPerClick = 1000000000, Desc = "Neon boss", Palette = "PinkCyan", Robux = nil },
	{ Name = "Volt Spectre", World = 2, CostHeists = 15000000000, PowerPerClick = 3000000000, Desc = "Electric phantom", Palette = "CyanYellow", Robux = nil },
	{ Name = "Shade Assassin", World = 2, CostHeists = 40000000000, PowerPerClick = 8000000000, Desc = "Shadow killer", Palette = "BlackPurple", Robux = nil },
	{ Name = "Titan Warlord", World = 2, CostHeists = 100000000000, PowerPerClick = 22000000000, Desc = "Warlord", Palette = "PurpleGold", Robux = nil },
	{ Name = "Neon Mad Titan", World = 2, CostHeists = nil, PowerPerClick = nil, Desc = "+100% best", Palette = "PurpleGold", Robux = 149, IsBestMultiplier = true },

	-- World 3 — Sky Citadel (mirrors source W3 1B→2.5T)
	{ Name = "Captain Chaos", World = 3, CostHeists = 1000000000, PowerPerClick = 15000000000, Desc = "Evil Captain", Palette = "BlueRed", Robux = nil },
	{ Name = "Night Raven", World = 3, CostHeists = 2000000000, PowerPerClick = 35000000000, Desc = "Nightwing foe", Palette = "BlackBlue", Robux = nil },
	{ Name = "Stone Goliath", World = 3, CostHeists = 4000000000, PowerPerClick = 80000000000, Desc = "Thing foe", Palette = "OrangeGray", Robux = nil },
	{ Name = "Silk Widow", World = 3, CostHeists = 7500000000, PowerPerClick = 200000000000, Desc = "Spider-Gwen foe", Palette = "WhiteBlack", Robux = nil },
	{ Name = "Blade Oni", World = 3, CostHeists = 15000000000, PowerPerClick = 400000000000, Desc = "Katana foe", Palette = "RedBlack", Robux = nil },
	{ Name = "Colossus Prime", World = 3, CostHeists = 30000000000, PowerPerClick = 1000000000000, Desc = "Mr Incredible foe", Palette = "RedYellow", Robux = nil },
	{ Name = "Hawk Vulture", World = 3, CostHeists = 50000000000, PowerPerClick = 2500000000000, Desc = "Hawkeye foe", Palette = "PurpleOrange", Robux = nil },
	{ Name = "Crimson Carnage Prime", World = 3, CostHeists = 100000000000, PowerPerClick = 6000000000000, Desc = "Carnage prime", Palette = "RedBlack", Robux = nil },
	{ Name = "Star Tyrant", World = 3, CostHeists = 200000000000, PowerPerClick = 15000000000000, Desc = "Starfire foe", Palette = "PurpleOrange", Robux = nil },
	{ Name = "Inferno Herald", World = 3, CostHeists = 400000000000, PowerPerClick = 35000000000000, Desc = "Human Torch foe", Palette = "OrangeRed", Robux = nil },
	{ Name = "Fear Lantern", World = 3, CostHeists = 750000000000, PowerPerClick = 60000000000000, Desc = "Sinestro prime", Palette = "YellowBlack", Robux = nil },
	{ Name = "Unstoppable", World = 3, CostHeists = 1500000000000, PowerPerClick = 150000000000000, Desc = "Invincible foe", Palette = "YellowBlue", Robux = nil },
	{ Name = "Fallen Paragon Prime", World = 3, CostHeists = 2500000000000, PowerPerClick = 400000000000000, Desc = "Evil Superman prime", Palette = "BlueRed", Robux = nil },
	{ Name = "Citadel Mad Titan", World = 3, CostHeists = nil, PowerPerClick = nil, Desc = "+100% best", Palette = "PurpleGold", Robux = 149, IsBestMultiplier = true },

	-- World 4 — Volcanic Lair (10T → 750B scaled to Q)
	{ Name = "Magma Crawler", World = 4, CostHeists = 10000000000000, PowerPerClick = 2000000000000000, Desc = "Lava villain", Palette = "OrangeRed", Robux = nil }, -- 10T
	{ Name = "Ash Wraith", World = 4, CostHeists = 25000000000000, PowerPerClick = 5000000000000000, Desc = "Ash phantom", Palette = "GrayOrange", Robux = nil },
	{ Name = "Obsidian Golem", World = 4, CostHeists = 50000000000000, PowerPerClick = 12000000000000000, Desc = "Stone golem", Palette = "BlackOrange", Robux = nil },
	{ Name = "Hell Hound Alpha", World = 4, CostHeists = 100000000000000, PowerPerClick = 30000000000000000, Desc = "Hound", Palette = "RedBlack", Robux = nil },
	{ Name = "Volcano Monarch", World = 4, CostHeists = 250000000000000, PowerPerClick = 80000000000000000, Desc = "Lair king", Palette = "RedGold", Robux = nil },
	{ Name = "Cinder Witch", World = 4, CostHeists = 500000000000000, PowerPerClick = 200000000000000000, Desc = "Fire witch", Palette = "PurpleOrange", Robux = nil },
	{ Name = "Molten Colossus", World = 4, CostHeists = 1000000000000000, PowerPerClick = 500000000000000000, Desc = "Molten giant", Palette = "OrangeYellow", Robux = nil }, -- 1Q
	{ Name = "Inferno Maw", World = 4, CostHeists = 2500000000000000, PowerPerClick = 1200000000000000000, Desc = "Maw", Palette = "RedOrange", Robux = nil },
	{ Name = "Caldera Tyrant", World = 4, CostHeists = 5000000000000000, PowerPerClick = 3000000000000000000, Desc = "Caldera", Palette = "BlackRed", Robux = nil },
	{ Name = "Eruption Herald", World = 4, CostHeists = 10000000000000000, PowerPerClick = 8000000000000000000, Desc = "Herald", Palette = "YellowRed", Robux = nil },
	{ Name = "Lava Leviathan", World = 4, CostHeists = 25000000000000000, PowerPerClick = 20000000000000000000, Desc = "Leviathan", Palette = "OrangeBlack", Robux = nil },
	{ Name = "Volcanic Mad Titan", World = 4, CostHeists = nil, PowerPerClick = nil, Desc = "+100% best", Palette = "PurpleGold", Robux = 149, IsBestMultiplier = true },

	-- World 5 — Shadow Dimension (endgame)
	{ Name = "Void Stalker", World = 5, CostHeists = 50000000000000000, PowerPerClick = 50000000000000000000, Desc = "Void", Palette = "BlackPurple", Robux = nil }, -- 50Q
	{ Name = "Umbral King", World = 5, CostHeists = 100000000000000000, PowerPerClick = 120000000000000000000, Desc = "Shadow king", Palette = "PurpleBlack", Robux = nil },
	{ Name = "Nether Phantom", World = 5, CostHeists = 250000000000000000, PowerPerClick = 300000000000000000000, Desc = "Nether", Palette = "BlackCyan", Robux = nil },
	{ Name = "Abyss Sovereign", World = 5, CostHeists = 500000000000000000, PowerPerClick = 800000000000000000000, Desc = "Abyss king", Palette = "BlackPurple", Robux = nil },
	{ Name = "Eclipse Harbinger", World = 5, CostHeists = 1000000000000000000, PowerPerClick = 2000000000000000000000, Desc = "Eclipse", Palette = "BlackYellow", Robux = nil }, -- 1Sextillion
	{ Name = "Oblivion Core", World = 5, CostHeists = 2500000000000000000, PowerPerClick = 5000000000000000000000, Desc = "Core", Palette = "BlackRed", Robux = nil },
	{ Name = "Final Mad Titan", World = 5, CostHeists = nil, PowerPerClick = nil, Desc = "+100% best (endgame)", Palette = "PurpleGold", Robux = 199, IsBestMultiplier = true },
}

-- Henchmen (Pets) — multiplier on Infamy per click
-- Each egg costs Heists (or Tokens for mystery). Hatching gives random henchman from egg pool.
Config.HenchmenEggs = {
	-- World 1
	{ Name = "Basic Capsule", World = 1, CostHeists = 5, CostTokens = nil, Henchmen = { {Name="Goonlet", Mult=1.5}, {Name="Thuglet", Mult=2}, {Name="Bruiser", Mult=3}, {Name="Enforcer", Mult=5} } },
	{ Name = "Street Capsule", World = 1, CostHeists = 50, CostTokens = nil, Henchmen = { {Name="Knife Runner", Mult=6}, {Name="Smogger", Mult=8}, {Name="Chain Brute", Mult=12}, {Name="Rioter", Mult=18} } },
	{ Name = "Dominus Capsule", World = 1, CostHeists = 500, CostTokens = nil, Henchmen = { {Name="Dominus Thug", Mult=25}, {Name="Dominus Brute", Mult=35}, {Name="Dominus Wraith", Mult=50} } },
	{ Name = "Neon Capsule", World = 1, CostHeists = 5000, CostTokens = nil, Henchmen = { {Name="Neon Stalker", Mult=75}, {Name="Neon Reaver", Mult=110} } },
	-- World 2
	{ Name = "Undercity Capsule", World = 2, CostHeists = 500000, CostTokens = nil, Henchmen = { {Name="Cyber Thug", Mult=200}, {Name="Neon Ghoul", Mult=350}, {Name="Volt Fiend", Mult=600} } },
	{ Name = "Voltage Capsule", World = 2, CostHeists = 5000000, CostTokens = nil, Henchmen = { {Name="Storm Minion", Mult=900}, {Name="Arc Brute", Mult=1500} } },
	-- World 3
	{ Name = "Citadel Capsule", World = 3, CostHeists = 1000000000, CostTokens = nil, Henchmen = { {Name="Sky Raider", Mult=3000}, {Name="Aero Brute", Mult=5000}, {Name="Citadel Guard", Mult=8000} } },
	{ Name = "Aero Capsule", World = 3, CostHeists = 10000000000, CostTokens = nil, Henchmen = { {Name="Gale Wraith", Mult=12000}, {Name="Tempest King", Mult=20000} } },
	-- World 4
	{ Name = "Cactus Capsule", World = 4, CostHeists = 1000000000000, CostTokens = nil, Henchmen = { {Name="Camel", Mult=2000}, {Name="Scorpion", Mult=4000}, {Name="Sphinx", Mult=6000} } }, -- kept for compat with source naming
	{ Name = "Volcano Capsule", World = 4, CostHeists = 500000000000000, CostTokens = nil, Henchmen = { {Name="Fire Horse", Mult=5500}, {Name="Hell Hound", Mult=8000}, {Name="Phoenix", Mult=9000}, {Name="Lava Monkey", Mult=10000} } },
	{ Name = "Golden Cactus", World = 4, CostHeists = nil, CostTokens = nil, Henchmen = { {Name="Golden Sphinx", Mult=75000} }, Robux = 25 },
	{ Name = "Golden Volcano", World = 4, CostHeists = nil, CostTokens = nil, Henchmen = { {Name="Golden Phoenix", Mult=100000} }, Robux = 49 },
	-- World 5 + Tokens/Mystery
	{ Name = "Shadow Capsule", World = 5, CostHeists = 1000000000000000, CostTokens = nil, Henchmen = { {Name="Shadowling", Mult=50000}, {Name="Voidling", Mult=100000}, {Name="Abyssling", Mult=250000} } },
	{ Name = "Mystery Capsule", World = 5, CostHeists = nil, CostTokens = 1000000, Henchmen = { {Name="Brr Patapim", Mult=nil, IsBestPercent=5}, {Name="Bombino Piggino", Mult=nil, IsBestPercent=10}, {Name="Frigo Camelo", Mult=nil, IsBestPercent=30}, {Name="Larila Larila", Mult=nil, IsBestPercent=100}, {Name="Golden Larila", Mult=nil, IsBestPercent=500} } },
	{ Name = "Brainrot Capsule", World = 5, CostHeists = nil, CostTokens = nil, Henchmen = { {Name="Brainrot King", Mult=500000} }, Robux = 75 },
}

-- Dungeon (Heist) — enemy scaling per level
Config.Dungeon = {
	LevelsPerWorld = 10,
	EnemiesPerLevel = 3,
	BaseEnemyHealth = 10,
	HealthGrowth = 1.35, -- per level
	HeistsPerLevel = 1, -- base, scaled by world
	HeistsGrowth = 1.5,
	TokensPerRaidStage = 4000,
	RaidIntervalSeconds = 3600, -- hourly at XX:30
	RaidLives = 3,
}

-- Gamepasses (mid-aggressive, generous launch discounts)
Config.Gamepasses = {
	{ Name = "2x Infamy", Id = 1111111, Price = 149, DiscountPrice = 79, Desc = "Double Infamy per click" },
	{ Name = "2x Heists", Id = 1111112, Price = 199, DiscountPrice = 99, Desc = "Double Heists banked" },
	{ Name = "+3 Henchmen", Id = 1111113, Price = 249, DiscountPrice = 149, Desc = "Equip 3 extra henchmen" },
	{ Name = "Auto-Train", Id = 1111114, Price = 99, DiscountPrice = 49, Desc = "Auto-train everywhere" },
	{ Name = "VIP Aura", Id = 1111115, Price = 399, DiscountPrice = 199, Desc = "VIP tag + aura" },
}

-- Helpers
function Config.GetVillainByName(name: string)
	for _, v in Config.Villains do
		if v.Name == name then return v end
	end
	return nil
end

function Config.GetWorld(worldId: number)
	for _, w in Config.Worlds do
		if w.Id == worldId then return w end
	end
	return nil
end

function Config.GetPowerPerClick(villainName: string, henchmenMult: number, rebirths: number, has2xInfamy: boolean): number
	local v = Config.GetVillainByName(villainName)
	local base = 1
	if v and v.PowerPerClick then base = v.PowerPerClick end
	if v and v.IsBestMultiplier then
		-- +100% better than best owned is handled server-side by lookup; placeholder here uses base of best non-robux
		base = 60000 -- fallback for W1; server will override
	end
	local rebirthMult = 1 + (rebirths * Config.Rebirth.MultiplierPerRebirth)
	local total = base * (henchmenMult or 1) * rebirthMult
	if has2xInfamy then total *= 2 end
	return math.floor(total)
end

return Config
