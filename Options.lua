local NAME, S = ...
local KIT = KethoInstanceTimer

local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L
local profile, char

function KIT:RefreshDB2()
	profile = self.db.profile
	char = self.db.char
end

	---------------------
	--- GlobalStrings ---
	---------------------

-- remove "%d"
local SECONDS_ABBR2 = gsub(SECONDS_ABBR, "%%d ", "")
local MINUTES_ABBR2 = gsub(MINUTES_ABBR, "%%d ", "")
local HOURS_ABBR2 = gsub(HOURS_ABBR, "%%d ", "")
local DAYS_ABBR2 = gsub(DAYS_ABBR, "%%d ", "")

local arrow = "|cffF6ADC6->|r"
local REALM = FRIENDS_LIST_REALM:gsub(":", "")
S.crop = ":64:64:4:60:4:60"

	---------------
	--- Options ---
	---------------

S.defaults = {
	profile = {
		party = true,
		raid = true,
		scenario = true,
		InstanceTimerMsg = L.INSTANCE_TIMER_MSG,

		LegacyTime = true,
		TimeMaxCount = 2,

		sink20OutputSink = "Channel",
		sink20ScrollArea = GROUP,
	},
}

S.options = {
	type = "group",
	childGroups = "tab",
	name = format("%s |cffADFF2F%s|r", NAME, S.VERSION),
	args = {
		main = {
			type = "group", order = 1,
			name = GAMEOPTIONS_MENU,
			handler = KIT,
			get = "GetValue",
			set = "SetValue",
			args = {
				inline1 = {
					type = "group", order = 1,
					name = "|cff3FBF3F"..L.INSTANCE_TIMER.."|r",
					inline = true,
					args = {
						party = {
							type = "toggle", order = 1,
							width = "full", descStyle = "",
							name = " |cffA8A8FF"..DUNGEONS.."|r",
						},
						raid = {
							type = "toggle", order = 2,
							width = "full", descStyle = "",
							name = " |cffFF7F00"..RAIDS.."|r",
						},
						scenario = {
							type = "toggle", order = 3,
							width = "full", descStyle = "",
							name = " "..SCENARIOS,
						},
					},
				},
				InstanceTimerMsg = {
					type = "input", order = 2,
					width = "full",
					name = " ",
					usage = "\n|cffA8A8FFINSTANCE|r, |cff71D5FFTIME|r\n|cffF6ADC6START|r, |cffADFF2FEND|r\n|cff0070DDDATE|r, |cff0070DDDATE2|r\n|cffFFFF00DIFFICULTY|r",
					set = function(i, v) profile.InstanceTimerMsg = v
						if strtrim(v) == "" then
							profile.InstanceTimerMsg = S.defaults.profile.InstanceTimerMsg
						end
					end,
				},
				Preview = {
					type = "description", order = 3,
					fontSize = "medium",
					name = function() return "  "..KIT:InstanceText(true) end,
				},
				spacing1 = {type = "description", order = 4, name = "\n"},
				Stopwatch = {
					type = "toggle", order = 5,
					width = "full", descStyle = "",
					name = S.isRetail and "|TInterface\\Icons\\Spell_Holy_BorrowedTime:16:16:1:0"..S.crop.."|t  "..STOPWATCH_TITLE.."|r"
						or "|TInterface\\Icons\\spell_nature_timestop:16:16:1:0"..S.crop.."|t  "..STOPWATCH_TITLE.."|r",
					set = function(i, v)
						profile.Stopwatch = v
						if v then
							if S.IsStopwatch() then
								S.StopwatchStart()
							end
						else
							S.StopwatchEnd()
						end
					end,
				},
				Screenshot = {
					type = "toggle", order = 6,
					width = "full", descStyle = "",
					name = "|TInterface\\Icons\\inv_misc_spyglass_03:16:16:1:0"..S.crop.."|t  "..BINDING_NAME_SCREENSHOT,
				},
				Data = {
					type = "execute", order = 8,
					descStyle = "",
					name = "|TInterface\\Icons\\INV_Misc_Note_01:16:16:1:-1"..S.crop.."|t  |cffFFFFFF"..HISTORY.."|r",
					func = "DataFrame",
				},
			},
		},
		advanced = {
			type = "group", order = 3,
			name = "|TInterface\\Icons\\Trade_Engineering:16:16:-2:-1"..S.crop.."|t "..ADVANCED_LABEL,
			handler = KIT,
			get = "GetValue",
			set = "SetValue",
			args = {
				inline1 = {
					type = "group", order = 1,
					name = "|cff3FBF3F"..L.TIME_FORMAT.."|r",
					inline = true,
					args = {
						PreviewTime = {
							type = "description", order = 1,
							fontSize = "large",
							name = function()
								local s = profile.LegacyTime and KIT:TimeString(S.TimeOmitZero, not profile.TimeOmitZero) or KIT:Time(S.TimeUnits[profile.TimeMaxCount])
								return "|cffF6ADC6"..s.."|r"
							end,
						},
						header1 = {type = "header", order = 2, name = ""},
						LegacyTime = {
							type = "toggle", order = 3,
							width = "full", descStyle = "",
							name = function() return (profile.LegacyTime and "" or "|cff979797")..L.TIME_FORMAT_LEGACY end,
						},
						TimeOmitZero = {
							type = "toggle", order = 4,
							width = "full",
							desc = format("%s %s %s", KIT:TimeString(S.TimeOmitZero, true), arrow, KIT:TimeString(S.TimeOmitZero, false)),
							name = L.TIME_OMIT_ZERO_VALUE,
							hidden = function() return not profile.LegacyTime end,
						},
						TimeMaxCount = {
							type = "range", order = 5,
							descStyle = "",
							name = "   "..L.TIME_MAX_UNITS,
							min = 1,
							max = 4,
							step = 1,
							hidden = "LegacyTime",
						},
						TimeOmitSec = {
							type = "toggle", order = 6,
							width = "full",
							desc = SECONDS.." "..arrow.." |cffFF0000"..NOT_APPLICABLE.."|r",
							name = L.TIME_OMIT_SECONDS,
							hidden = "LegacyTime",
						},
						TimeLowerCase = {
							type = "toggle", order = 7,
							width = "full",
							desc = format("%s %s %s", HOURS, arrow, HOURS:lower()),
							name = L.TIME_LOWER_CASE,
							hidden = "LegacyTime",
						},
						TimeAbbrev = {
							type = "toggle", order = 8,
							width = "full",
							desc = format("%s %s %s\n%s %s %s\n%s %s %s\n%s %s %s",
								SECONDS, arrow, SECONDS_ABBR2, MINUTES, arrow, MINUTES_ABBR2, HOURS, arrow, HOURS_ABBR2, DAYS, arrow, DAYS_ABBR2),
							name = L.TIME_ABBREVIATE,
							hidden = "LegacyTime",
						},
					},
				},
				ManualStart = {
					type = "execute", order = 2,
					descStyle = "", confirm = true,
					name = L.MANUAL_START,
					func = "StartData",
				},
				newline1 = {type = "description", order = 3, name = ""},
				ManualEnd = {
					type = "execute", order = 4,
					descStyle = "", confirm = true,
					name = L.MANUAL_RESET,
					func = function() KIT:ResetTime(true) end,
				},
			},
		},
	},
}

function KIT:GetValue(i)
	return profile[i[#i]]
end

function KIT:SetValue(i, v)
	profile[i[#i]] = v
end

function KIT:LegacyTime()
	return profile.LegacyTime
end

	-----------------
	--- DataFrame ---
	-----------------

-- I peeked into Prat's CopyChat code for the ScrollFrame & EditBox <.<
-- and FloatingChatFrameTemplate for the ResizeButton >.>
function KIT:DataFrame()
	if not KethoInstanceTimerData then
		local f = CreateFrame("Frame", "KethoInstanceTimerData", UIParent, "DialogBoxFrame")
		f:SetPoint("CENTER"); f:SetSize(1000, 500)

		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
			edgeSize = 16,
			insets = { left = 8, right = 6, top = 8, bottom = 8 },
		})
		f:SetBackdropBorderColor(0, .44, .87, 0.5)

	---------------
	--- Movable ---
	---------------

		f:EnableMouse(true) -- also seems to be automatically enabled when setting the OnMouseDown script
		f:SetMovable(true); f:SetClampedToScreen(true)
		f:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self:StartMoving()
			end
		end)
		f:SetScript("OnMouseUp", f.StopMovingOrSizing)

	-------------------
	--- ScrollFrame ---
	-------------------

		local sf = CreateFrame("ScrollFrame", "KethoInstanceTimerDataScrollFrame", KethoInstanceTimerData, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetPoint("BOTTOM", KethoInstanceTimerDataButton, "TOP", 0, 0)

	---------------
	--- EditBox ---
	---------------

		local eb = CreateFrame("EditBox", "KethoInstanceTimerDataEditBox", KethoInstanceTimerDataScrollFrame)
		eb:SetSize(sf:GetSize()) -- seems inheriting the points won't automatically set the width/size

		eb:SetMultiLine(true)
		eb:SetFontObject("ChatFontNormal")
		eb:SetAutoFocus(false) -- make keyboard not automatically focused to this editbox
		eb:SetScript("OnEscapePressed", function(self)
			--self:ClearFocus()
			f:Hide() -- rather hide, since we only use it for copying to clipboard
		end)

		sf:SetScrollChild(eb)

	-----------------
	--- Resizable ---
	-----------------

		f:SetResizable(true)
		if S.isRetail then
			f:SetResizeBounds(150, 100)
		else
			f:SetMinResize(150, 100) -- at least show the "okay" button
		end

		local rb = CreateFrame("Button", "KethoInstanceTimerDataResizeButton", KethoInstanceTimerData)
		rb:SetPoint("BOTTOMRIGHT", -6, 7); rb:SetSize(16, 16)

		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- we only want to see the PushedTexture now
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			eb:SetWidth(sf:GetWidth()) -- update editbox to the new scrollframe width
		end)

	-------------
	--- Realm ---
	-------------

		local realm = CreateFrame("CheckButton", nil, KethoInstanceTimerData, "UICheckButtonTemplate")
		realm:SetPoint("BOTTOMLEFT", 8, 7)
		realm.text:SetText(REALM)
		realm.text:SetFont("Fonts\\FRIZQT__.TTF", 16)

		realm:SetChecked(profile.Realm)
		realm:SetScript("OnClick", function(self, button)
			profile.Realm = self:GetChecked()
			eb:SetText(KIT:GetData())
		end)

	------------------
	--- Difficulty ---
	------------------

		local diff = CreateFrame("CheckButton", nil, KethoInstanceTimerData, "UICheckButtonTemplate")
		diff:SetPoint("BOTTOMLEFT", 140, 7)
		diff.text:SetText(DUNGEON_DIFFICULTY)
		diff.text:SetFont("Fonts\\FRIZQT__.TTF", 16)

		diff:SetChecked(profile.Difficulty)
		diff:SetScript("OnClick", function(self, button)
			profile.Difficulty = self:GetChecked()
			eb:SetText(KIT:GetData())
		end)

	----------------------------------------
	--- Skin for ElvUI if it's installed ---
	----------------------------------------

		if ElvUI then
			local S = ElvUI[1]:GetModule('Skins')
			KethoInstanceTimerData:SetTemplate('Transparent')
			S:HandleButton(KethoInstanceTimerDataButton)
			S:HandleScrollBar(KethoInstanceTimerDataScrollFrameScrollBar)
			S:HandleCheckBox(realm)
			S:HandleCheckBox(diff)
		end

		f:Show()
	else
		KethoInstanceTimerData:Show()
	end

	ACD:Close(NAME) -- close the options panel, its in the way now
	KethoInstanceTimerDataEditBox:SetText(self:GetData())
	GameTooltip:Hide() -- most likely the popup frame will prevent the GameTooltip's OnLeave script from firing
end

do
	local t = {}
	local realm = GetRealmName()

	function KIT:GetData()
		for i = 1, 4 do
			t[i] = t[i] or {}
			wipe(t[i])
		end

		for i = #char.TimeInstanceList, 1, -1 do
			local l = char.TimeInstanceList[i]

			for j, v in ipairs(l.party) do
				if profile.Realm then
					t[3][j] = format("|cff%s%s|r-%s", S.classCache[v[3]], v[1], (v[2] == realm) and "|cffADFF2F"..v[2].."|r" or v[2])
				else
					t[3][j] = format("|cff%s%s|r", S.classCache[v[3]], v[1])
				end
			end
			local partyformat = next(t[3]) and " - %s" or "%s"

			-- instanceType and difficulty data were added in v0.7
			local instanceColor = S.pve[l.instanceType or "party"]

			if profile.Difficulty and l.difficulty then
				local diff = S.difficulty[l.difficulty] or UNKNOWN -- most pre-mop data is wrong now ..

				tinsert(t[4], format("%s |cffF6ADC6[%s]|r-|cffADFF2F[%s]|r |cff%s[%s]|r |cffFFFF00%s|r - %s"..partyformat,
					l.date, l.start, l["end"], instanceColor, l.zone, diff, self:Time(l.time), strjoin(", ", unpack(t[3]))))
			else
				tinsert(t[4], format("%s |cffF6ADC6[%s]|r-|cffADFF2F[%s]|r |cff%s[%s]|r %s"..partyformat,
					l.date, l.start, l["end"], instanceColor, l.zone, self:Time(l.time), strjoin(", ", unpack(t[3]))))
			end

			wipe(t[3]) -- wipe for next iteration
		end

		return strjoin("\n", unpack(t[4]))
	end
end
