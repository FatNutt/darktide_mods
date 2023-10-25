local mod = get_mod('better_buff_management')

local MOD_NAME = mod:localize('mod_name')

local ERRORS = {
    UPDATE_NOT_IMPLEMENTED = ('[%s][%s] %s:update is not implemented'):format(MOD_NAME, '%s', '%s')
}


-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BaseComponent = class('BaseComponent')
function BaseComponent:init()
end


-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BaseComponent:update()
    error(ERRORS.UPDATE_NOT_IMPLEMENTED:format(self.__class_name, self.__class_name))
end

return BaseComponent