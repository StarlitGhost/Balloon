local theme = {}

theme.apply = function(theme_settings)
    local options = {}

    options.balloon_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/balloon.png'
    options.system_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/system.png'
    options.name_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/name-bg.png'
    options.prompt_image = windower.addon_path .. 'themes/' .. theme_settings.name .. '/advance-prompt.png'

    options.message = {}
    options.message.width = theme_settings.message.width
    options.message.height = theme_settings.message.height
    options.message.offset_x = theme_settings.message.textoffsetx
    options.message.offset_y = theme_settings.message.textoffsety
    options.message.max_length = theme_settings.message.maxlength
    local message_languages = {English=theme_settings.message.fontenglish, Japanese=theme_settings.message.fontjapanese}
    options.message.font = message_languages[windower.ffxi.get_info().language]
    options.message.font_size = theme_settings.message.size
    options.message.font_alpha = theme_settings.message.alpha

    options.message.font_color_red = theme_settings.message.dialogue.color.red
    options.message.font_color_green = theme_settings.message.dialogue.color.green
    options.message.font_color_blue = theme_settings.message.dialogue.color.blue
    options.message.dialogue_reset = ('%d,%d,%d'):format(options.message.font_color_red, options.message.font_color_green, options.message.font_color_blue)
    options.message.dialogue_items = theme_settings.message.dialogue.items
    options.message.dialogue_keyitems = theme_settings.message.dialogue.keyitems
    options.message.dialogue_gear = theme_settings.message.dialogue.gear
    options.message.dialogue_roe = theme_settings.message.dialogue.roe
    if theme_settings.message.dialogue.stroke then
        options.message.stroke_width = theme_settings.message.dialogue.stroke.width
        options.message.stroke_alpha = theme_settings.message.dialogue.stroke.alpha
        options.message.stroke_red = theme_settings.message.dialogue.stroke.red
        options.message.stroke_green = theme_settings.message.dialogue.stroke.green
        options.message.stroke_blue = theme_settings.message.dialogue.stroke.blue
    end

    options.message.system_red = theme_settings.message.system.color.red
    options.message.system_green = theme_settings.message.system.color.green
    options.message.system_blue = theme_settings.message.system.color.blue
    options.message.system_reset = ('%d,%d,%d'):format(options.message.system_red, options.message.system_green, options.message.system_blue)
    options.message.system_items = theme_settings.message.system.items
    options.message.system_keyitems = theme_settings.message.system.keyitems
    options.message.system_gear = theme_settings.message.system.gear
    options.message.system_roe = theme_settings.message.system.roe
    if theme_settings.message.system.stroke then
        options.message.system_stroke_width = theme_settings.message.system.stroke.width
        options.message.system_stroke_alpha = theme_settings.message.system.stroke.alpha
        options.message.system_stroke_red = theme_settings.message.system.stroke.red
        options.message.system_stroke_green = theme_settings.message.system.stroke.green
        options.message.system_stroke_blue = theme_settings.message.system.stroke.blue
    end

    options.name = {}
    options.name.width = theme_settings.npcname.width
    options.name.height = theme_settings.npcname.height
    options.name.offset_x = theme_settings.npcname.textoffsetx
    options.name.offset_y = theme_settings.npcname.textoffsety
    options.name.background_offset_x = theme_settings.npcname.offsetx
    options.name.background_offset_y = theme_settings.npcname.offsety
    local name_languages = {English=theme_settings.npcname.fontenglish, Japanese=theme_settings.npcname.fontjapanese}
    options.name.font = name_languages[windower.ffxi.get_info().language]
    options.name.font_size = theme_settings.npcname.size
    options.name.font_alpha = theme_settings.npcname.color.alpha
    options.name.font_color_red = theme_settings.npcname.color.red
    options.name.font_color_green = theme_settings.npcname.color.green
    options.name.font_color_blue = theme_settings.npcname.color.blue
    if theme_settings.npcname.stroke then
        options.name.stroke_width = theme_settings.npcname.stroke.width
        options.name.stroke_alpha = theme_settings.npcname.stroke.alpha
        options.name.stroke_red = theme_settings.npcname.stroke.red
        options.name.stroke_green = theme_settings.npcname.stroke.green
        options.name.stroke_blue = theme_settings.npcname.stroke.blue
    end

    options.prompt_width = theme_settings.prompt.width
    options.prompt_height = theme_settings.prompt.height
    options.prompt_offset_x = theme_settings.prompt.offsetx
    options.prompt_offset_y = theme_settings.prompt.offsety

    return options
end

return theme