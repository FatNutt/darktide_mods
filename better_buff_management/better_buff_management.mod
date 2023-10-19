return {
    run = function()
        fassert(rawget(_G, 'new_mod'), '`better_buff_management` encountered an error loading the Darktide Mod Framework.')

        local MOD_DATA_PATH = 'better_buff_management/scripts/mods/better_buff_management/better_buff_management_data'

        local mod = new_mod('better_buff_management', {
            mod_script       = 'better_buff_management/scripts/mods/better_buff_management/better_buff_management',
            mod_data         = MOD_DATA_PATH,
            mod_localization = 'better_buff_management/scripts/mods/better_buff_management/better_buff_management_localization',
        })

        local mod_data = mod:io_dofile(MOD_DATA_PATH)

        if mod_data then
            getmetatable(mod._data).__index['options'] = mod_data.options
        end
    end,
    packages = {},
}
