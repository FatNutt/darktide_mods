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

local function validate_params(params)
    if type(params) ~= 'table' then
        error(ERRORS.PARAMS_NOT_TABLE, 1)
    end

    if table.size(params) == 0 then
        error(ERRORS.ALL_PARAMS_IS_MISSING, 1)
    end

    if string.is_nil_or_whitespace(params.name) then
        error(ERRORS.PARAMS_NAME_IS_MISSING, 1)
    end
end


-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffData = class(CLASS_NAME)
function BuffData:init(params)
    validate_params(params)

    self.name = params.name
    self.icon = params.icon
    self.is_hidden = params.is_hidden or false
    self.bar_name = params.bar_name
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffData:save_data()
    return { name = self.name, is_hidden = self.is_hidden, bar_name = self.bar_name }
end

function BuffData:toggle_hidden()
    self.is_hidden = not self._is_hidden
end

return BuffData