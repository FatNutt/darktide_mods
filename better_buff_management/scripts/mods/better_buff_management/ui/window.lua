local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/debug')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_component')

local BuffsProvider = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/lib/buffs_provider')
local BuffBarsProvider = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/lib/buff_bars_provider')

local SettingsComponent = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/ui/components/settings_component')
local BuffBarsComponent = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/ui/components/buff_bars_component')
local SearchComponent = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/ui/components/search_component')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'ManagementWindow'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local ManagementWindow = class(CLASS_NAME, 'BaseComponent')
function ManagementWindow:init(params)
    ManagementWindow.super.init(self)

    self._buffs_provider = params and params.buffs_provider or BuffsProvider:new()
    self._bars_provider = params and params.bars_provider or BuffBarsProvider:new()

    self.is_open = false
    self._first_open = true

    self._settings_component = nil
    self._buff_bars_component = nil
    self._search_component = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function ManagementWindow:_load_data()
    self._bars = self._bars_provider:smart_load_buff_bars()
end

function ManagementWindow:_save_data()
    self._bars_provider:save_buff_bars(self._bars)
    self._bars = nil
end

function ManagementWindow:_create_ui_components()
    local settings_widgets = mod:get_internal_data('options').widgets
    self._settings_component = SettingsComponent:new(settings_widgets)

    local component_params = {
        buffs_provider = self._buffs_provider,
        bars_provider = self._bars_provider,
        bars = self._bars,
    }
    self._buff_bars_component = BuffBarsComponent:new(component_params)
    self._search_component = SearchComponent:new(component_params)
end

function ManagementWindow:_destroy_ui_components()
    self._settings_component = nil
    self._buff_bars_component = nil
    self._search_component = nil
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function ManagementWindow:open()
    local input_manager = Managers.input
    local name = self.__class_name

    if not input_manager:cursor_active() then
        input_manager:push_cursor(name)
    end

    self:_load_data()
    self:_create_ui_components()

    self.is_open = true
    Imgui.open_imgui()
end

function ManagementWindow:close()
    local input_manager = Managers.input
    local name = self.__class_name

    if input_manager:cursor_active() then
        input_manager:pop_cursor(name)
    end

    self:_save_data()
    self:_destroy_ui_components()

    self.is_open = false
    Imgui.close_imgui()
end

function ManagementWindow:update()
    if self.is_open then
        if self._first_open then
            self._first_open = false
            Imgui.set_next_window_size(800, 500)
        end

        local _, closed = Imgui.begin_window(mod:localize('mod_name'))
        if closed then
            self:close()
        else
            self._settings_component:update()

            Imgui.separator()

            self._buff_bars_component:update()

            Imgui.separator()

            self._search_component:update()
        end
        Imgui.end_window()
    end
end

return ManagementWindow
