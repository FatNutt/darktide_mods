require('scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling')

local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
local BuffBarDefinitions = mod:io_dofile(
'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_definitions')

-- Cache vanilla definitions for the temporary swap trick
local VanillaDefinitions = require(
    'scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_definitions'
)

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local HudElementBuffBar = class('HudElementBuffBar', 'HudElementPlayerBuffs')
function HudElementBuffBar:init(parent, draw_layer, start_scale, filter)
    -- The parent class re-requires vanilla definitions internally.
    -- Temporarily swap the vanilla scenegraph so the engine builds
    -- the live scenegraph from our values.
    local orig_scenegraph = VanillaDefinitions.scenegraph_definition
    local orig_widget_defs = VanillaDefinitions.widget_definitions
    local orig_buff_def = VanillaDefinitions.buff_widget_definition

    VanillaDefinitions.scenegraph_definition = BuffBarDefinitions.scenegraph_definition
    VanillaDefinitions.widget_definitions = BuffBarDefinitions.widget_definitions
    VanillaDefinitions.buff_widget_definition = BuffBarDefinitions.buff_widget_definition

    HudElementBuffBar.super.init(self, parent, draw_layer, start_scale, BuffBarDefinitions)

    -- Restore vanilla definitions immediately
    VanillaDefinitions.scenegraph_definition = orig_scenegraph
    VanillaDefinitions.widget_definitions = orig_widget_defs
    VanillaDefinitions.buff_widget_definition = orig_buff_def

    self._definitions = BuffBarDefinitions
    self._filter = filter
end

-- -------------------------------
-- ------- Event Functions -------
-- -------------------------------

function HudElementBuffBar:event_player_buff_added(player, buff_instance)
    if self._filter and self._filter[buff_instance._template_name] then
        HudElementBuffBar.super.event_player_buff_added(self, player, buff_instance)
    end
end

function HudElementBuffBar:event_player_buff_stack_added(player, buff_instance)
    if self._filter and self._filter[buff_instance._template_name] then
        HudElementBuffBar.super.event_player_buff_stack_added(self, player, buff_instance)
    end
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function HudElementBuffBar:_sync_current_active_buffs(buffs)
    if not buffs then
        return
    end

    ---@diagnostic disable-next-line: undefined-field
    local filtered_buffs = table.filter(buffs, function(buff)
        return self._filter and self._filter[buff._template_name]
    end)

    if table.is_nil_or_empty(filtered_buffs) then
        return
    end

    filtered_buffs = table.to_array(filtered_buffs)

    HudElementBuffBar.super._sync_current_active_buffs(self, filtered_buffs)
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function HudElementBuffBar:draw(dt, t, ui_renderer, render_settings, input_service)
    if mod:is_in_hub() then
        return
    end

    HudElementBuffBar.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementBuffBar
