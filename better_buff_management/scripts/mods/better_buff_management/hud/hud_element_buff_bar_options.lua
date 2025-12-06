local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

local HudElementBuffBarOptions = class('HudElementBuffBarOptions')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

HudElementBuffBarOptions.DIRECTIONS = {
    HORIZONTAL = 1,
    VERTICAL = 2
}
HudElementBuffBarOptions.ALIGNMENTS = {
    LEFT = 1,
    RIGHT = 2
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------


local function get_filter_for_bar(buffs_data, bar_name)
    local filter_data = table.filter(buffs_data, function(filter_data)
        return filter_data.bar_name == bar_name and not filter_data.is_hidden
    end)

    if table.is_nil_or_empty(filter_data) then
        return nil
    end

    return table.map(filter_data, function(_)
        return true
    end)
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------

function HudElementBuffBarOptions:init(bar_name, buffs_data, buff_direction, buff_alignment)
    self.bar_name = bar_name or 'DefaultBuffBar'
    self.filter = get_filter_for_bar(buffs_data, bar_name)
    self.direction = buff_direction or self.DIRECTIONS.HORIZONTAL
    self.alignment = buff_alignment or self.ALIGNMENTS.LEFT
end

-- -------------------------------
-- ---- Overloaded Functions -----
-- -------------------------------

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------
function HudElementBuffBarOptions:refresh_filter(buff_data)
    self.filter = get_filter_for_bar(buff_data, self.bar_name)
end

return HudElementBuffBarOptions
