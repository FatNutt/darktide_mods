local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/mod')
mod:add_require_path('better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar')

local management_window = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/window'):new()

local BUFFS_DATA_SETTING_ID = 'buffs_data'

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
        return filter_data.name == bar_name and not filter_data.is_hidden
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

    if not table.is_nil_or_empty(buffs_data) then
        local raw_bars = table.filter(buffs_data, function(data)
            return data.bar_name
        end)
        local bars = table.to_array(table.set(raw_bars))

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
    remove_buff_bar_hud_definitions(definitions)
    add_buff_bar_hud_definitions(definitions)

    return func(self, definitions, visibility_groups, params)
end)

mod:hook('UiHud', '_add_element', function(func, self, definition, elements, elements_array)
    func(self, definition, elements, elements_array)

    if definition.class_name:starts_with('HudElementBuffBar') and elements[definition.class_name] then
        local hud_element = elements[definition.class_name]
        hud_element.__class_name = definition.class_name
        hud_element.load_buffs_filter(definition.buffs_filter)
    end
end)