local mod = get_mod('BetterBuffManagement')

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