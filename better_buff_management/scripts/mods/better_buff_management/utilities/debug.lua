local mod = get_mod('better_buff_management')

function mod.dump_keys_from_table(tbl)
    local dump_tbl = {}

    for key, _ in pairs(tbl) do
        table.insert(dump_tbl, key)
    end

    mod:dump(dump_tbl)
end

function mod.dump_value_from_table(tbl, key)
    local dump_tbl = {}

    for _, value in pairs(tbl) do
        table.insert(dump_tbl, tbl[key])
    end

    mod:dump(dump_tbl)
end

local function unpack_values(val, layer, max_layer, skip_keys)
    max_layer = type(max_layer) == 'number' and max_layer or 3
    layer = type(layer) == 'number' and layer or max_layer
    skip_keys = skip_keys or {}

    if val == nil then
        return "nil"
    end

    if type(val) ~= 'table' or layer >= max_layer then
        return tostring(val)
    end

    local indent = string.rep("    ", layer)
    local inner_indent = string.rep("    ", layer + 1)
    local result = "{\n"

    for key, value in pairs(val) do
        local key_str = tostring(key)
        if not skip_keys[key_str] then
            result = result ..
                inner_indent .. key_str .. " = " .. unpack_values(value, layer + 1, max_layer, skip_keys) .. ",\n"
        end
    end

    result = result .. indent .. "}"
    return result
end

function mod.stringify(val, max_layer, skip_keys)
    max_layer = type(max_layer) == 'number' and max_layer or 3
    skip_keys = type(skip_keys) == 'table' and skip_keys or {}

    -- Convert array to hash table for O(1) lookup
    local skip_hash = {}
    if type(skip_keys) == "table" and #skip_keys > 0 then
        for _, key in ipairs(skip_keys) do
            skip_hash[tostring(key)] = true
        end
    else
        skip_hash = skip_keys
    end

    return unpack_values(val, 0, max_layer, skip_hash)
end
