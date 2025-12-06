local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_component')

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BaseBuffComponent = class('BaseBuffComponent', 'BaseComponent')
function BaseBuffComponent:init(bars)
    BaseBuffComponent.super.init(self)
    self._bars = bars
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BaseBuffComponent:update()
    BaseBuffComponent.super.update(self)
end

return BaseBuffComponent
