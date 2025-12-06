local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

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
local function update_filter(filter)
    for buff_name, data in filter do
        local buff = BuffsProvider.try_get_buff(buff_name)

        if buff then
            filter[buff_name] = data
        end
    end
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffBarsProvider = class(CLASS_NAME)

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------
function BuffBarsProvider.load_from_old_buff_bars()
    local raw_buffs_data = mod:get(BUFFS_DATA_SETTING_ID)

    if table.is_nil_or_empty(raw_buffs_data) then
        return {}
    end

    local bars = {}
    for buff_name, data in pairs(raw_buffs_data) do
        local buff = BuffsProvider.try_get_buff(buff_name)
        if buff then
            if bars[data.bar_name] == nil then
                bars[data.bar_name] = {}
            end

            bars[data.bar_name] = BuffData:new(data)
        end
    end
    return bars
end

function BuffBarsProvider.load_buff_bars()
    local raw_bars_data = mod:get(BUFF_BARS_SETTING_ID)

    if table.is_nil_or_empty(raw_bars_data) then
        return
    end

    local bars = {}
    for bar_name, data in pairs(raw_bars_data) do
        update_filter(data.filter)

        table.insert(bars, bar_name, data)
    end
    return bars
end

function BuffBarsProvider.smart_load_buff_bars()
    if mod:get(BUFFS_DATA_SETTING_ID) and not mod:get(BUFF_BARS_SETTING_ID) then
        return BuffBarsProvider.load_from_old_buff_bars()
    else
        return BuffBarsProvider.load_buff_bars()
    end
end

function BuffBarsProvider.save_buff_bars(bars)
    local save_data = {}

    for bar_id, data in pairs(bars) do
        if not string.is_nil_or_whitespace(data.bar_name) then
            save_data[bar_id] = data:save_data()
        end
    end

    mod:set(BUFF_BARS_SETTING_ID, save_data)
end

return BuffBarsProvider
