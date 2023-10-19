local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

mod:add_require_path('better_buff_management/scripts/mods/better_buff_management/hud/buff_bars/hud_element_buff_bar_2')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar02 = class('HudElementBuffBar02', 'HudElementBuffBar')
function HudElementBuffBar02:init(parent, draw_layer, start_scale)
    HudElementBuffBar02.super.init(self, parent, draw_layer, start_scale)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

-- function HudElementBuffBar02:event_player_buff_added(player, buff_instance)
--     HudElementBuffBar02.super.event_player_buff_added(self, player, buff_instance)
-- end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

return HudElementBuffBar02
