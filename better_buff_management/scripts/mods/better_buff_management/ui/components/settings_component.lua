local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/imgui')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_component')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'SettingsComponent'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    UPDATE_REQUIRES_SETTINGS_WIDGET = ('%s func update requires a valid settings_widgets table'):format(ERROR_PREFIX),
    SETTINGS_WIDGETS_CANNOT_BE_EMPTY = ('%s settings_widgets table cannot be empty'):format(ERROR_PREFIX)
}

local BUFF_DIRECTION_SETTING_ID = 'add_buff_direction'
local TOGGLE_HIDDEN_SETTING_ID = 'toggle_hidden_buffs'
local TOGGLE_DEFAULT_BAR_SETTING_ID = 'toggle_default_bar'
local RESET_SETTIINGS_LOCALIZATION_ID = 'reset_all_settings'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function validate_settings_widgets(settings_widgets)
    if settings_widgets == nil then
        error(ERRORS.UPDATE_REQUIRES_SETTINGS_WIDGET, 1)
    end

    if table.is_empty(settings_widgets) then
        error(ERRORS.SETTINGS_WIDGETS_CANNOT_BE_EMPTY, 1)
    end
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local SettingsComponent = class(CLASS_NAME, 'BaseComponent')
function SettingsComponent:init(settings_widgets)
    SettingsComponent.super.init(self)
    validate_settings_widgets(settings_widgets)

    self._settings_widgets = settings_widgets
    -- self._direction_options = settings_widgets[table.find_by_key(settings_widgets, 'setting_id', BUFF_DIRECTION_SETTING_ID)].options

    self._buff_direction = mod:get(BUFF_DIRECTION_SETTING_ID)
    self._toggle_hidden = mod:get(TOGGLE_HIDDEN_SETTING_ID)
    self._toggle_default_bar = mod:get(TOGGLE_DEFAULT_BAR_SETTING_ID)
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- function SettingsComponent:_update_buff_direction()
--     local combo_items = table.map(self._direction_options, function(option)
--         return mod:localize(option.text)
--     end)

--     local current_index = table.find_by_key(self._direction_options, 'value', self._buff_direction)
--     local new_index = Imgui.combo(mod:localize(BUFF_DIRECTION_SETTING_ID), combo_items, current_index, false)

--     if new_index ~= current_index then
--         self._buff_direction = self._direction_options[new_index].value
--         mod:set(BUFF_DIRECTION_SETTING_ID, self._buff_direction)
--     end
-- end

-- function SettingsComponent:_update_toggle_hidden()
--     local new_flag = Imgui.checkbox(mod:localize(TOGGLE_HIDDEN_SETTING_ID), self._toggle_hidden)

--     if new_flag ~= self._toggle_hidden then
--         self._toggle_hidden = new_flag
--         mod:set(TOGGLE_HIDDEN_SETTING_ID, self._toggle_hidden)
--     end
-- end

function SettingsComponent:_update_toggle_default_bar()
    local new_flag = Imgui.checkbox(mod:localize(TOGGLE_DEFAULT_BAR_SETTING_ID), self._toggle_default_bar)

    if new_flag ~= self._toggle_default_bar then
        self._toggle_default_bar = new_flag
        mod:set(TOGGLE_DEFAULT_BAR_SETTING_ID, self._toggle_default_bar)
    end
end

function SettingsComponent:_update_reset_settings()
    if Imgui.button(mod:localize(RESET_SETTIINGS_LOCALIZATION_ID)) then
        for _, widget in ipairs(self._settings_widgets) do
            if widget.setting_id ~= 'configure_buffs' then
                mod:set(widget.setting_id, widget.default_value)
            end
        end
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function SettingsComponent:update()
    -- self:_update_buff_direction()
    -- self:_update_toggle_hidden()
    self:_update_toggle_default_bar()
    self:_update_reset_settings()
end

return SettingsComponent