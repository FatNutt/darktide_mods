local mod = get_mod('better_buff_management')
local HudElementPlayerBuffsDefinitions = require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_definitions')

local BUFF_SIZE = { 38, 38 }

local HudElementBuffBarDefinitions = table.clone(HudElementPlayerBuffsDefinitions)

-- HudElementBuffBarDefinitions.scenegraph_definition.background.size = BUFF_SIZE

-- HudElementBuffBarDefinitions.scenegraph_definition.buff.size = BUFF_SIZE

-- HudElementBuffBarDefinitions.buff_widget_definition.style.size = BUFF_SIZE

return HudElementBuffBarDefinitions