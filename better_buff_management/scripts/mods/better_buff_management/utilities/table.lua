if table._bbm_initalized then return end
table._bbm_initalized = true

local old_empty = table.is_empty
table.is_empty = function(tbl)
    return table.size(tbl) == 0 or old_empty(tbl)
end

function table.keys(tbl)
    local keys = {}

    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    return keys
end

function table.values(tbl)
    local values = {}

    for _, value in pairs(tbl) do
        table.insert(values, value)
    end

    return values
end

function table.is_nil_or_empty(tbl)
    return tbl == nil or table.is_empty(tbl)
end

function table.map(tbl, func)
    local retTbl = {}

    for key, value in pairs(tbl) do
        retTbl[key] = func(value)
    end

    return retTbl
end

function table.to_array(tbl)
    local array_tbl = {}

    for _, value in pairs(tbl) do
        table.insert(array_tbl, value)
    end

    return array_tbl
end

function table.is_array(tbl)
    if type(tbl) ~= 'table' then
        return false
    end

    local last_key = nil
    for key, _ in pairs(tbl) do
        if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 or (last_key ~= nil and last_key ~= key - 1) then
            return false
        end
        last_key = key
    end

    return true
end

function table.sorted_by_value(tbl, sort_func)
    local retTbl = {}
    for _, value in pairs(tbl) do
        table.insert(retTbl, value)
    end

    table.sort(retTbl, function(a, b)
        return sort_func(a, b)
    end)

    return retTbl
end

function table.sorted_by_keys(tbl, sort_func)
    local keys = table.keys(tbl)

    if sort_func then
        table.sort(keys, function(a, b)
            return sort_func(a, b)
        end)
    else
        table.sort(keys)
    end

    local retTbl = {}
    for _, key in pairs(keys) do
        table.insert(retTbl, { key = key, value = tbl[key] })
    end

    return retTbl
end
