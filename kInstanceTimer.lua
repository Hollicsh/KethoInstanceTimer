-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.05.27					---
--- Version: 0.8.0 [2012.06.25]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/kinstancetimer
--- WoWInterface	http://www.wowinterface.com/downloads/info19910-kInstanceTimer.html

-- To Do:
-- * new record time
-- * Check BossTargetFrameTemplate how Blizzard sees when a boss dies

local NAME, S = ...
S.VERSION = "0.8.0"
S.BUILD = "Release"

kInstanceTimer = LibStub("AceAddon-3.0"):NewAddon(NAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0", "LibSink-2.0")
local KIT = kInstanceTimer
KIT.S = S -- debug purpose

local L = S.L
local profile, char

function KIT:RefreshDB1()
	profile = self.db.profile
	char = self.db.char
end

local date, time = date, time
local floor = floor
local format, gsub = format, gsub 

S.args = {}
local args = S.args

	--------------
	--- Events ---
	--------------

S.events = {
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_SYSTEM",
	"COMBAT_LOG_EVENT_UNFILTERED",
	
	-- fallback/secondary events
	"LFG_PROPOSAL_SUCCEEDED",
	"LFG_COMPLETION_REWARD",
	
	-- RESET_INSTANCES button / ResetInstances()
	"CHAT_MSG_SYSTEM",
}

	----------------------
	--- Instance Types ---
	----------------------

-- also used for color
S.pve = {
	party = "A8A8FF",
	raid = "FF7F00",
	seasonal = "FFD700", -- imaginary instance type
}

S.pvediff = {
	party = "PLAYER_DIFFICULTY",
	raid = "RAID_DIFFICULTY",
}

S.pvp = {
	pvp = true,
	arena = true,
}

	----------------
	--- Boss IDs ---
	----------------

S.BossIDs = { -- Instance Timer
	-- [1-60] Classic
	[1853] = true, -- Darkmaster Gandling; Scholomance
	[2748] = true, -- Archaedas; Uldaman
	[3975] = true, -- Herod; Scarlet Monastery: Armory
	[3977] = true, -- High Inquisitor Whitemane; Scarlet Monastery: Cathedral
	[3654] = true, -- Mutanus the Devourer; Wailing Caverns
	[4275] = true, -- Archmage Arugal; Shadowfang Keep (Normal/Heroic)
	[4421] = true, -- Charlga Razorflank; Razorfen Kraul
	[4543] = true, -- Bloodmage Thalnos; Scarlet Monastery: Graveyard
	[4829] = true, -- Aku'mai; Blackfathom Deeps
	[5709] = true, -- Shade of Eranikus; Sunken Temple
	[6487] = true, -- Arcanist Doan; Scarlet Monastery: Library
	[7267] = true, -- Chief Ukorz Sandscalp; Zul'Farrak
	[7358] = true, -- Amnennar the Coldbringer; Razorfen Downs
	[7800] = true, -- Mekgineer Thermaplugg; Gnomeregan
	[9018] = true, -- High Interrogator Gerstahn; Blackrock Depths: Prison
	[9019] = true, -- Emperor Dagran Thaurissan; Blackrock Depths: Upper City
	-- Blackrock Spire doesn't return the instance's name as the zone name
	[9568] = L["Lower Blackrock Spire"], -- Overlord Wyrmthalak; Lower Blackrock Spire
	[10363] = L["Upper Blackrock Spire"], -- General Drakkisath; Upper Blackrock Spire
	[10813] = true, -- Balnazzar; Stratholme: Main Gate
	[11486] = true, -- Prince Tortheldrin; Dire Maul: Capital Gardens
	[11492] = true, -- Alzzin the Wildshaper; Dire Maul: Warpwood Quarter
	[11501] = true, -- King Gordok; Dire Maul: Gordok Commons
	[11520] = true, -- Taragaman the Hungerer; Ragefire Chasm
	[12201] = true, -- Princess Theradras; Maraudon: Earth Song Falls
	[12236] = true, -- Lord Vyletongue; Maraudon: The Wicked Grotto
	[12258] = true, -- Razorlash; Maraudon: Foulspore Cavern
	[45412] = true, -- Lord Aurius Rivendare; Stratholme - Service Entrance
	[46964] = true, -- Lord Godfrey; Shadowfang Keep
	[46254] = true, -- Hogger; Stormwind Stockade
	[47739] = true, -- "Captain" Cookie; Deadmines (Normal)
	[49541] = true, -- Vanessa VanCleef; Deadmines (Heroic)

	-- [60-70] The Burning Crusade
	[16808] = true, -- Warchief Kargath Bladefist; Hellfire Citadel: The Shattered Halls
	[17377] = true, -- Keli'dan the Breaker; Hellfire Citadel: The Blood Furnace
--	[17536] = true, -- [Old] Nazan; Hellfire Citadel: Hellfire Ramparts
	[17307] = true, -- Nazan; Hellfire Citadel: Hellfire Ramparts
	[17798] = true, -- Warlord Kalithresh; Coilfang Reservoir: The Steamvault
	[17881] = true, -- Aeonus; Caverns of Time: The Black Morass
	[17882] = true, -- The Black Stalker; Coilfang Reservoir: The Underbog
	[17942] = true, -- Quagmirran; Coilfang Reservoir: The Slave Pens
	[17977] = true, -- Warp Splinter; Tempest Keep: The Botanica
	[18344] = true, -- Nexus-Prince Shaffar; Auchindoun: Mana-Tombs
	[18373] = true, -- Exarch Maladaar; Auchindoun: Auchenai Crypts
	[18473] = true, -- Talon King Ikiss; Auchindoun: Sethekk Halls
	[18708] = true, -- Murmur; Auchindoun: Shadow Labyrinth
	[18096] = true, -- Epoch Hunter; Caverns of Time: Old Hillsbrad Foothills
	[19220] = true, -- Pathaleon the Calculator; Tempest Keep: The Mechanar
	[20912] = true, -- Harbinger Skyriss; Tempest Keep: The Arcatraz

	-- [70-80] Wrath of the Lich King
	[26632] = true, -- The Prophet Tharon'ja; Drak'Tharon Keep (name has an extra space at the end when transformed] = true, GUID remains unchanged though)
	[26723] = true, -- Keristrasza; The Nexus: The Nexus
	[26861] = true, -- King Ymiron; Utgarde Keep: Utgarde Pinnacle
	[27656] = true, -- Ley-Guardian Eregos; The Nexus: The Oculus
	[27978] = true, -- Sjonnir The Ironshaper; Ulduar: Halls of Stone
	[28923] = true, -- Loken; Ulduar: Halls of Lightning
	[29120] = true, -- Anub'arak; Azjol-Nerub: Azjol-Nerub
	[29306] = true, -- Gal'darah; Gundrak
	[29311] = true, -- Herald Volazj; Azjol-Nerub: Ahn'kahet: The Old Kingdom
	[31134] = true, -- Cyanigosa; The Violet Hold
	[36502] = true, -- Devourer of Souls; Icecrown Citadel: The Forge of Souls
	[36658] = true, -- Scourgelord Tyrannus; Icecrown Citadel: Pit of Saron
--	[23954] = true, -- Ingvar the Plunderer; Utgarde Keep: Utgarde Pinnacle (dies 2x)
--	[26533] = true, -- Mal'Ganis; Caverns of Time: The Culling of Stratholme (no death)
--	[35451] = true, -- The Black Knight; Crusaders' Coliseum: Trial of the Champion (dies 3x)
--	[36954] = true, -- The Lich King; Icecrown Citadel: Halls of Reflection (no death)

	-- [80-85] Cataclysm
	[39705] = true, -- Ascendant Lord Obsidius; Blackrock Caverns
	[39378] = true, -- Rajh; Halls of Origination
	[40484] = true, -- Erudax; Grim Batol
	[42333] = true, -- High Priestess Azil; The Stonecore
	[43875] = true, -- Asaad; The Vortex Pinnacle
--	[44566] = true, -- Ozumat; Throne of the Tides [no death; 1hp]
	[44819] = true, -- Siamat; Lost City of the Tol'vir
	[52148] = true, -- Jin'do the Godbreaker; Zul'Gurub (does he actually die?)
--	[52150] = true, -- Jin'do the Godbreaker; Zul'Gurub (the phase 2 version)
	[23863] = true, -- Daakara; Zul'Aman
	[54432] = true, -- Murozond; End Time
	[54969] = true, -- Mannoroth; Well of Eternity (not sure if this one works)
	[54938] = true, -- Archbishop Benedictus; Hour of Twilight
}

S.Seasonal = {
	[23682] = L["The Headless Horseman"], -- "Headless Horseman", Hallow's End
	[23872] = L["Coren Direbrew"], -- "Coren Direbrew", Brewfest
	[25740] = L["The Frost Lord Ahune"], -- "Ahune", Midsummer Fire Festival
	[36296] = L["The Crown Chemical Co."], -- "Apothecary Hummel", Love is in the Air
}

-- copy seasonal into boss ids, so we can still differentiate between them
for k, v in pairs(S.Seasonal) do
	S.BossIDs[k] = v
end

S.PreBossIDs = {
	[12236] = true, -- Lord Vyletongue
	[12258] = true, -- Razorlash
	[9018] = true, -- High Interrogator Gerstahn
	[10813] = true, -- Balnazzar
}

S.FinalBossIDs = {
	[12201] = true, -- Princess Theradras
	[9019] = true, -- Emperor Dagran Thaurissan
	[45412] = true, -- Lord Aurius Rivendare
}

S.RaidBossIDs = { -- untested
	-- [1-60] Classic
	[11502] = true, -- Ragnaros; Molten Core
	[11583] = true, -- Nefarian; Blackwing Lair
	[15339] = true, -- Ossirian the Unscarred; Ruins of Ahn'Qiraj
	[15727] = true, -- C'Thun; Temple of Ahn'Qiraj
	
	-- [60-70] The Burning Crusade
	[15690] = true, -- Prince Malchezaar; Karazhan
	[17257] = true, -- Magtheridon; Hellfire Citadel: Magtheridon's Lair
	[17968] = true, -- Archimonde; Caverns of Time: Hyjal Summit
	[19044] = true, -- Gruul the Dragonkiller; Gruul's Lair
	[19622] = true, -- Kael'thas Sunstrider; Tempest Keep: The Eye
	[21212] = true, -- Lady Vashj; Coilfang Reservoir: Serpentshrine Cavern
	[22917] = true, -- Illidan Stormrage; Black Temple
	[25315] = true, -- Kil'jaeden; Sunwell Plateau
	
	-- [70-80] Wrath of the Lich King
	[10184] = true, -- Onyxia; Onyxia's Lair
	[15990] = true, -- Kel'Thuzad; Naxxramas
	[28859] = true, -- Malygos; The Nexus: The Eye of Eternity
	[28860] = true, -- Sartharion; Wyrmrest Temple: The Obsidian Sanctum
	[33288] = true, -- Yogg-Saron; Ulduar
	[34564] = true, -- Anub'arak; Crusaders' Coliseum: Trial of the Crusader
	[36597] = true, -- The Lich King; Icecrown Citadel
	[38433] = true, -- Toravon the Ice Watcher; Vault of Archavon
	[39863] = true, -- Halion; Wyrmrest Temple: The Ruby Sanctum
	
	-- [80-85] Cataclysm
	[41376] = true, -- Nefarian; Blackwing Descent
	[43324] = true, -- Cho'gall; The Bastion of Twilight
	[46753] = true, -- Al'Akir; Throne of the Four Winds
	[52363] = true, -- Occu'thar; Baradin Hold
	[52409] = true, -- Ragnaros; Firelands
	[55689] = true, -- Hagara the Stormbinder; Dragon Soul (To Do: only when in Raid Finder)
	[56173] = true, -- Deathwing; Dragon Soul (no death)
}

S.SubZoneBossIDs = {
	-- Scarlet Monastery
	[4543] = L.Graveyard, -- [26-36] Bloodmage Thalnos
	[6487] = L.Library, -- [29-39] Arcanist Doan
	[3975] = L.Armory, -- [32-42] Herod
	[3977] = L.Cathedral, -- [35-45] High Inquisitor Whitemane
	-- Maraudon
	[12236] = L["The Wicked Grotto"], -- [30-40] Lord Vyletongue
	[12258] = L["Foulspore Cavern"], -- [32-42] Razorlash
	[12201] = L["Earth Song Falls"], -- [34-44] Princess Theradras
	-- Blackrock Depths
	[9018] = L["Detention Block"], -- [47-57] High Interrogator Gerstahn
	[9019] = L["Upper City"], -- [51-61] Emperor Dagran Thaurissan
	-- Dire Maul
	[11492] = L["Warpwood Quarter"], -- [36-46] Alzzin the Wildshaper
	[11486] = L["Capital Gardens"], -- [39-49] Prince Tortheldrin
	[11501] = L["Gordok Commons"], -- [42-52] King Gordok
	-- Stratholme
	[10813] = L["Main Gate"], -- [42-52] Balnazzar
	[45412] = L["Service Entrance"], -- [46-56] Lord Aurius Rivendare
}

S.SubRaidZoneBossIDs = {
	-- Dragon Soul
	[55689] = L["The Siege of Wyrmrest Temple"], -- Hagara the Stormbinder
	[56173] = L["Fall of Deathwing"], --  Deathwing
}

	---------------------
	--- Instance Time ---
	---------------------

function KIT:GetInstanceTime()
	return S.backupInstance or char.timeInstance
end

function KIT:StartData()
	char.timeInstance = time()
	
	char.startDate = date("%Y.%m.%d")
	char.startTime = date("%H:%M")
	
	-- reset so broker can start counting again
	S.backupInstance = nil
	S.LastInst = nil	
end

function KIT:ResetTime(isLeave)
	char.timeInstance = 0
	char.startDate = ""
	char.startTime = ""
	
	if isLeave then
		S.backupInstance = nil
		S.LastInst = nil
	end
end

	------------
	--- Time ---
	------------

function KIT:SecondsTime(v)
	return SecondsToTime(v, profile.TimeOmitSec, not profile.TimeAbbrev, profile.TimeMaxCount)
end

do
	-- not capitalized
	local D_SECONDS = strlower(D_SECONDS)
	local D_MINUTES = strlower(D_MINUTES)
	local D_HOURS = strlower(D_HOURS)
	local D_DAYS = strlower(D_DAYS)
	
	-- exception for German capitalization
	if GetLocale() == "deDE" then
		D_SECONDS = _G.D_SECONDS
		D_MINUTES = _G.D_MINUTES
		D_HOURS = _G.D_HOURS
		D_DAYS = _G.D_DAYS
	end
	
	function KIT:TimeString(v, full)
		local sec = floor(v) % 60
		local minute = floor(v/60) % 60
		local hour = floor(v/3600) % 24
		local day = floor(v/86400)
		
		local fsec = format(D_SECONDS, sec)
		local fmin = format(D_MINUTES, minute)
		local fhour = format(D_HOURS, hour)
		local fday = format(D_DAYS, day)
		
		if v >= 86400 then
			return (hour > 0 or full) and format("%s, %s", fday, fhour) or fday
		elseif v >= 3600 then
			return (minute > 0 or full) and format("%s, %s", fhour, fmin) or fhour
		elseif v >= 60 then
			return (sec > 0 or full) and format("%s, %s", fmin, fsec) or fmin
		elseif v >= 0 then
			return fsec
		else
			return v
		end
	end
end

do
	local b = CreateFrame("Button")
	
	function KIT:Time(v)
		local s
		if profile.LegacyTime then
			s = self:TimeString(v, not profile.TimeOmitZero)
		else
			s = self:SecondsTime(v)
			s = profile.TimeLowerCase and s:lower() or s
		end
		-- sanitize for SendChatMessage by removing any pipe characters
		return b:GetText(b:SetText(s)) or ""
	end
end

	---------------------------
	--- Time Format Example ---
	---------------------------

do
	local tday, thour, tmin, tsec = random(9), random(23), random(59), random(59)
	
	S.TimeUnits = {
		60*tmin,
		60*tmin + tsec,
		3600*thour + 60*tmin + tsec,
		86400*tday + 3600*thour + 60*tmin + tsec,
	}
	
	S.TimeOmitZero = 3600*thour
end

	-----------------
	--- Stopwatch ---
	-----------------

function S.StopwatchStart()
	
	local v
	local instance = select(2, IsInInstance())
	
	if S.pve[instance] then
		v = KIT:GetInstanceTime()
	elseif S.pvp[instance] then
		v = GetBattlefieldInstanceRunTime()
	end
	
	StopwatchFrame:Show()
	if v and v > 0 then
		StopwatchTicker.timer = time() - v
	else
		Stopwatch_Clear()
	end
	Stopwatch_Play()
end

function S.StopwatchEnd()
	Stopwatch_Clear()
	StopwatchFrame:Hide()
end

function S.IsStopwatch()
	local instance = select(2, IsInInstance())
	return (profile.Stopwatch and instance ~= "none")
end

	--------------------
	--- Class Colors ---
	--------------------

S.classCache = setmetatable({}, {__index = function(t, k)
	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[k] or RAID_CLASS_COLORS[k]
	local v = format("%02X%02X%02X", color.r*255, color.g*255, color.b*255)
	rawset(t, k, v)
	return v
end})

	------------
	--- Rest ---
	------------

function KIT:NoGroup()
	return GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 and not IsOnePersonParty()
end

function KIT:Zone()
	return GetRealZoneText() or GetSubZoneText() or ZONE
end

	--------------
	--- Report ---
	--------------

local exampleTime = random(3600)

function KIT:InstanceText(subZone, isPreview, special)
	wipe(args)
	local instanceTime = self:GetInstanceTime()
	
	if isPreview then
		args.instance = "|cffA8A8FF"..self:Zone().."|r"
		args.time = "|cff71D5FF"..self:Time(instanceTime > 0 and time() - instanceTime or exampleTime).."|r"
		args.start = "|cffF6ADC6"..(instanceTime > 0 and char.startTime or date("%H:%M")).."|r"
		args["end"] = "|cffADFF2F"..date("%H:%M", time() + exampleTime).."|r" -- can't use keywords as a table key o_O
		args.date = "|cff0070DD"..date("%Y.%m.%d").."|r"
		args.date2 = "|cff0070DD"..date("%m/%d/%y").."|r"
	else
		args.instance = special or self:Zone()..(subZone and ": "..subZone or "")
		args.time = self:Time(instanceTime > 0 and time() - instanceTime or 0)
		args.start = char.startTime
		args["end"] = date("%H:%M")
		args.date = date("%Y.%m.%d")
		args.date2 = date("%m/%d/%y")
	end
	return self:ReplaceArgs(profile.InstanceTimerMsg, args)
end

	---------------
	--- Replace ---
	---------------

function KIT:ReplaceArgs(msg, args)
	-- new random messages init as nil
	if not msg then return "" end
	
	for k in gmatch(msg, "%b<>") do
		-- remove <>, make case insensitive
		local s = strlower(gsub(k, "[<>]", ""))
		
		-- escape special characters
		s = gsub(args[s] or s, "(%p)", "%%%1")
		k = gsub(k, "(%p)", "%%%1")
		
		msg = msg:gsub(k, s)
	end
	wipe(args)
	return msg
end

	--------------
	--- Record ---
	--------------

-- Save Instance Timer data
function KIT:Record(subZone, special, seasonal)
	-- tried recycling "party" and that was kinda dumb of me
	local party = {}
	
	-- don't record (party) members for raid instances
	if not (GetNumRaidMembers() > 0) then
		for i = 1, GetNumPartyMembers() do
			local name, realm = UnitName("party"..i)
			local class = select(2, UnitClass("party"..i))
			party[i] = {name, realm or GetRealmName(), class}
		end
	end
	
	local isRaidFinder = (GetLFGModeType() == "raid")
	
	tinsert(char.TimeInstanceList, {
		date = char.startDate,
		start = char.startTime,
		["end"] = date("%H:%M"),
		zone = special or self:Zone()..(subZone and ": "..subZone or ""),
		instanceType = seasonal and "seasonal" or select(2, IsInInstance()),
		difficulty = isRaidFinder or GetInstanceDifficulty(),
		time = time() - char.timeInstance,
		party = party,
	})
end
