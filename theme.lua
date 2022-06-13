local theme = {}

theme.apply = function(theme_settings)
    local options = {}

    options.balloon_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/balloon.png'
    options.system_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/system.png'
    options.portrait_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/portrait-bg.png'
    options.portrait_frame = windower.addon_path .. 'themes/' .. theme_settings.name .. '/portrait-frame.png'
    options.name_background = windower.addon_path .. 'themes/' .. theme_settings.name .. '/name-bg.png'
    options.prompt_image = windower.addon_path .. 'themes/' .. theme_settings.name .. '/advance-prompt.png'

    options.message = {}
    options.message.width = theme_settings.message.width
    options.message.height = theme_settings.message.height
    options.message.offset_x = theme_settings.message.textoffsetx
    options.message.offset_y = theme_settings.message.textoffsety
    options.message.max_length = theme_settings.message.maxlength or 75
    local message_languages = {English=theme_settings.message.fontenglish, Japanese=theme_settings.message.fontjapanese}
    options.message.font = message_languages[windower.ffxi.get_info().language]
    options.message.font_size = theme_settings.message.size
    options.message.font_color = {}
    options.message.font_color.alpha = theme_settings.message.dialogue.color.alpha
    options.message.font_color.red = theme_settings.message.dialogue.color.red
    options.message.font_color.green = theme_settings.message.dialogue.color.green
    options.message.font_color.blue = theme_settings.message.dialogue.color.blue

    options.message.dialogue = {}
    options.message.dialogue.alpha = theme_settings.message.dialogue.color.alpha
    options.message.dialogue.red = theme_settings.message.dialogue.color.red
    options.message.dialogue.green = theme_settings.message.dialogue.color.green
    options.message.dialogue.blue = theme_settings.message.dialogue.color.blue
    options.message.dialogue.items = theme_settings.message.dialogue.items
    options.message.dialogue.keyitems = theme_settings.message.dialogue.keyitems
    options.message.dialogue.gear = theme_settings.message.dialogue.gear
    options.message.dialogue.roe = theme_settings.message.dialogue.roe
    options.message.dialogue.emote = theme_settings.message.dialogue.emote
    options.message.stroke = {}
    options.message.dialogue.stroke = {}
    if theme_settings.message.dialogue.stroke then
        options.message.stroke.width = theme_settings.message.dialogue.stroke.width
        options.message.stroke.alpha = theme_settings.message.dialogue.stroke.alpha
        options.message.stroke.red = theme_settings.message.dialogue.stroke.red
        options.message.stroke.green = theme_settings.message.dialogue.stroke.green
        options.message.stroke.blue = theme_settings.message.dialogue.stroke.blue
        options.message.dialogue.stroke.width = theme_settings.message.dialogue.stroke.width
        options.message.dialogue.stroke.alpha = theme_settings.message.dialogue.stroke.alpha
        options.message.dialogue.stroke.red = theme_settings.message.dialogue.stroke.red
        options.message.dialogue.stroke.green = theme_settings.message.dialogue.stroke.green
        options.message.dialogue.stroke.blue = theme_settings.message.dialogue.stroke.blue
    end

    options.message.system = {}
    if theme_settings.message.system then
        options.message.system.alpha = theme_settings.message.system.color.alpha
        options.message.system.red = theme_settings.message.system.color.red
        options.message.system.green = theme_settings.message.system.color.green
        options.message.system.blue = theme_settings.message.system.color.blue
        options.message.system.items = theme_settings.message.system.items
        options.message.system.keyitems = theme_settings.message.system.keyitems
        options.message.system.gear = theme_settings.message.system.gear
        options.message.system.roe = theme_settings.message.system.roe
        options.message.system.emote = theme_settings.message.system.emote
        options.message.system.stroke = {}
        if theme_settings.message.system.stroke then
            options.message.system.stroke.width = theme_settings.message.system.stroke.width
            options.message.system.stroke.alpha = theme_settings.message.system.stroke.alpha
            options.message.system.stroke.red = theme_settings.message.system.stroke.red
            options.message.system.stroke.green = theme_settings.message.system.stroke.green
            options.message.system.stroke.blue = theme_settings.message.system.stroke.blue
        end
    else
        -- use dialogue settings if there are no system settings
        options.message.system = options.message.dialogue
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
    options.name.font_color = {}
    options.name.font_color.alpha = theme_settings.npcname.color.alpha
    options.name.font_color.red = theme_settings.npcname.color.red
    options.name.font_color.green = theme_settings.npcname.color.green
    options.name.font_color.blue = theme_settings.npcname.color.blue
    options.name.stroke = {}
    if theme_settings.npcname.stroke then
        options.name.stroke.width = theme_settings.npcname.stroke.width
        options.name.stroke.alpha = theme_settings.npcname.stroke.alpha
        options.name.stroke.red = theme_settings.npcname.stroke.red
        options.name.stroke.green = theme_settings.npcname.stroke.green
        options.name.stroke.blue = theme_settings.npcname.stroke.blue
    end

    if theme_settings.portrait then
        options.portrait = {}
        options.portrait.width = theme_settings.portrait.width
        options.portrait.height = theme_settings.portrait.height
        options.portrait.offset_x = theme_settings.portrait.offsetx
        options.portrait.offset_y = theme_settings.portrait.offsety
        options.portrait.max_length = theme_settings.portrait.maxlength
        options.portrait.message_offset_x = theme_settings.portrait.messagetextoffsetx
        options.portrait.message_offset_y = theme_settings.portrait.messagetextoffsety
    end

    if theme_settings.prompt then
        options.prompt = {}
        options.prompt.width = theme_settings.prompt.width
        options.prompt.height = theme_settings.prompt.height
        options.prompt.offset_x = theme_settings.prompt.offsetx
        options.prompt.offset_y = theme_settings.prompt.offsety
    end

    options.timer = {}
    if theme_settings.timer then
        options.timer.offset_x = theme_settings.timer.textoffsetx or theme_settings.prompt.offsetx
        options.timer.offset_y = theme_settings.timer.textoffsety or theme_settings.prompt.offsety
        local timer_languages = {English=theme_settings.timer.fontenglish or theme_settings.message.fontenglish,
                                 Japanese=theme_settings.timer.fontjapanese or theme_settings.message.fontjapanese}
        options.timer.font = timer_languages[windower.ffxi.get_info().language]
        options.timer.font_size = theme_settings.timer.size or theme_settings.message.size

        options.timer.font_color = {}
        if theme_settings.timer.color then
            options.timer.font_color.alpha = theme_settings.timer.color.alpha
            options.timer.font_color.red = theme_settings.timer.color.red
            options.timer.font_color.green = theme_settings.timer.color.green
            options.timer.font_color.blue = theme_settings.timer.color.blue
        else
            options.timer.font_color = options.message.font_color
        end
        options.timer.stroke = {}
        if theme_settings.timer.stroke then
            options.timer.stroke.width = theme_settings.timer.stroke.width
            options.timer.stroke.alpha = theme_settings.timer.stroke.alpha
            options.timer.stroke.red = theme_settings.timer.stroke.red
            options.timer.stroke.green = theme_settings.timer.stroke.green
            options.timer.stroke.blue = theme_settings.timer.stroke.blue
        else
            options.timer.stroke = options.message.stroke
        end
    else
        -- use prompt position and message font settings, if no timer settings exist in the theme
        options.timer.offset_x = theme_settings.prompt.offsetx
        options.timer.offset_y = theme_settings.prompt.offsety
        options.timer.font = options.message.font
        options.timer.font_size = options.message.font_size
        options.timer.font_color = options.message.font_color
        options.timer.stroke = options.message.stroke
    end

    return options
end

return theme