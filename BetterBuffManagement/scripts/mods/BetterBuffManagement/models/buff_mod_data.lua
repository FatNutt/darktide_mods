local mod = get_mod('BetterBuffManagement')

local SearchItem = mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/models/search_item')
local BuffModData = class('BuffModData')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function is_private(key)
    return string.find(key, '^_') == 1
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------

function BuffModData:init(params)
    if params == nil then
        params = {}
    end

    if type(params) ~= 'table' then
        error('params must be a table', 2)
    end

    self._name = params.name
    self.display_name = params.display_name

    if string.is_null_or_whitespace(self.display_name) then
        self.display_name = name
    end

    self.is_hidden = params.is_hidden or false
    self.is_grouping = params.is_grouping or false
    self._meta = {
        search_item = SearchItem:new()
    }
end

-- -------------------------------
-- ---- Overloaded Functions -----
-- -------------------------------

-- function BuffModData:__newindex(key, value)
--     if key ~= '__newindex' then
--         self[key] = value
--     end
--     if not is_private(key) then
--         self._dirty = true
--     end
-- end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Getter Functions ------
-- -------------------------------

function BuffModData:get_search_item()
    return self._meta.search_item
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffModData:is_dirty()
    return self._dirty
end

function BuffModData:get_save_data()
    local save_data = {}

    for key, value in pairs(self) do
        if type(value) ~= 'function' and not is_private(key) then
            save_data[key] = value
        end
    end

    return save_data
end

return BuffModData