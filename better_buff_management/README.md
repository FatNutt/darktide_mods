# Better Buff Management

## Todo
- Draw custom buff bars
    - Buffs not being loaded
        - Created fake_require for buff bars specifically that reuses teh hud_element_buff_bar but replaces the class name
            - This is "working". No errors, hud elements appear. BUT NO BUFFS! Idk why
    - Filter buffs by proper buff bar (Use __class_name to find buff bar name)
    - Going to just try limiting buff bars to 3 bars max: NO CUSTOM NAMES
- Hide buffs from bars
- Add setting to toggle default buff bar
- Add extension function UIManager for recreating hud
- Stack buff bars upwards incase user doesn't have custom_hud
- Sort options for buffs (Alphanumeric)