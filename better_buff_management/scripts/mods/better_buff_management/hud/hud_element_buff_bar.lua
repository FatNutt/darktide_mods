require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
local BuffBarDefinitions = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'
local BUFF_MOD_DATA_SETTING_ID = 'bbm_buff_mod_data'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function _get_filter(buff_bar_num)
    if buff_bar_num then
        local buff_bars = mod:get(BUFF_BARS_SETTING_ID)

        if buff_bars and #buff_bars > 0 and buff_bars[buff_bar_num] and #buff_bars[buff_bar_num].buffs > 0 then
            return buff_bars[buff_bar_num].buffs
        end
    end

    return nil
end

local function _get_filter_data(filter)
    if filter and #filter > 0 then
        local buff_data = mod:get(BUFF_MOD_DATA_SETTING_ID)

        if buff_data then
            buff_data = table.filter(buff_data, function(data)
                return table.contains(filter, data.name) -- or table.contains(filter, data.name:gsub('_parent', ''))
            end)
    
            return buff_data
        end
    end

    return nil
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale, buff_bar_num)
    if buff_bar_num then
        self._filter = _get_filter(buff_bar_num)
        self._filter_data = _get_filter_data(self._filter)
    end

    HudElementBuffBar.super.init(self, parent, draw_layer, start_scale, BuffBarDefinitions)
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

function HudElementBuffBar:event_player_buff_added(player, buff_instance)
    if self:_should_display_buff(buff_instance._template_name) then
        HudElementBuffBar.super.event_player_buff_added(self, player, buff_instance)
    end
end


-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function HudElementBuffBar:_should_display_buff(buff_name)
    if self._filter_data and table.size(self._filter_data) > 0 then
        return self._filter_data[buff_name] and (self._filter_data[buff_name].is_hidden == nil or not self._filter_data[buff_name].is_hidden)
    elseif self._filter and #self._filter > 0 then
        return table.contains(self._filter, buff_name)
    else
        return false
    end
end

function HudElementBuffBar:_sync_current_active_buffs(buffs)
    if not buffs then
        return
    end

    ---@diagnostic disable-next-line: undefined-field
    local filtered_buffs = table.filter(buffs, function(buff)
        return self:_should_display_buff(buff._template_name)
    end)

    if not filtered_buffs or table.size(filtered_buffs) == 0 then
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
