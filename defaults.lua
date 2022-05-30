local defaults = {}

defaults.DisplayMode = 2
defaults.MovementCloses = false
defaults.NoPromptCloseDelay = 10
defaults.AnimatePrompt = true
defaults.Theme = 'default'

local windower_settings = windower.get_windower_settings()
defaults.Position = {}
defaults.Position.X = windower_settings.ui_x_res / 2 - 330
defaults.Position.Y = windower_settings.ui_y_res - 258

return defaults