local ui = {}

local text_setup = {
    flags = {
        draggable = false
    },
    padding = 2
}

ui.message_background = images.new()
ui.name_background = images.new()
ui.prompt = images.new()

ui.message_text = texts.new(text_setup)
ui.name_text = texts.new(text_setup)

ui._dialogue_settings = {}
ui._system_settings = {}
ui._type = {}

ui._theme = 'default'
ui._scale = 1.0

local function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
end

local function setup_text(text, text_options)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(text_options.font, 'meiryo', 'segoe ui', 'sans-serif')
    text:size(text_options.font_size)
    text:alpha(text_options.font_alpha)
    text:color(text_options.font_color_red, text_options.font_color_green, text_options.font_color_blue)
    text:stroke_transparency(text_options.stroke_alpha or 0)
    text:stroke_color(text_options.stroke_red or 0, text_options.stroke_green or 0, text_options.stroke_blue or 0)
    text:stroke_width(text_options.stroke_width or 0)
end

function ui:load(settings, theme_options)
    self._theme = settings.Theme
    self._scale = settings.Scale

    self._dialogue_settings.path = theme_options.balloon_background
    self._dialogue_settings.color = {}
    self._dialogue_settings.color.red = theme_options.message.font_color_red
    self._dialogue_settings.color.green = theme_options.message.font_color_green
    self._dialogue_settings.color.blue = theme_options.message.font_color_blue
    self._dialogue_settings.reset = theme_options.message.dialogue_reset
    self._dialogue_settings.items = theme_options.message.dialogue_items
    self._dialogue_settings.keyitems = theme_options.message.dialogue_keyitems
    self._dialogue_settings.gear = theme_options.message.dialogue_gear
    self._dialogue_settings.roe = theme_options.message.dialogue_roe
    self._dialogue_settings.stroke = {}
    self._dialogue_settings.stroke.width = theme_options.message.stroke_width or 0
    self._dialogue_settings.stroke.alpha = theme_options.message.stroke_alpha or 0
    self._dialogue_settings.stroke.red = theme_options.message.stroke_red or 0
    self._dialogue_settings.stroke.green = theme_options.message.stroke_green or 0
    self._dialogue_settings.stroke.blue = theme_options.message.stroke_blue or 0

    self._system_settings.path = theme_options.system_background
    self._system_settings.color = {}
    self._system_settings.color.red = theme_options.message.system_red
    self._system_settings.color.green = theme_options.message.system_green
    self._system_settings.color.blue = theme_options.message.system_blue
    self._system_settings.reset = theme_options.message.system_reset
    self._system_settings.items = theme_options.message.system_items
    self._system_settings.keyitems = theme_options.message.system_keyitems
    self._system_settings.gear = theme_options.message.system_gear
    self._system_settings.roe = theme_options.message.system_roe
    self._system_settings.stroke = {}
    self._system_settings.stroke.width = theme_options.message.system_stroke_width or 0
    self._system_settings.stroke.alpha = theme_options.message.system_stroke_alpha or 0
    self._system_settings.stroke.red = theme_options.message.system_stroke_red or 0
    self._system_settings.stroke.green = theme_options.message.system_stroke_green or 0
    self._system_settings.stroke.blue = theme_options.message.system_stroke_blue or 0

    self._type = self._dialogue_settings

    setup_image(self.message_background, self._type.path)
    setup_image(self.name_background, theme_options.name_background)
    setup_image(self.prompt, theme_options.prompt_image)

    setup_text(self.message_text, theme_options.message)
    setup_text(self.name_text, theme_options.name)

    self:position(settings, theme_options)

    self.message_background:draggable(true)
end

function ui:position(settings, theme_options)
    self._scale = settings.Scale

    local center_offset_x = theme_options.message.width / 2
    local center_offset_y = theme_options.message.height / 2
    local x = settings.Position.X - center_offset_x * settings.Scale
    local y = settings.Position.Y - center_offset_y * settings.Scale
    local name_bg_offset_x = theme_options.name.background_offset_x * settings.Scale
    local name_bg_offset_y = theme_options.name.background_offset_y * settings.Scale
    local prompt_offset_x = theme_options.prompt_offset_x * settings.Scale
    local prompt_offset_y = theme_options.prompt_offset_y * settings.Scale
    local message_text_offset_x = theme_options.message.offset_x * settings.Scale
    local message_text_offset_y = theme_options.message.offset_y * settings.Scale
    local name_text_offset_x = theme_options.name.offset_x * settings.Scale
    local name_text_offset_y = theme_options.name.offset_y * settings.Scale

    self.message_background:pos(x, y)
    self.name_background:pos(x + name_bg_offset_x, y + name_bg_offset_y)
    self.prompt:pos(x + prompt_offset_x, y + prompt_offset_y)

    self.message_text:pos(x + message_text_offset_x, y + message_text_offset_y)
    self.name_text:pos(x + name_text_offset_x, y + name_text_offset_y)

    self.message_background:size(theme_options.message.width * settings.Scale, theme_options.message.height * settings.Scale)
    self.name_background:size(theme_options.name.width * settings.Scale, theme_options.name.height * settings.Scale)
    self.prompt:size(theme_options.prompt_width * settings.Scale, theme_options.prompt_height * settings.Scale)

    self.message_text:size(theme_options.message.font_size * settings.Scale)
    self.name_text:size(theme_options.name.font_size * settings.Scale)
end

function ui:hide()
    self.message_background:hide()
    self.name_background:hide()
    self.prompt:hide()

    self.message_text:hide()
    self.name_text:hide()
end

function ui:show()
    self.message_background:show()
    self.message_text:show()

    if self.name_text:text() ~= ' ' then
        self.name_background:show()
        self.name_text:show()
    end

    self.prompt:show()
end

function ui:set_type(type)
    local types = {
        --[190] = self._system_settings, -- system text (always a duplicate of 151?)
        [150] = self._dialogue_settings, -- npc text
        [151] = self._system_settings, -- system text
        [142] = self._dialogue_settings, -- battle text
        [144] = self._dialogue_settings, -- prompt-less npc text
        [146] = self._system_settings -- "You hear something moving to the east..."
    }
    self._type = types[type]

    self:update_message_bg(self._type.path)
    self.message_text:color(self._type.color.red, self._type.color.green, self._type.color.blue)
    self.message_text:stroke_transparency(self._type.stroke.alpha)
    self.message_text:stroke_color(self._type.stroke.red, self._type.stroke.green, self._type.stroke.blue)
    self.message_text:stroke_width(self._type.stroke.width)
end

function ui:set_character(name)
    self.name_text:text(' '..name)

    -- set a custom balloon based on npc name, if an image for them exists
    local fname = windower.addon_path..'themes/'..self._theme..('/characters/%s.png'):format(name)
	if windower.file_exists(fname) then
		self:update_message_bg(fname)
        return true
    end
    return false
end

function ui:update_message_bg(path)
    if path ~= self.message_background:path() then
        self.message_background:path(path)
    end
end

function ui:set_message(message)
    self.message_text:text(message)
end

local function smooth_sawtooth(time, frequency)
	local x = time * frequency
	return(-math.sin(x-math.sin(x)/2))
end

function ui:animate_prompt(frame_count, theme_options)
    local amplitude = 2.5
	local bounceOffset = smooth_sawtooth(frame_count/60, 6) * amplitude

	local pos_y = self.message_background:pos_y() + (theme_options.prompt_offset_y + bounceOffset) * self._scale
	self.prompt:pos_y(pos_y)
end

return ui