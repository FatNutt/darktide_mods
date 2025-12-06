# Notes

These are general dev orientated notes of where things live and what they do.
Any specific descriptions will be left in the file themselves as comments.

## Overview

```
better_buff_management/
├── better_buff_management.mod                            # Mod metadata for Darktide Mod Loader (DON'T CHANGE)
└── scripts/
    └── mods/
        └── better_buff_management/
            ├── better_buff_management.lua                # Main entry point, sets up mod, hooks, and UI
            ├── better_buff_management_data.lua           # Mod configuration for loading via Darktide Mod Framework
            ├── better_buff_management_localization.lua   # Localization strings (UI text, etc.)
            ├── hud/
            │   ├── hud_element_buff_bar.lua              # Core logic for custom buff bar UI element (The Darktide source code component)
            │   ├── hud_element_buff_bar_definitions.lua  # Definitions for how buff bars look/behave (Usefule for changing source code variables)
            │   └── hud_element_buff_bar_settings.lua     # Hardcoded settings for custom buff bar
            ├── models/
            │   ├── buff_data.lua                         # Data model for buffs (structure, properties)
            │   └── search_item.lua                       # Model for tracking buff selection in ImGui
            ├── ui/
            │   ├── settings.lua                          # Some hardcoded values
            │   ├── window.lua                            # Main settings window for the mod (This is the entrypoint for ImGui stuff)
            │   └── components/
            │       ├── base_buff_component.lua           # Base ImGui component for displaying a buff
            │       ├── base_component.lua                # Base class for ImGui components
            │       ├── buff_bars_component.lua           # ImGui component for managing/displaying buff bars
            │       ├── search_component.lua              # ImGui for searching buffs
            │       └── settings_component.lua            # ImGui for settings controls
            └── utilities/
                ├── debug.lua                             # Debugging helpers/logging
                ├── global.lua                            # Global variables/utilities
                ├── imgui.lua                             # ImGui UI helpers
                ├── mod.lua                               # Mod loader helpers
                ├── string.lua                            # String utilities
                └── table.lua                             # Table utilities
```

Some more general information. Depending on the modification things should be relatively setup for easy extension / modification.

Some features that should be relatively easy to add include things like:

- Mod level buff filtering (i.e. filtering a set of buffs for everyone that uses the mod)
  - I would probably do this type of thing in `the better_buff_management.lua`. It handles saving & loading buff data out of user settings which would make it an easy place to catch any mod level buffs we want to filter.
  - There would need to be a slight change in the ImGui though to filter the buff before the user sees it in the user interface.
- Changing position, direction, order buffs appear (i.e. making buffs load right to left, middle out, etc)
  - Since a custom buff bar implementation was made its easy enough to override the default draw from the source code. Adding the correct draw function to `hud/hud_element_buff_bar.lua` and adjusting the draw positions on loop should solve most unique display needs.
  - The ImGui portion will need a settings addition to the buff data regarding how bars should be drawn but that should be straight forward enough.

Some features that may require significant effort / refactoring:

- Adding built in buff bar positioning (i.e. not needing to use an external mod to change where bars live)
  - This would require a larger effort mainly because there is no supporting code for positioning. The code utilizes the source code ui framework without an easy way to integrate further in ways such as, resizing, positioning, or changing opacity or other visuals.
- Changes to ImGui other than small bug fixes
  - This becomes a larger effort mainly due to the lack of a framework that makes integrating ImGui easier. ImGui is very flexible but most documentation has to be translated from the ImGui manual and the REFramework bindings. This makes implementing ImGui changes slightly more difficult.
  - The initial implementation was focused on getting something working without lots of abstraction. In the future I would love to implement a layer of abstraction between ImGui and building out the user interface, similar to how SPA applications abstract the writing of HTML, Javascript, and CSS from the actual UX implementation.

## Resources

- [Darktide Source Code Repo](https://github.com/Aussiemon/Darktide-Source-Code/tree/master)
- [DarktideMod Framework Repo](https://github.com/Darktide-Mod-Framework/Darktide-Mod-Framework)
- [DarktideMod Framework Docs](https://dmf-docs.darkti.de/)
- [ImGui Manual](https://pthom.github.io/imgui_manual_online/manual/imgui_manual.html)
- [ImGui Bindings](https://github.com/praydog/REFramework/blob/5b3bb27bbfce690821aaa96f3112a02cdab8d8f6/src/mods/bindings/ImGui.cpp#L1906)
