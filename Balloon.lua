-- Copyright 2018, Hando
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
_addon.author = 'Hando'
_addon.name = 'Balloon'
_addon.version = '0.6'
_addon.commands = {'Balloon','Bl'}
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
defaults.pos = {}
defaults.pos.x = center_screen - 280
defaults.pos.y = BalloonY - 4
defaults.text = {}
defaults.text.font = 'ＭＳ ゴシック'
defaults.text.size = 16
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
defaults.name.text.font = 'メイリオ'
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
mouseON = 0

-------------------------------------------------------------------------------

windower.register_event('load',function()
	--スレッド開始
	thread_id = coroutine.schedule(moving_check,0) 
end)

function moving_check()
	local p = windower.ffxi.get_player()
	local me,x,y

	while true do
		me = windower.ffxi.get_mob_by_id(p.id)
		if me ~= nil then
			x = string.format("%6.2f",me.x)
			y = string.format("%6.2f",me.y)
			if x ~= old_x and y ~= old_y then
				moving = true
				old_y = y
				old_x = x
			else
				moving = false
			end
		end
		--wait
		coroutine.sleep(0.1)
		if moving == true then close_balloon() end
	end

end

windower.register_event('unload', function()
	config.save(settings)
end)

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	--会話中かの確認
	if (id == 82) then
		if (bl_debug ==2 ) then print("**chunk** id: " .. id,"original: " .. original) end
		close_balloon()
	end
end)

--閉じる
function close_balloon()
	Balloon_Image:hide()
	Balloon_name:clear()
	Balloon_txt:clear()
end

windower.register_event('incoming text',function(original,modified,original_mode,modified_mode,blocked)

	if ( bl_debug == 1 ) then print("** Mode: " .. original_mode , "Text: '" .. original .."'") end
	npcname = ""
	result = original
	if ( S{150,151,142,190}[original_mode] ) and (settings.blswitch >= 1)then
		-- 発言者名の抽出
		s,e = original:find(".-: ")
		npcname = ""
		if s ~= nil then
			if e < 32 and s > 0 then npcname = original:sub(s,e) end
		end	
		Balloon_name:clear()
		Balloon_name:append(npcname:sub(0,string.len(npcname)-2))
		
		if npcname =="" then
			result = "" .. "\n"
		else
			result = original:sub(string.len(original)-1,string.len(original))
			--original = original:sub(0,string.len(original)-2)
			--original = original:strip_format()
			mes = windower.from_shift_jis(original) --utf8へ変換
			mes = mes:strip_format()                --制御文字カット			
		end
		if settings.blswitch == 2 then result = original end
		
		-- 発言
		mes = windower.from_shift_jis(original)
		if npcname ~= "" then 
			mes = mes:gsub(npcname:gsub("-","--"),"") --タルタル等対応
		end
		mess = split(mes,"")	
		Balloon_txt:clear()		
		for k,v in ipairs(mess) do
			v = string.gsub(v, "", "\\cs(84,155,17)")
			v = string.gsub(v, "", "\\cs(97,127,217)")
			v = string.gsub(v, "", "\\cs(0,0,0)")
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
			v = " " .. v 
			Balloon_txt:append('\n%s':format(v))
		end
		update()
		Balloon_name:show()		
		Balloon_Image:show()
		Balloon_txt:show()
	end
	return(result)
	
end)

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


windower.register_event("addon command", function(command,arg1)

	if command == 'help' then
		local t = {}
		t[#t+1] = "Ballon(Bl)" .. "Ver." .._addon.version
		t[#t+1] = "  <コマンド>" 
		t[#t+1] = "     //Balloon 0  	:吹き出し非表示＆ログ表示"
		t[#t+1] = "     //Balloon 1  	:吹き出し表示＆ログ非表示" 
		t[#t+1] = "     //Balloon 2  	:吹き出し表示＆ログ表示"
		t[#t+1] = "     //Balloon reset :吹き出し位置初期化"
		t[#t+1] = "　"
		for tk,tv in pairs(t) do
			windower.add_to_chat(207, windower.to_shift_jis(tv))
		end

	elseif command == '1' then
		settings.blswitch = 1
		printFF11("モード1　　:吹き出し表示＆ログ非表示")

	elseif command == '0' then
		settings.blswitch = 0
		printFF11("モード0　　:吹き出し非表示＆ログ表示")

	elseif command == '2' then
		settings.blswitch = 2
		printFF11("モード2　　:吹き出し表示＆ログ表示")
		
	elseif command == 'reset' then
		settings.blImage.pos.x = center_screen - 330
		settings.blImage.pos.y = BalloonY
		printFF11("Balloon位置リセットしました。")
	elseif command == 'debug' and arg1 ~= nil then
		bl_debug = tonumber(arg1)
		print( "Balloon: debug " .. bl_debug )
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



