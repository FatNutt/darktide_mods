local mod = get_mod('BetterBuffManagement')
mod:io_dofile("BetterBuffManagement/scripts/mods/BetterBuffManagement/helpers/misc")

local BetterBuffManagementWindow = class('BetterBuffManagementWindow')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local BUFF_TEMPLATES = require('scripts/settings/buff/buff_templates')
local MASTER_ITEMS = require('scripts/backend/master_items')

local GROUPINGS_SETTING_ID = 'bbm_groupings'
local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local ADD_BUFF_DIRECTION_SETTING_ID = 'add_buff_direction'
local TOGGLE_HIDDEN_BUFFS_SETTING_ID = 'toggle_hidden_buffs'

local RESET_SETTIINGS_LOCALIZATION_ID = 'reset_all_settings'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function get_widget_by_setting_id(widgets, setting_id_value)
    return mod.find_table_by_key_value_pair(widgets, 'setting_id', setting_id_value)
end

local function reset_all_settings(widgets)
    for _, widget in ipairs(widgets) do
        mod:set(widget.setting_id, widget.default_value)
    end
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------

function BetterBuffManagementWindow:init()
    self._is_open = false
    self._cached_items = nil
    self._buffs = nil
    self._groupings = {
        { name = 'grouping_1', display_name = 'Grouping 1' },
        { name = 'grouping_2', display_name = 'Grouping 2' },
        { name = 'grouping_3', display_name = 'Grouping 3' },
    }
    -- mod:set(GROUPINGS_SETTING_ID, self._groupings) -- DEBUG: REMOVE ME WHEN DONE
    self._buff_bars = {}

    if not mod:get(GROUPINGS_SETTING_ID) then
        mod:set(GROUPINGS_SETTING_ID, self._groupings)
    end

    if not mod:get(BUFF_BARS_SETTING_ID) then
        mod:set(BUFF_BARS_SETTING_ID, self._buff_bars)
    end
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function BetterBuffManagementWindow:_get_icon(buff_template)
    if buff_template.hide_icon_in_hud then
        return nil
    end

    if buff_template.hud_icon then
        return buff_template.hud_icon
    end

    local buff_name = buff_template.name

    if string.find(buff_name, "_parent") then
        buff_name = string.gsub(buff_name, "_parent", "")
    end

    for _, item in pairs(self._cached_items) do
        if item.trait == buff_name then
            if item.icon and item.icon ~= "" then
                return item.icon
            end
        end
    end

    return nil
end

function BetterBuffManagementWindow:_update_add_buff_direction_combo(widgets)
    if widgets then
        local widget = get_widget_by_setting_id(widgets, ADD_BUFF_DIRECTION_SETTING_ID)

        if widget then
            local items = widget.options
            local setting_value = mod:get(ADD_BUFF_DIRECTION_SETTING_ID)
            local selected_item = mod.find_table_by_key_value_pair(items, 'value', setting_value)
    
            if Imgui.begin_combo(mod:localize(widget.setting_id), selected_item.text) then
    
                for index, item in ipairs(items) do
                    local is_selected = item.value == selected_item.value
    
                    if Imgui.selectable(item.text, is_selected) then
                        mod:set(ADD_BUFF_DIRECTION_SETTING_ID, item.value)
                    end
    
                    if is_selected then
                        Imgui.set_item_default_focus()
                    end
                end
    
                Imgui.end_combo()
            end
        end
    end
end

function BetterBuffManagementWindow:_update_toggle_hidden_buffs_checkbox(widgets)
    local old_flag = mod:get(TOGGLE_HIDDEN_BUFFS_SETTING_ID)
    local new_flag = Imgui.checkbox(mod:localize(TOGGLE_HIDDEN_BUFFS_SETTING_ID), old_flag)

    if new_flag ~= old_flag then
        mod:set(TOGGLE_HIDDEN_BUFFS_SETTING_ID, new_flag)
    end
end

function BetterBuffManagementWindow:_update_reset_all_settings_button(widgets)
    if Imgui.button(mod:localize(RESET_SETTIINGS_LOCALIZATION_ID)) then
        reset_all_settings(widgets)
    end
end

function BetterBuffManagementWindow:_update_settings()
    local mod_widgets = mod:get_internal_data('options').widgets

    self:_update_add_buff_direction_combo(mod_widgets)
    self:_update_toggle_hidden_buffs_checkbox()
    self:_update_reset_all_settings_button(mod_widgets)
end

local debug_once_again = false
function BetterBuffManagementWindow:_update_groupings()
    local groupings = mod:get(GROUPINGS_SETTING_ID)

    local dirty = false
    for index, grouping in ipairs(groupings) do
        local old_flag = grouping.display_header or false
        grouping.display_header = Imgui.checkbox(grouping.display_name, old_flag)

        if index < #groupings then
            Imgui.same_line()
        end

        if grouping.display_header ~= old_flag then
            dirty = true
        end
    end
    if dirty then
        mod:set(GROUPINGS_SETTING_ID, groupings)
    end

    local edittable_groupings = mod.filter_array_by_key_value_pair(groupings, 'display_header', true)
    dirty = false
    for _, grouping in ipairs(edittable_groupings) do
        local old_flag = grouping.is_header_open or false
        grouping.is_header_open = Imgui.collapsing_header(grouping.display_name, old_flag)

        if old_flag ~= grouping.is_header_open then
            dirty = true
        end
    end
    if dirty then
        mod:set(GROUPINGS_SETTING_ID, groupings)
    end
end

function BetterBuffManagementWindow:_update_buff_bars()
end

function BetterBuffManagementWindow:_update_buffs_search()
end


-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BetterBuffManagementWindow:open()
    local input_manager = Managers.input
    local name = self.__class_name

    if not input_manager:cursor_active() then
        input_manager:push_cursor(name)
    end

    if not self._cached_items and not self._buffs then
        self._cached_items = MASTER_ITEMS.get_cached()
        self._buffs = {}

        for _, buff_template in pairs(BUFF_TEMPLATES) do
            local hud_icon = self:_get_icon(buff_template)
            if hud_icon then
                buff_template.cached_icon = hud_icon
                self._buffs[buff_template.name] = buff_template
            end
        end
    end

    self._is_open = true
    Imgui.open_imgui()
end

function BetterBuffManagementWindow:close()
    local input_manager = Managers.input
    local name = self.__class_name

    if input_manager:cursor_active() then
        input_manager:pop_cursor(name)
    end

    self._is_open = false
    Imgui.close_imgui()
end

local debug_once = true
function BetterBuffManagementWindow:update()
    if self._is_open then
        local _, closed = Imgui.begin_window('Better Buff Managment Configuration', 'always_auto_resize')
        if closed then
            self:close()
        end

        self:_update_settings()

        Imgui.separator()
        -- Imgui.separator_text(mod:localize('grouping_separator'))

        self:_update_groupings()

        Imgui.separator()
        -- Imgui.separator_text(mod:localize('buff_bars_separator'))

        -- self:_update_buff_bars()

        Imgui.separator()
        -- Imgui.separator_text(mod:localize('buffs_search_separator'))

        -- self:_update_buffs_search()

        if not debug_once then
            debug_once = true

            local debug_tbl = {}
            for key, value in pairs(Imgui) do
                if string.find(key, 'line') then
                    table.insert(debug_tbl, key)
                end
            end
            mod:dump(debug_tbl)
        end

        Imgui.end_window()
    end
end

return BetterBuffManagementWindow
