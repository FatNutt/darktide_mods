local mod = get_mod('BetterBuffManagement')

function mod.find_table_by_key_value_pair(arrayTbls, matchKey, matchValue)
    for _, tblValue in ipairs(arrayTbls) do
        if tblValue[matchKey] == matchValue then
            return tblValue
        end
    end
    return nil
end