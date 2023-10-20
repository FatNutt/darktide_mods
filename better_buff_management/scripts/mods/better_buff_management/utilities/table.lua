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