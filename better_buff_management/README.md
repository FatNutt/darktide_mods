# Better Buff Management

## Todo
- Hide buffs from bars
- Actually use groupings
- Add setting to toggle default buff bar
- Fix size of hud elements
- Draw buffs based on direction
- Create buff bar huds dynamically
    - apply_material_values ERROR IS NOT CODE RELATED? AT LEAST NOT DIRECTLY? CHECK DUMP FILES AND OTHER CACHE STUFF
        - Maybe go back to dynamic if can figure out? IT WAS CAUSED BY DRAWING THE HUD REGARDLESS IF IN HUB.
- Stack buff bars upwards incase user doesn't have custom_hud
- Add extension function UIManager for recreating hud
- Sort options for buffs (Alphanumeric)
- Move grouping and buff_bar tracking to mod_data?

## Comments / Bugs
- Fix buffs displaying
    - Passive buffs not displaying
    - Some weapon blessings not showing
- Hitting 'Add selected buffs to bar' errors out if nothing is selected
- Add delete all buffs buff for buff bars / groupings
- Make config window resizable
- Disable config window in hub (only psychanium or in game)
