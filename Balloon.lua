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
_addon.author = 'Hando / Modified for English client by Yuki / String code from Kenshi / Additional work by Ghosty'
_addon.name = 'Balloon'
_addon.version = '0.11.2'
_addon.commands = {'Balloon','Bl'}

require('luau')
chars = require('chat.chars')
texts = require('texts')
images = require('images')

local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)

local theme = require('theme')
local theme_path = 'themes/' .. settings.Theme .. '/theme.xml'
local theme_settings = config.load(theme_path, {['name']=settings.Theme})
local theme_options = theme.apply(theme_settings)

local ui = require('ui')

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

-------------------------------------------------------------------------------

local function initialize()
	ui:load(settings, theme_options)

	balloon.initialized = true
end

local function close()
	ui:hide()

	balloon.on = false
	balloon.waiting_to_close = false
end

local function open()
	if not balloon.initialized then
		initialize()
	end

	ui:show()
	--schedule an update to fix image scale if the balloon background has changed
	coroutine.schedule(update,0.1)
	balloon.on = true
end

windower.register_event('login',function()
	if windower.ffxi.get_info().logged_in then
		initialize()
	end

	--スレッド開始 (Thread start)
	thread_id = coroutine.schedule(moving_check,0)
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
	--会話中かの確認 (Check if you are in a conversation)
	if (id == 82) then
		if (S{'chunk', 'all'}[balloon.debug] ) then print("**chunk** id: " .. id,"original: " .. original) end
		close()
    elseif id == 0xB then
        close()
	end
end)

windower.register_event('incoming text',function(original,modified,original_mode,modified_mode,blocked)
	-- skip text modes that aren't NPC speech
    if not ( S{150,151,142,144}[original_mode] ) then return end

	-- print debug info
	if (S{'codes', 'mode', 'all'}[balloon.debug]) then print("** Mode: " .. original_mode , "Text: '" .. original .."'") end
	if (S{'codes', 'all'}[balloon.debug]) then print("codes: " .. codes(original)) end

	-- detect whether messages have an 'enter' prompt or not
	local noenter = true
	local endchar1 = string.byte(original:sub(string.len(original)-1,string.len(original)-1),1)
	local endchar2 = string.byte(original:sub(string.len(original),string.len(original)),1)
	local startchar1 = string.byte(original:sub(1,1),1)
	local startchar2 = string.byte(original:sub(2,2),1)
	if (endchar1 == 127 and endchar2 == 49 and not S{142,144}[original_mode]) or (startchar1 == 30 and startchar2 == 1) or (original_mode == 151) then
		noenter = false
	end

	local result = original
	if (settings.DisplayMode >= 1) then
		result = process_balloon(original, original_mode)

		if noenter then
			ui.prompt:hide()
			balloon.waiting_to_close = true
			coroutine.sleep(settings.NoPromptCloseDelay)
			if balloon.waiting_to_close then
				close()
			end
		else
			ui.prompt:show()
			balloon.waiting_to_close = false
		end
    end
    return(result)

end)

function process_balloon(npc_text, mode)
	if not balloon.initialized then
		initialize()
	end

	-- 発言者名の抽出 (Speaker name extraction)
	local s,e = npc_text:find(".- : ")
	local npc_prefix = ""
	if s ~= nil then
		if e < 32 and s > 0 then npc_prefix = npc_text:sub(s,e) end
	end
	local npc_name = npc_prefix:sub(0,string.len(npc_prefix)-2)
	npc_name = string.trim(npc_name)

	if not ui:set_character(npc_name) then
		ui:set_type(mode)
	end

	-- mode 1, blank log lines and visible balloon
	if settings.DisplayMode == 1 then
		if npc_prefix == "" then
			result = "" .. "\n"
		else
			result = npc_text:sub(string.len(npc_text)-1,string.len(npc_text))
		end
	-- mode 2, visible log and balloon
	elseif settings.DisplayMode == 2 then
		-- pass through the original message for the log
		result = npc_text
	end

	-- 発言 (Remark)
	local mes = SubElements(npc_text)
	mes = SubCharactersPreShift(mes)
	mes = windower.from_shift_jis(mes)
	mes = SubCharactersPostShift(mes)

	-- strip the NPC name from the start of the message
	if npc_prefix ~= "" then
		mes = mes:gsub(npc_prefix:gsub("-","--"),"") --タルタル等対応 (Correspondence such as tartar)
	end

	if (S{'process', 'all'}[balloon.debug]) then print("Pre-process: " .. mes) end
	if (S{'codes', 'all'}[balloon.debug]) then print("codes: " .. codes(mes)) end

	--strip the default color code from the start of messages,
	--it causes the first part of the message to get cut off somehow
	local default_color = string.char(30)..string.char(1)
	if string.sub(mes, 1, #default_color) == default_color then
		mes = string.sub(mes, #default_color + 1)
	end

	-- split by newlines
	local mess = split(mes,string.char(7))

	local message = ""
	for k,v in ipairs(mess) do
		v = string.gsub(v, string.char(30)..string.char(1), "[BL_c1]") --color code 1 (black/reset)
		v = string.gsub(v, string.char(30)..string.char(2), "[BL_c2]") --color code 2 (green/regular items)
		v = string.gsub(v, string.char(30)..string.char(3), "[BL_c3]") --color code 3 (blue/key items)
		v = string.gsub(v, string.char(30)..string.char(4), "[BL_c4]") --color code 4 (blue/???)
		v = string.gsub(v, string.char(30)..string.char(5), "[BL_c5]") --color code 5 (magenta/equipment?)
		v = string.gsub(v, string.char(30)..string.char(6), "[BL_c6]") --color code 6 (cyan/???)
		v = string.gsub(v, string.char(30)..string.char(7), "[BL_c7]") --color code 7 (yellow/???)
		v = string.gsub(v, string.char(30)..string.char(8), "[BL_c8]") --color code 8 (orange/RoE objectives?)
		v = string.gsub(v, "1", "")
		v = string.gsub(v, "4", "")
		v = string.gsub(v, "", "")
		v = string.gsub(v, "", "")
		v = string.gsub(v, "6", "")
		v = string.gsub(v, "^?", "")
		v = string.gsub(v, "　　 ", "")
		v = string.gsub(v, "", "")
		v = string.gsub(v, "", "")
		v = string.gsub(v, "", "")
		v = string.gsub(v, "5", "")
		v = string.gsub(v, '(%w)(%.%.%.+)([%w“])', "%1%2 %3") --add a space after elipses to allow better line splitting
		v = string.gsub(v, '([%w”])%-%-([%w%p])', "%1-- %2") --same for double dashes
		if (S{'wrap', 'all'}[balloon.debug]) then print("Pre-wrap: " .. v) end
		v = WrapText(v, theme_options.message.max_length)
		if (S{'wrap', 'all'}[balloon.debug]) then print("Post-wrap: " .. v) end
		v = " " .. v
		v = string.gsub(v, "%[BL_c1]", "\\cs("..ui._type.reset..")")
		v = string.gsub(v, "%[BL_c2]", "\\cs("..ui._type.items..")")
		v = string.gsub(v, "%[BL_c3]", "\\cs("..ui._type.keyitems..")")
		v = string.gsub(v, "%[BL_c4]", "\\cs("..ui._type.keyitems..")")
		v = string.gsub(v, "%[BL_c5]", "\\cs("..ui._type.gear..")")
		v = string.gsub(v, "%[BL_c6]", "\\cs(0,159,173)")
		v = string.gsub(v, "%[BL_c7]", "\\cs(156,149,19)")
		v = string.gsub(v, "%[BL_c8]", "\\cs("..ui._type.roe..")")
		message = message .. ('\n%s'):format(v)
	end
	if (S{'process', 'all'}[balloon.debug]) then print("Final: " .. message) end

	ui:set_message(message)
	open()

	return(result)
end

-- parses a string into char(decimal bytecode)
function codes(str)
	local teststr = ""
	for i = 1, #str do
		local c = string.byte(str:sub(i,i),1)
		teststr = teststr .. (str:sub(i,i) .. "(" .. c .. ")")
	end
	return teststr
end

windower.register_event('keyboard',function(dik,pressed,flags,blocked)
	if windower.ffxi.get_info().chat_open or blocked then return end
	if balloon.on == true then
		--print("dik:", dik, "pressed:", pressed, "flags:", flags, "blocked:", blocked)
		if dik == 28 and pressed and not balloon.keydown then
			balloon.keydown = true
			close()
		end
	end
	if dik ==28 and not pressed then balloon.keydown = false end
end)

function SubCharactersPreShift(str)
	local new_str = str
	if S{'chars', 'all'}[balloon.debug] then print("Pre-charsub pre-shift: " .. new_str) end
	new_str = string.gsub(new_str, string.char(129, 244), '[BL_note]') -- musical note
	new_str = string.gsub(new_str, string.char(135, 178), '[BL_lquote]') -- left quote
	new_str = string.gsub(new_str, string.char(135, 179), '[BL_rquote]') -- right quote
	new_str = string.gsub(new_str, string.char(136, 105), '[BL_e_acute]') -- acute accented e
	if S{'chars', 'all'}[balloon.debug] then print("Post-charsub pre-shift: " .. new_str) end
	return new_str
end

function SubCharactersPostShift(str)
	local new_str = str
	if S{'chars', 'all'}[balloon.debug] then print("Pre-charsub post-shift: " .. new_str) end
	new_str = string.gsub(new_str, '%[BL_note]', '♪')
	new_str = string.gsub(new_str, '%[BL_lquote]', '“')
	new_str = string.gsub(new_str, '%[BL_rquote]', '”')
	new_str = string.gsub(new_str, '%[BL_e_acute]', 'é')
	if S{'chars', 'all'}[balloon.debug] then print("Post-charsub post-shift: " .. new_str) end
	return new_str
end

function SubElements(str)
	local new_str = str
	if S{'elements', 'all'}[balloon.debug] then print("Pre-elementsub: " .. new_str) end
	local col = string.char(30)..string.char(2)
	local reset = string.char(30)..string.char(1)
	new_str = string.gsub(new_str, string.char(239) .. "\"", col.."Earth "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "%$", col.."Water "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "&", col.."Dark "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "", col.."Fire "..reset)
	new_str = string.gsub(new_str, string.char(239) .. " ", col.."Ice "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "!", col.."Wind "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "#", col.."Lightning "..reset)
	new_str = string.gsub(new_str, string.char(239) .. "%%", col.."Light "..reset)
	if S{'elements', 'all'}[balloon.debug] then print("Post-elementsub: " .. new_str) end
	return new_str
end

function Tokenize(str)
	local result = {}
	for word in str:gmatch("%S+") do
		result[#result+1] = word
	end
	return result
end

function WrapText(str, length)
	local line_length = length+1
	local length_left = line_length
	local result = {}
	local line = {}

	for _, word in ipairs(Tokenize(str)) do
		if #word+1 > length_left then
			table.insert(result, table.concat(line, ' '))
			line = {word}
			length_left = line_length - #word
		else
			table.insert(line, word)
			length_left = length_left - (#word + 1)
		end
	end

	table.insert(result, table.concat(line, ' '))
	return table.concat(result, '\n ')
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
		t[#t+1] = "     //Balloon delay <seconds> - Delay before closing promptless balloons"
		t[#t+1] = "     //Balloon animate - Toggle the advancement prompt indicator bouncing"
		t[#t+1] = "     //Balloon move_closes - Toggle balloon auto-close on player movement"
		t[#t+1] = "     //Balloon debug 0/1/2 - Enable debug modes"
		t[#t+1] = "     //Balloon test <name> : <message> - Display a test balloon"
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
		ui:position(settings, theme_options)
		update()
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
			local ts = config.load(tp, {['name']=settings.Theme})
			theme_options = theme.apply(ts)
			ui:load(settings, theme_options)
			log("changed theme from '%s' to '%s'":format(old_theme, settings.Theme))
		else
			log("current theme is '%s'":format(settings.Theme))
		end

	elseif command == 'scale' then
		local old_scale = settings.Scale
		if not args:empty() then
			settings.Scale = tonumber(args[1])
			ui:position(settings, theme_options)
			log("scale changed from %d to %d":format(old_scale, settings.Scale))
		else
			log("current scale is %d (default: %d)":format(settings.Scale, defaults.Scale))
		end

	elseif command == 'delay' then
		local old_delay = settings.NoPromptCloseDelay
		if not args:empty() then
			settings.NoPromptCloseDelay = tonumber(args[1])
		else
			settings.NoPromptCloseDelay = defaults.NoPromptCloseDelay
		end
		log("delay before prompt-less balloons are closed changed: %s -> %s":format(old_delay, settings.NoPromptCloseDelay))

	elseif command == 'animate' then
		settings.AnimatePrompt = not settings.AnimatePrompt
		update()
		log("animated text advance prompt - " .. (settings.AnimatePrompt and "on" or "off"))

	elseif command == 'move_closes' then
		settings.MovementCloses = not settings.MovementCloses
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
		coroutine.sleep(settings.NoPromptCloseDelay)
		close()

	end

	config.save(settings)
end)

windower.register_event("prerender",function()
	-- switching the message background image resets the scale, this fixes that
	if ui.message_background:path() ~= balloon.prev_path then
		ui:position(settings, theme_options)
		balloon.prev_path = ui.message_background:path()
	end

	-- animate our text advance indicator bouncing up and down
	balloon.frame_count = balloon.frame_count + 1
	if balloon.frame_count > 60*math.pi*2 then balloon.frame_count = balloon.frame_count - 60*math.pi*2 end

	if not balloon.on or not settings.AnimatePrompt then return end

	ui:animate_prompt(balloon.frame_count, theme_options)
end)

windower.register_event("mouse",function(type,x,y,delta,blocked)
    if not ui.message_background:hover(x, y) then return false end

	if type == 1 then
		balloon.mouse_on = true
	end
	if type == 2 then
		balloon.mouse_on = false
		config.save(settings)
	end
	if balloon.mouse_on == true then
		update()
	end
end)

function update()
	settings.Position.X = ui.message_background:pos_x() + ui.message_background:width() / 2
	settings.Position.Y = ui.message_background:pos_y() + ui.message_background:height() / 2

	ui:position(settings, theme_options)
end
