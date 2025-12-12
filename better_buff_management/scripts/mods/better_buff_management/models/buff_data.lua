local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffData'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    PARAMS_NOT_TABLE = ('%s constructor requires parameters passed via a table'):format(ERROR_PREFIX),
    ALL_PARAMS_IS_MISSING = ('%s parameters missing "name" and "icon"'):format(ERROR_PREFIX),
    PARAMS_NAME_IS_MISSING = ('%s parameters.name is missing'):format(ERROR_PREFIX),
}


-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffData = class(CLASS_NAME)
function BuffData:init(params)
    self.icon = params ~= nil and params.icon ~= nil and params.icon or nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffData:save_data()
    return {}
end

return BuffData
