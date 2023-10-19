local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

mod:add_require_path('better_buff_management/scripts/mods/better_buff_management/hud/buff_bars/hud_element_buff_bar_1')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar01 = class('HudElementBuffBar01', 'HudElementBuffBar')
function HudElementBuffBar01:init(parent, draw_layer, start_scale)
    HudElementBuffBar01.super.init(self, parent, draw_layer, start_scale)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

-- function HudElementBuffBar01:event_player_buff_added(player, buff_instance)
--     HudElementBuffBar01.super.event_player_buff_added(self, player, buff_instance)
-- end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

return HudElementBuffBar01
