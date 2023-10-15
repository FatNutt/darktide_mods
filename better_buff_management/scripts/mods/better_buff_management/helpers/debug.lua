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