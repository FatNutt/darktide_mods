local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/debug')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/profile')

local BUFF_TEMPLATES = require('scripts/settings/buff/buff_templates')
local MASTER_ITEMS = require('scripts/backend/master_items')

local BuffData = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_data')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffsProvider'

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
local BuffsProvider = class(CLASS_NAME)
function BuffsProvider:init()
    self._cached_items = MASTER_ITEMS.get_cached()
    self._buffs = nil

    mod.profile_start('get_all_buffs()')

    self:get_all_buffs()

    mod.profile_end('get_all_buffs()')
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------
function BuffsProvider:_get_icon(buff_template)
    if buff_template.hide_icon_in_hud then
        return nil
    end

    if buff_template.hud_icon then
        return buff_template.hud_icon
    end

    local buff_name = buff_template.name

    if buff_name:find('_parent') then
        buff_name = buff_name:gsub('_parent', '')
    end

    local parent = table.find_by_key(BUFF_TEMPLATES, 'child_buff_template', buff_name)
    if parent then
        return BUFF_TEMPLATES[parent].hud_icon
    end

    if table.is_nil_or_empty(self._cached_items) then
        return nil
    end

    for _, item in pairs(self._cached_items) do
        if item.trait == buff_name then
            if item.icon and item.icon ~= '' then
                return item.icon
            end
        end
    end

    return nil
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffsProvider:get_all_buffs()
    if self._buffs == nil then
        self._buffs = {}

        for buffCategory, template in pairs(BUFF_TEMPLATES) do
            if not (buffCategory == "PREDICTED" or buffCategory == "NON_PREDICTED") then
                local icon = self:_get_icon(template)

                if icon and self._buffs[template.name] == nil then
                    self._buffs[template.name] = BuffData:new({
                        icon = icon
                    })
                end
            end
        end
    end

    return self._buffs
end

function BuffsProvider:try_get_buff(buff_name)
    if table.is_nil_or_empty(self._buffs) then
        return nil
    end

    return self._buffs[buff_name]
end

function BuffsProvider:validate_buff(buff_name)
    local template = table.find_by_key(BUFF_TEMPLATES, 'name', buff_name)

    return template and true or false
end

return BuffsProvider
