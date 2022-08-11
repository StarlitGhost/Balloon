-- Copyright 2018, Hando
-- Copyright 2021, Yuki
-- Copyright 2022, Ghosty
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Balloon nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Hando BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--
_addon.author = 'Originally by Hando, English support added by Yuki & Kenshi, themes added by Ghosty'
_addon.name = 'Balloon'
_addon.version = '0.13'
_addon.commands = {'balloon','bl'}

require('luau')
chars = require('chat.chars')
chars.cldquo = string.char(0x87, 0xB2)
chars.crdquo = string.char(0x87, 0xB3)
texts = require('texts')
images = require('images')

local defaults = require('defaults')
local settings = {}

local theme = require('theme')
local theme_options = {}

local ui = require('ui')

local MODE = {}
MODE.MESSAGE = 150
MODE.SYSTEM = 151
MODE.TIMED_MESSAGE = 144
MODE.TIMED_BATTLE = 142
MODE.CUTSCENE_EMOTE = 15

local ENTER_KEY = 28
local SCROLL_LOCK_KEY = 70

local ZONE_OUT_PACKET = 0x0B
local LEAVE_CONVERSATION_PACKET = 0x52

-- 0x31-0x33 and 0x37 all appear the same
local PROMPT_CHARS = string.char(0x7F,0x31)
-- the 0x01 in this is the number of seconds before the prompt continues itself
-- 0x34-0x36 seem to do the same thing
local AUTO_PROMPT_CHARS = string.char(0x7F,0x34,0x01)

local balloon = {}
balloon.initialized = false
balloon.debug = 'off'
balloon.moving = false
balloon.old_x = "0"
balloon.old_y = "0"
balloon.on = false
balloon.keydown = false
balloon.mouse_on = false
balloon.waiting_to_close = false
balloon.frame_count = 0
balloon.prev_path = nil
balloon.close_timer = 0
balloon.timer_running = false
balloon.last_text = ''
balloon.last_mode = 0
balloon.movement_thread = nil

-------------------------------------------------------------------------------

function initialize()
	settings = config.load(defaults)
	config.save(settings)

	apply_theme()

	--スレッド開始 (Thread start)
	timer:schedule(0)
	if settings.MovementCloses then
		balloon.movement_thread = moving_check:schedule(0)
	end

	balloon.initialized = true
end

function apply_theme()
	local theme_path = 'themes/' .. settings.Theme .. '/theme.xml'
	local theme_settings = config.load(theme_path, {['name']=settings.Theme})
	theme_options = theme.apply(theme_settings)

	ui:load(settings, theme_options)
	if balloon.on then
		process_balloon(balloon.last_text, balloon.last_mode)
	end
end

function open(timed)
	if not balloon.initialized then
		initialize()
	end

	if timed then
		balloon.close_timer = settings.NoPromptCloseDelay
		ui.timer_text:text(''..balloon.close_timer)
	end

	ui:show(timed)

	balloon.waiting_to_close = timed
	balloon.on = true
end

function close()
	ui:hide()

	balloon.on = false
	balloon.waiting_to_close = false
end

function timer()
	-- from Aelmar's npcbox https://www.ffxiah.com/forum/topic/56227/balloon-story-addon/2/#3627878
	-- thanks for letting me use bits from it, Aelmar!
    if balloon.timer_running then return end
    balloon.timer_running = true
    while true do
		if balloon.waiting_to_close then
			if balloon.close_timer == 0 then
				close()
			end
			if balloon.close_timer > 0 then
				ui.timer_text:text(balloon.close_timer..'')
			end
			if balloon.close_timer >= 0 then
				balloon.close_timer = balloon.close_timer - 1
			end
		end
        coroutine.sleep(1)
    end
end

windower.register_event('load',function()
	if windower.ffxi.get_info().logged_in then
		initialize()
	end
end)

windower.register_event('login',function()
	-- re-load settings and theme 10 seconds after login,
	-- so per-character settings are picked up properly
	initialize:schedule(10)
end)

function moving_check()
	local p = windower.ffxi.get_player()
	if p == nil then return end

	local me,x,y

	while true do
		me = windower.ffxi.get_mob_by_id(p.id)
		if me ~= nil then
			x = string.format("%6d",me.x)
			y = string.format("%6d",me.y)
			--if x ~= old_x and y ~= old_y then
			if (tonumber(x) < tonumber(balloon.old_x) - 1 or tonumber(x) > tonumber(balloon.old_x) + 1) or (tonumber(y) < tonumber(balloon.old_y) - 1 or tonumber(y) > tonumber(balloon.old_y) + 1) then
				balloon.moving = true
				balloon.old_y = y
				balloon.old_x = x
			else
				balloon.moving = false
			end
		end
		--wait
		balloon.waiting_to_close = true
		coroutine.sleep(settings.NoPromptCloseDelay)
		if balloon.moving and settings.MovementCloses and balloon.waiting_to_close then
			close()
		end
	end

end

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	if S{'chunk', 'all'}[balloon.debug] then print("Chunk: " .. '0x%02X':format(id) .. " original: " .. original) end

	--会話中かの確認 (Check if you have left a conversation)
	if S{LEAVE_CONVERSATION_PACKET, ZONE_OUT_PACKET}[id] then
		close()
	end
end)

windower.register_event('incoming text',function(original,modified,mode,modified_mode,blocked)
	-- print debug info
	if S{'codes', 'mode', 'all'}[balloon.debug] then print("Mode: " .. mode .. " Text: " .. original) end

	-- skip text modes that aren't NPC speech
    if not S{MODE.MESSAGE, MODE.SYSTEM, MODE.TIMED_BATTLE, MODE.TIMED_MESSAGE}[mode] then return end

	-- blank prompt line that auto-continues itself,
	-- usually used to clear a space for a scene change?
	if original:endswith(AUTO_PROMPT_CHARS) then
		close()
		return
	end

	-- print debug info
	if S{'codes', 'all'}[balloon.debug] then print("codes: " .. codes(original)) end

	local result = original
	if settings.DisplayMode >= 1 then
		result = process_balloon(original, mode)
    end
    return(result)

end)

function process_balloon(npc_text, mode)
	if not balloon.initialized then
		initialize()
	end

	balloon.last_text = npc_text
	balloon.last_mode = mode

	-- detect whether messages have a prompt button
	local timed = true
	if S{MODE.MESSAGE, MODE.SYSTEM}[mode] and npc_text:sub(-#PROMPT_CHARS) == PROMPT_CHARS then
		timed = false
	end

	-- 発言者名の抽出 (Speaker name extraction)
	local start,_end = npc_text:find(".- : ")
	local npc_prefix = ""
	if start ~= nil then
		if _end < 32 and start > 0 then npc_prefix = npc_text:sub(start,_end) end
	end
	local npc_name = npc_prefix:sub(0,#npc_prefix-2)
	npc_name = string.trim(npc_name)

	if not ui:set_character(npc_name) then
		ui:set_type(mode)
	end

	-- mode 1, blank log lines and visible balloon
	if settings.DisplayMode == 1 then
		if npc_prefix == "" then
			result = "" .. "\n"
		else
			result = npc_text:sub(#npc_text-1,#npc_text)
		end
	-- mode 2, visible log and balloon
	elseif settings.DisplayMode == 2 then
		-- pass through the original message for the log
		result = npc_text
	end

	-- 発言 (Remark)
	local mes = SubCharactersPreShift(npc_text)
	mes = windower.from_shift_jis(mes)
	mes = SubCharactersPostShift(mes)

	-- strip the NPC name from the start of the message
	if npc_prefix ~= "" then
		mes = mes:gsub(npc_prefix:gsub("-","--"),"") --タルタル等対応 (Correspondence such as tartar)
	end

	if S{'process', 'all'}[balloon.debug] then print("Pre-process: " .. mes) end
	if S{'codes', 'all'}[balloon.debug] then print("codes: " .. codes(mes)) end

	--strip the default color code from the start of messages,
	--it causes the first part of the message to get cut off somehow
	local default_color = string.char(0x1E,0x01)
	if string.sub(mes, 1, #default_color) == default_color then
		mes = string.sub(mes, #default_color + 1)
	end

	-- split by newlines
	local mess = split(mes,string.char(0x07))

	local message = ""
	for k,v in ipairs(mess) do
		v = string.gsub(v, string.char(0x1E,0x01), "[BL_c1]") --color code 1 (black/reset)
		v = string.gsub(v, string.char(0x1E,0x02), "[BL_c2]") --color code 2 (green/regular items)
		v = string.gsub(v, string.char(0x1E,0x03), "[BL_c3]") --color code 3 (blue/key items)
		v = string.gsub(v, string.char(0x1E,0x04), "[BL_c4]") --color code 4 (blue/???)
		v = string.gsub(v, string.char(0x1E,0x05), "[BL_c5]") --color code 5 (magenta/equipment?)
		v = string.gsub(v, string.char(0x1E,0x06), "[BL_c6]") --color code 6 (cyan/???)
		v = string.gsub(v, string.char(0x1E,0x07), "[BL_c7]") --color code 7 (yellow/???)
		v = string.gsub(v, string.char(0x1E,0x08), "[BL_c8]") --color code 8 (orange/RoE objectives?)
		v = string.gsub(v, string.char(0x1F,0x0F), "") --cutscene emote color code (handled by the message type instead)
		v = string.gsub(v, PROMPT_CHARS, "")
		-- these are the auto-prompt characters
		v = string.gsub(v, string.char(0x7F,0x34), "")
		v = string.gsub(v, string.char(0x7F,0x35), "")
		v = string.gsub(v, string.char(0x7F,0x36), "")
		-- these are often the timings for the auto-prompt
		v = string.gsub(v, string.char(0x01), "")
		v = string.gsub(v, string.char(0x02), "")
		v = string.gsub(v, string.char(0x03), "")
		v = string.gsub(v, string.char(0x04), "")
		v = string.gsub(v, string.char(0x05), "")
		v = string.gsub(v, string.char(0x06), "")
		v = string.gsub(v, "^?([%w%.'(<“])", "%1")
		v = string.gsub(v, '(%w)(%.%.%.+)([%w“])', "%1%2 %3") --add a space after elipses to allow better line splitting
		v = string.gsub(v, '([%w”])%-%-([%w%p])', "%1-- %2") --same for double dashes

		v = ui:wrap_text(v)

		v = " " .. v
		v = string.gsub(v, "%[BL_c1]", "\\cr")
		v = string.gsub(v, "%[BL_c2]", "\\cs("..ui._type.items..")")
		v = string.gsub(v, "%[BL_c3]", "\\cs("..ui._type.keyitems..")")
		v = string.gsub(v, "%[BL_c4]", "\\cs("..ui._type.keyitems..")")
		v = string.gsub(v, "%[BL_c5]", "\\cs("..ui._type.gear..")")
		v = string.gsub(v, "%[BL_c6]", "\\cs(0,159,173)")
		v = string.gsub(v, "%[BL_c7]", "\\cs(156,149,19)")
		v = string.gsub(v, "%[BL_c8]", "\\cs("..ui._type.roe..")")
		--TODO: theme settings for these element colors
		v = string.gsub(v, "%[BL_Fire]", "\\cs(255,0,0)Fire \\cr")
		v = string.gsub(v, "%[BL_Ice]", "\\cs(0,255,255)Ice \\cr")
		v = string.gsub(v, "%[BL_Wind]", "\\cs(0,255,0)Wind \\cr")
		v = string.gsub(v, "%[BL_Earth]", "\\cs(153,76,0)Earth \\cr")
		v = string.gsub(v, "%[BL_Lightning]", "\\cs(127,0,255)Lightning \\cr")
		v = string.gsub(v, "%[BL_Water]", "\\cs(0,76,153)Water \\cr")
		v = string.gsub(v, "%[BL_Light]", "\\cs(224,224,224)Light \\cr")
		v = string.gsub(v, "%[BL_Dark]", "\\cs(82,82,82)Dark \\cr")
		message = message .. ('\n%s'):format(v)
	end
	if S{'process', 'all'}[balloon.debug] then print("Final: " .. message) end

	ui:set_message(message)
	open(timed)

	return(result)
end

-- parses a string into char[hex bytecode]
function codes(str)
	return (str:gsub('.', function (c)
		return string.format('%s[%02X]', c, string.byte(c))
	end))
end

function SubCharactersPreShift(str)
	local new_str = str
	if S{'chars', 'all'}[balloon.debug] then print("Pre-charsub pre-shift: " .. new_str) end
	new_str = string.gsub(new_str, string.char(0x81, 0x40), '    ') -- tab
	new_str = string.gsub(new_str, string.char(0x81, 0xF4), '[BL_note]') -- musical note
	new_str = string.gsub(new_str, chars.bstar, '[BL_bstar]') -- empty star
	new_str = string.gsub(new_str, chars.wstar, '[BL_wstar]') -- full star
	new_str = string.gsub(new_str, chars.wave, '[BL_wave]') -- wide tilde
	new_str = string.gsub(new_str, chars.cldquo, '[BL_cldquote]') -- centered left double quote
	new_str = string.gsub(new_str, chars.crdquo, '[BL_crdquote]') -- centered right double quote
	new_str = string.gsub(new_str, string.char(0x88, 0x69), '[BL_e_acute]') -- acute accented e

	-- element symbols
	new_str = string.gsub(new_str, string.char(0xEF,0x1F), "[BL_Fire]")
	new_str = string.gsub(new_str, string.char(0xEF,0x20), "[BL_Ice]")
	new_str = string.gsub(new_str, string.char(0xEF,0x21), "[BL_Wind]")
	new_str = string.gsub(new_str, string.char(0xEF,0x22), "[BL_Earth]")
	new_str = string.gsub(new_str, string.char(0xEF,0x23), "[BL_Lightning]")
	-- extra 0x25 in these two to escape the characters
	new_str = string.gsub(new_str, string.char(0xEF,0x25,0x24), "[BL_Water]")
	new_str = string.gsub(new_str, string.char(0xEF,0x25,0x25), "[BL_Light]")
	new_str = string.gsub(new_str, string.char(0xEF,0x26), "[BL_Dark]")
	if S{'chars', 'all'}[balloon.debug] then print("Post-charsub pre-shift: " .. new_str) end
	return new_str
end

function SubCharactersPostShift(str)
	local new_str = str
	if S{'chars', 'all'}[balloon.debug] then print("Pre-charsub post-shift: " .. new_str) end
	new_str = string.gsub(new_str, '%[BL_note]', '♪')
	new_str = string.gsub(new_str, '%[BL_bstar]', '☆')
	new_str = string.gsub(new_str, '%[BL_wstar]', '★')
	new_str = string.gsub(new_str, '%[BL_wave]', '~')
	new_str = string.gsub(new_str, '%[BL_cldquote]', '“')
	new_str = string.gsub(new_str, '%[BL_crdquote]', '”')
	new_str = string.gsub(new_str, '%[BL_e_acute]', 'é')
	if S{'chars', 'all'}[balloon.debug] then print("Post-charsub post-shift: " .. new_str) end
	return new_str
end

function split(str, delim)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local lastPos
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part)
        lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))
    return result
end

windower.register_event("addon command", function(command, ...)
	local args = L{ ... }

	if command == 'help' then
		local t = {}
		t[#t+1] = "Balloon(Bl)" .. "Ver." .._addon.version
		t[#t+1] = "  <コマンド> (<Command>)"
		t[#t+1] = "     //Balloon 0  	:吹き出し非表示＆ログ表示 (Hiding balloon & displaying log)"
		t[#t+1] = "     //Balloon 1  	:吹き出し表示＆ログ非表示 (Show balloon & hide log)"
		t[#t+1] = "     //Balloon 2  	:吹き出し表示＆ログ表示 (Balloon display & log display)"
		t[#t+1] = "     //Balloon reset :吹き出し位置初期化 (Initialize balloon position)"
		t[#t+1] = "     //Balloon theme <theme> - loads the specified theme"
		t[#t+1] = "     //Balloon scale <scale> - scales the size of the balloon by a decimal (eg: 1.5)"
		t[#t+1] = "     //Balloon delay <seconds> - delay before closing promptless balloons"
		t[#t+1] = "     //Balloon text_speed <chars> - speed that text is displayed, in characters per frame"
		t[#t+1] = "     //Balloon animate - toggle the advancement prompt indicator bouncing"
		t[#t+1] = "     //Balloon portrait - toggle the display of character portraits, if the theme has settings for them"
		t[#t+1] = "     //Balloon move_closes - toggle balloon auto-close on player movement"
		t[#t+1] = "     //Balloon debug off/all/mode/codes/chunk/process/wrap/chars/elements - enable debug modes"
		t[#t+1] = "     //Balloon test <name> : <message> - display a test balloon"
		t[#t+1] = "　"
		for tk,tv in pairs(t) do
			windower.add_to_chat(207, windower.to_shift_jis(tv))
		end

	elseif command == '1' then
		settings.DisplayMode = 1
		log("モード (mode) 1　　:吹き出し表示＆ログ非表示 (Show balloon & hide log)")

	elseif command == '0' then
		settings.DisplayMode = 0
		log("モード (mode) 0　　:吹き出し非表示＆ログ表示 (Hiding balloon & displaying log)")

	elseif command == '2' then
		settings.DisplayMode = 2
		log("モード (mode) 2　　:吹き出し表示＆ログ表示 (Balloon display & log display)")

	elseif command == 'reset' then
		settings.Position.X = defaults.Position.X
		settings.Position.Y = defaults.Position.Y
		ui:position(settings.Position.X, settings.Position.Y)
		log("Balloon位置リセットしました。 (Balloon position reset.)")

	elseif command == 'theme' then
		if not args:empty() then
			local tp = 'themes/'..args[1]..'/theme.xml'
			if not windower.file_exists(windower.addon_path..tp) then
				log("theme.xml not found under %s":format(tp))
				return
			end

			local old_theme = settings.Theme
			settings.Theme = args[1]
			apply_theme()
			log("changed theme from '%s' to '%s'":format(old_theme, settings.Theme))
		else
			log("current theme is '%s' (default: %s)":format(settings.Theme, defaults.Theme))
		end

	elseif command == 'scale' then
		local old_scale = settings.Scale
		if not args:empty() then
			settings.Scale = tonumber(args[1])
			ui:scale(settings.Scale)
			log("scale changed from %.2f to %.2f":format(old_scale, settings.Scale))
		else
			log("current scale is %.2f (default: %.2f)":format(settings.Scale, defaults.Scale))
		end

	elseif command == 'delay' then
		local old_delay = settings.NoPromptCloseDelay
		if not args:empty() then
			settings.NoPromptCloseDelay = tonumber(args[1])
			log("promptless close delay changed from %d to %d":format(old_delay, settings.NoPromptCloseDelay))
		else
			log("current promptless close delay is %d (default: %d)":format(old_delay, defaults.NoPromptCloseDelay))
		end

	elseif command == 'text_speed' then
		local old_speed = settings.TextSpeed
		if not args:empty() then
			settings.TextSpeed = tonumber(args[1])
			log("text speed changed from %d to %d":format(old_speed, settings.TextSpeed))
		else
			log("current text speed is %d (default: %d)":format(settings.TextSpeed, defaults.TextSpeed))
		end

	elseif command == 'animate' then
		settings.AnimatePrompt = not settings.AnimatePrompt
		ui:position()
		log("animated text advance prompt - " .. (settings.AnimatePrompt and "on" or "off"))

	elseif command == 'portrait' then
		settings.ShowPortraits = not settings.ShowPortraits
		apply_theme()
		log("portrait display - " .. (settings.ShowPortraits and "on" or "off"))

	elseif command == 'move_closes' then
		settings.MovementCloses = not settings.MovementCloses
		if settings.MovementCloses then
			balloon.movement_thread = moving_check:schedule(0)
		else
			if balloon.movement_thread ~= nil and coroutine.status(balloon.movement_thread) ~= 'dead' then
				coroutine.close(balloon.movement_thread)
			end
		end

		log("close balloons on player movement - " .. (settings.MovementCloses and "on" or "off"))

	elseif command == 'debug' then
		if not args:empty() then
			balloon.debug = args[1]
		else
			balloon.debug = (balloon.debug == 'off' and 'all' or 'off')
		end
		log("set debug mode " .. balloon.debug)

	elseif command == 'test' then
		process_balloon(args:concat(' '), 150)

	end

	config.save(settings)
end)

windower.register_event("prerender",function()
	-- animate our text advance indicator bouncing up and down
	balloon.frame_count = balloon.frame_count + 1
	if balloon.frame_count > 60*math.pi*2 then balloon.frame_count = balloon.frame_count - 60*math.pi*2 end

	if balloon.on then
		if settings.AnimatePrompt then
			ui:animate_prompt(balloon.frame_count)
		end
		ui:animate_text_display(settings.TextSpeed)
	end
end)

windower.register_event('keyboard',function(key_id,pressed,flags,blocked)
	if windower.ffxi.get_info().chat_open or blocked then return end
	if balloon.on == true then
		if key_id == ENTER_KEY and pressed and not balloon.keydown then
			balloon.keydown = true
			close()
		end
		if key_id == SCROLL_LOCK_KEY and pressed and not balloon.keydown then
			balloon.keydown = true
			if not ui:hidden() then
				ui:hide()
			else
				ui:show()
			end
		end
	end
	if S{ENTER_KEY, SCROLL_LOCK_KEY}[key_id] and not pressed then balloon.keydown = false end
end)

windower.register_event("mouse",function(type,x,y,delta,blocked)
    if not ui.message_background:hover(x, y) then return false end

	-- press
	if type == 1 then
		balloon.mouse_on = true
	end
	-- release
	if type == 2 then
		balloon.mouse_on = false
		config.save(settings)
	end
	if balloon.mouse_on == true then
		update_position()
	end
end)

function update_position()
	settings.Position.X = ui.message_background:pos_x() + ui.message_background:width() / 2
	settings.Position.Y = ui.message_background:pos_y() + ui.message_background:height() / 2

	ui:position(settings.Position.X, settings.Position.Y)
end
