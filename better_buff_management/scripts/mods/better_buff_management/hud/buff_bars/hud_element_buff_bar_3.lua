local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

mod:add_require_path('better_buff_management/scripts/mods/better_buff_management/hud/buff_bars/hud_element_buff_bar_3')

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar03 = class('HudElementBuffBar03', 'HudElementBuffBar')
function HudElementBuffBar03:init(parent, draw_layer, start_scale)
    HudElementBuffBar03.super.init(self, parent, draw_layer, start_scale, 3)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

return HudElementBuffBar03
