local mod = get_mod('better_buff_management')

local BuffSettings = require("scripts/settings/buff/buff_settings")
local HudElementPlayerBuffsSettings = require(
    'scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_settings')

local HudElementBuffBarSettings = table.clone(HudElementPlayerBuffsSettings)

HudElementBuffBarSettings.spacing = 42
HudElementBuffBarSettings.reserved_spots = {
    [BuffSettings.buff_categories.generic] = 0,
    [BuffSettings.buff_categories.talents] = 0,
    [BuffSettings.buff_categories.weapon_traits] = 0,
}
HudElementBuffBarSettings.gap_offset_size = 0.5

return HudElementBuffBarSettings
