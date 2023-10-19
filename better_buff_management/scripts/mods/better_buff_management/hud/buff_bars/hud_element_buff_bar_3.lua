local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

mod:add_require_path('better_buff_management/scripts/mods/better_buff_management/hud/buff_bars/hud_element_buff_bar_3')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar03 = class('HudElementBuffBar03', 'HudElementBuffBar')
function HudElementBuffBar03:init(parent, draw_layer, start_scale)
    HudElementBuffBar03.super.init(self, parent, draw_layer, start_scale)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

-- function HudElementBuffBar03:event_player_buff_added(player, buff_instance)
--     HudElementBuffBar03.super.event_player_buff_added(self, player, buff_instance)
-- end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

return HudElementBuffBar03
