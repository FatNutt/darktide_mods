--[[
    BuffBarsProvider
    
    Manages the collection of user-configured buff bars.
    Handles loading/saving bar configurations from mod settings.
    
    Supports migration from legacy 'buffs_data' format to new 'buff_bars' format
    via smart_load_buff_bars() which auto-detects and converts old data.
--]]

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/debug')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/profile')

local BuffBar = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_bar')

local BuffsProvider = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/lib/buffs_provider')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffBarsProvider'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    PARAMS_NOT_TABLE = ('%s constructor requires parameters passed via a table'):format(ERROR_PREFIX),
    PARAMS_TABLE_EMPTY = ('%s parameters table is empty'):format(ERROR_PREFIX),
    PARAMS_IS_MISSING = ('%s parameters.%s is missing'):format(ERROR_PREFIX, '%s'),
}

local BUFFS_DATA_SETTING_ID = 'buffs_data'
local BUFF_BARS_SETTING_ID = 'buff_bars'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffBarsProvider = class(CLASS_NAME)
function BuffBarsProvider:init(buffs_provider)
    self._buffs_provider = buffs_provider or BuffsProvider:new()
    self._bars = nil

    mod.profile_start('BuffBarsProvider:smart_load_buff_bars()')
    self:smart_load_buff_bars()
    mod.profile_end('BuffBarsProvider:smart_load_buff_bars()')
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------
function BuffBarsProvider:_update_filter(filter)
    for _, buff_name in ipairs(filter) do
        local buff = self._buffs_provider:try_get_buff(buff_name)

        if buff == nil then
            filter[buff_name] = nil
        end
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------
function BuffBarsProvider:load_from_old_buff_bars()
    local raw_buffs_data = mod:get(BUFFS_DATA_SETTING_ID)

    if table.is_nil_or_empty(raw_buffs_data) then
        return {}
    end

    local bars = {}
    for buff_name, buff_data in pairs(raw_buffs_data) do
        local buff = self._buffs_provider:try_get_buff(buff_name)

        if buff then
            if bars[buff_data.bar_name] == nil then
                bars[buff_data.bar_name] = BuffBar:new({
                    filter = {},
                    direction = BuffBar.DIRECTIONS.HORIZONTAL,
                    alignment = BuffBar.ALIGNMENTS.VERTICAL
                })
            end

            table.insert(bars[buff_data.bar_name].filter, buff_name)
        end
    end

    return bars
end

function BuffBarsProvider:load_buff_bars()
    local raw_bars_data = mod:get(BUFF_BARS_SETTING_ID)

    if table.is_nil_or_empty(raw_bars_data) then
        return
    end

    local bars = {}
    for bar_name, data in pairs(raw_bars_data) do
        local bar = BuffBar:new(data)

        self:_update_filter(bar.filter)

        bars[bar_name] = bar
    end
    return bars
end

-- Smart loader that handles migration between data formats:
-- - If old 'buffs_data' exists but new 'buff_bars' doesn't -> migrate from old format
-- - Otherwise -> load from new format (or empty if neither exists)
-- Only runs once per session; subsequent calls return cached _bars
function BuffBarsProvider:smart_load_buff_bars()
    if self._bars == nil then
        self._bars = {}

        if mod:get(BUFFS_DATA_SETTING_ID) and not mod:get(BUFF_BARS_SETTING_ID) then
            self._bars = self:load_from_old_buff_bars()
        else
            self._bars = self:load_buff_bars()
        end
    end
    return self._bars
end

function BuffBarsProvider:save_buff_bars()
    mod:set(BUFF_BARS_SETTING_ID, self._bars)
end

return BuffBarsProvider
