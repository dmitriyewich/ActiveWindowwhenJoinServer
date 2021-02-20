script_name("Activated window game when Join Server") 
script_author("dmitriyewich")
script_description("With this simple script, you won't miss your server connection.")
script_url("https://vk.com/dmitriyewichmods")
script_dependencies("ffi", "memory", "samp.events")
script_properties('work-in-pause', 'forced-reloading-only')
script_version("1.2")
script_version_number(03)
require "lib.moonloader"
local ffi = require 'ffi'
local lsampev, sampev = pcall(require, 'samp.events') -- https://github.com/THE-FYP/SAMP.Lua
local lwm, wm = pcall(require, 'lib.windows.message')
local lmemory, memory = pcall(require, 'memory')

ffi.cdef [[
	typedef void* HANDLE;
	typedef const char* LPCSTR;
	typedef unsigned UINT;
    typedef int BOOL;
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef int bInvert;
	typedef unsigned long DWORD;
	typedef DWORD *PDWORD;
 
    HWND GetActiveWindow(void);
	HWND SetActiveWindow(HWND hWnd);
	BOOL ShowWindow(HWND hWnd, int  nCmdShow);
	
	BOOL OpenIcon(HWND hWnd);
	
	HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
	BOOL IsIconic(HWND hWnd);
	BOOL SetForegroundWindow(HWND hWnd);
	BOOL ShowWindowAsync(HWND hWnd,int nCmdShow);
	void SwitchToThisWindow(HWND hwnd, BOOL fUnknown);
	BOOL BlockInput(BOOL fBlockIt);
	BOOL BringWindowToTop(HWND hWnd);
	
	HWND GetForegroundWindow(void);
	DWORD GetCurrentThreadId(void);
	DWORD GetWindowThreadProcessId(HWND hWnd, PDWORD lpdwProcessId);
	BOOL AttachThreadInput(DWORD idAttach, DWORD idAttachTo, BOOL  fAttach);
]]

local arr = {}
local active = true
function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	hwnd = ffi.C.FindWindowA("Grand theft auto San Andreas", nil)
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
			if msg == wm.WM_KILLFOCUS then
				memory.write(0x747FB6, 0x1, 1, true)
				memory.write(0x74805A, 0x1, 1, true)
				memory.fill(0x74542B, 0x90, 8, true)
				memory.fill(0x53EA88, 0x90, 6, true)
				lockPlayerControl(true)
				active = true
			elseif msg == wm.WM_SETFOCUS then
				memory.write(0x747FB6, 0x0, 1, true)
				memory.write(0x74805A, 0x0, 1, true)
				arr = { 0x50, 0x51, 0xFF, 0x15, 0x00, 0x83, 0x85, 0x00 }
				memset(0x74542B)
				arr = { 0x0F, 0x84, 0x7B, 0x01, 0x00, 0x00 }
				memset(0x53EA88)
				lockPlayerControl(false)
				active = false
			end
        end
    end)
	checklibs() -- эту удалить если не нужна проверка на библиотеки 
	wait(-1)
	end

function memset(addr)
	for i = 1, #arr do
		memory.write(addr + i - 1, arr[i], 1, true)
	end
end

if lsampev then
	function sampev.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
		if active then
			lua_thread.create(function()
				hCurrWnd = ffi.C.GetForegroundWindow()
				iMyTID   = ffi.C.GetCurrentThreadId()
				iCurrTID = ffi.C.GetWindowThreadProcessId(hCurrWnd, nil)
				ffi.C.BlockInput(true)
				wait(74)
				ffi.C.AttachThreadInput(iMyTID, iCurrTID, true)
				ffi.C.SetForegroundWindow(hwnd)
				ffi.C.OpenIcon(hwnd);
				ffi.C.SetActiveWindow(hwnd)
				ffi.C.ShowWindow(hwnd, 3)
				ffi.C.SwitchToThisWindow(hwnd, true)
				ffi.C.BringWindowToTop(hwnd)
				wait(74)
				ffi.C.BlockInput(false)
				ffi.C.AttachThreadInput(iMyTID, iCurrTID, false)
			end)
		end
	end
end

function checklibs() -- с этой строки и до конца
	if not lsampev then
		lua_thread.create(function()
			print('Подгрузка необходимых библиотек..')
			--samp.lua 
			createDirectory(getWorkingDirectory()..'\\lib\\samp')
			createDirectory(getWorkingDirectory()..'\\lib\\samp\\events')
			downloadFile('events', getWorkingDirectory()..'\\lib\\samp\\events.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events.lua') do wait(0) end
			downloadFile('raknet', getWorkingDirectory()..'\\lib\\samp\\raknet.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/raknet.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\raknet.lua') do wait(0) end
			downloadFile('synchronization', getWorkingDirectory()..'\\lib\\samp\\synchronization.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/synchronization.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\synchronization.lua') do wait(0) end
			downloadFile('bitstream_io', getWorkingDirectory()..'\\lib\\samp\\events\\bitstream_io.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events\\bitstream_io.lua') do wait(0) end
			downloadFile('core', getWorkingDirectory()..'\\lib\\samp\\events\\core.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/core.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events\\core.lua') do wait(0) end
			downloadFile('extra_types', getWorkingDirectory()..'\\lib\\samp\\events\\extra_types.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/extra_types.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events\\extra_types.lua') do wait(0) end
			downloadFile('handlers', getWorkingDirectory()..'\\lib\\samp\\events\\handlers.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/handlers.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events\\handlers.lua') do wait(0) end
			downloadFile('utils', getWorkingDirectory()..'\\lib\\samp\\events\\utils.lua', 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/utils.lua')
		 	while not doesFileExist(getWorkingDirectory()..'\\lib\\samp\\events\\utils.lua') do wait(0) end				
			print('Подгрузка необходимых библиотек окончена. Перезагружаюсь..')
			noErrorDialog = true
			wait(1000)
			thisScript():reload()
		end)
		return false
	end
	return true
end

function downloadFile(name, path, link)
	if not doesFileExist(path) then 
		downloadUrlToFile(link, path, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				print('Файл {006AC2}«'..name..'»{FFFFFF} загружен!')
			end
		end)
	end
end