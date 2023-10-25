local old_empty = table.is_empty
table.is_empty = function (tbl)
    return table.size(tbl) == 0 or old_empty(tbl)
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

function table.unpack_value(tbl, key)
    local retTbl = {}

    for _, value in pairs(tbl) do
        if value[key] then
            table.insert(retTbl, value[key])
        end
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
