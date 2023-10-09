return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BetterBuffManagement` encountered an error loading the Darktide Mod Framework.")

		new_mod("BetterBuffManagement", {
			mod_script       = "BetterBuffManagement/scripts/mods/BetterBuffManagement/BetterBuffManagement",
			mod_data         = "BetterBuffManagement/scripts/mods/BetterBuffManagement/BetterBuffManagement_data",
			mod_localization = "BetterBuffManagement/scripts/mods/BetterBuffManagement/BetterBuffManagement_localization",
		})
	end,
	packages = {},
}
