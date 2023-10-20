local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/misc')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/helpers/separator')

local BuffModData = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_mod_data')

local BetterBuffManagementSettingsComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/bbm_settings')
local BuffGroupingsComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/buff_groupings')
local BuffBarsComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/buff_bars')
local BuffSearchComponent = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/buff_search')

local BetterBuffManagementWindow = class('BetterBuffManagementWindow')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local BUFF_TEMPLATES = require('scripts/settings/buff/buff_templates')
local MASTER_ITEMS = require('scripts/backend/master_items')

local BUFF_MOD_DATA_SETTING_ID = 'bbm_buff_mod_data'
local GROUPINGS_SETTING_ID = 'bbm_groupings'

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

function BetterBuffManagementWindow:init()
    self._is_open = false
    self._search = ''
    self._cached_items = nil
    self._buffs = {}
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function BetterBuffManagementWindow:_load_grouping_buff_data()
    local groupings = mod:get(GROUPINGS_SETTING_ID)

    for _, grouping in ipairs(groupings) do
        local grouping_id = mod.name_to_grouping_id(grouping.name)
        local grouping_buff = self._buffs[grouping_id]

        if not grouping_buff then
            self._buffs[grouping_id] = { 
                template = nil, 
                data = BuffModData:new({ 
                    name = grouping.name:to_snake_case(),
                    display_name = grouping.name,
                    is_grouping = true
                })
            }
            grouping_buff = self._buffs[grouping_id]
        end

        if grouping.buffs and #grouping.buffs > 0 and grouping.selected_buff_index > 0 then
            grouping_buff.template = self._buffs[grouping.buffs[grouping.selected_buff_index]].template
        end
    end
end

function BetterBuffManagementWindow:_load_all_buff_templates()
    local cached_items = MASTER_ITEMS.get_cached()

    for _, buff_template in pairs(BUFF_TEMPLATES) do
        local hud_icon = get_icon(buff_template, cached_items)
        if hud_icon then
            buff_template.cached_icon = hud_icon

            if not self._buffs[buff_template.name] then
                self._buffs[buff_template.name] = { template = nil, data = BuffModData:new({ name = buff_template.name })}
            end

            self._buffs[buff_template.name].template = buff_template
        end
    end
end

function BetterBuffManagementWindow:_load_all_bbm_buff_data()
    self._buffs = {}

    local mod_data = mod:get(BUFF_MOD_DATA_SETTING_ID)

    if mod_data then
        for buff_name, buff_data in pairs(mod_data) do
            self._buffs[buff_name] = { template = nil, data = BuffModData:new(buff_data) }
        end
    end
end

function BetterBuffManagementWindow:_save_all_bbm_buff_data()
    local mod_data = {}

    -- Only save mod related data
    for buff_name, buff in pairs(self._buffs) do
        if buff.data:is_dirty() then
            mod_data[buff_name] = buff.data.get_save_data()
        end
    end

    mod:set(BUFF_MOD_DATA_SETTING_ID, mod_data)
end

function BetterBuffManagementWindow:_draw_buff_bars()
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

    self:_load_all_bbm_buff_data()

    self:_load_all_buff_templates()

    self:_load_grouping_buff_data()

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
        local _, closed = Imgui.begin_window(mod:localize('mod_name'), 'always_auto_resize')
        if closed then
            self:close()
        end

        local mod_widgets = mod:get_internal_data('options').widgets
        BetterBuffManagementSettingsComponent.draw(mod_widgets)

        Imgui.draw_custom_separator()

        local are_groupings_dirty = BuffGroupingsComponent.draw(self._buffs)

        Imgui.draw_custom_separator()

        local are_buff_bars_dirty = BuffBarsComponent.draw(self._buffs)

        Imgui.draw_custom_separator()

        BuffSearchComponent.draw(self._buffs)

        Imgui.end_window()

        return are_groupings_dirty, are_buff_bars_dirty
    end
end

return BetterBuffManagementWindow
