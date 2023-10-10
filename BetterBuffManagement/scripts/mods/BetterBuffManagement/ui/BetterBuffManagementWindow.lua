local mod = get_mod('BetterBuffManagement')
mod:io_dofile("BetterBuffManagement/scripts/mods/BetterBuffManagement/helpers/misc")
-- local BuffTemplates = require('scripts/settings/buff/buff_templates')
-- local MasterItems = require('scripts/backend/master_items')

local BetterBuffManagementWindow = class('BetterBuffManagementWindow')

function BetterBuffManagementWindow:init()
    self._is_open = false
    -- self._items = {}
    -- self._icon_cache = {}
    -- self._buffs = {}
    -- self._num_buffs = 0
    -- self._page = 1
    -- self._search = ''

    -- self._items = MasterItems.get_cached()

    -- if self._num_buffs == 0 then
    --     for _, buff_template in pairs(BuffTemplates) do
    --         local hud_icon = self:_get_icon(buff_template)
    --         if hud_icon then
    --             self._num_buffs = self._num_buffs + 1
    --             self._buffs[buff_template.name] = buff_template
    --         end
    --     end
    -- end
end

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
-- ------ Private Functions ------
-- -------------------------------

function BetterBuffManagementWindow:_update_add_buff_direction_combo(widgets)
    if widgets then
        local widget = get_widget_by_setting_id(widgets, 'add_buff_direction')

        if widget then
            local items = widget.options
            local setting_value = mod:get('add_buff_direction')
            local selected_item = mod.find_table_by_key_value_pair(items, 'value', setting_value)
    
            if Imgui.begin_combo(mod:localize(widget.setting_id), selected_item.text) then
    
                for index, item in ipairs(items) do
                    local is_selected = item.value == selected_item.value
    
                    if Imgui.selectable(item.text, is_selected) then
                        mod:set('add_buff_direction', item.value)
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
    local old_flag = mod:get('toggle_hidden_buffs')
    local new_flag = Imgui.checkbox(mod:localize('toggle_hidden_buffs'), old_flag)

    if new_flag ~= old_flag then
        mod:set('toggle_hidden_buffs', new_flag)
    end
end

function BetterBuffManagementWindow:_update_reset_all_settings_button(widgets)
    if Imgui.button(mod:localize('reset_all_settings')) then
        reset_all_settings(widgets)
    end
end

function BetterBuffManagementWindow:_update_settings()
    local mod_widgets = mod:get_internal_data('options').widgets

    self:_update_add_buff_direction_combo(mod_widgets)
    self:_update_toggle_hidden_buffs_checkbox()
    self:_update_reset_all_settings_button(mod_widgets)

    Imgui.separator()
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

function BetterBuffManagementWindow:update()
    if self._is_open then
        mod:debug('open')
        local _, closed = Imgui.begin_window('Better Buff Managment Configuration', 'always_auto_resize')
        if closed then
            self:close()
        end

        self:_update_settings()

        Imgui.end_window()
    end
end

return BetterBuffManagementWindow
