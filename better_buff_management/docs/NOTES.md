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
            │   ├── hud_element_buff_bar_definitions.lua  # Definitions for how buff bars look/behave (Useful for changing source code variables)
            │   └── hud_element_buff_bar_settings.lua     # Hardcoded settings for custom buff bar
            ├── lib/
            │   ├── buffs_provider.lua                    # Loads and caches all buff data from BUFF_TEMPLATES with optimized lookups
            │   └── buff_bars_provider.lua                # Manages user-configured buff bar collections, handles save/load
            ├── models/
            │   ├── buff_bar.lua                          # Data model for a buff bar (filter, direction, alignment)
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
                ├── profile.lua                           # Performance profiling utilities
                ├── string.lua                            # String utilities
                └── table.lua                             # Table utilities
```

## Architecture Notes

### Performance & Reload Optimization

The mod uses several patterns to ensure fast loading and stable mod reloads (CTRL+SHIFT+R):

1. **Persistent Tables** (`mod:persistent_table()`)

   - Provider instances (`buffs_provider`, `bars_provider`) are cached across reloads
   - Buff data indices (`child_parent_index`, `trait_icon_index`, `buffs_cache`) survive reloads
   - This prevents expensive re-computation of ~1000+ buff templates on each reload

2. **Initialization Guards**

   - All utility files use guards like `if mod._xyz_initialized then return end`
   - Prevents function redefinition and avoids stacking wrapped functions
   - Critical for utilities that modify globals (`table`, `string`, `_G`)

3. **Pre-computed Lookup Indices**
   - `BuffsProvider` builds O(1) lookup tables instead of O(n) searches
   - `_child_to_parent`: Maps child buff names to parent template names
   - `_trait_to_icon`: Maps trait names to icon paths from MASTER_ITEMS

### Data Flow

```
Game Load
    │
    ├─► better_buff_management.lua (entry point)
    │       │
    │       ├─► BuffsProvider:new() ──► Builds indices, caches all buff data
    │       │
    │       └─► BuffBarsProvider:new() ──► Loads user bar configs from settings
    │
    ├─► UIHud:init hook ──► Injects custom buff bar definitions
    │
    └─► UIHud:_add_element hook ──► Creates HudElementBuffBar instances
```

### Settings Storage

- `buffs_data` - Legacy format (v1.x), per-buff settings
- `buff_bars` - New format (v2.x), bar-centric with filters
- `BuffBarsProvider:smart_load_buff_bars()` auto-migrates from legacy format

## Extension Guide

Some features that should be relatively easy to add include things like:

- **Mod level buff filtering** (i.e. filtering a set of buffs for everyone that uses the mod)

  - Modify `BuffsProvider:_populate_buffs()` to skip certain buff names
  - Or filter in `BuffBarsProvider` before exposing to UI

- **Changing position, direction, order buffs appear** (i.e. making buffs load right to left, middle out, etc)
  - The custom buff bar implementation in `hud/hud_element_buff_bar.lua` can override draw logic
  - Add settings to `BuffBar` model for draw direction preferences

Some features that may require significant effort / refactoring:

- **Adding built in buff bar positioning** (i.e. not needing to use an external mod to change where bars live)

  - Requires integrating with the source code UI framework for positioning, resizing, opacity
  - No existing abstraction for this currently

- **Major ImGui changes**
  - ImGui documentation must be translated from ImGui manual + REFramework bindings
  - Consider building an abstraction layer for complex UI work

## Resources

- [Darktide Source Code Repo](https://github.com/Aussiemon/Darktide-Source-Code/tree/master)
- [Darktide Mod Framework Repo](https://github.com/Darktide-Mod-Framework/Darktide-Mod-Framework)
- [Darktide Mod Framework Docs](https://dmf-docs.darkti.de/)
- [ImGui Manual](https://pthom.github.io/imgui_manual_online/manual/imgui_manual.html)
- [ImGui Bindings](https://github.com/praydog/REFramework/blob/5b3bb27bbfce690821aaa96f3112a02cdab8d8f6/src/mods/bindings/ImGui.cpp#L1906)
