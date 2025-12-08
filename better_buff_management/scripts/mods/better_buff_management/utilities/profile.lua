local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

mod.profile_start = function(id)
    id = id or 'default'

    if table.is_nil_or_empty(mod.profiles) then
        mod.profiles = {}
    end

    mod.profiles[id] = os.clock()
end

mod.profile_end = function(id)
    id = id or 'default'

    if mod.profiles[id] == nil then
        return
    end

    local end_time = os.clock()
    local start_time = mod.profiles[id]
    local execution_time_ms = (end_time - start_time) * 1000

    print(("%s loading took %.3f milliseconds"):format(id, execution_time_ms))
end
