local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffBar'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    PARAMS_NOT_TABLE = ('%s constructor requires parameters passed via a table'):format(ERROR_PREFIX),
    PARAMS_TABLE_EMPTY = ('%s parameters table is empty'):format(ERROR_PREFIX),
    PARAMS_IS_MISSING = ('%s parameters.%s is missing'):format(ERROR_PREFIX, '%s'),
}


-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
local function validate_params(params)
    if type(params) ~= 'table' then
        error(ERRORS.PARAMS_NOT_TABLE, 1)
    end

    if table.size(params) == 0 then
        error(ERRORS.PARAMS_TABLE_EMPTY, 1)
    end

    if params.filter == nil then
        error(ERRORS.PARAMS_IS_MISSING:format('filter'), 1)
    end

    if params.direction == nil then
        error(ERRORS.PARAMS_IS_MISSING:format('direction'), 1)
    end

    if params.alignment == nil then
        error(ERRORS.PARAMS_IS_MISSING:format('alignment'), 1)
    end
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffBar = class(CLASS_NAME)

BuffBar.DIRECTIONS = {
    HORIZONTAL = 'horizontal',
    VERTICAL = 'vertical'
}
BuffBar.ALIGNMENTS = {
    LEFT = 'left',
    RIGHT = 'right'
}

function BuffBar:init(params)
    validate_params(params)

    self.filter = params.filter
    self.direction = params.direction
    self.alignment = params.alignment
end

BuffBar.DEFAULT = BuffBar:new({
    filter = {},
    direction = BuffBar.DIRECTIONS.HORIZONTAL,
    alignment = BuffBar.ALIGNMENTS.VERTICAL
})

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------
function BuffBar:save_data()
    local filter_data = {}
    for buff_name, data in pairs(self.filter) do
        filter_data[buff_name] = data:save_data()
    end

    return {
        filter = filter_data,
        direction = self.direction,
        alignment = self.alignment
    }
end

return BuffBar
