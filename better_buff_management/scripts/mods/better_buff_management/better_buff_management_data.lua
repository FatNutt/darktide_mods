local mod = get_mod('better_buff_management')

return {
    name = mod:localize('mod_name'),
    description = mod:localize('mod_description'),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = 'configure_buffs',
                type = 'keybind',
                default_value = {},
                keybind_global = false,
                keybind_trigger = 'pressed',
                keybind_type = 'function_call',
                function_name = 'configure_buffs'
            },
            -- {
            --     setting_id = 'add_buff_direction',
            --     type = 'dropdown',
            --     default_value = 'end',
            --     options = {
            --         { text = 'add_buff_direction_option_end', value = 'end' },
            --         { text = 'add_buff_direction_option_middle', value = 'middle' },
            --         { text = 'add_buff_direction_option_start', value = 'start' }
            --     }
            -- },
            -- {
            --     setting_id = 'toggle_hidden_buffs',
            --     type = 'checkbox',
            --     default_value = false
            -- },
            {
                setting_id = 'toggle_default_bar',
                type = 'checkbox',
                default_value = false
            }
        }
    }
}
