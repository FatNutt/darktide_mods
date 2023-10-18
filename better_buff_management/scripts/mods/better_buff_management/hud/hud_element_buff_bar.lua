require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
local BuffBarDefinitions = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale)
    HudElementBuffBar.super.init(self, parent, draw_layer, start_scale, BuffBarDefinitions)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

-- function HudElementBuffBar:event_player_buff_added(player, buff_instance)
--     HudElementBuffBar.super.event_player_buff_added(self, player, buff_instance)
-- end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

return HudElementBuffBar
