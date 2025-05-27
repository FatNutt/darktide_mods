local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_component')

local BUFF_TEMPLATES = require('scripts/settings/buff/buff_templates')
local MASTER_ITEMS = require('scripts/backend/master_items')

local BuffData = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_data')

local SettingsComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/settings_component')
local BuffBarsComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/buff_bars_component')
local SearchComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/search_component')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'ManagementWindow'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
}

local BUFFS_DATA_SETTING_ID = 'buffs_data'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function get_icon(buff_template, cached_items)
    if buff_template.hide_icon_in_hud then
        return nil
    end

    if buff_template.hud_icon then
        return buff_template.hud_icon
    end

    local buff_name = buff_template.name

    if buff_name:find('_parent') then
        buff_name = buff_name:gsub('_parent', '')
    end

    local parent = table.find_by_key(BUFF_TEMPLATES, 'child_buff_template', buff_name)
    if parent then
        return BUFF_TEMPLATES[parent].hud_icon
    end

    for _, item in pairs(cached_items) do
        if item.trait == buff_name then
            if item.icon and item.icon ~= '' then
                return item.icon
            end
        end
    end

    return nil
end


-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local ManagementWindow = class(CLASS_NAME, 'BaseComponent')
function ManagementWindow:init()
    ManagementWindow.super.init(self)

    self.is_open = false
    self._first_open = true
    self._buffs_data = nil

    self._settings_component = nil
    self._buff_bars_component = nil
    self._search_component = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function ManagementWindow:_load_buffs_data()
    local buffs_data = {}
    local raw_buffs_data = mod:get(BUFFS_DATA_SETTING_ID)

    -- Go through buffs and make sure they are still in the game
    if not table.is_nil_or_empty(raw_buffs_data) then
        for key, data in pairs(raw_buffs_data) do
            local template = table.find_by_key(BUFF_TEMPLATES, 'name', data.name)

            if template then -- if there is a template, then the buff is still in the game
                buffs_data[key] = BuffData:new(data)
            end
        end
    end

    -- Go through templates and either update icons or add new buffs with icons not in save data
    local cached_items = MASTER_ITEMS.get_cached()

    for buffCategory, template in pairs(BUFF_TEMPLATES) do
        if not (buffCategory == "PREDICTED" or buffCategory == "NON_PREDICTED") then 
          local icon = get_icon(template, cached_items)

          if icon then
              if buffs_data[template.name] == nil then
                  buffs_data[template.name] = BuffData:new({
                      name = template.name,
                      icon = icon
                  })
              else
                  buffs_data[template.name].icon = icon
              end
          end
        end
    end

    self._buffs_data = buffs_data
end

function ManagementWindow:_save_buffs_data()
    local save_data = {}

    for _, data in pairs(self._buffs_data) do
        if not string.is_nil_or_whitespace(data.bar_name) then
          save_data[data.name] = data:save_data()
        end
    end

    mod:set(BUFFS_DATA_SETTING_ID, save_data)
    self._buffs_data = nil
end

function ManagementWindow:_create_ui_components()
    local settings_widgets = mod:get_internal_data('options').widgets
    self._settings_component = SettingsComponent:new(settings_widgets)
    self._buff_bars_component = BuffBarsComponent:new(self._buffs_data)
    self._search_component = SearchComponent:new(self._buffs_data)
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

    self:_load_buffs_data()
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

    self:_save_buffs_data()
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
    end
end

return ManagementWindow