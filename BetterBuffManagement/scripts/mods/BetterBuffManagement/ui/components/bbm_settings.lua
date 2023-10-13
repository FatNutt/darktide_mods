local mod = get_mod('BetterBuffManagement')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/helpers/misc')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local ADD_BUFF_DIRECTION_SETTING_ID = 'add_buff_direction'
local TOGGLE_HIDDEN_BUFFS_SETTING_ID = 'toggle_hidden_buffs'
local RESET_SETTIINGS_LOCALIZATION_ID = 'reset_all_settings'

local BetterBuffManagementSettingsComponent = {}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function draw_add_buff_direction_combo(widget)
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

local function draw_toggle_hidden_buffs_checkbox()
    local old_flag = mod:get(TOGGLE_HIDDEN_BUFFS_SETTING_ID)
    local new_flag = Imgui.checkbox(mod:localize(TOGGLE_HIDDEN_BUFFS_SETTING_ID), old_flag)

    if new_flag ~= old_flag then
        mod:set(TOGGLE_HIDDEN_BUFFS_SETTING_ID, new_flag)
    end
end

local function reset_all_settings(widgets)
    for _, widget in ipairs(widgets) do
        if widget.setting_id ~= 'configure_buffs' then
            mod:set(widget.setting_id, widget.default_value)
        end
    end
end

local function draw_reset_all_settings_button(widgets)
    if Imgui.button(mod:localize(RESET_SETTIINGS_LOCALIZATION_ID)) then
        reset_all_settings(widgets)
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BetterBuffManagementSettingsComponent.draw = function(widgets)
    local add_buff_direction_widget = mod.find_table_by_key_value_pair(widgets, 'setting_id', ADD_BUFF_DIRECTION_SETTING_ID)
    draw_add_buff_direction_combo(add_buff_direction_widget)

    draw_toggle_hidden_buffs_checkbox()

    draw_reset_all_settings_button(widgets)
end

return BetterBuffManagementSettingsComponent