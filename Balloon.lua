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
_addon.author = 'Hando / Modified for English client by Yuki / String code from Kenshi'
_addon.name = 'Balloon'
_addon.version = '0.9'
_addon.commands = {'Balloon','Bl'}
require('lists')
require('chat')
config = require('config')
texts = require('texts')
images = require('images')

windower_settings = windower.get_windower_settings()
center_screen = windower_settings.ui_x_res / 2
ui_scale = { x = windower_settings.x_res / windower_settings.ui_x_res , 
                y = windower_settings.y_res / windower_settings.ui_y_res }
BalloonY = windower_settings.ui_y_res - 258
				
bl_debug = 0
defaults = {}
defaults.blswitch = 2
defaults.filter_speech_patterns = false
defaults.pos = {}
defaults.pos.x = center_screen - 280
defaults.pos.y = BalloonY - 4
defaults.text = {}
defaults.text.font = 'Segoe UI'
defaults.text.size = 11
defaults.text.red = 0
defaults.text.green = 0
defaults.text.blue = 0
defaults.text.alpha = 255
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
defaults.name.pos = {}
defaults.name.pos.x = center_screen - 280
defaults.name.pos.y = BalloonY - 10
defaults.name.text = {}
defaults.name.text.font = 'Segoe UI'
defaults.name.text.size = 16
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

local settings = config.load(defaults)


settings.blImage.texture = {}
settings.blImage.texture.path = windower.addon_path..'balloon.png'
settings.blImage.texture.fit = true
settings.blImage.size = {}
settings.blImage.size.height = 127
settings.blImage.size.width = 647
settings.blImage.draggable = true
settings.blImage.repeatable = {}
settings.blImage.repeatable.x = 1
settings.blImage.repeatable.y = 1


local Balloon_name = texts.new(settings.name)
local Balloon_txt = texts.new(settings)
local Balloon_Image = images.new(settings.blImage)
--Balloon_Image:pos( center_screen - 330,510)
local moving = false	
local old_x = "0"
local old_y = "0"
local balloon_on = false
local keydown = false
local keyup = false
mouseON = 0

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
		coroutine.sleep(1)
		--if moving == true then close_balloon() end
	end

end

windower.register_event('unload', function()
	config.save(settings)
end)

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
	--print("closed")
	Balloon_Image:hide()
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
		result = process_balloon(original)

		if noenter then
			coroutine.sleep(10)
			close_balloon()
		end
    end
    return(result)

end)

function process_balloon(npc_text)
	-- 発言者名の抽出 (Speaker name extraction)
	local s,e = npc_text:find(".- : ")
	local npcname = ""
	if s ~= nil then
		if e < 32 and s > 0 then npcname = npc_text:sub(s,e) end
	end
	Balloon_name:clear()
	Balloon_name:append(npcname:sub(0,string.len(npcname)-2))

	-- mode 1, blank log lines and visible balloon
	if settings.blswitch == 1 then
		if npcname == "" then
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
	if npcname ~= "" then
		mes = mes:gsub(npcname:gsub("-","--"),"") --タルタル等対応 (Correspondence such as tartar)
	end

	if ( bl_debug == 1 ) then
		print("Pre-process: " .. mes)
		print("codes: " .. codes(mes))
	end

	-- split by newlines
	local mess = split(mes,string.char(7))

	-- filter out racial speech patterns
	if settings.filter_speech_patterns then
		for k,v in ipairs(mess) do
			mess[k] = string.gsub(v, "rrr", "r") -- Mithra rolling r
			--todo: tarutaru baby talk?
		end
	end

	Balloon_txt:clear()

	local message = ""
	for k,v in ipairs(mess) do
		v = string.gsub(v, string.char(30)..string.char(1), "%%%%color1%%%%") --color code 1 (black/reset)
		v = string.gsub(v, string.char(30)..string.char(2), "%%%%color2%%%%") --color code 2 (green/regular items)
		v = string.gsub(v, string.char(30)..string.char(3), "%%%%color3%%%%") --color code 3 (blue/key items)
		v = string.gsub(v, string.char(30)..string.char(4), "%%%%color4%%%%") --color code 4 (blue/???)
		v = string.gsub(v, string.char(30)..string.char(5), "%%%%color5%%%%") --color code 5 (magenta/equipment)
		v = string.gsub(v, string.char(30)..string.char(6), "%%%%color6%%%%") --color code 6 (cyan/???)
		v = string.gsub(v, string.char(30)..string.char(7), "%%%%color7%%%%") --color code 7 (yellow/???)
		v = string.gsub(v, string.char(30)..string.char(8), "%%%%color8%%%%") --color code 8 (orange/RoE objectives?)
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
		v = string.gsub(v, "%%%%color1%%%%", "\\cs(0,0,0)")
		v = string.gsub(v, "%%%%color2%%%%", "\\cs(84,155,17)")
		v = string.gsub(v, "%%%%color3%%%%", "\\cs(97,127,217)")
		v = string.gsub(v, "%%%%color4%%%%", "\\cs(97,127,217)")
		v = string.gsub(v, "%%%%color5%%%%", "\\cs(177,26,177)")
		v = string.gsub(v, "%%%%color6%%%%", "\\cs(0,159,173)")
		v = string.gsub(v, "%%%%color7%%%%", "\\cs(156,149,19)")
		v = string.gsub(v, "%%%%color8%%%%", "\\cs(173,72,0)")
		message = message .. '\n%s':format(v)
	end

	Balloon_txt:append(message)

	update()
	Balloon_name:show()
	Balloon_Image:show()
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
	new_str = string.gsub(new_str, string.char(129)..string.char(244), '%%%%note%%%%') -- musical note
	new_str = string.gsub(new_str, string.char(135)..string.char(178), '%%%%lquote%%%%') -- left quote
	new_str = string.gsub(new_str, string.char(135)..string.char(179), '%%%%rquote%%%%') -- right quote
	new_str = string.gsub(new_str, string.char(136)..string.char(105), '%%%%e_acute%%%%') -- acute accented e
	if bl_debug == 1 then print("Post-charsub pre-shift: " .. new_str) end
	return new_str
end

function SubCharactersPostShift(str)
	local new_str = str
	if bl_debug == 1 then print("Pre-charsub post-shift: " .. new_str) end
	new_str = string.gsub(new_str, '%%%%note%%%%', '♪')
	new_str = string.gsub(new_str, '%%%%lquote%%%%', '“')
	new_str = string.gsub(new_str, '%%%%rquote%%%%', '”')
	new_str = string.gsub(new_str, '%%%%e_acute%%%%', 'é')
	if bl_debug == 1 then print("Post-charsub post-shift: " .. new_str) end
	return new_str
end

function SubElements(str)
	local new_str = str
	if bl_debug == 1 then print("Pre-elementsub: " .. new_str) end
	new_str = string.gsub(new_str, string.char(239) .. "\"", "Earth ") -- ɑEarth ɣ
	new_str = string.gsub(new_str, string.char(239) .. "%$", "Water ")
	new_str = string.gsub(new_str, string.char(239) .. "&", "Dark ")
	new_str = string.gsub(new_str, string.char(239) .. "", "Fire ")
	new_str = string.gsub(new_str, string.char(239) .. " ", "Ice ")
	new_str = string.gsub(new_str, string.char(239) .. "!", "Wind ")
	new_str = string.gsub(new_str, string.char(239) .. "#", "Lightning ")
	new_str = string.gsub(new_str, string.char(239) .. "%%", "Light ")
	if bl_debug == 1 then print("Post-elementsub: " .. new_str) end
	return new_str
end

function SplitLines(str, length)
	local soft_max_line_length = 65
    local new_str = str
    local splits = length/soft_max_line_length
    local position = soft_max_line_length
    while splits > 0 do
        local pos = string.find(new_str, ' ', position)
        if pos then
            new_str = new_str:gsub('()',{[pos]='\n'})
            position = pos + soft_max_line_length - 4
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

	elseif command == 'filter' then
		settings.filter_speech_patterns = not settings.filter_speech_patterns
		printFF11("speech pattern filtering: "..(settings.filter_speech_patterns and "on" or "off"))

	elseif command == 'reset' then
		settings.blImage.pos.x = center_screen - 330
		settings.blImage.pos.y = BalloonY
		printFF11("Balloon位置リセットしました。 (Balloon position reset.)")

	elseif command == 'debug' then
		if args then
			bl_debug = tonumber(args[1])
		else
			bl_debug = (bl_debug == 0 and 1 or 0)
		end
		print( "Balloon: debug " .. bl_debug )

	elseif command == 'test' then
		process_balloon(args:concat(' '))
		coroutine.sleep(10)
		close_balloon()

	end

	config.save(settings)
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
	settings.pos.x = settings.blImage.pos.x + 50
	settings.pos.y = settings.blImage.pos.y - 4
	Balloon_txt:pos( settings.pos.x, settings.pos.y)
	settings.name.pos.x = settings.blImage.pos.x + 50
	settings.name.pos.y = settings.blImage.pos.y - 10
	Balloon_name:pos( settings.name.pos.x, settings.name.pos.y)
	Balloon_Image:pos(settings.blImage.pos.x,settings.blImage.pos.y)
end



