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
_addon.version = '0.9'
_addon.commands = {'Balloon','Bl'}

require('luau')
require('chat')
local config = require('config')
local texts = require('texts')
local images = require('images')

local windower_settings = windower.get_windower_settings()
local center_screen = windower_settings.ui_x_res / 2
BalloonY = windower_settings.ui_y_res - 258

local bl_debug = 0
local defaults = {}
defaults.blswitch = 2
defaults.soft_max_line_length = 68
defaults.movement_closes = false
defaults.no_prompt_close_delay = 5
defaults.animate_prompt = true
defaults.offset = {}
defaults.offset.x = 48
defaults.offset.y = -4
defaults.text = {}
defaults.text.font = 'Segoe UI'
defaults.text.size = 11
defaults.text.red = 0
defaults.text.green = 0
defaults.text.blue = 0
defaults.text.alpha = 255
defaults.light = {}
defaults.light.red = 0
defaults.light.green = 0
defaults.light.blue = 0
defaults.light.alpha = 255
defaults.light.reset = '0,0,0'
defaults.light.items = '84,155,17'
defaults.light.keyitems = '97,127,217'
defaults.light.gear = '177,26,177'
defaults.light.roe = '173,72,0'
defaults.dark = {}
defaults.dark.red = 255
defaults.dark.green = 255
defaults.dark.blue = 255
defaults.dark.alpha = 255
defaults.dark.reset = '255,255,255'
defaults.dark.items = '0,255,0'
defaults.dark.keyitems = '0,64,255'
defaults.dark.gear = '255,0,255'
defaults.dark.roe = '255,140,0'
defaults.bg = {}
defaults.bg.visible = false
defaults.flags = {}
defaults.flags.draggable = false
defaults.blImage = {}
defaults.blImage.color = {}
defaults.blImage.color.alpha = 255
defaults.blImage.color.red = 255
defaults.blImage.color.green = 255
defaults.blImage.color.blue = 255
defaults.blImage.visible = true
defaults.blImage.pos = {}
defaults.blImage.pos.x = center_screen - 330
defaults.blImage.pos.y = BalloonY
defaults.name = {}
defaults.name.offset = {}
defaults.name.offset.x = 50
defaults.name.offset.y = -10
defaults.name.text = {}
defaults.name.text.font = 'Segoe UI'
defaults.name.text.size = 14
defaults.name.text.red = 255
defaults.name.text.green = 255
defaults.name.text.blue = 255
defaults.name.text.alpha = 255
defaults.name.bg = {}
defaults.name.bg.visible = false
defaults.name.text.stroke = {}
defaults.name.text.stroke.width = 2
defaults.name.text.stroke.alpha = 200
defaults.name.text.stroke.red = 0
defaults.name.text.stroke.green = 0
defaults.name.text.stroke.blue = 0
defaults.name.text.visible = true
defaults.name.flags = {}
defaults.name.flags.draggable = false
defaults.name.image = {}
defaults.name.image.color = {}
defaults.name.image.color.alpha = 255
defaults.name.image.color.red = 255
defaults.name.image.color.green = 255
defaults.name.image.color.blue = 255
defaults.name.image.visible = true
defaults.name.image.offset = {}
defaults.name.image.offset.x = 15
defaults.name.image.offset.y = -18
defaults.enterPrompt = {}
defaults.enterPrompt.color = {}
defaults.enterPrompt.color.alpha = 255
defaults.enterPrompt.color.red = 255
defaults.enterPrompt.color.green = 255
defaults.enterPrompt.color.blue = 255
defaults.enterPrompt.visible = true
defaults.enterPrompt.offset = {}
defaults.enterPrompt.offset.x = 605
defaults.enterPrompt.offset.y = 90

local settings = config.load(defaults)

settings.blImage.texture = {}
settings.blImage.texture.path = windower.addon_path..'balloon.png'
settings.blImage.texture.fit = true
settings.blImage.size = {}
settings.blImage.size.height = 142
settings.blImage.size.width = 660
settings.blImage.draggable = true
settings.blImage.repeatable = {}
settings.blImage.repeatable.x = 1
settings.blImage.repeatable.y = 1

settings.name.image.texture = {}
settings.name.image.texture.path = windower.addon_path..'name-bg.png'
settings.name.image.texture.fit = true
settings.name.image.size = {}
settings.name.image.size.height = 43
settings.name.image.size.width = 360
settings.name.image.draggable = false
settings.name.image.repeatable = {}
settings.name.image.repeatable.x = 1
settings.name.image.repeatable.y = 1

settings.enterPrompt.texture = {}
settings.enterPrompt.texture.path = windower.addon_path..'advance-prompt.png'
settings.enterPrompt.texture.fit = true
settings.enterPrompt.size = {}
settings.enterPrompt.size.height = 16
settings.enterPrompt.size.width = 26
settings.enterPrompt.draggable = false
settings.enterPrompt.repeatable = {}
settings.enterPrompt.repeatable.x = 1
settings.enterPrompt.repeatable.y = 1

local Balloon_name = texts.new(settings.name)
local Balloon_txt = texts.new(settings)
local Balloon_Image = images.new(settings.blImage)
local Balloon_name_bg = images.new(settings.name.image)
local Balloon_enter_prompt = images.new(settings.enterPrompt)
--Balloon_Image:pos( center_screen - 330,510)
local moving = false
local old_x = "0"
local old_y = "0"
local balloon_on = false
local keydown = false
local mouseON = 0
local frame_count = 0

-------------------------------------------------------------------------------

windower.register_event('load',function()
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
			if (tonumber(x) < tonumber(old_x) - 1 or tonumber(x) > tonumber(old_x) + 1) or (tonumber(y) < tonumber(old_y) - 1 or tonumber(y) > tonumber(old_y) + 1) then
				moving = true
				old_y = y
				old_x = x
			else
				moving = false
			end
		end
		--wait
		coroutine.sleep(settings.no_prompt_close_delay)
		if moving and settings.movement_closes then close_balloon() end
	end

end

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	--会話中かの確認 (Check if you are in a conversation)
	if (id == 82) then
		if (bl_debug ==2 ) then print("**chunk** id: " .. id,"original: " .. original) end
		close_balloon()
    elseif id == 0xB then
        close_balloon()
	end
end)

--閉じる (close)
function close_balloon()
	Balloon_Image:hide()
	Balloon_name_bg:hide()
	Balloon_enter_prompt:hide()
	Balloon_name:clear()
	Balloon_txt:clear()
	balloon_on = false
end

windower.register_event('incoming text',function(original,modified,original_mode,modified_mode,blocked)
	-- skip text modes that aren't NPC speech
    if not ( S{150,151,142,190,144}[original_mode] ) then return end

	-- print debug info
	if ( bl_debug == 1 ) then
		print("** Mode: " .. original_mode , "Text: '" .. original .."'")
		print("codes: " .. codes(original))
	end

	-- detect whether messages have an 'enter' prompt or not
	local noenter = true
	local endchar1 = string.byte(original:sub(string.len(original)-1,string.len(original)-1),1)
	local endchar2 = string.byte(original:sub(string.len(original),string.len(original)),1)
	local startchar1 = string.byte(original:sub(1,1),1)
	local startchar2 = string.byte(original:sub(2,2),1)
	if (endchar1 == 127 and endchar2 == 49 and not S{144}[original_mode]) or (startchar1 == 30 and startchar2 == 1) then
		noenter = false
	end

	local result = original
	if (settings.blswitch >= 1) then
		result = process_balloon(original, original_mode)

		if noenter then
			Balloon_enter_prompt:hide()
			coroutine.sleep(settings.no_prompt_close_delay)
			close_balloon()
		else
			Balloon_enter_prompt:show()
		end
    end
    return(result)

end)

function process_balloon(npc_text, mode)
	-- 発言者名の抽出 (Speaker name extraction)
	local s,e = npc_text:find(".- : ")
	local npc_prefix = ""
	if s ~= nil then
		if e < 32 and s > 0 then npc_prefix = npc_text:sub(s,e) end
	end
	local npc_name = npc_prefix:sub(0,string.len(npc_prefix)-2)
	npc_name = string.trim(npc_name)
	Balloon_name:clear()
	Balloon_name:append(npc_name)

	local dark = false
	Balloon_txt:color(settings.light.red, settings.light.green, settings.light.blue)

	local fname = windower.addon_path..'character_balloons/%s.png':format(npc_name)
	if windower.file_exists(fname) then
		-- set a custom balloon based on npc name, if an image for them exists
		Balloon_Image:path(fname)
		Balloon_Image:update()
	elseif mode == 190 or npc_name == "" then
		-- system messages, set up dark mode (dark balloon, light text)
		-- no npc name is probably also a system message
		dark = true

		Balloon_Image:path(windower.addon_path..'system.png')
		Balloon_Image:update()

		Balloon_txt:color(settings.dark.red, settings.dark.green, settings.dark.blue)

		if npc_name == "" then
			Balloon_name_bg:hide()
		end
	else
		-- default balloon
		Balloon_Image:path(windower.addon_path..'balloon.png')
		Balloon_Image:update()
	end

	-- mode 1, blank log lines and visible balloon
	if settings.blswitch == 1 then
		if npc_prefix == "" then
			result = "" .. "\n"
		else
			result = npc_text:sub(string.len(npc_text)-1,string.len(npc_text))
		end
	-- mode 2, visible log and balloon
	elseif settings.blswitch == 2 then
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

	if ( bl_debug == 1 ) then
		print("Pre-process: " .. mes)
		print("codes: " .. codes(mes))
	end

	-- split by newlines
	local mess = split(mes,string.char(7))

	Balloon_txt:clear()

	local message = ""
	for k,v in ipairs(mess) do
		v = string.gsub(v, string.char(30)..string.char(1), "BL_c1_BL") --color code 1 (black/reset)
		v = string.gsub(v, string.char(30)..string.char(2), "BL_c2_BL") --color code 2 (green/regular items)
		v = string.gsub(v, string.char(30)..string.char(3), "BL_c3_BL") --color code 3 (blue/key items)
		v = string.gsub(v, string.char(30)..string.char(4), "BL_c4_BL") --color code 4 (blue/???)
		v = string.gsub(v, string.char(30)..string.char(5), "BL_c5_BL") --color code 5 (magenta/equipment?)
		v = string.gsub(v, string.char(30)..string.char(6), "BL_c6_BL") --color code 6 (cyan/???)
		v = string.gsub(v, string.char(30)..string.char(7), "BL_c7_BL") --color code 7 (yellow/???)
		v = string.gsub(v, string.char(30)..string.char(8), "BL_c8_BL") --color code 8 (orange/RoE objectives?)
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
		v = string.gsub(v, "%.%.%.([%w%p])", "... %1") --add a space after elipses to allow better line splitting
		v = string.gsub(v, "([%w%p])%-%-([%w%p])", "%1-- %2") --same for double dashes
		v = " " .. v
		v = SplitLines(v, string.len(v))
		if not dark then
			v = string.gsub(v, "BL_c1_BL", "\\cs("..settings.light.reset..")")
			v = string.gsub(v, "BL_c2_BL", "\\cs("..settings.light.items..")")
			v = string.gsub(v, "BL_c3_BL", "\\cs("..settings.light.keyitems..")")
			v = string.gsub(v, "BL_c4_BL", "\\cs("..settings.light.keyitems..")")
			v = string.gsub(v, "BL_c5_BL", "\\cs("..settings.light.gear..")")
			v = string.gsub(v, "BL_c6_BL", "\\cs(0,159,173)")
			v = string.gsub(v, "BL_c7_BL", "\\cs(156,149,19)")
			v = string.gsub(v, "BL_c8_BL", "\\cs("..settings.light.roe..")")
		else
			v = string.gsub(v, "BL_c1_BL", "\\cs("..settings.dark.reset..")")
			v = string.gsub(v, "BL_c2_BL", "\\cs("..settings.dark.items..")")
			v = string.gsub(v, "BL_c3_BL", "\\cs("..settings.dark.keyitems..")")
			v = string.gsub(v, "BL_c4_BL", "\\cs("..settings.dark.keyitems..")")
			v = string.gsub(v, "BL_c5_BL", "\\cs("..settings.dark.gear..")")
			v = string.gsub(v, "BL_c6_BL", "\\cs(0,159,173)")
			v = string.gsub(v, "BL_c7_BL", "\\cs(156,149,19)")
			v = string.gsub(v, "BL_c8_BL", "\\cs("..settings.dark.roe..")")
		end
		message = message .. '\n%s':format(v)
	end

	Balloon_txt:append(message)

	update()
	Balloon_name:show()
	Balloon_Image:show()
	if npc_name ~= "" then
		Balloon_name_bg:show()
	end
	Balloon_txt:show()
	balloon_on = true

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
	if balloon_on == true then
		--print("dik:", dik, "pressed:", pressed, "flags:", flags, "blocked:", blocked)
		if dik == 28 and pressed and not keydown then
			keydown = true
			close_balloon()
		end
	end
	if dik ==28 and not pressed then keydown = false end
end)

function SubCharactersPreShift(str)
	local new_str = str
	if bl_debug == 1 then print("Pre-charsub pre-shift: " .. new_str) end
	new_str = string.gsub(new_str, string.char(129)..string.char(244), 'BL_note_BL') -- musical note
	new_str = string.gsub(new_str, string.char(135)..string.char(178), 'BL_lquote_BL') -- left quote
	new_str = string.gsub(new_str, string.char(135)..string.char(179), 'BL_rquote_BL') -- right quote
	new_str = string.gsub(new_str, string.char(136)..string.char(105), 'BL_e_acute_BL') -- acute accented e
	if bl_debug == 1 then print("Post-charsub pre-shift: " .. new_str) end
	return new_str
end

function SubCharactersPostShift(str)
	local new_str = str
	if bl_debug == 1 then print("Pre-charsub post-shift: " .. new_str) end
	new_str = string.gsub(new_str, 'BL_note_BL', '♪')
	new_str = string.gsub(new_str, 'BL_lquote_BL', '“')
	new_str = string.gsub(new_str, 'BL_rquote_BL', '”')
	new_str = string.gsub(new_str, 'BL_e_acute_BL', 'é')
	if bl_debug == 1 then print("Post-charsub post-shift: " .. new_str) end
	return new_str
end

function SubElements(str)
	local new_str = str
	if bl_debug == 1 then print("Pre-elementsub: " .. new_str) end
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
	if bl_debug == 1 then print("Post-elementsub: " .. new_str) end
	return new_str
end

function SplitLines(str, length)
    local new_str = str
    local splits = length/settings.soft_max_line_length
    local position = settings.soft_max_line_length
    while splits > 0 do
        local pos = string.find(new_str, ' ', position)
        if pos then
            new_str = new_str:gsub('()',{[pos]='\n'})
            position = pos + settings.soft_max_line_length - 4
        end
        splits = splits - 1
    end
    if splits < 1 then
        return new_str
    end
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
		t[#t+1] = "     //Balloon max <length> - Soft max line length for splitting"
		t[#t+1] = "     //Balloon delay <seconds> - Delay before closing promptless balloons"
		t[#t+1] = "     //Balloon animate - Toggle the advancement prompt indicator bouncing"
		t[#t+1] = "     //Balloon move_closes - Toggle balloon auto-close on player movement (flaky)"
		t[#t+1] = "     //Balloon debug 0/1/2 - Enable debug modes"
		t[#t+1] = "     //Balloon test <name> : <message> - Display a test balloon"
		t[#t+1] = "　"
		for tk,tv in pairs(t) do
			windower.add_to_chat(207, windower.to_shift_jis(tv))
		end

	elseif command == '1' then
		settings.blswitch = 1
		printFF11("モード (mode) 1　　:吹き出し表示＆ログ非表示 (Show balloon & hide log)")

	elseif command == '0' then
		settings.blswitch = 0
		printFF11("モード (mode) 0　　:吹き出し非表示＆ログ表示 (Hiding balloon & displaying log)")

	elseif command == '2' then
		settings.blswitch = 2
		printFF11("モード (mode) 2　　:吹き出し表示＆ログ表示 (Balloon display & log display)")

	elseif command == 'reset' then
		settings.blImage.pos.x = center_screen - 330
		settings.blImage.pos.y = BalloonY
		printFF11("Balloon位置リセットしました。 (Balloon position reset.)")

	elseif command == 'max' then
		local old_len = settings.soft_max_line_length
		if not args:empty() then
			settings.soft_max_line_length = tonumber(args[1])
		else
			settings.soft_max_line_length = defaults.soft_max_line_length
		end
		printFF11("Balloon: soft maximum line length changed: " .. old_len .. " -> " .. settings.soft_max_line_length)

	elseif command == 'delay' then
		local old_delay = settings.no_prompt_close_delay
		if not args:empty() then
			settings.no_prompt_close_delay = tonumber(args[1])
		else
			settings.no_prompt_close_delay = defaults.no_prompt_close_delay
		end
		printFF11("Balloon: delay before prompt-less balloons are closed changed: " .. old_delay .. " -> " .. settings.no_prompt_close_delay)

	elseif command == 'animate' then
		settings.animate_prompt = not settings.animate_prompt
		update()
		printFF11("Balloon: animated text advance prompt - " .. (settings.animate_prompt and "on" or "off"))

	elseif command == 'move_closes' then
		settings.movement_closes = not settings.movement_closes
		printFF11("Balloon: close balloons on player movement - " .. (settings.movement_closes and "on" or "off"))

	elseif command == 'debug' then
		if not args:empty() then
			bl_debug = tonumber(args[1])
		else
			bl_debug = (bl_debug == 0 and 1 or 0)
		end
		print( "Balloon: set debug mode " .. bl_debug )

	elseif command == 'test' then
		process_balloon(args:concat(' '), 150)
		coroutine.sleep(settings.no_prompt_close_delay)
		close_balloon()

	end

	config.save(settings)
end)

function smooth_sawtooth(time, frequency)
	local x = time * frequency
	return(-math.sin(x-math.sin(x)/2))
end

windower.register_event("prerender",function()
	-- animate our text advance indicator bouncing up and down
	frame_count = frame_count + 1
	if frame_count > 60*math.pi*2 then frame_count = frame_count - 60*math.pi*2 end

	if not balloon_on or not settings.animate_prompt then return end

	local amplitude = 2.5
	local bounceOffset = smooth_sawtooth(frame_count/60, 6) * amplitude

	local pos_y = settings.blImage.pos.y + settings.enterPrompt.offset.y + bounceOffset
	Balloon_enter_prompt:pos_y(pos_y)
end)

windower.register_event("mouse",function(type,x,y,delta,blocked)
	if type == 1 then
		mouseON = 1
	end
	if type == 2 then
		mouseON = 0
		config.save(settings)
	end
	if mouseON == 1 then
		update()
	end
end)

function printFF11( text )
	windower.add_to_chat(207, windower.to_shift_jis(text))
end

function update()
	local pos_x = settings.blImage.pos.x + settings.offset.x
	local pos_y = settings.blImage.pos.y + settings.offset.y
	Balloon_txt:pos(pos_x, pos_y)

	local name_pos_x = settings.blImage.pos.x + settings.name.offset.x
	local name_pos_y = settings.blImage.pos.y + settings.name.offset.y
	Balloon_name:pos(name_pos_x, name_pos_y)

	local name_image_pos_x = settings.blImage.pos.x + settings.name.image.offset.x
	local name_image_pos_y = settings.blImage.pos.y + settings.name.image.offset.y
	Balloon_name_bg:pos(name_image_pos_x, name_image_pos_y)

	local enterPrompt_pos_x = settings.blImage.pos.x + settings.enterPrompt.offset.x
	local enterPrompt_pos_y = settings.blImage.pos.y + settings.enterPrompt.offset.y
	Balloon_enter_prompt:pos(enterPrompt_pos_x, enterPrompt_pos_y)

	Balloon_Image:pos(settings.blImage.pos.x,settings.blImage.pos.y)
end



