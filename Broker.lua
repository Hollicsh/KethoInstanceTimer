local NAME, S = ...
local KIT = kInstanceTimer

local ACD = LibStub("AceConfigDialog-3.0")
local L = S.L

local IsInInstance = IsInInstance
local GetBattlefieldInstanceRunTime = GetBattlefieldInstanceRunTime

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "data source",
	icon = "Interface\\Icons\\Spell_Holy_BorrowedTime",
	OnClick = function(clickedframe, button)
		ACD[ACD.OpenFrames.kInstanceTimer and "Close" or "Open"](ACD, NAME)
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddLine(L.BROKER_CLICK)
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

KIT:ScheduleRepeatingTimer(function()
	local instance = select(2, IsInInstance())
	
	if S.pve[instance] then
		local istanceTime = KIT:GetInstanceTime()
		dataobject.text = MilitaryTime(S.LastInst and S.LastInst or (istanceTime > 0 and time() - istanceTime or 0))
	elseif S.pvp[instance] then -- no idea about arena
		local bgTime = GetBattlefieldInstanceRunTime() or 0
		dataobject.text = MilitaryTime(bgTime / 1000)
	else
		dataobject.text = MilitaryTime(0)
	end
end, 1)

LibStub("LibDataBroker-1.1"):NewDataObject(NAME, dataobject)
