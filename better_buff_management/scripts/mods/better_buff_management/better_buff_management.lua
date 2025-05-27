local HudElementsDefinitions = require('scripts/ui/hud/hud_elements_player')

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/mod')
local HudElementBuffBar = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

local management_window = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/window'):new()

local BUFFS_DATA_SETTING_ID = 'buffs_data'
local BARS_SETTING_ID = 'bars'
local TOGGLE_DEFAULT_BAR_SETTING_ID = 'toggle_default_bar'

local HUD_ELEMENT_PLAYER_BUFFS = 'HudElementPlayerBuffs'
local _, PlayerBuffsDefinition = table.find_by_key(HudElementsDefinitions, 'class_name', HUD_ELEMENT_PLAYER_BUFFS)

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function recreate_hud()
    local ui_manager = Managers.ui
    if ui_manager then

        local hud = ui_manager._hud
        if hud then
            local player_manager = Managers.player
            local player = player_manager:local_player(1)
            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            ui_manager:destroy_player_hud()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

local function remove_buff_bar_hud_definitions(definitions)
    repeat
        local index = table.index_of_condition(definitions, function(definition)
            return definition.class_name:starts_with('HudElementBuffBar')
        end)

        if index > 0 then
            table.remove(definitions, index)
        end

    until index == -1
    definitions = table.to_array(definitions)
end

local function get_filter_for_bar(buffs_data, bar_name)
    local filter_data = table.filter(buffs_data, function(filter_data)
        return filter_data.bar_name == bar_name and not filter_data.is_hidden
    end)

    if table.is_nil_or_empty(filter_data) then
        return nil
    end

    return table.map(filter_data, function(_)
        return true
    end)
end

local function add_buff_bar_hud_definitions(definitions)
    local buffs_data = mod:get(BUFFS_DATA_SETTING_ID)
    local bars = mod:get(BARS_SETTING_ID)

    if not table.is_nil_or_empty(buffs_data) and not table.is_nil_or_empty(bars) then

        for _, bar_name in ipairs(bars) do
            table.insert(definitions, {
                package = 'packages/ui/hud/player_buffs/player_buffs',
                use_retained_mode = true,
                use_hud_scale = true,
                class_name = ('%s_%s'):format('HudElementBuffBar', string.to_pascal_case(bar_name)),
                filename = 'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar',
                visibility_groups = {
                    'dead',
                    'alive',
                    'communication_wheel'
                },
                buffs_filter = get_filter_for_bar(buffs_data, bar_name)
            })
        end
    end
end

local function add_or_remove_default_buff_bar(definitions)
    local index = table.index_of_condition(definitions, function(definition)
        return definition.class_name == HUD_ELEMENT_PLAYER_BUFFS
    end)

    if mod:get(TOGGLE_DEFAULT_BAR_SETTING_ID) then
        if index > 0 then
            table.remove(definitions, index)
        end
    elseif not mod:is_in_hub() then
        if index <= 0 then
            table.insert(definitions, PlayerBuffsDefinition)
        end
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

mod.configure_buffs = function()
    if management_window.is_open then
        management_window:close()
        recreate_hud()
    elseif not mod:is_in_hub() then
        recreate_hud()
        management_window:open()
    end
end

mod.on_setting_changed = function(setting_id)
    if setting_id == TOGGLE_DEFAULT_BAR_SETTING_ID then
        recreate_hud()
    end
end

mod.update = function()
    management_window:update()
end

-- -- -------------------------------
-- -- ------------ Hooks ------------
-- -- -------------------------------

mod:hook('UIManager', 'using_input', function(func, ...)
    return management_window.is_open or func(...)
end)

mod:hook('UIHud', 'init', function(func, self, definitions, visibility_groups, params)
    add_or_remove_default_buff_bar(definitions)

    remove_buff_bar_hud_definitions(definitions)
    add_buff_bar_hud_definitions(definitions)

    return func(self, definitions, visibility_groups, params)
end)

mod:hook('UIHud', '_add_element', function(func, self, definition, elements, elements_array)
    if definition.class_name:starts_with('HudElementBuffBar') then
        local draw_layer = 0
        local hud_scale = definition.use_hud_scale and (self._hud_scale ~= nil and self:_hud_scale()) or RESOLUTION_LOOKUP.scale
        local hud_element = HudElementBuffBar:new(self, draw_layer, hud_scale, definition.buffs_filter)
        hud_element.__class_name = definition.class_name
        elements[definition.class_name] = hud_element
        table.insert(elements_array, hud_element)
    else
        func(self, definition, elements, elements_array)
    end
end)
