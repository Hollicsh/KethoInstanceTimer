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
	"CHAT_MSG_SYSTEM",

	"LFG_PROPOSAL_SUCCEEDED",
	"LFG_COMPLETION_REWARD",
	"SCENARIO_COMPLETED",
	"CHALLENGE_MODE_COMPLETED",
	"ENCOUNTER_END",
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
	seasonal = "FFD700",
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
	[1152] = true,
	[1330] = true,
	[1153] = true,
	[1154] = true,
	[1158] = true,
	[1331] = true,
	[1159] = true,
	[1160] = true,
}

S.difficulty = {}

if S.isRetail then
	for i = 1, 200 do
		S.difficulty[i] = GetDifficultyInfo(i)
	end
end

local normalRaid = {
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[14] = true,
	[15] = true,
	[16] = true,
}

function S.IsNormalRaid()
	return normalRaid[select(3, GetInstanceInfo())]
end

S.BossIDs = {
	[11502] = true,
	[11583] = true,
	[15339] = true,
	[15727] = true,

	[15690] = true,
	[17257] = true,
	[17968] = true,
	[19044] = true,
	[19622] = true,
	[21212] = true,
	[22917] = true,
	[25315] = true,

	[10184] = true,
	[15990] = true,
	[28859] = true,
	[28860] = true,
	[33288] = true,
	[34564] = true,
	[36597] = true,
	[38433] = true,
	[39863] = true,

	[41376] = true,
	[43324] = true,
	[46753] = true,
	[52363] = true,
	[52409] = true,
	[56173] = true,

	[60400] = true,
	[60999] = true,
	[62837] = true,

	[77428] = true,
	[77325] = true,
	[91331] = true,

	[102206] = true,
	[110533] = true,
	[114537] = true,
	[117269] = true,
	[124828] = true,

	[132998] = true,
	[149684] = true,
	[150397] = true,
	[155126] = true,
}

S.ClassicBossIDs = {
	[639] = true,
	[1716] = true,
	[1853] = true,
	[2748] = true,
	[3654] = true,
	[3977] = true,
	[4275] = true,
	[4421] = true,
	[4829] = true,
	[5709] = true,
	[7267] = true,
	[7358] = true,
	[7800] = true,
	[9019] = true,
	[9568] = L["Lower Blackrock Spire"],
	[10363] = L["Upper Blackrock Spire"],
	[10813] = L["Stratholme - Main Gate"],
	[10440] = L["Stratholme - Service Entrance"],
	[11501] = true,
	[11520] = true,
	[12201] = true,
}

S.DungeonName = {}

function S.RemapDungeon()
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

		[55689] = S.DungeonName[416],
		[56173] = S.DungeonName[417],

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
	S.LastKillTime = nil
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

	local endTime = S.LastKillTime or GetServerTime()
	S.LastInst = (char.timeInstance > 0) and endTime - char.timeInstance

	self:ResetTime()
	wipe(S.MultipleCache)
end

function KIT:Record(zoneName, endTime)
	endTime = endTime or GetServerTime()
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
		["end"] = date("%H:%M", endTime),
		zone = zoneName or self:Zone(),
		instanceType = S.instance,
		difficulty = select(3, GetInstanceInfo()),
		time = endTime - char.timeInstance,
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

function KIT:InstanceText(isPreview, name, endTime)
	wipe(args)
	local serverTime = endTime or GetServerTime()

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