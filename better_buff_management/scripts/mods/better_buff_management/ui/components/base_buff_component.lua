local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_component')

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BaseBuffComponent = class('BaseBuffComponent', 'BaseComponent')
function BaseBuffComponent:init(buffs_data)
    BaseBuffComponent.super.init(self)
    self._buffs_data = buffs_data
end


-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function BaseBuffComponent:_get_buffs_for_bar(buff_bar_name, buffs_data)
    if table.is_nil_or_empty(buffs_data) then
        buffs_data = self._buffs_data
    end

    if not table.is_nil_or_empty(buffs_data) then
        return table.filter(buffs_data, function(data)
            return data.name == buff_bar_name
        end)
    end

    return nil
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BaseBuffComponent:update()
    BaseBuffComponent.super.update(self)
end

return BaseBuffComponent