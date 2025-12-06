require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/debug')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
local BuffSettings = require("scripts/settings/buff/buff_settings")
local BuffBarSettings = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_settings')
local BuffBarDefinitions = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')
local BuffBar = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/models/buff_bar')
-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale, data)
    HudElementBuffBar.super.init(self, parent, draw_layer, start_scale, BuffBarDefinitions)

    self._data = data or BuffBar.DEFAULT
    self._number_of_buffs_per_category = {}
    self._category_data = {
        offsets = {},
        numbers = {}
    }
end

-- @TODO: use new BuffBar class to get filter


-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

function HudElementBuffBar:event_player_buff_added(player, buff_instance)
    local filter = self:_filter()
    if filter and filter[buff_instance._template_name] then
        HudElementBuffBar.super.event_player_buff_added(self, player, buff_instance)
    end
end

function HudElementBuffBar:event_player_buff_stack_added(player, buff_instance)
    local filter = self:_filter()
    if filter and filter[buff_instance._template_name] then
        HudElementBuffBar.super.event_player_buff_stack_added(self, player, buff_instance)
    end
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------
function HudElementBuffBar:_filter()
    return self._options.filter
end

function HudElementBuffBar:_sync_current_active_buffs(buffs)
    if not buffs then
        return
    end

    ---@diagnostic disable-next-line: undefined-field
    local filtered_buffs = table.filter(buffs, function(buff)
        return self._filter and self._filter[buff._template_name]
    end)

    if table.is_nil_or_empty(filtered_buffs) then
        return
    end

    filtered_buffs = table.to_array(filtered_buffs)

    HudElementBuffBar.super._sync_current_active_buffs(self, filtered_buffs)
end

function HudElementBuffBar:_should_use_categories()
    local save_manager = Managers.save
    local group_buff_icon_in_categories = false

    if save_manager then
        local account_data = save_manager:account_data()

        group_buff_icon_in_categories = account_data.interface_settings.group_buff_icon_in_categories
    end

    return group_buff_icon_in_categories
end

function HudElementBuffBar:_get_number_of_buffs_per_category()
    local active_buffs_data = self._active_buffs_data

    local number_of_buffs_per_category = {}
    for i = 1, #active_buffs_data do
        local buff_data = active_buffs_data[i]
        local buff_category = buff_data.buff_category or BuffSettings.buff_categories.generic

        if buff_data.show and not buff_data.is_negative then
            number_of_buffs_per_category[buff_category] = (number_of_buffs_per_category[buff_category] or 0) + 1
        end
    end

    return number_of_buffs_per_category
end

function HudElementBuffBar:_get_category_data()
    local spacing = BuffBarSettings.spacing

    local category_data = {
        offsets = {},
        numbers = {}
    }
    local current_number = 0

    for _, buff_category in ipairs(BuffSettings.buff_category_order) do
        local number_in_category = math.max(self._number_of_buffs_per_category[buff_category] or 0,
            BuffBarSettings.reserved_spots[buff_category] or 0)

        category_data['offsets'][buff_category] = current_number * spacing
        category_data['numbers'][buff_category] = current_number

        current_number = current_number + number_in_category +
            (number_in_category > 0 and BuffBarSettings.gap_offset_size or 0)
    end

    return category_data
end

function HudElementBuffBar:_align_buffs(force_update, dt, use_categories, direction, reversed)
    local direction = direction or 'horz'
    local reversed = reversed or false

    local active_buffs_data = self._active_buffs_data
    local category_offsets = self._category_data['offsets']
    local category_numbers = self._category_data['numbers']

    local previous_positive_buff_offset = 0
    local previous_negative_buff_offset = 0
    local num_aligned_positive_buffs = 0
    local num_aligned_negative_buffs = 0

    local spacing = BuffBarSettings.spacing
    if reversed then
        spacing = spacing * -1
    end

    -- determines if x or y offset should be used
    local idx = direction == 'horz' and 1 or 2

    for _, buff_data in pairs(active_buffs_data) do
        local widget = buff_data.widget
        local is_negative = buff_data.is_negative

        local previous_buff_offset = is_negative and previous_negative_buff_offset or
            previous_positive_buff_offset

        local num_aligned_category_buffs = is_negative and num_aligned_negative_buffs or
            use_categories and (category_numbers[buff_data.buff_category] or 0) or num_aligned_positive_buffs

        if widget then
            local offset = widget.offset

            offset[idx == 1 and 2 or 1] = is_negative and -42 or 0

            local old_offset = offset[idx]
            local target = spacing * num_aligned_category_buffs

            if force_update then
                offset[idx] = target
                widget.dirty = true
            else
                if widget.initialize_offset then
                    widget.initialize_offset = nil
                    offset[idx] = target + spacing
                    widget.content.opacity = 0
                else
                    offset[idx] = math.lerp(old_offset, target, dt * 6)
                    widget.content.opacity = math.lerp(widget.content.opacity, 1, dt * 4)
                end
            end

            if is_negative then
                previous_negative_buff_offset = offset[1]
                num_aligned_negative_buffs = num_aligned_negative_buffs + 1
            elseif use_categories then
                category_offsets[buff_data.buff_category] = offset[idx]
                category_numbers[buff_data.buff_category] = (category_numbers[buff_data.buff_category] or 0) +
                    1
            else
                previous_positive_buff_offset = offset[idx]
                num_aligned_positive_buffs = num_aligned_positive_buffs + 1
            end

            if old_offset ~= offset[idx] then
                widget.dirty = true
            end
        end
    end
end

function HudElementBuffBar:_update_buff_alignments(force_update, dt)
    local should_use_categories = self:_should_use_categories()

    if should_use_categories then
        self._number_of_buffs_per_category = self:_get_number_of_buffs_per_category()
        self._category_data = self:_get_category_data()
    end

    self:_align_buffs(force_update, dt)
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
