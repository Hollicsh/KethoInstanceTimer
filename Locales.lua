local _, S = ...

local L = {
	enUS = {
		INSTANCE_TIMER = "Instance Timer",
		INSTANCE_TIMER_MSG = "[<INSTANCE>] cleared in <TIME> [<START>]-[<END>]",
		MANUAL_RESET = TRACKER_SORT_MANUAL.." "..RESET,
		MANUAL_START = TRACKER_SORT_MANUAL.." "..START,
		RECORD_DATA = "Record Data",
		
		TIME_FORMAT = "Time Format",
		TIME_FORMAT_LEGACY = "Legacy Time Format",
		TIME_OMIT_ZERO_VALUE = "Omit Zero Value",
		TIME_MAX_UNITS = "Max time units",
		TIME_OMIT_SECONDS = "Omit "..SECONDS,
		TIME_LOWER_CASE = "Lower Case",
		TIME_ABBREVIATE = "Abbreviate",
		
		BROKER_LCLICK = "|cffFFFFFFLeft Click|r to toggle History",
		BROKER_RCLICK = "|cffFFFFFFRight Click|r to toggle the options menu",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift + Left Click|r to toggle this AddOn",
	},
	deDE = {
		INSTANCE_TIMER = "Instanz-Zeitnehmer",
		INSTANCE_TIMER_MSG = "[<INSTANCE>] beendet in <TIME> [<START>]-[<END>]",
		MANUAL_RESET = "Manuell zurücksetzen",
		MANUAL_START = "Manuell starten",
		RECORD_DATA = "Daten speichern",
		
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmenü zu öffnen",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-klickt|r, um dieses AddOn ein-/auszuschalten",
	},
	--esES = {},
	esMX = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones.",
		BROKER_SHIFT_CLICK = "|cffffffffMayús-clic|r para activar/desactivar.",
	},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ruRU = {INSTANCE_TIMER = "Таймер подземелья",
		INSTANCE_TIMER_MSG = "[<INSTANCE>] пройден за <TIME> [<START>]-[<END>]",
		MANUAL_RESET = TRACKER_SORT_MANUAL.." "..RESET,
		MANUAL_START = TRACKER_SORT_MANUAL.." "..START,
		RECORD_DATA = "Запись данных",
		
		TIME_FORMAT = "Формат времени",
		TIME_FORMAT_LEGACY = "Устаревший формат времени",
		TIME_OMIT_ZERO_VALUE = "Не использовать нулевое значение",
		TIME_MAX_UNITS = "Максимальное количество единиц времени",
		TIME_OMIT_SECONDS = "Не использовать "..SECONDS,
		TIME_LOWER_CASE = "Нижний регистр",
		TIME_ABBREVIATE = "Сокращение",
		
		BROKER_LCLICK = "|cffFFFFFFЛКМ|r - открыть историю",
		BROKER_RCLICK = "|cffFFFFFFПКМ|r - открыть настройки",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift+ЛКМ|r - открыть аддон",
		},
	zhCN = {		
		INSTANCE_TIMER = "副本计时器",
		INSTANCE_TIMER_MSG = "[<INSTANCE>] 已完成，用时 <TIME> [<START>]-[<END>]",
		MANUAL_RESET = "手动重置",
		MANUAL_START = "手动开始",
		RECORD_DATA = "记录数据",
		
		BROKER_CLICK = "|cffFFFFFF点击|r打开选项菜单",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-点击|r 启用或禁用插件",
	},
	zhTW = {
		INSTANCE_TIMER = "副本計時器",
		INSTANCE_TIMER_MSG = "[<INSTANCE>] 已完成，用時 <TIME> [<START>]-[<END>]",
		MANUAL_RESET = "手動重置",
		MANUAL_START = "手動開始",
		RECORD_DATA = "紀錄數據",
		
		BROKER_CLICK = "|cffFFFFFF點擊|r打開選項菜單",
		BROKER_SHIFT_CLICK = "|cffFFFFFFrShift-點擊|r 啟用或禁用插件",
	},
}

L.esES = L.esMX -- instance strings are identical

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
