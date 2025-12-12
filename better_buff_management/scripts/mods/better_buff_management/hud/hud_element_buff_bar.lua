require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
local BuffBarDefinitions = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')

local BuffBar = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_bar')


-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
local function create_filter_index(raw_filter)
    local filter = {}

    for _, buff_name in ipairs(raw_filter) do
        filter[buff_name] = true
    end

    return filter
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale, params)
    HudElementBuffBar.super.init(self, parent, draw_layer, start_scale, BuffBarDefinitions)
    self._bar_data = params and params.bar_data or BuffBar:new()
    self._filter = create_filter_index(self._bar_data.filter)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

function HudElementBuffBar:event_player_buff_added(player, buff_instance)
    if self._filter and self._filter[buff_instance._template_name:trim()] then
        HudElementBuffBar.super.event_player_buff_added(self, player, buff_instance)
    end
end

function HudElementBuffBar:event_player_buff_stack_added(player, buff_instance)
    if self._filter and self._filter[buff_instance._template_name:trim()] then
        HudElementBuffBar.super.event_player_buff_stack_added(self, player, buff_instance)
    end
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------
function HudElementBuffBar:_sync_current_active_buffs(buffs)
    if not buffs then
        return
    end

    ---@diagnostic disable-next-line: undefined-field
    local filtered_buffs = table.filter(buffs, function(buff)
        return self._filter and self._filter[buff._template_name:trim()]
    end)

    if table.is_nil_or_empty(filtered_buffs) then
        return
    end

    filtered_buffs = table.to_array(filtered_buffs)

    HudElementBuffBar.super._sync_current_active_buffs(self, filtered_buffs)
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function HudElementBuffBar:draw(dt, t, ui_renderer, render_settings, input_service)
    if mod:is_in_hub() then
        return
    end

    HudElementBuffBar.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementBuffBar
