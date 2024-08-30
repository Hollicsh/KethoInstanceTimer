local NAME, S = ...
local KIT = KethoInstanceTimer

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L
local options = S.options

local profile, char

	---------------------------
	--- Ace3 Initialization ---
	---------------------------

function KIT:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("KethoInstanceTimerDB", S.defaults, true)

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshDB")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshDB")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshDB")
	self:RefreshDB()

	self.db.global.version = S.VERSION
	self.db.global.build = S.BUILD

	options.args.libsink = self:GetSinkAce3OptionsDataTable()
	options.args.libsink.order = 2

	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profiles.order = 4
	options.args.profiles.name = "|TInterface\\Icons\\INV_Misc_Note_01:16:16:-2:-1"..S.crop.."|t "..options.args.profiles.name

	ACR:RegisterOptionsTable(NAME, S.options)
	ACD:AddToBlizOptions(NAME, NAME)
	ACD:SetDefaultSize(NAME, 550, 430)

	---------------------
	--- Dungeon Names ---
	---------------------

	if S.isRetail then
		-- grab the localized names from the dungeon finder
		for i = 1, GetNumRFDungeons() do
			local id, name = GetRFDungeonInfo(i)
			S.DungeonName[id] = name
		end

		for k, v in pairs(S.SpecialDungeon) do
			S.DungeonName[k] = GetLFGDungeonInfo(k)
		end
	end

	S.RemapDungeon()

	----------------------
	--- Slash Commands ---
	----------------------

	for _, v in ipairs({"kit", "kethoinstance", "kethoinstancetimer"}) do
		self:RegisterChatCommand(v, "SlashCommand")
	end

	-----------------------------
	--- Custom SavedVariables ---
	-----------------------------

	char.TimeInstanceList = char.TimeInstanceList or {}

	-- time data should be preserved between every /reload
	char.timeInstance = char.timeInstance or 0
	char.startDate = char.startDate or ""
	char.startTime = char.startTime or ""
end

function KIT:OnEnable()
	for _, v in ipairs(S.isRetail and S.Events or S.ClassicEvents) do
		self:RegisterEvent(v)
	end

	-- support [Class Colors] by Phanx
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback("WipeCache", self)
	end

	-- player is not in a group (anymore) -> reset timer
	if not IsInGroup() then
		self:ResetTime(true)
	end

	-- initialize stopwatch while in an instance
	if S.IsStopwatch() then
		S.instance = select(2, IsInInstance())
		S.StopwatchStart()
	end
end

function KIT:OnDisable()
	self:UnregisterAllEvents()

	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:UnregisterCallback("WipeCache", self)
	end

	if S.IsStopwatch() then
		S.StopwatchEnd()
	end
end

function KIT:RefreshDB()
	profile = self.db.profile
	char = self.db.char

	self:SetSinkStorage(profile) -- LibSink

	-- update table references in other files
	for i = 1, 2 do
		self["RefreshDB"..i](self)
	end
end

local enable = {
	["1"] = true,
	on = true,
	enable = true,
	load = true,
}

local disable = {
	["0"] = true,
	off = true,
	disable = true,
	unload = true,
}

function KIT:SlashCommand(input)
	if enable[input] then
		self:Enable()
		self:Print("|cffADFF2F"..VIDEO_OPTIONS_ENABLED.."|r")
	elseif disable[input] then
		self:Disable()
		self:Print("|cffFF2424"..VIDEO_OPTIONS_DISABLED.."|r")
	elseif input == "toggle" then
		self:SlashCommand(self:IsEnabled() and "0" or "1")
	else
		ACD:Open(NAME)
	end
end

	-------------
	--- Start ---
	-------------

function KIT:PLAYER_ENTERING_WORLD(event)
	S.instance = select(2, IsInInstance())

	local prevInstance = S.mapinstance
	S.mapinstance = select(8, GetInstanceInfo())

	if S.pve[S.instance] and not S.IsGarrison() then
		-- zoned from an instance to a different instance
		local changedInstances = prevInstance and prevInstance ~= S.mapinstance
		-- entered instance
		if char.timeInstance == 0 or changedInstances then
			self:StartData()
		end

		if S.IsStopwatch() then
			S.StopwatchStart()
		end
	-- player is outside of the instance and player is alone or not in an (instance group == premade)
	--- still have no idea if the "home" group can change into an "instance" group on entering and vice versa on leaving
	--- hopefully it does, otherwise this is bad..
	elseif (S.instance == "none" or S.IsGarrison()) and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		-- left instance
		self:ResetTime(true)

		if profile.Stopwatch then
			S.StopwatchEnd()
		end
	end
end

	-----------
	--- End ---
	-----------

function KIT:COMBAT_LOG_EVENT_UNFILTERED(event)
	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

	if subevent ~= "UNIT_DIED" then return end

	local unitType, _, _, _, _, npcId = strsplit("-", destGUID)
	npcId = tonumber(npcId)

	local hasBossID = S.isRetail and S.BossIDs[npcId] or S.ClassicBossIDs[npcId]
	-- dont report raid finder in normal/heroic/mythic raids
	-- note that we still want to report in dungeons like maraudon and seasonal
	local name = not S.IsNormalRaid() and S.DungeonIDs[npcId] or hasBossID

	if S.npc[unitType] and name and char.timeInstance > 0 then

		-- boss fights with multiple npcs
		if S.Multiple[npcId] and not S.CheckMultiple(npcId) then return end

		-- if its raid finder/seasonal, get specific name, otherwise fall back to zone
		local name = (type(name) == "string") and name

		-- Record
		self:Record(name)

		-- Report
		if profile[S.instance] then
			self:Pour(self:InstanceText(nil, name))
		end

		self:Finalize()
	end
end

	---------------------
	--- Leave / Reset ---
	---------------------

-- dunno how to find a string consisting of 2 words, with just %s
local INSTANCE_RESET_SUCCESS = INSTANCE_RESET_SUCCESS:gsub("%%s", "")

function KIT:CHAT_MSG_SYSTEM(event, msg)
	-- left or kicked from group; or reset through ResetInstances()
	if msg == ERR_LEFT_GROUP_YOU or msg == ERR_UNINVITE_YOU or strfind(msg, INSTANCE_RESET_SUCCESS) then
		self:ResetTime(true)

		if profile.Stopwatch then
			S.StopwatchEnd()
		end
	end
end

	-----------------------
	--- Secondary Start ---
	-----------------------

function KIT:LFG_PROPOSAL_SUCCEEDED(event)
	C_Timer.After(20, function()
		if char.timeInstance == 0 then
			self:StartData()

			if S.IsStopwatch() then
				S.StopwatchStart()
			end
		end
	end)
end

	---------------------
	--- Secondary End ---
	---------------------

function KIT:SecondaryCompletion()
	-- delay it a bit, so it doesn't react on the same time as boss death
	C_Timer.After(1, function()
		if char.timeInstance > 0 then
			self:Record()

			if profile[S.instance] then
				self:Pour(self:InstanceText())
			end

			self:Finalize()
		end
	end)
end

-- only fires after completing a random dungeon
function KIT:LFG_COMPLETION_REWARD(event)
	self:SecondaryCompletion()
end

-- scenarios and instances (since WoD)
function KIT:SCENARIO_COMPLETED(event)
	self:SecondaryCompletion()
end
