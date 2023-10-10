-- -------------------------------
-- --------- Definitions ---------
-- -------------------------------

local mod = get_mod('BetterBuffManagement')
local BetterBuffManagementWindow = mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/ui/BetterBuffManagementWindow')
local configure_window = BetterBuffManagementWindow:new()


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
