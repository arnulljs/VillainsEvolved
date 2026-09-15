--!strict
-- Villains Evolved: Single Source of Truth for Balancing & Config (Grounded to Live Screenshots)
local Config = {}

export type Villain = {
	id: string,
	name: string,
	sourceRef: string?,
	district: number,
	cost: number,
	costType: string,
	infamyPerClick: number,
	special: string?,
	morph: {
		bodyColor: Color3,
		headColor: Color3,
		torsoColor: Color3,
		scale: number,
		auraColor: Color3?,
		accessoryName: string?,
	},
}

export type Job = {
	jobIndex: number,
	requiredInfamy: number,
	enemyHp: number,
	enemyCount: number,
	lootPayout: number,
	bossName: string?,
}

export type Henchman = {
	id: string,
	name: string,
	rarity: "Common" | "Rare" | "Epic" | "Legendary" | "Mythic",
	crateId: string,
	multipliers: {
		infamy: number,
		loot: number,
		speed: number,
		heat: number,
	},
	special: string?,
}

export type Crate = {
	id: string,
	name: string,
	district: number,
	cost: number,
	costType: "Loot" | "Robux" | "Heat",
	weights: { [string]: number },
}

-- 1. Districts
Config.Districts = {
	{ id = 1, name = "Back Alley Slums", unlockRequirement = 0, themeColor = Color3.fromRGB(80, 80, 85), bossName = "The Rookie Cape" },
	{ id = 2, name = "Bank District", unlockRequirement = 350000, themeColor = Color3.fromRGB(40, 180, 220), bossName = "Captain Justice" },
	{ id = 3, name = "Toxic Docks", unlockRequirement = 500000000, themeColor = Color3.fromRGB(70, 200, 70), bossName = "The Tidebreaker" },
	{ id = 4, name = "Blackgate Prison", unlockRequirement = 500000000000, themeColor = Color3.fromRGB(200, 60, 40), bossName = "The Warden" },
	{ id = 5, name = "Orbital Citadel", unlockRequirement = 500000000000000, themeColor = Color3.fromRGB(150, 50, 220), bossName = "The Paragon" },
}

-- 2. Rebirth & Level (Grounded to Screenshot: Power is UNLIMITED, Level requires threshold for Rebirth)
function Config.GetMaxLevel(rebirths: number): number
	if rebirths == 0 then return 10 end
	return 10 + (rebirths * 25)
end

Config.Rebirth = {
	-- Required level to unlock rebirth: starts at 10, escalates (+25 per rebirth, matching live screenshots)
	requiredLevel = Config.GetMaxLevel,
	-- Multiplier: screenshot shows Rebirth 222 = 344x, Rebirth 223 = 346x (+2x per rebirth)
	multiplier = function(rebirths: number): number
		return 1 + (rebirths * 2)
	end,
	keepRatio = 0.0,
	trainingStationUnlocks = {
		[0] = { name = "Back Alley Dummy", multiplier = 1, minRebirth = 0 },
		[3] = { name = "Underground Garage", multiplier = 3, minRebirth = 3 },
		[8] = { name = "Abandoned Warehouse", multiplier = 8, minRebirth = 8 },
		[15] = { name = "Heist Bank Vault", multiplier = 20, minRebirth = 15 },
		[25] = { name = "Secret Bio-Lab", multiplier = 50, minRebirth = 25 },
	},
}

-- Experience points required to advance from current level to next level
function Config.GetXpForLevel(level: number): number
	return math.floor(50 * (1.35 ^ (math.max(1, level) - 1)))
end

-- Fallback level calculation from Infamy
function Config.GetLevelFromInfamy(infamy: number): number
	if infamy <= 0 then
		return 1
	end
	local lvl = math.floor(math.log(infamy + 1) / math.log(1.8)) + 1
	return math.max(1, lvl)
end

-- 3. Villains Roster (Placeholder Roster with sourceRef)
Config.Villains = {
	-- District 1: Back Alley Slums
	{ id = "nobody", name = "Nobody", sourceRef = "PLACEHOLDER: Generic Thug", district = 1, cost = 0, costType = "Loot", infamyPerClick = 1, morph = { bodyColor = Color3.fromRGB(90, 90, 90), headColor = Color3.fromRGB(210, 180, 140), torsoColor = Color3.fromRGB(60, 60, 65), scale = 1.0 } },
	{ id = "enigma", name = "Enigma", sourceRef = "PLACEHOLDER: The Riddler", district = 1, cost = 1, costType = "Loot", infamyPerClick = 2, morph = { bodyColor = Color3.fromRGB(30, 120, 50), headColor = Color3.fromRGB(220, 190, 150), torsoColor = Color3.fromRGB(40, 150, 60), scale = 1.0, auraColor = Color3.fromRGB(80, 220, 100) } },
	{ id = "strawman", name = "Strawman", sourceRef = "PLACEHOLDER: Scarecrow", district = 1, cost = 5, costType = "Loot", infamyPerClick = 5, morph = { bodyColor = Color3.fromRGB(120, 90, 50), headColor = Color3.fromRGB(160, 130, 80), torsoColor = Color3.fromRGB(100, 75, 40), scale = 1.02 } },
	{ id = "jester", name = "Jester", sourceRef = "PLACEHOLDER: The Joker", district = 1, cost = 25, costType = "Loot", infamyPerClick = 10, morph = { bodyColor = Color3.fromRGB(110, 30, 130), headColor = Color3.fromRGB(240, 240, 240), torsoColor = Color3.fromRGB(120, 40, 140), scale = 1.03, auraColor = Color3.fromRGB(180, 40, 220) } },
	{ id = "nightshade", name = "Nightshade", sourceRef = "PLACEHOLDER: Poison Ivy", district = 1, cost = 100, costType = "Loot", infamyPerClick = 25, morph = { bodyColor = Color3.fromRGB(40, 140, 70), headColor = Color3.fromRGB(220, 190, 150), torsoColor = Color3.fromRGB(30, 100, 50), scale = 1.03, auraColor = Color3.fromRGB(60, 255, 90) } },
	{ id = "velvet", name = "Velvet", sourceRef = "PLACEHOLDER: Catwoman", district = 1, cost = 250, costType = "Loot", infamyPerClick = 60, morph = { bodyColor = Color3.fromRGB(25, 25, 25), headColor = Color3.fromRGB(35, 35, 35), torsoColor = Color3.fromRGB(20, 20, 20), scale = 1.04 } },
	{ id = "janus", name = "Janus", sourceRef = "PLACEHOLDER: Two-Face", district = 1, cost = 750, costType = "Loot", infamyPerClick = 150, morph = { bodyColor = Color3.fromRGB(80, 80, 80), headColor = Color3.fromRGB(190, 100, 100), torsoColor = Color3.fromRGB(50, 50, 90), scale = 1.05 } },
	{ id = "monocle", name = "Monocle", sourceRef = "PLACEHOLDER: The Penguin", district = 1, cost = 2000, costType = "Loot", infamyPerClick = 400, morph = { bodyColor = Color3.fromRGB(30, 30, 35), headColor = Color3.fromRGB(230, 200, 160), torsoColor = Color3.fromRGB(200, 200, 210), scale = 1.06 } },
	{ id = "absolute_zero", name = "Absolute Zero", sourceRef = "PLACEHOLDER: Mr. Freeze", district = 1, cost = 5000, costType = "Loot", infamyPerClick = 1000, morph = { bodyColor = Color3.fromRGB(70, 150, 220), headColor = Color3.fromRGB(180, 220, 255), torsoColor = Color3.fromRGB(40, 100, 180), scale = 1.08, auraColor = Color3.fromRGB(100, 200, 255) } },
	{ id = "silt", name = "Silt", sourceRef = "PLACEHOLDER: Clayface", district = 1, cost = 15000, costType = "Loot", infamyPerClick = 3000, morph = { bodyColor = Color3.fromRGB(130, 90, 50), headColor = Color3.fromRGB(120, 80, 45), torsoColor = Color3.fromRGB(140, 100, 60), scale = 1.15 } },
	{ id = "breaker", name = "Breaker", sourceRef = "PLACEHOLDER: Bane", district = 1, cost = 40000, costType = "Loot", infamyPerClick = 8000, morph = { bodyColor = Color3.fromRGB(45, 45, 50), headColor = Color3.fromRGB(30, 30, 30), torsoColor = Color3.fromRGB(40, 160, 70), scale = 1.2, auraColor = Color3.fromRGB(50, 255, 100) } },
	{ id = "crime_king", name = "Crime King", sourceRef = "PLACEHOLDER: Kingpin", district = 1, cost = 100000, costType = "Loot", infamyPerClick = 22000, morph = { bodyColor = Color3.fromRGB(230, 230, 235), headColor = Color3.fromRGB(220, 185, 150), torsoColor = Color3.fromRGB(240, 240, 245), scale = 1.25 } },
	{ id = "deathblow", name = "Deathblow", sourceRef = "PLACEHOLDER: Deathstroke", district = 1, cost = 300000, costType = "Loot", infamyPerClick = 60000, morph = { bodyColor = Color3.fromRGB(30, 40, 60), headColor = Color3.fromRGB(220, 110, 20), torsoColor = Color3.fromRGB(40, 50, 70), scale = 1.15, auraColor = Color3.fromRGB(255, 120, 30) } },
	{ id = "harlequeen", name = "Harlequeen", sourceRef = "PLACEHOLDER: Harley Quinn", district = 1, cost = 99, costType = "Robux", infamyPerClick = 500, special = "District 1 Robux", morph = { bodyColor = Color3.fromRGB(220, 40, 80), headColor = Color3.fromRGB(240, 230, 230), torsoColor = Color3.fromRGB(40, 40, 50), scale = 1.05, auraColor = Color3.fromRGB(255, 60, 120) } },
	{ id = "mad_titan_d1", name = "Mad Titan", sourceRef = "PLACEHOLDER: Thanos", district = 1, cost = 179, costType = "Robux", infamyPerClick = 0, special = "Always +100% over best owned", morph = { bodyColor = Color3.fromRGB(120, 60, 150), headColor = Color3.fromRGB(140, 70, 170), torsoColor = Color3.fromRGB(210, 160, 30), scale = 1.3, auraColor = Color3.fromRGB(255, 215, 0) } },

	-- District 2: Bank District
	{ id = "vibro", name = "Vibro", sourceRef = "PLACEHOLDER: Shocker", district = 2, cost = 500000, costType = "Loot", infamyPerClick = 350000, morph = { bodyColor = Color3.fromRGB(180, 150, 50), headColor = Color3.fromRGB(200, 170, 60), torsoColor = Color3.fromRGB(140, 110, 40), scale = 1.1 } },
	{ id = "mirage", name = "Mirage", sourceRef = "PLACEHOLDER: Mysterio", district = 2, cost = 1000000, costType = "Loot", infamyPerClick = 700000, morph = { bodyColor = Color3.fromRGB(50, 140, 100), headColor = Color3.fromRGB(180, 230, 240), torsoColor = Color3.fromRGB(120, 50, 130), scale = 1.1, auraColor = Color3.fromRGB(100, 240, 200) } },
	{ id = "carrion", name = "Carrion", sourceRef = "PLACEHOLDER: Vulture", district = 2, cost = 1500000, costType = "Loot", infamyPerClick = 1500000, morph = { bodyColor = Color3.fromRGB(60, 110, 60), headColor = Color3.fromRGB(210, 180, 150), torsoColor = Color3.fromRGB(50, 90, 50), scale = 1.1 } },
	{ id = "huntsman", name = "Huntsman", sourceRef = "PLACEHOLDER: Kraven", district = 2, cost = 3000000, costType = "Loot", infamyPerClick = 3000000, morph = { bodyColor = Color3.fromRGB(160, 90, 40), headColor = Color3.fromRGB(215, 180, 145), torsoColor = Color3.fromRGB(140, 80, 30), scale = 1.12 } },
	{ id = "voltaic", name = "Voltaic", sourceRef = "PLACEHOLDER: Electro", district = 2, cost = 5000000, costType = "Loot", infamyPerClick = 6000000, morph = { bodyColor = Color3.fromRGB(40, 150, 220), headColor = Color3.fromRGB(240, 240, 80), torsoColor = Color3.fromRGB(30, 120, 180), scale = 1.12, auraColor = Color3.fromRGB(80, 200, 255) } },
	{ id = "grit", name = "Grit", sourceRef = "PLACEHOLDER: Sandman", district = 2, cost = 10000000, costType = "Loot", infamyPerClick = 16000000, morph = { bodyColor = Color3.fromRGB(190, 160, 110), headColor = Color3.fromRGB(190, 160, 110), torsoColor = Color3.fromRGB(50, 120, 70), scale = 1.15 } },
	{ id = "hornhead", name = "Hornhead", sourceRef = "PLACEHOLDER: Rhino", district = 2, cost = 15000000, costType = "Loot", infamyPerClick = 35000000, morph = { bodyColor = Color3.fromRGB(110, 115, 120), headColor = Color3.fromRGB(100, 105, 110), torsoColor = Color3.fromRGB(120, 125, 130), scale = 1.22 } },
	{ id = "octavian", name = "Octavian", sourceRef = "PLACEHOLDER: Doctor Octopus", district = 2, cost = 30000000, costType = "Loot", infamyPerClick = 80000000, morph = { bodyColor = Color3.fromRGB(50, 100, 60), headColor = Color3.fromRGB(220, 185, 150), torsoColor = Color3.fromRGB(170, 120, 40), scale = 1.14, auraColor = Color3.fromRGB(180, 180, 190) } },
	{ id = "goblin_king", name = "Goblin King", sourceRef = "PLACEHOLDER: Green Goblin", district = 2, cost = 50000000, costType = "Loot", infamyPerClick = 180000000, morph = { bodyColor = Color3.fromRGB(50, 150, 60), headColor = Color3.fromRGB(60, 160, 70), torsoColor = Color3.fromRGB(110, 40, 130), scale = 1.15, auraColor = Color3.fromRGB(120, 50, 160) } },
	{ id = "abyss", name = "Abyss", sourceRef = "PLACEHOLDER: Venom", district = 2, cost = 100000000, costType = "Loot", infamyPerClick = 400000000, morph = { bodyColor = Color3.fromRGB(20, 20, 22), headColor = Color3.fromRGB(15, 15, 18), torsoColor = Color3.fromRGB(25, 25, 28), scale = 1.25, auraColor = Color3.fromRGB(50, 50, 60) } },
	{ id = "slaughter", name = "Slaughter", sourceRef = "PLACEHOLDER: Carnage", district = 2, cost = 150000000, costType = "Loot", infamyPerClick = 1000000000, morph = { bodyColor = Color3.fromRGB(180, 30, 30), headColor = Color3.fromRGB(190, 20, 20), torsoColor = Color3.fromRGB(160, 20, 20), scale = 1.24, auraColor = Color3.fromRGB(255, 30, 30) } },
	{ id = "omnius", name = "Omnius", sourceRef = "PLACEHOLDER: Ultron", district = 2, cost = 300000000, costType = "Loot", infamyPerClick = 2500000000, morph = { bodyColor = Color3.fromRGB(160, 165, 175), headColor = Color3.fromRGB(180, 185, 195), torsoColor = Color3.fromRGB(140, 145, 155), scale = 1.22, auraColor = Color3.fromRGB(255, 40, 40) } },
	{ id = "ironmask", name = "Ironmask", sourceRef = "PLACEHOLDER: Doctor Doom", district = 2, cost = 750000000, costType = "Loot", infamyPerClick = 6000000000, morph = { bodyColor = Color3.fromRGB(150, 155, 160), headColor = Color3.fromRGB(160, 165, 170), torsoColor = Color3.fromRGB(40, 110, 50), scale = 1.2, auraColor = Color3.fromRGB(80, 220, 120) } },
	{ id = "nightfell", name = "Nightfell", sourceRef = "PLACEHOLDER: Black Cat", district = 2, cost = 99, costType = "Robux", infamyPerClick = 100000, special = "District 2 Robux", morph = { bodyColor = Color3.fromRGB(30, 30, 35), headColor = Color3.fromRGB(230, 230, 240), torsoColor = Color3.fromRGB(20, 20, 25), scale = 1.05 } },

	-- District 3: Toxic Docks
	{ id = "croak", name = "Croak", sourceRef = "PLACEHOLDER: Toad", district = 3, cost = 1000000000, costType = "Loot", infamyPerClick = 15000000000, morph = { bodyColor = Color3.fromRGB(90, 130, 50), headColor = Color3.fromRGB(100, 140, 60), torsoColor = Color3.fromRGB(80, 110, 40), scale = 1.1 } },
	{ id = "fang", name = "Fang", sourceRef = "PLACEHOLDER: Sabretooth", district = 3, cost = 2000000000, costType = "Loot", infamyPerClick = 35000000000, morph = { bodyColor = Color3.fromRGB(180, 120, 40), headColor = Color3.fromRGB(220, 185, 150), torsoColor = Color3.fromRGB(150, 100, 30), scale = 1.18 } },
	{ id = "shiftskin", name = "Shiftskin", sourceRef = "PLACEHOLDER: Mystique", district = 3, cost = 4000000000, costType = "Loot", infamyPerClick = 80000000000, morph = { bodyColor = Color3.fromRGB(50, 90, 180), headColor = Color3.fromRGB(60, 100, 200), torsoColor = Color3.fromRGB(230, 230, 235), scale = 1.08, auraColor = Color3.fromRGB(200, 40, 40) } },
	{ id = "gator", name = "Gator", sourceRef = "PLACEHOLDER: Killer Croc", district = 3, cost = 7500000000, costType = "Loot", infamyPerClick = 200000000000, morph = { bodyColor = Color3.fromRGB(60, 100, 50), headColor = Color3.fromRGB(50, 90, 40), torsoColor = Color3.fromRGB(70, 110, 60), scale = 1.25 } },
	{ id = "scale", name = "Scale", sourceRef = "PLACEHOLDER: The Lizard", district = 3, cost = 15000000000, costType = "Loot", infamyPerClick = 400000000000, morph = { bodyColor = Color3.fromRGB(50, 130, 60), headColor = Color3.fromRGB(60, 140, 70), torsoColor = Color3.fromRGB(220, 220, 230), scale = 1.2 } },
	{ id = "nocturne", name = "Nocturne", sourceRef = "PLACEHOLDER: Man-Bat", district = 3, cost = 30000000000, costType = "Loot", infamyPerClick = 1000000000000, morph = { bodyColor = Color3.fromRGB(70, 50, 45), headColor = Color3.fromRGB(60, 45, 40), torsoColor = Color3.fromRGB(80, 55, 50), scale = 1.22 } },
	{ id = "the_unstoppable", name = "The Unstoppable", sourceRef = "PLACEHOLDER: Juggernaut", district = 3, cost = 50000000000, costType = "Loot", infamyPerClick = 2500000000000, morph = { bodyColor = Color3.fromRGB(140, 60, 40), headColor = Color3.fromRGB(120, 50, 30), torsoColor = Color3.fromRGB(150, 70, 45), scale = 1.35, auraColor = Color3.fromRGB(200, 80, 40) } },
	{ id = "lodestone", name = "Lodestone", sourceRef = "PLACEHOLDER: Magneto", district = 3, cost = 100000000000, costType = "Loot", infamyPerClick = 6000000000000, morph = { bodyColor = Color3.fromRGB(140, 30, 40), headColor = Color3.fromRGB(130, 25, 35), torsoColor = Color3.fromRGB(100, 30, 120), scale = 1.15, auraColor = Color3.fromRGB(160, 40, 200) } },
	{ id = "pale_doctor", name = "Pale Doctor", sourceRef = "PLACEHOLDER: Mister Sinister", district = 3, cost = 200000000000, costType = "Loot", infamyPerClick = 15000000000000, morph = { bodyColor = Color3.fromRGB(40, 50, 70), headColor = Color3.fromRGB(240, 240, 245), torsoColor = Color3.fromRGB(30, 40, 60), scale = 1.18, auraColor = Color3.fromRGB(255, 30, 30) } },
	{ id = "cinder_queen", name = "Cinder Queen", sourceRef = "PLACEHOLDER: Dark Phoenix", district = 3, cost = 400000000000, costType = "Loot", infamyPerClick = 35000000000000, morph = { bodyColor = Color3.fromRGB(180, 40, 30), headColor = Color3.fromRGB(230, 190, 150), torsoColor = Color3.fromRGB(200, 140, 30), scale = 1.12, auraColor = Color3.fromRGB(255, 100, 20) } },
	{ id = "bone_red", name = "Bone Red", sourceRef = "PLACEHOLDER: Red Skull", district = 3, cost = 750000000000, costType = "Loot", infamyPerClick = 60000000000000, morph = { bodyColor = Color3.fromRGB(40, 45, 50), headColor = Color3.fromRGB(200, 20, 20), torsoColor = Color3.fromRGB(35, 40, 45), scale = 1.16 } },
	{ id = "the_ashen", name = "The Ashen", sourceRef = "PLACEHOLDER: Apocalypse", district = 3, cost = 1500000000000, costType = "Loot", infamyPerClick = 150000000000000, morph = { bodyColor = Color3.fromRGB(80, 95, 120), headColor = Color3.fromRGB(160, 170, 185), torsoColor = Color3.fromRGB(60, 80, 110), scale = 1.32, auraColor = Color3.fromRGB(60, 180, 240) } },
	{ id = "toxin_lord", name = "Toxin Lord", sourceRef = "PLACEHOLDER: Ultimate Green Goblin", district = 3, cost = 2500000000000, costType = "Loot", infamyPerClick = 400000000000000, morph = { bodyColor = Color3.fromRGB(40, 120, 40), headColor = Color3.fromRGB(50, 140, 50), torsoColor = Color3.fromRGB(60, 110, 40), scale = 1.35, auraColor = Color3.fromRGB(80, 255, 60) } },
	{ id = "warmachine", name = "Warmachine", sourceRef = "PLACEHOLDER: War Machine Variant", district = 3, cost = 129, costType = "Robux", infamyPerClick = 2000000000000, special = "District 3 Robux", morph = { bodyColor = Color3.fromRGB(60, 65, 70), headColor = Color3.fromRGB(70, 75, 80), torsoColor = Color3.fromRGB(50, 55, 60), scale = 1.2, auraColor = Color3.fromRGB(240, 50, 50) } },

	-- District 4: Blackgate Prison
	{ id = "wretch", name = "Wretch", sourceRef = "PLACEHOLDER: Abomination", district = 4, cost = 3500000000000, costType = "Loot", infamyPerClick = 1000000000000000, morph = { bodyColor = Color3.fromRGB(70, 120, 60), headColor = Color3.fromRGB(60, 110, 50), torsoColor = Color3.fromRGB(80, 130, 70), scale = 1.3 } },
	{ id = "mirrorman", name = "Mirrorman", sourceRef = "PLACEHOLDER: Bizarro", district = 4, cost = 8400000000000, costType = "Loot", infamyPerClick = 2500000000000000, morph = { bodyColor = Color3.fromRGB(150, 160, 175), headColor = Color3.fromRGB(160, 170, 185), torsoColor = Color3.fromRGB(50, 70, 140), scale = 1.25 } },
	{ id = "frostbite", name = "Frostbite", sourceRef = "PLACEHOLDER: Captain Cold", district = 4, cost = 20000000000000, costType = "Loot", infamyPerClick = 6250000000000000, morph = { bodyColor = Color3.fromRGB(60, 120, 180), headColor = Color3.fromRGB(220, 190, 150), torsoColor = Color3.fromRGB(40, 90, 150), scale = 1.15 } },
	{ id = "the_reverse", name = "The Reverse", sourceRef = "PLACEHOLDER: Reverse-Flash", district = 4, cost = 48000000000000, costType = "Loot", infamyPerClick = 15600000000000000, morph = { bodyColor = Color3.fromRGB(220, 200, 30), headColor = Color3.fromRGB(220, 200, 30), torsoColor = Color3.fromRGB(220, 200, 30), scale = 1.12, auraColor = Color3.fromRGB(255, 40, 40) } },
	{ id = "predator", name = "Predator", sourceRef = "PLACEHOLDER: Cheetah", district = 4, cost = 115000000000000, costType = "Loot", infamyPerClick = 39000000000000000, morph = { bodyColor = Color3.fromRGB(210, 160, 60), headColor = Color3.fromRGB(210, 160, 60), torsoColor = Color3.fromRGB(180, 130, 40), scale = 1.14 } },
	{ id = "fearlight", name = "Fearlight", sourceRef = "PLACEHOLDER: Sinestro", district = 4, cost = 275000000000000, costType = "Loot", infamyPerClick = 97500000000000000, morph = { bodyColor = Color3.fromRGB(30, 30, 35), headColor = Color3.fromRGB(180, 50, 70), torsoColor = Color3.fromRGB(25, 25, 30), scale = 1.15, auraColor = Color3.fromRGB(255, 220, 30) } },
	{ id = "warbringer", name = "Warbringer", sourceRef = "PLACEHOLDER: Ares", district = 4, cost = 660000000000000, costType = "Loot", infamyPerClick = 244000000000000000, morph = { bodyColor = Color3.fromRGB(130, 80, 40), headColor = Color3.fromRGB(80, 80, 85), torsoColor = Color3.fromRGB(150, 40, 30), scale = 1.3 } },
	{ id = "warlord_zaan", name = "Warlord Zaan", sourceRef = "PLACEHOLDER: General Zod", district = 4, cost = 1580000000000000, costType = "Loot", infamyPerClick = 610000000000000000, morph = { bodyColor = Color3.fromRGB(40, 40, 45), headColor = Color3.fromRGB(210, 180, 150), torsoColor = Color3.fromRGB(30, 30, 35), scale = 1.25 } },
	{ id = "cortex", name = "Cortex", sourceRef = "PLACEHOLDER: Brainiac", district = 4, cost = 3800000000000000, costType = "Loot", infamyPerClick = 1525000000000000000, morph = { bodyColor = Color3.fromRGB(90, 180, 80), headColor = Color3.fromRGB(100, 200, 90), torsoColor = Color3.fromRGB(120, 50, 140), scale = 1.2, auraColor = Color3.fromRGB(80, 240, 120) } },
	{ id = "baron_lux", name = "Baron Lux", sourceRef = "PLACEHOLDER: Lex Luthor", district = 4, cost = 9100000000000000, costType = "Loot", infamyPerClick = 3800000000000000000, morph = { bodyColor = Color3.fromRGB(50, 150, 70), headColor = Color3.fromRGB(220, 190, 150), torsoColor = Color3.fromRGB(120, 40, 140), scale = 1.24 } },
	{ id = "black_aten", name = "Black Aten", sourceRef = "PLACEHOLDER: Black Adam", district = 4, cost = 21800000000000000, costType = "Loot", infamyPerClick = 9500000000000000000, morph = { bodyColor = Color3.fromRGB(25, 25, 30), headColor = Color3.fromRGB(200, 170, 135), torsoColor = Color3.fromRGB(20, 20, 25), scale = 1.26, auraColor = Color3.fromRGB(255, 215, 0) } },
	{ id = "armageddon", name = "Armageddon", sourceRef = "PLACEHOLDER: Doomsday", district = 4, cost = 52400000000000000, costType = "Loot", infamyPerClick = 23750000000000000000, morph = { bodyColor = Color3.fromRGB(110, 115, 125), headColor = Color3.fromRGB(120, 125, 135), torsoColor = Color3.fromRGB(90, 95, 105), scale = 1.4, auraColor = Color3.fromRGB(200, 40, 40) } },
	{ id = "dread_lord", name = "Dread Lord", sourceRef = "PLACEHOLDER: Darkseid", district = 4, cost = 125000000000000000, costType = "Loot", infamyPerClick = 59000000000000000000, morph = { bodyColor = Color3.fromRGB(80, 85, 95), headColor = Color3.fromRGB(90, 95, 105), torsoColor = Color3.fromRGB(40, 50, 90), scale = 1.38, auraColor = Color3.fromRGB(255, 60, 40) } },
	{ id = "parademon_prime", name = "Parademon Prime", sourceRef = "PLACEHOLDER: Steppenwolf", district = 4, cost = 149, costType = "Robux", infamyPerClick = 5000000000000000, special = "District 4 Robux", morph = { bodyColor = Color3.fromRGB(120, 120, 130), headColor = Color3.fromRGB(130, 130, 140), torsoColor = Color3.fromRGB(100, 100, 110), scale = 1.28 } },

	-- District 5: Orbital Citadel
	{ id = "trickster_god", name = "Trickster God", sourceRef = "PLACEHOLDER: Loki", district = 5, cost = 200000000000000000, costType = "Loot", infamyPerClick = 150000000000000000000, morph = { bodyColor = Color3.fromRGB(30, 100, 50), headColor = Color3.fromRGB(220, 190, 150), torsoColor = Color3.fromRGB(180, 140, 30), scale = 1.2, auraColor = Color3.fromRGB(60, 220, 90) } },
	{ id = "emberlord", name = "Emberlord", sourceRef = "PLACEHOLDER: Surtur", district = 5, cost = 480000000000000000, costType = "Loot", infamyPerClick = 375000000000000000000, morph = { bodyColor = Color3.fromRGB(180, 50, 20), headColor = Color3.fromRGB(220, 80, 20), torsoColor = Color3.fromRGB(140, 30, 15), scale = 1.45, auraColor = Color3.fromRGB(255, 90, 20) } },
	{ id = "death_queen", name = "Death Queen", sourceRef = "PLACEHOLDER: Hela", district = 5, cost = 1150000000000000000, costType = "Loot", infamyPerClick = 940000000000000000000, morph = { bodyColor = Color3.fromRGB(20, 40, 25), headColor = Color3.fromRGB(220, 220, 230), torsoColor = Color3.fromRGB(15, 30, 20), scale = 1.25, auraColor = Color3.fromRGB(40, 220, 80) } },
	{ id = "trigor", name = "Trigor", sourceRef = "PLACEHOLDER: Trigon", district = 5, cost = 2760000000000000000, costType = "Loot", infamyPerClick = 2350000000000000000000, morph = { bodyColor = Color3.fromRGB(160, 25, 25), headColor = Color3.fromRGB(180, 30, 30), torsoColor = Color3.fromRGB(30, 30, 35), scale = 1.42, auraColor = Color3.fromRGB(255, 30, 30) } },
	{ id = "infernal", name = "Infernal", sourceRef = "PLACEHOLDER: Mephisto", district = 5, cost = 6600000000000000000, costType = "Loot", infamyPerClick = 5870000000000000000000, morph = { bodyColor = Color3.fromRGB(190, 30, 30), headColor = Color3.fromRGB(210, 35, 35), torsoColor = Color3.fromRGB(220, 40, 40), scale = 1.28, auraColor = Color3.fromRGB(255, 50, 30) } },
	{ id = "flameborn", name = "Flameborn", sourceRef = "PLACEHOLDER: Dormammu", district = 5, cost = 15800000000000000000, costType = "Loot", infamyPerClick = 14600000000000000000000, morph = { bodyColor = Color3.fromRGB(40, 40, 50), headColor = Color3.fromRGB(240, 80, 30), torsoColor = Color3.fromRGB(30, 30, 40), scale = 1.4, auraColor = Color3.fromRGB(255, 120, 20) } },
	{ id = "the_annihilator", name = "The Annihilator", sourceRef = "PLACEHOLDER: Annihilus", district = 5, cost = 38000000000000000000, costType = "Loot", infamyPerClick = 36500000000000000000000, morph = { bodyColor = Color3.fromRGB(60, 130, 50), headColor = Color3.fromRGB(70, 150, 60), torsoColor = Color3.fromRGB(120, 40, 130), scale = 1.32 } },
	{ id = "deathlord", name = "Deathlord", sourceRef = "PLACEHOLDER: Nekron", district = 5, cost = 91000000000000000000, costType = "Loot", infamyPerClick = 91000000000000000000000, morph = { bodyColor = Color3.fromRGB(30, 30, 35), headColor = Color3.fromRGB(180, 190, 205), torsoColor = Color3.fromRGB(20, 20, 25), scale = 1.35, auraColor = Color3.fromRGB(50, 50, 60) } },
	{ id = "the_unmaker", name = "The Unmaker", sourceRef = "PLACEHOLDER: Anti-Monitor", district = 5, cost = 218000000000000000000, costType = "Loot", infamyPerClick = 227000000000000000000000, morph = { bodyColor = Color3.fromRGB(180, 185, 195), headColor = Color3.fromRGB(200, 205, 215), torsoColor = Color3.fromRGB(50, 80, 160), scale = 1.48, auraColor = Color3.fromRGB(80, 150, 255) } },
	{ id = "void_king", name = "Void King", sourceRef = "PLACEHOLDER: Knull", district = 5, cost = 524000000000000000000, costType = "Loot", infamyPerClick = 568000000000000000000000, morph = { bodyColor = Color3.fromRGB(15, 15, 18), headColor = Color3.fromRGB(230, 230, 235), torsoColor = Color3.fromRGB(20, 20, 24), scale = 1.36, auraColor = Color3.fromRGB(200, 20, 20) } },
	{ id = "world_eater", name = "World Eater", sourceRef = "PLACEHOLDER: Galactus", district = 5, cost = 1250000000000000000000, costType = "Loot", infamyPerClick = 1420000000000000000000000, morph = { bodyColor = Color3.fromRGB(110, 35, 125), headColor = Color3.fromRGB(130, 40, 145), torsoColor = Color3.fromRGB(50, 80, 160), scale = 1.6, auraColor = Color3.fromRGB(160, 50, 200) } },
	{ id = "the_beyond", name = "The Beyond", sourceRef = "PLACEHOLDER: The Beyonder", district = 5, cost = 3000000000000000000000, costType = "Loot", infamyPerClick = 3550000000000000000000000, morph = { bodyColor = Color3.fromRGB(240, 240, 245), headColor = Color3.fromRGB(245, 245, 250), torsoColor = Color3.fromRGB(235, 235, 240), scale = 1.3, auraColor = Color3.fromRGB(255, 255, 255) } },
	{ id = "living_tribunal", name = "Living Tribunal", sourceRef = "PLACEHOLDER: The Living Tribunal", district = 5, cost = 7200000000000000000000, costType = "Loot", infamyPerClick = 8870000000000000000000000, morph = { bodyColor = Color3.fromRGB(220, 180, 30), headColor = Color3.fromRGB(240, 200, 40), torsoColor = Color3.fromRGB(210, 170, 25), scale = 1.65, auraColor = Color3.fromRGB(255, 225, 50) } },
	{ id = "silver_herald", name = "Silver Herald", sourceRef = "PLACEHOLDER: Silver Surfer Fallen", district = 5, cost = 149, costType = "Robux", infamyPerClick = 1000000000000000000000, special = "District 5 Robux", morph = { bodyColor = Color3.fromRGB(200, 205, 215), headColor = Color3.fromRGB(210, 215, 225), torsoColor = Color3.fromRGB(190, 195, 205), scale = 1.2, auraColor = Color3.fromRGB(220, 230, 255) } },
}

-- 4. Jobs Table
Config.Jobs = {}
Config.Jobs[1] = {
	{ jobIndex = 1, requiredInfamy = 10, enemyHp = 120, enemyCount = 4, lootPayout = 1 },
	{ jobIndex = 2, requiredInfamy = 50, enemyHp = 600, enemyCount = 4, lootPayout = 5 },
	{ jobIndex = 3, requiredInfamy = 250, enemyHp = 3000, enemyCount = 4, lootPayout = 25 },
	{ jobIndex = 4, requiredInfamy = 1500, enemyHp = 18000, enemyCount = 4, lootPayout = 150 },
	{ jobIndex = 5, requiredInfamy = 8000, enemyHp = 96000, enemyCount = 4, lootPayout = 800, bossName = "Sergeant Mallcop" },
	{ jobIndex = 6, requiredInfamy = 40000, enemyHp = 480000, enemyCount = 4, lootPayout = 4000 },
	{ jobIndex = 7, requiredInfamy = 200000, enemyHp = 2400000, enemyCount = 4, lootPayout = 20000 },
	{ jobIndex = 8, requiredInfamy = 1000000, enemyHp = 12000000, enemyCount = 4, lootPayout = 100000 },
	{ jobIndex = 9, requiredInfamy = 5000000, enemyHp = 60000000, enemyCount = 4, lootPayout = 500000 },
	{ jobIndex = 10, requiredInfamy = 20000000, enemyHp = 240000000, enemyCount = 4, lootPayout = 2000000, bossName = "Lieutenant Shield" },
	{ jobIndex = 11, requiredInfamy = 70000000, enemyHp = 840000000, enemyCount = 4, lootPayout = 7000000 },
	{ jobIndex = 12, requiredInfamy = 200000000, enemyHp = 2400000000, enemyCount = 4, lootPayout = 20000000 },
	{ jobIndex = 13, requiredInfamy = 450000000, enemyHp = 5400000000, enemyCount = 4, lootPayout = 45000000 },
	{ jobIndex = 14, requiredInfamy = 700000000, enemyHp = 8400000000, enemyCount = 4, lootPayout = 70000000 },
	{ jobIndex = 15, requiredInfamy = 1000000000, enemyHp = 12000000000, enemyCount = 4, lootPayout = 150000000, bossName = "The Rookie Cape" },
}

for d = 2, 5 do
	Config.Jobs[d] = {}
	local baseReq = (Config.Jobs[d - 1][15].requiredInfamy * 1.5)
	local baseLoot = (Config.Jobs[d - 1][15].lootPayout * 1.3)
	for j = 1, 15 do
		local req = math.floor(baseReq * (2.2 ^ (j - 1)))
		local hp = req * 12
		local loot = math.floor(baseLoot * (2.1 ^ (j - 1)))
		local boss = nil
		if j == 5 then boss = "Sub-Enforcer D" .. tostring(d)
		elseif j == 10 then boss = "Captain D" .. tostring(d)
		elseif j == 15 then boss = Config.Districts[d].bossName end
		table.insert(Config.Jobs[d], {
			jobIndex = j,
			requiredInfamy = req,
			enemyHp = hp,
			enemyCount = 4 + math.floor(j / 3),
			lootPayout = loot,
			bossName = boss,
		})
	end
end

-- 5. Henchmen (Pets) & Items (Weapons)
Config.Henchmen = {
	{ id = "alley_cat", name = "Alley Cat", rarity = "Common", crateId = "crate_slums", multipliers = { infamy = 0.15, loot = 0.1, speed = 1, heat = 0 } },
	{ id = "sewer_rat", name = "Sewer Rat", rarity = "Common", crateId = "crate_slums", multipliers = { infamy = 0.2, loot = 0.1, speed = 1, heat = 0 } },
	{ id = "guard_hound", name = "Guard Hound", rarity = "Rare", crateId = "crate_slums", multipliers = { infamy = 0.5, loot = 0.25, speed = 1, heat = 0 } },
	{ id = "shadow_raven", name = "Shadow Raven", rarity = "Epic", crateId = "crate_slums", multipliers = { infamy = 1.2, loot = 0.5, speed = 1.1, heat = 0 } },
	{ id = "robotic_drone", name = "Robotic Drone", rarity = "Legendary", crateId = "crate_slums", multipliers = { infamy = 3.0, loot = 1.0, speed = 1.2, heat = 0 } },
	{ id = "quantum_amoeba", name = "Quantum Amoeba", rarity = "Mythic", crateId = "crate_slums", multipliers = { infamy = 5.0, loot = 2.0, speed = 1.2, heat = 0 }, special = "Retains 25% of your Infamy through Go Underground" },
}

Config.Items = {
	{ id = "crowbar", name = "Steel Crowbar", power = 25, rarity = "Common" },
	{ id = "brass_knuckles", name = "Heavy Knuckles", power = 100, rarity = "Common" },
	{ id = "mace", name = "Spiked Flail", power = 500, rarity = "Rare" },
	{ id = "shotgun", name = "Sawed-Off", power = 2500, rarity = "Epic" },
	{ id = "riot_shield", name = "Aegis Shield", power = 10000, rarity = "Legendary" },
	{ id = "reaper_scythe", name = "Chrono Scythe", power = 50000, rarity = "Mythic" },
}

Config.Crates = {
	{
		id = "crate_slums",
		name = "Stray Crate",
		district = 1,
		cost = 10,
		costType = "Loot",
		weights = {
			alley_cat = 50,
			sewer_rat = 30,
			guard_hound = 15,
			shadow_raven = 4,
			robotic_drone = 0.9,
			quantum_amoeba = 0.1,
		},
	},
}

-- 6. Raids & Retention (Hero Boss & Hourly Big Score)
Config.Raids = {
	HeroRaid = {
		intervalSeconds = 600, -- 10 minutes
		joinWindowSeconds = 30,
		enrageHpRatio = 0.4,
		baseBossHealth = 500000,
	},
	BigScore = {
		fixedClockMinute = 30,
		lives = 3,
		baseBossHealth = 2500000,
		clearHeatReward = 4500,
	},
	TheGrind = {
		heatPerKill = 25,
		waveInterval = 5,
	},
}

-- 7. Codes
Config.Codes = {
	["RELEASE"] = { loot = 50, heat = 100, label = "50 Loot & 100 Heat" },
	["LOOT2026"] = { loot = 250, heat = 0, label = "250 Free Loot" },
	["HEATWAVE"] = { loot = 0, heat = 500, label = "500 Bonus Heat" },
	["UNDERGROUND"] = { loot = 500, heat = 250, label = "500 Loot & 250 Heat" },
	["VILLAIN"] = { loot = 1000, heat = 0, label = "1,000 Loot" },
	["OVERLORD"] = { loot = 2500, heat = 1000, label = "2,500 Loot & 1,000 Heat" },
}

-- 8. Passes & Micro-Products
Config.Gamepasses = {
	{ id = 1001, name = "+3 Henchmen", price = 89 },
	{ id = 1002, name = "Getaway Van", price = 359 },
	{ id = 1003, name = "2x Infamy", price = 179 },
	{ id = 1004, name = "2x Loot", price = 269 },
	{ id = 1005, name = "Auto Click", price = 129 },
	{ id = 1006, name = "Auto Heist", price = 449 },
	{ id = 1007, name = "2x Speed", price = 12 }, -- matches screenshot "2x Speed ONLY 12 R$"
	{ id = 1008, name = "2x Wins", price = 19 }, -- matches screenshot "2x Wins ONLY 19 R$"
	{ id = 1009, name = "Skip Rebirth", price = 19 }, -- matches screenshot "Skip Rebirth 19 R$"
	{ id = 1010, name = "VIP Kingpin", price = 359 },
}

function Config.GetVillain(id: string): Villain?
	for _, v in Config.Villains do
		if v.id == id then return v end
	end
	return nil
end

function Config.GetDistrict(districtId: number)
	for _, d in Config.Districts do
		if d.id == districtId then return d end
	end
	return nil
end

return Config
