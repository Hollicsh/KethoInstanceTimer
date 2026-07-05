---@diagnostic disable: undefined-field
local NAME, S = ...

local function SafeGetAddOnMetadata(name, key)
	if C_AddOns and C_AddOns.GetAddOnMetadata then
		return C_AddOns.GetAddOnMetadata(name, key)
	elseif GetAddOnMetadata then
		return GetAddOnMetadata(name, key)
	else
		return "Unknown"
	end
end

S.VERSION = SafeGetAddOnMetadata(NAME, "Version")
S.BUILD = "Release"

KethoInstanceTimer = LibStub("AceAddon-3.0"):NewAddon(NAME, "AceEvent-3.0", "AceConsole-3.0", "LibSink-2.0")
local KIT = KethoInstanceTimer
KIT.S = S

S.isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

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


S.Events = {
	"PLAYER_ENTERING_WORLD",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"CHAT_MSG_SYSTEM",

	"LFG_PROPOSAL_SUCCEEDED",
	"LFG_COMPLETION_REWARD",
	"SCENARIO_COMPLETED",
}

S.ClassicEvents = {
	"PLAYER_ENTERING_WORLD",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"CHAT_MSG_SYSTEM",
}

S.pve = {
	party = "A8A8FF",
	raid = "FF7F00",
	scenario = "FFFFFF",
	seasonal = "FFD700", -- imaginary instance type
}

S.pvp = {
	pvp = true,
	arena = true,
}

S.npc = {
	Creature = true,
	Vehicle = true,
}

S.garrison = {
	[1152] = true, -- FW Horde Garrison Level 1
	[1330] = true, -- FW Horde Garrison Level 2
	[1153] = true, -- FW Horde Garrison Level 3
	[1154] = true, -- FW Horde Garrison Level 4
	[1158] = true, -- SMV Alliance Garrison Level 1
	[1331] = true, -- SMV Alliance Garrison Level 2
	[1159] = true, -- SMV Alliance Garrison Level 3
	[1160] = true, -- SMV Alliance Garrison Level 4
}

S.difficulty = {}

if S.isRetail then
	for i = 1, 200 do
		S.difficulty[i] = GetDifficultyInfo(i)
	end
end

local normalRaid = {
	[3] = true, -- "10 Player" raid
	[4] = true, -- "25 Player" raid
	[5] = true, -- "10 Player (Heroic)" raid
	[6] = true, -- "25 Player (Heroic)" raid
	[14] = true, -- "Normal" raid
	[15] = true, -- "Heroic" raid
	[16] = true, -- "Mythic" raid
}

function S.IsNormalRaid()
	return normalRaid[select(3, GetInstanceInfo())]
end

S.BossIDs = { -- untested
	-- [60] Classic
	[11502] = true, -- Ragnaros; Molten Core
	[11583] = true, -- Nefarian; Blackwing Lair
	[15339] = true, -- Ossirian the Unscarred; Ruins of Ahn'Qiraj
	[15727] = true, -- C'Thun; Temple of Ahn'Qiraj

	-- [70] The Burning Crusade
	[15690] = true, -- Prince Malchezaar; Karazhan
	[17257] = true, -- Magtheridon; Hellfire Citadel: Magtheridon's Lair
	[17968] = true, -- Archimonde; Caverns of Time: Hyjal Summit
	[19044] = true, -- Gruul the Dragonkiller; Gruul's Lair
	[19622] = true, -- Kael'thas Sunstrider; Tempest Keep: The Eye
	[21212] = true, -- Lady Vashj; Coilfang Reservoir: Serpentshrine Cavern
	[22917] = true, -- Illidan Stormrage; Black Temple
	[25315] = true, -- Kil'jaeden; Sunwell Plateau

	-- [80] Wrath of the Lich King
	[10184] = true, -- Onyxia; Onyxia's Lair
	[15990] = true, -- Kel'Thuzad; Naxxramas
	[28859] = true, -- Malygos; The Nexus: The Eye of Eternity
	[28860] = true, -- Sartharion; Wyrmrest Temple: The Obsidian Sanctum
	[33288] = true, -- Yogg-Saron; Ulduar
	[34564] = true, -- Anub'arak; Crusaders' Coliseum: Trial of the Crusader
	[36597] = true, -- The Lich King; Icecrown Citadel
	[38433] = true, -- Toravon the Ice Watcher; Vault of Archavon
	[39863] = true, -- Halion; Wyrmrest Temple: The Ruby Sanctum

	-- [85] Cataclysm
	[41376] = true, -- Nefarian; Blackwing Descent
	[43324] = true, -- Cho'gall; The Bastion of Twilight
	[46753] = true, -- Al'Akir; Throne of the Four Winds
	[52363] = true, -- Occu'thar; Baradin Hold
	[52409] = true, -- Ragnaros; Firelands
	[56173] = true, -- Deathwing (no death); Dragon Soul

	-- [90] Mists of Pandaria
	[60400] = true, -- Jan-xi; Mogu'shan Vaults
	[60999] = true, -- Sha of Fear; Terrace of Endless Spring
	[62837] = true, -- Grand Empress Shek'zeer; Heart of Fear

	-- [100] Warlords of Draenor
	[77428] = true, -- Imperator Mar'gok; Highmaul
	[77325] = true, -- Blackhand; Blackrock Foundry
	[91331] = true, -- Archimonde; Hellfire Citadel

	-- [110] Legion (untested)
	[102206] = true, -- Xavius; The Emerald Nightmare
	[110533] = true, -- Gul'dan; The Nighthold
	[114537] = true, -- Helya; Trial of Valor
	[117269] = true, -- Kil'jaeden; Tomb of Sargeras
	[124828] = true, -- Argus the Unmaker; Antorus, the Burning Throne

	-- [120] Battle for Azeroth (untested)
	[132998] = true, -- G'huun; Uldir
	[149684] = true, -- Lady Jaina Proudmoore; Battle of Dazar'alor
	[150397] = true, -- King Mechagon; Operation: Mechagon
	[155126] = true, -- Queen Azshara; The Eternal Palace
}

S.ClassicBossIDs = {
	[639] = true, -- Edwin VanCleef; Deadmines
	[1716] = true, -- Bazil Thredd; Stormwind Stockade
	[1853] = true, -- Darkmaster Gandling; Scholomance
	[2748] = true, -- Archaedas; Uldaman
	[3654] = true, -- Mutanus the Devourer; Wailing Caverns
	[3977] = true, -- High Inquisitor Whitemane; Scarlet Monastery
	[4275] = true, -- Archmage Arugal; Shadowfang Keep
	[4421] = true, -- Charlga Razorflank; Razorfen Kraul
	[4829] = true, -- Aku'mai; Blackfathom Deeps
	[5709] = true, -- Shade of Eranikus; Sunken Temple
	[7267] = true, -- Chief Ukorz Sandscalp; Zul'Farrak
	[7358] = true, -- Amnennar the Coldbringer; Razorfen Downs
	[7800] = true, -- Mekgineer Thermaplugg; Gnomeregan
	[9019] = true, -- Emperor Dagran Thaurissan; Blackrock Depths
	[9568] = L["Lower Blackrock Spire"], -- Overlord Wyrmthalak
	[10363] = L["Upper Blackrock Spire"], -- General Drakkisath
	[10813] = L["Stratholme - Main Gate"], -- Balnazzar
	[10440] = L["Stratholme - Service Entrance"], -- Lord Aurius Rivendare
	[11501] = true, -- King Gordok; Dire Maul
	[11520] = true, -- Taragaman the Hungerer; Ragefire Chasm
	[12201] = true, -- Princess Theradras; Maraudon
}

-- /run for i = 1, GetNumRFDungeons() do print(GetRFDungeonInfo(i)) end
-- GetLFGDungeonInfo(i)
S.DungeonName = {}

function S.RemapDungeon() -- wait for init S.DungeonName
	S.DungeonIDs = {
		[23682] = S.DungeonName[285],
		[25740] = S.DungeonName[286],
		[25865] = S.DungeonName[286],
		[23872] = S.DungeonName[287],
		[36296] = S.DungeonName[288],
		[36565] = S.DungeonName[288],
		[36272] = S.DungeonName[288],

		-- Multiple Parts Dungeon
		[12258] = S.DungeonName[26],
		[12236] = S.DungeonName[272],
		[12201] = S.DungeonName[273],

		[9018] = S.DungeonName[30],
		[9019] = S.DungeonName[276],

		[11486] = S.DungeonName[36],
		[11492] = S.DungeonName[34],
		[11501] = S.DungeonName[38],

		[10813] = S.DungeonName[40],
		[45412] = S.DungeonName[274],

		[9568] = S.DungeonName[32],
		[10363] = S.DungeonName[330],
		[77120] = S.DungeonName[860],

		-- [85] Cataclysm
		[55689] = S.DungeonName[416],
		[56173] = S.DungeonName[417],

		-- [90] Mists of Pandaria
		-- ...

		-- [100] Warlords of Draenor
		[78491] = S.DungeonName[849],
		[79015] = S.DungeonName[850],
		[77428] = S.DungeonName[851],

		[76806] = S.DungeonName[847],
		[77692] = S.DungeonName[846],
		[77557] = S.DungeonName[848],
		[77231] = S.DungeonName[848],
		[77477] = S.DungeonName[848],
		[77325] = S.DungeonName[823],

		[90435] = S.DungeonName[982],
		[91809] = S.DungeonName[983],
		[93439] = S.DungeonName[984],
		[91349] = S.DungeonName[985],
		[91331] = S.DungeonName[986],

		-- [110] Legion
		-- ...
	}
end

S.SpecialDungeon = {
	[285] = true,
	[286] = true,
	[287] = true,
	[288] = true,

	[26] = true,
	[272] = true,
	[273] = true,

	[30] = true,
	[276] = true,

	[34] = true,
	[36] = true,
	[38] = true,

	[40] = true,
	[274] = true,

	[32] = true,
	[330] = true,
	[860] = true,
}

S.Multiple = {
	[36296] = "The Crown Chemical Co.",
	[36565] = "The Crown Chemical Co.",
	[36272] = "The Crown Chemical Co.",
	[77557] = "Iron Assembly",
	[77231] = "Iron Assembly",
	[77477] = "Iron Assembly",
}

S.MultipleCache = {}

local multipleHash = {}
for k, v in pairs(S.Multiple) do
	multipleHash[v] = multipleHash[v] or {}
	multipleHash[v][k] = true
end

function S.CheckMultiple(v)
	if S.Multiple[v] then
		S.MultipleCache[v] = true

		for k in pairs(multipleHash[S.Multiple[v]]) do
			if not S.MultipleCache[k] then
				return
			end
		end
	end

	return true
end

function KIT:StartData()
	local serverTime = GetServerTime()
	char.timeInstance = serverTime
	char.startDate = date("%Y.%m.%d", serverTime)
	char.startTime = date("%H:%M", serverTime)

	S.LastInst = nil
end

function KIT:ResetTime(isLeave)
	char.timeInstance = 0
	char.startDate = ""
	char.startTime = ""

	if isLeave then
		S.LastInst = nil
	end
end

function KIT:SecondsTime(v)
	return SecondsToTime(v, profile.TimeOmitSec, not profile.TimeAbbrev, profile.TimeMaxCount)
end

do
	local D_SECONDS = strlower(D_SECONDS)
	local D_MINUTES = strlower(D_MINUTES)
	local D_HOURS = strlower(D_HOURS)
	local D_DAYS = strlower(D_DAYS)

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
		return b:GetText(b:SetText(s)) or ""
	end
end

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

function S.StopwatchStart()
	if S.pve[S.instance] then
		if char.timeInstance > 0 then
			StopwatchTicker.timer = GetServerTime() - char.timeInstance
		else
			Stopwatch_Clear()
		end
	elseif S.pvp[S.instance] then
		StopwatchTicker.timer = GetBattlefieldInstanceRunTime()/1000
	end

	StopwatchFrame:Show()
	Stopwatch_Play()
end

function S.StopwatchEnd()
	Stopwatch_Clear()
	StopwatchFrame:Hide()
end

function S.StopwatchPause()
	StopwatchTicker.timer = GetServerTime() - char.timeInstance
	StopwatchTicker_Update()
	Stopwatch_Pause()
end

function S.IsStopwatch()
	return (profile.Stopwatch and S.instance ~= "none" and not S.IsGarrison())
end

-- garrison instance type == "party"
function S.IsGarrison()
	local instanceID = select(8, GetInstanceInfo())
	return S.garrison[instanceID]
end

S.classCache = setmetatable({}, {__index = function(t, k)
	local colorTable = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	local color = colorTable and colorTable[k]
	if not color then
		rawset(t, k, "FFFFFF")
		return "FFFFFF"
	end
	local v = format("%02X%02X%02X", color.r*255, color.g*255, color.b*255)
	rawset(t, k, v)
	return v
end})

function KIT:WipeCache()
	wipe(S.classCache)
end

function KIT:Zone()
	return GetRealZoneText() or GetSubZoneText() or ZONE
end

function KIT:Finalize()
	if profile.Stopwatch then
		S.StopwatchPause()
	end

	if profile.Screenshot then
		C_Timer.After(1, function() Screenshot() end)
	end

	S.LastInst = (char.timeInstance > 0) and GetServerTime() - char.timeInstance

	self:ResetTime()
	wipe(S.MultipleCache)
end

function KIT:Record(zoneName)
	local party = {}

	if not IsInRaid() and IsInGroup() then
		for i = 1, GetNumSubgroupMembers() do
			local name, realm = UnitName("party"..i)
			local class = select(2, UnitClass("party"..i))
			if not realm or realm == "" then
				realm = GetRealmName() -- WoD empty string fix
			end
			party[i] = {name, realm, class}
		end
	end

	tinsert(char.TimeInstanceList, {
		date = char.startDate,
		start = char.startTime,
		["end"] = date("%H:%M", GetServerTime()),
		zone = zoneName or self:Zone(),
		instanceType = S.instance,
		difficulty = select(3, GetInstanceInfo()),
		time = GetServerTime() - char.timeInstance,
		party = party,
	})
end

local function ReplaceArgs(msg, args)
	if not msg then return "" end

	for k in gmatch(msg, "%b<>") do
		local s = strlower(gsub(k, "[<>]", ""))

		s = gsub(args[s] or s, "(%p)", "%%%1")
		k = gsub(k, "(%p)", "%%%1")

		msg = msg:gsub(k, s)
	end
	wipe(args)
	return msg
end

local exampleTime = random(3600)

function KIT:InstanceText(isPreview, name)
	wipe(args)
	local serverTime = GetServerTime()

	if isPreview then
		args.instance = "|cffA8A8FF"..self:Zone().."|r"
		args.time = "|cff71D5FF"..self:Time(char.timeInstance > 0 and serverTime - char.timeInstance or exampleTime).."|r"
		args.start = "|cffF6ADC6"..(char.timeInstance > 0 and char.startTime or date("%H:%M", serverTime)).."|r" -- note startTime can be an empty string
		args["end"] = "|cffADFF2F"..date("%H:%M", serverTime + exampleTime).."|r" -- can't use keywords as a table key o_O
		args.date = "|cff0070DD"..date("%Y.%m.%d", serverTime).."|r"
		args.date2 = "|cff0070DD"..date("%m/%d/%y", serverTime).."|r"
		args.difficulty = "|cffFFFF00"..(select(4, GetInstanceInfo()) or UNKNOWN).."|r"
	else
		args.instance = name or self:Zone()
		args.time = self:Time(char.timeInstance > 0 and serverTime - char.timeInstance or 0)
		args.start = char.startTime
		args["end"] = date("%H:%M", serverTime)
		args.date = date("%Y.%m.%d",serverTime)
		args.date2 = date("%m/%d/%y", serverTime)
		args.difficulty = select(4, GetInstanceInfo()) or UNKNOWN
	end
	return ReplaceArgs(profile.InstanceTimerMsg, args)
end
