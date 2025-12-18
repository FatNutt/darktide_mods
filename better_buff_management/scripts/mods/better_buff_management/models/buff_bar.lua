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
    RIGHT = 'right',
    UP = 'up',
    DOWN = 'down'
}

function BuffBar:init(params)
    self.filter = params ~= nil and params.filter ~= nil and params.filter or {}
    self.direction = params ~= nil and params.direction ~= nil and params.direction or BuffBar.DIRECTIONS.HORIZONTAL
    self.alignment = params ~= nil and params.alignment ~= nil and params.alignment or BuffBar.ALIGNMENTS.LEFT
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
