script_name("Activated window game when Join Server") 
script_author("dmitriyewich")
script_description("With this simple script, you won't miss your server connection.")
script_url("https://vk.com/dmitriyewichmods")
script_dependencies("ffi", "memory", "samp.events")
script_properties('work-in-pause', 'forced-reloading-only')
script_version("1.3")
script_version_number(03)
require "lib.moonloader"
local ffi = require 'ffi'
local lsampev, sampev = pcall(require, 'samp.events') assert(lsampev, 'Library \'samp.events\' not found.')-- https://github.com/THE-FYP/SAMP.Lua
local lwm, wm = pcall(require, 'lib.windows.message')
local lmemory, memory = pcall(require, 'memory')
local lencoding, encoding = pcall(require, 'encoding') assert(lencoding, 'Library \'encoding\' not found.')

encoding.default = 'CP1251'
u8 = encoding.UTF8
CP1251 = encoding.CP1251

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
	-- hwnd = ffi.C.FindWindowA("Grand theft auto San Andreas", nil)
	hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
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

	wait(-1)
end

function memset(addr)
	for i = 1, #arr do
		memory.write(addr + i - 1, arr[i], 1, true)
	end
end

function sampev.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
	if active then
		lua_thread.create(function()
			hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
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
