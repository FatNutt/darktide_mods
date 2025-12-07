local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/debug')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

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
local function update_filter(filter)
    for _, buff_name in ipairs(filter) do
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
function BuffBarsProvider:init(buffs_provider)
    self._buffs_provider = buffs_provider or BuffsProvider:new()
    self._bars = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

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
                bars[buff_data.bar_name] = BuffBar:new()
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

        update_filter(bar.filter)

        table.insert(bars, bar_name, bar)
    end
    return bars
end

function BuffBarsProvider:smart_load_buff_bars()
    if self._bars == nil then
        local start_time = os.clock()

        if true or mod:get(BUFFS_DATA_SETTING_ID) and not mod:get(BUFF_BARS_SETTING_ID) then
            self._bars = self:load_from_old_buff_bars()
        else
            self._bars = self:load_buff_bars()
        end

        local end_time = os.clock()
        local execution_time_ms = (end_time - start_time) * 1000
        print(string.format("Buff bars loading took %.2f milliseconds", execution_time_ms))
    end
    return self._bars
end

function BuffBarsProvider:save_buff_bars()
    local save_data = {}

    if not table.is_nil_or_empty(self._bars) then
        for bar_id, data in pairs(self._bars) do
            if not string.is_nil_or_whitespace(data.bar_name) then
                save_data[bar_id] = data:save_data()
            end
        end
    end

    mod:set(BUFF_BARS_SETTING_ID, save_data)
end

return BuffBarsProvider
