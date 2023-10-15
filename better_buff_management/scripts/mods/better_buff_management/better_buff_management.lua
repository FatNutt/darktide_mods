-- -------------------------------
-- --------- Definitions ---------
-- -------------------------------

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/helpers/string')

local BetterBuffManagementWindow = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/better_buff_managementWindow')


-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local configure_window = BetterBuffManagementWindow:new()

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function create_hud_element_definition(buff_bar)
    return {
        package = "packages/ui/hud/player_buffs/player_buffs",
        use_retained_mode = true,
        use_hud_scale = true,
        class_name = buff_bar.name:to_pascal_case(),
        filename = "BuffHUDImprovements/scripts/mods/BuffHUDImprovements/HudElementPriorityBuffs",
        visibility_groups = {
            "dead",
            "alive",
            "communication_wheel",
        }
    }
end

local function get_hud_elements_definitions()
    local hud_definitions = {}

    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)

    for _, bar in ipairs(buff_bars) do
        if bar.buffs and #bar.buffs > 0 then
            
        end
    end

    -- local hud_element = {
-- 	package = "packages/ui/hud/player_buffs/player_buffs",
-- 	use_retained_mode = true,
-- 	use_hud_scale = true,
-- 	class_name = "HudElementPriorityBuffs",
-- 	filename = "BuffHUDImprovements/scripts/mods/BuffHUDImprovements/HudElementPriorityBuffs",
-- 	visibility_groups = {
-- 		"dead",
-- 		"alive",
-- 		"communication_wheel",
-- 	},
-- }

-- mod:add_require_path(hud_element.filename)
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
    if configure_window and configure_window._is_open then
        configure_window:update()
    end
end


-- -------------------------------
-- ------------ Hooks ------------
-- -------------------------------

mod:hook('UIManager', 'using_input', function(func, ...)
    return configure_window._is_open or func(...)
end)

-- mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", function(elements)
--     if not table.find_by_key(elements, "class_name", ) then
--         table.insert(elements, hud_element)
--     end
-- end)

-- mod:hook_require("scripts/ui/hud/hud_elements_player", function(elements)
--     if not table.find_by_key(elements, "class_name", hud_element.class_name) then
--         table.insert(elements, hud_element)
--     end
-- end)
