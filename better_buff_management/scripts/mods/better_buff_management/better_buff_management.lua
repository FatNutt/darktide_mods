-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local BUFF_BAR_FILENAME = 'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar'
local BUFF_BAR_CLASS_NAME = 'HudElementBuffBar'

local GROUPINGS_SETTING_ID = 'bbm_groupings'
local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'


-- -------------------------------
-- ----- Requires / Imports ------
-- -------------------------------

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/mod')
mod:io_dofile(BUFF_BAR_FILENAME)

local BetterBuffManagementWindow = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/better_buff_management_window')


-- -------------------------------
-- --------- Definitions ---------
-- -------------------------------

local configure_window = BetterBuffManagementWindow:new()


-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function create_buff_bar_class_name(buff_bar_name)
    return BUFF_BAR_CLASS_NAME .. '' .. buff_bar_name:to_pascal_case()
end

local function create_buff_bar_file_name(buff_bar_name)
    return BUFF_BAR_FILENAME .. '_' .. buff_bar_name:to_snake_case()
end

local function create_hud_element_buff_bar_definition(buff_bar_name)
    if string.is_null_or_whitespace(buff_bar_name) then
        return nil
    end

    local buff_bar_class_name = create_buff_bar_class_name(buff_bar_name)
    local buff_bar_file_name = create_buff_bar_file_name(buff_bar_name)

    return {
        package = 'packages/ui/hud/player_buffs/player_buffs',
        use_retained_mode = true,
        use_hud_scale = true,
        class_name = buff_bar_class_name,
        filename = buff_bar_file_name,
        visibility_groups = {
            'dead',
            'alive',
            'communication_wheel'
        }
    }
end

local function get_hud_element_buff_bar_definitions()
    local buff_bar_definitions = {}
    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)

    for _, bar in ipairs(buff_bars) do
        if bar.buffs and #bar.buffs > 0 then
            local definition = create_hud_element_buff_bar_definition(bar.name)

            if definition then
                table.insert(buff_bar_definitions, definition)
            end
        end
    end

    return buff_bar_definitions
end

local function remove_buff_bars_from_elements(elements)
    local function is_buff_bar_element(element)
        return element and element.class_name:starts_with(BUFF_BAR_CLASS_NAME)
    end

    repeat
        local index = table.index_of_condition(elements, is_buff_bar_element)

        if index > 0 then
            table.remove(elements, index)
        end

    until index == -1
end

local function add_definitions_to_elements(buff_bar_definitions, elements)
    for _, definition in ipairs(buff_bar_definitions) do
        ---@diagnostic disable-next-line: undefined-field
        if not table.find_by_key(elements, 'class_name', definition.class_name) then
            mod:add_fake_buff_bar_require_path(definition.filename)
            table.insert(elements, definition)
        end
    end
end

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


-- -------------------------------
-- -------- Mod Functions --------
-- -------------------------------

mod.configure_buffs = function()
    if configure_window._is_open then
        configure_window:close()
    else
        configure_window:open()
    end
end

mod.update = function()
    local groupings = mod:get(GROUPINGS_SETTING_ID)
    if groupings == nil then
        mod:set(GROUPINGS_SETTING_ID, {})
    end
    
    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
    if buff_bars == nil then
        mod:set(BUFF_BARS_SETTING_ID, {})
    end

    if configure_window and configure_window._is_open then
        local are_groupings_dirty, are_buff_bars_dirty = configure_window:update()

        if are_groupings_dirty or are_buff_bars_dirty then

        end
    end
end

-- -------------------------------
-- ---------- Commands -----------
-- -------------------------------

mod:command('bbm_recreate_hud', 'Recreate the hud', function()
    recreate_hud()
end)

-- -------------------------------
-- ------------ Hooks ------------
-- -------------------------------

mod:hook('UIManager', 'using_input', function(func, ...)
    return configure_window._is_open or func(...)
end)

mod:hook('UIHud', 'init', function(func, self, elements, visibility_groups, params)
    remove_buff_bars_from_elements(elements)
    mod:clear_fake_buff_bar_require_paths()

    local buff_bar_definitions = get_hud_element_buff_bar_definitions()
    if buff_bar_definitions then
        add_definitions_to_elements(buff_bar_definitions, elements)
    end

    return func(self, elements, visibility_groups, params)
end)