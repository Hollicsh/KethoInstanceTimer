local NAME, S = ...
local KIT = KethoInstanceTimer

local ACD = LibStub("AceConfigDialog-3.0")
local L = S.L

local GetBattlefieldInstanceRunTime = GetBattlefieldInstanceRunTime

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "data source",
	icon = "Interface\\Icons\\Spell_Holy_BorrowedTime",
	OnClick = function(clickedframe, button)
		if button == "RightButton" then
			ACD[ACD.OpenFrames[NAME] and "Close" or "Open"](ACD, NAME)
		elseif button == "LeftButton" and not IsModifierKeyDown() then
			if KethoInstanceTimerData then
				if KethoInstanceTimerData:IsShown() then
					KethoInstanceTimerData:Hide()
				else
					KethoInstanceTimerData:Show()
				end
			else
				KethoInstanceTimer:DataFrame()
			end
		elseif button == "LeftButton" and IsModifierKeyDown() then
			KIT:SlashCommand(KIT:IsEnabled() and "0" or "1")
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddLine(L.BROKER_LCLICK)
		tt:AddLine(L.BROKER_RCLICK)
		tt:AddLine(L.BROKER_SHIFT_CLICK)
	end,
}

	------------
	--- Time ---
	------------

local function MilitaryTime(v)
	local sec = floor(v) % 60
	local minute = floor(v/60) % 60
	local hour = floor(v/3600)

	if v >= 3600 then
		return format("%02.f:%02.f:%02.f", hour, minute, sec)
	else
		return format("%02.f:%02.f", minute, sec)
	end
end

	-------------
	--- Timer ---
	-------------

C_Timer.NewTicker(1, function()
	if S.pvp[S.instance] then -- no idea about arena
		local bgTime = GetBattlefieldInstanceRunTime() or 0
		dataobject.text = MilitaryTime(bgTime / 1000)
	else
		local timeInstance = KIT.db.char.timeInstance
		dataobject.text = MilitaryTime(S.LastInst and S.LastInst or (timeInstance > 0 and GetServerTime() - timeInstance or 0))
	end
end)

LibStub("LibDataBroker-1.1"):NewDataObject(NAME, dataobject)
