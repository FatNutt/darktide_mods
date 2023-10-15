local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/helpers/string')

function mod.name_to_grouping_id(name)
    return name:to_snake_case() .. '_grouping'
end

function mod.name_to_buff_bar_id(name)
    return name:to_snake_case() .. '_buff_bar'
end

function mod.find_index_by_value(arrayTbl, matchValue)
    for index, value in ipairs(arrayTbl) do
        if value == matchValue then
            return index
        end
    end

    return nil
end

function mod.find_index_by_key_value_pair(arrayTbls, matchKey, matchValue)
    for tblIndex, tblValue in ipairs(arrayTbls) do
        if type(tblValue) == 'table' and tblValue[matchKey] == matchValue then
            return tblIndex
        end
    end

    return nil
end

function mod.find_table_by_key_value_pair(arrayTbls, matchKey, matchValue)
    local tblIndex = mod.find_index_by_key_value_pair(arrayTbls, matchKey, matchValue)

    if tblIndex then
        return arrayTbls[tblIndex]
    end

    return nil
end

function mod.filter_array_by_key_value_pair(arrayTbls, matchKey, matchValue)
    local filteredTbl = {}

    for _, tblValue in ipairs(arrayTbls) do
        if tblValue[matchKey] and tblValue[matchKey] == matchValue then
            table.insert(filteredTbl, tblValue)
        end
    end

    return filteredTbl
end

function mod.unpack_values_from_tables(arrayTbls, key)
    local extractedTbl = {}

    for _, tblValue in ipairs(arrayTbls) do
        if tblValue[key] then
            table.insert(extractedTbl, tblValue[key])
        end
    end

    return extractedTbl
end

function mod.unpack_keys_from_table(tbl)
    local extractedTbl = {}

    for key, _ in pairs(tbl) do
        table.insert(extractedTbl, key)
    end

    return extractedTbl
end

function mod.table_contains_value(arrayTbls, matchValue)
    for _, value in ipairs(arrayTbls) do
        if value == matchValue then
            return true
        end
    end

    return false
end
