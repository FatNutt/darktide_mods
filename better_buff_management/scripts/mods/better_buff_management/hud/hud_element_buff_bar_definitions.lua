local mod = get_mod('better_buff_management')
local HudElementPlayerBuffsDefinitions = require(
    'scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_definitions'
)
local UIWorkspaceSettings = require('scripts/settings/ui/ui_workspace_settings')

local BAR_SIZE = { 80, 40 }
local BUFF_SIZE = { 38, 38 }

-- Only override the scenegraph layout; keep widget definitions vanilla
local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    background = {
        horizontal_alignment = 'left',
        parent = 'screen',
        vertical_alignment = 'top',
        size = { BAR_SIZE[1], BAR_SIZE[2] },
        position = { 0, 0, 1 },
    },
    buff = {
        horizontal_alignment = 'left',
        parent = 'background',
        vertical_alignment = 'top',
        size = { BUFF_SIZE[1], BUFF_SIZE[2] },
        position = { 0, 0, 1 },
    },
}

return {
    animations = HudElementPlayerBuffsDefinitions.animations,
    buff_widget_definition = HudElementPlayerBuffsDefinitions.buff_widget_definition,
    widget_definitions = HudElementPlayerBuffsDefinitions.widget_definitions,
    scenegraph_definition = scenegraph_definition,
}
