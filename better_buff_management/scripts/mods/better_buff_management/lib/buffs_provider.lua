--[[
    BuffsProvider

    Responsible for loading and caching all buff data from Darktide's BUFF_TEMPLATES.

    Performance Optimization:
    - Uses mod:persistent_table() to cache data across mod reloads (CTRL+SHIFT+R)
    - Pre-builds lookup indices for O(1) icon resolution instead of O(n) searches
    - Only populates buffs that have displayable icons

    The caching is critical because BUFF_TEMPLATES contains thousands of entries
    and iterating through them on every reload would cause exponential slowdown.
--]]

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

    mod.profile_start('BuffsProvider:_build_parent_lookup()')
    self:_build_parent_lookup()
    mod.profile_end('BuffsProvider:_build_parent_lookup()')

    mod.profile_start('BuffsProvider:_build_trait_index()')
    self:_build_trait_index()
    mod.profile_end('BuffsProvider:_build_trait_index()')

    mod.profile_start('BuffsProvider:_populate_buffs()')
    self:_populate_buffs()
    mod.profile_end('BuffsProvider:_populate_buffs()')
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------
-- Builds a reverse lookup: child_buff_template -> parent_name
-- This allows O(1) lookup when resolving icons for child buffs
-- Example: "some_buff" -> "some_buff_parent" so we can get parent's hud_icon
function BuffsProvider:_build_parent_lookup()
    if self._child_to_parent then return end

    self._child_to_parent = mod:persistent_table('child_parent_index')

    for name, template in pairs(BUFF_TEMPLATES) do
        if template.child_buff_template then
            self._child_to_parent[template.child_buff_template] = name
        end
    end
end

-- Builds lookup: trait_name -> icon_path from MASTER_ITEMS cache
-- Some buffs (especially weapon traits) get their icons from items rather than buff templates
-- This index enables O(1) icon lookup instead of scanning all items
function BuffsProvider:_build_trait_index()
    if self._trait_to_icon then return end

    self._trait_to_icon = mod:persistent_table('trait_icon_index')

    if table.is_nil_or_empty(self._cached_items) then return end

    for _, item in pairs(self._cached_items) do
        if item.trait and item.icon and item.icon ~= '' then
            self._trait_to_icon[item.trait] = item.icon
        end
    end
end

-- Resolves the display icon for a buff using priority-based fallback:
-- 1. Return nil if buff explicitly hides its icon
-- 2. Use buff's own hud_icon if defined
-- 3. Check if this is a child buff and use parent's icon
-- 4. Fall back to trait-based icon from MASTER_ITEMS
function BuffsProvider:_get_icon(buff_template)
    if buff_template.hide_icon_in_hud then
        return nil
    end

    if buff_template.hud_icon then
        return buff_template.hud_icon
    end

    local buff_name = buff_template.name

    -- Some buffs have "_parent" suffix but reference child templates
    if buff_name:find('_parent') then
        buff_name = buff_name:gsub('_parent', '')
    end

    -- Check if this buff is a child of another buff (use parent's icon)
    local parent_name = self._child_to_parent[buff_name]
    if parent_name then
        return BUFF_TEMPLATES[parent_name].hud_icon
    end

    -- Last resort: check if this buff name matches a weapon trait
    if table.is_nil_or_empty(self._trait_to_icon) then
        return nil
    end

    return self._trait_to_icon[buff_name]
end

function BuffsProvider:_populate_buffs()
    if self._buffs then return end

    self._buffs = mod:persistent_table('buffs_cache')

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

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffsProvider:get_all_buffs()
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
