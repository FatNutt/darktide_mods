return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`better_buff_management` encountered an error loading the Darktide Mod Framework.")

		new_mod("better_buff_management", {
			mod_script       = "better_buff_management/scripts/mods/better_buff_management/better_buff_management",
			mod_data         = "better_buff_management/scripts/mods/better_buff_management/better_buff_management_data",
			mod_localization = "better_buff_management/scripts/mods/better_buff_management/better_buff_management_localization",
		})
	end,
	packages = {},
}
