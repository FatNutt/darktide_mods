local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

-- Use DMF's loadstring backup to avoid sandbox issues
local _loadstring = Mods.lua.loadstring

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffBar'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
    PARAMS_NOT_TABLE = ('%s constructor requires parameters passed via a table'):format(ERROR_PREFIX),
    PARAMS_TABLE_EMPTY = ('%s parameters table is empty'):format(ERROR_PREFIX),
    PARAMS_IS_MISSING = ('%s parameters.%s is missing'):format(ERROR_PREFIX, '%s'),
    DESERIALIZE_INVALID = ('%s deserialize failed: invalid input'):format(ERROR_PREFIX),
    DESERIALIZE_PARSE_ERROR = ('%s deserialize failed: %%s'):format(ERROR_PREFIX),
}


-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- Escapes a key for use in a Lua table literal
-- Returns the key directly if it's a valid identifier, otherwise wraps appropriately
local function escape_key(key)
    local key_type = type(key)
    if key_type == 'number' then
        return string.format('[%d]', key)
    elseif key_type == 'string' then
        if key:match('^[%a_][%w_]*$') then
            return key
        else
            return string.format('["%s"]', key:gsub('\\', '\\\\'):gsub('"', '\\"'))
        end
    else
        return string.format('["%s"]', tostring(key))
    end
end

-- Converts a Lua value to its literal string representation
local function value_to_string(value)
    local t = type(value)
    if t == 'string' then
        return string.format('"%s"', value:gsub('\\', '\\\\'):gsub('"', '\\"'))
    elseif t == 'boolean' or t == 'number' then
        return tostring(value)
    elseif t == 'nil' then
        return 'nil'
    end
    return nil
end

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

-- Serializes the BuffBar to a Lua table literal string
-- @return string: The serialized BuffBar
function BuffBar:serialize()
    local parts = {}

    -- Serialize filter (array of buff name strings)
    local filter_parts = {}
    for _, buff_name in ipairs(self.filter) do
        table.insert(filter_parts, value_to_string(buff_name))
    end
    table.insert(parts, 'filter={' .. table.concat(filter_parts, ',') .. '}')

    -- Serialize direction and alignment
    table.insert(parts, 'direction=' .. value_to_string(self.direction))
    table.insert(parts, 'alignment=' .. value_to_string(self.alignment))

    return '{' .. table.concat(parts, ',') .. '}'
end

-- Deserializes a string into a BuffBar instance
-- @param str string: The serialized BuffBar string
-- @return BuffBar|nil: The deserialized BuffBar, or nil on error
-- @return string|nil: Error message if deserialization failed
function BuffBar.deserialize(str)
    if type(str) ~= 'string' or str == '' then
        return nil, ERRORS.DESERIALIZE_INVALID
    end

    -- Parse the Lua table literal using DMF's loadstring backup
    local chunk, err = _loadstring('return ' .. str)
    if not chunk then
        return nil, ERRORS.DESERIALIZE_PARSE_ERROR:format(err)
    end

    -- Execute in a protected call
    local success, data = pcall(chunk)
    if not success then
        return nil, ERRORS.DESERIALIZE_PARSE_ERROR:format(data)
    end

    if type(data) ~= 'table' then
        return nil, ERRORS.DESERIALIZE_INVALID
    end

    -- Create and return the BuffBar
    return BuffBar:new({
        filter = data.filter,
        direction = data.direction,
        alignment = data.alignment
    })
end

return BuffBar
