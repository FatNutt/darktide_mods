require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
local BuffBarDefinitions = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'
local BUFF_MOD_DATA_SETTING_ID = 'bbm_buff_mod_data'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function _is_in_hub()
    local game_mode_name = Managers.state.game_mode:game_mode_name()
    return game_mode_name == 'hub' or game_mode_name == 'prologue_hub'
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale, buff_bar_num)
    if buff_bar_num then
        self._filter = self:_get_filter(buff_bar_num)
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
---@diagnostic disable-next-line: undefined-field
    return self._filter and #self._filter > 0 and table.contains(self._filter, buff_name)
end

function HudElementBuffBar:_sync_current_active_buffs(buffs)
    if not buffs then
        return
    end

---@diagnostic disable-next-line: undefined-field
    buffs = table.filter(buffs, function(buff)
        return self:_should_display_buff(buff._template_name)
    end)
    HudElementBuffBar.super._sync_current_active_buffs(self, buffs)
end

function HudElementBuffBar:_get_filter(buff_bar_num)
    if buff_bar_num then
        local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
---@diagnostic disable-next-line: undefined-field
        if buff_bars and table.size(buff_bars) > 0 and buff_bars[buff_bar_num] then
            local filter = buff_bars[buff_bar_num].buffs

            local mod_data = mod:get(BUFF_MOD_DATA_SETTING_ID)
            if mod_data then
                for i = #filter, 1, -1 do
---@diagnostic disable-next-line: undefined-field
                    local index = table.index_of_condition(mod_data, function (data)
                        return data.name == filter[i] and data.is_hidden
                    end)

                    if index > 0 then
                        table.remove(filter, i)
                        i = i - 1
                    end
                end
            end

            return filter
        end
    end

    return nil
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------
  
function HudElementBuffBar:draw(dt, t, ui_renderer, render_settings, input_service)
    if _is_in_hub() then
        return
    end

    HudElementBuffBar.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementBuffBar
