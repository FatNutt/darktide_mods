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

local BUFF_BARS_SETTING_ID = 'buff_bars'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
-- function ManagementWindow:_load_buff_bars()
--     local buff_bars = {}
--     local raw_buff_bars = mod:get(BUFF_BARS_SETTING_ID)

--     if table.is_nil_or_empty(raw_buff_bars) then
--         return
--     end

--     local buffs_with_no_template = {}
--     for key, bar in pairs(raw_buff_bars) do
--         if bar and bar['filter'] ~= nil then

--         end
--     end
-- end

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

return BuffBarsProvider
