local mod = get_mod('BetterBuffManagement')

return {
    name = mod:localize('mod_name'),
    description = mod:localize('mod_description'),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = 'toggle_hidden_buffs',
                type = 'checkbox',
                default_value = false
            },
            {
                setting_id = 'add_buff_from',
                type = 'dropdown',
                default_value = 'end',
                options = {
                    { text = 'add_buff_from_option_end', value = 'end' },
                    { text = 'add_buff_from_option_middle', value = 'middle' },
                    { text = 'add_buff_from_option_start', value = 'start' }
                }
            }
        }
    }
}
