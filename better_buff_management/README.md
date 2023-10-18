# Better Buff Management

## Todo
- Draw custom buff bars
    - Buffs not being loaded
        - Created fake_require for buff bars specifically that reuses teh hud_element_buff_bar but replaces the class name
            - Idk why this is necessary but simply getting the class object then manually changing __class_name wasn't working
        - Problem currently: require is hooked by DMF and that hook is happening before my hook
    - Filter buffs by proper buff bar (Use __class_name to find buff bar name)
- Add setting to toggle default buff bar
- Sort options for buffs (Alphanumeric)