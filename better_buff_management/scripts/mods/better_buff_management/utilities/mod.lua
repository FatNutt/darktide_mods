local dmf = get_mod('DMF')

local _io = dmf:persistent_table('_io')
_io.initialized = _io.initialized or false
if not _io.initialized then
  _io = dmf.deepcopy(Mods.lua.io)
end

local mod = get_mod('better_buff_management')

-- Local backup of the loadstring function
local _loadstring = Mods.lua.loadstring

local BUFF_BAR_FILE_PATH = 'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar.lua'
local HUD_ELEMENT_FILE_PATH = './../mods/' .. BUFF_BAR_FILE_PATH

local _fake_buff_bar_requires = {}

local function get_fake_class_name(fake_path)
    local fake_path_parts = fake_path:split('/')
    local raw_class_name = fake_path_parts[#fake_path_parts]
    local buff_bar_name = raw_class_name:gsub('hud_element_buff_bar_', ''):to_pascal_case('_')
    local fake_class_name = 'HudElementBuffBar' .. buff_bar_name
    return fake_class_name
end

local function buff_bar_require(fake_buff_bar_path)
    -- Check for the existence of the path
    local ff, err_io = _io.open(HUD_ELEMENT_FILE_PATH, 'r')
    if ff == nil then
        mod:error('[BetterBuffManagement]Error opening ' .. BUFF_BAR_FILE_PATH .. ': ' .. tostring(err_io))
        return false
    end
    ff:close()

    local fake_class_name = get_fake_class_name(fake_buff_bar_path)
    local fake_file_path = fake_buff_bar_path.. '.lua'

    -- Make this a safe call
    local status, result = pcall(function ()
        local f = _io.open(HUD_ELEMENT_FILE_PATH, 'r')
        local result = f:read('*all')

        result = result:gsub('HudElementBuffBar', fake_class_name)

        local func = _loadstring(result, fake_file_path)
        local retVal = func()
        return retVal
    end)

    -- If status is failed, notify the user and return false
    if not status then
        mod:error('[BetterBuffManagement]Error processing ' .. fake_file_path .. ': ' .. tostring(result))
        return false
    end

    return result
end

function mod:add_fake_buff_bar_require_path(fake_buff_bar_path)
    _fake_buff_bar_requires[fake_buff_bar_path] = true
end

function mod:clear_fake_buff_bar_require_paths()
    _fake_buff_bar_requires = {}
end

mod:hook(_G, 'require', function (func, path, ...)
    if _fake_buff_bar_requires[path] then
        return buff_bar_require(path)
    end

    return func(path, ...)
end)