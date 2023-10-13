local mod = get_mod('BetterBuffManagement')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/ui/helpers/combo')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local GROUPINGS_SETTING_ID = 'bbm_groupings'

local CREATE_GROUPING_BUTTON_LOC_ID = 'create_grouping_button'
local DELETE_GROUPING_BUTTON_LOC_ID = 'delete_grouping_button'
local REMOVE_BUFF_FROM_GROUPING_LOC_ID = 'remove_buff_from_grouping'
local GROUPING_NAME_LOC_ID = 'grouping_name'
local ADD_GROUPING_LOC_ID = 'add_grouping'

local ADD_GROUPING_POPUP_ID = 'add_grouping_popup'

local GROUPING_WINDOW_SIZE = { 0, 125 }
local BUFF_WINDOW_SIZE = { 75, 100 }
local BUFF_IMAGE_SIZE = { 64, 64 }

local BuffGroupingsComponent = {
    add_grouping_name = '',
    selected_grouping_index = 1
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
local function draw_add_grouping()
    local add_grouping = Imgui.button(mod:localize(CREATE_GROUPING_BUTTON_LOC_ID))
    Imgui.same_line()
    BuffGroupingsComponent.add_grouping_name = Imgui.input_text('', BuffGroupingsComponent.add_grouping_name)

    return add_grouping
end

local function draw_delete_grouping(groupings)
    local delete_group = Imgui.button(mod:localize(DELETE_GROUPING_BUTTON_LOC_ID))
    Imgui.same_line()

    local groupings_names = mod.unpack_values_from_tables(groupings, 'name')
    BuffGroupingsComponent.selected_grouping_index = Imgui.draw_combo('  ', groupings_names, BuffGroupingsComponent.selected_grouping_index)

    return delete_group
end

local function draw_groupings_inputs(groupings)
    local dirty = false

    local add_group = draw_add_grouping()
    local delete_group = draw_delete_grouping(groupings)

    if add_group or delete_group then
        dirty = true
    end

    for index, grouping in ipairs(groupings) do
        if index > 1 then
            Imgui.same_line()
        end

        local old_flag = grouping.edit or false
        grouping.edit = Imgui.checkbox(grouping.name, old_flag)

        if grouping.edit ~= old_flag then
            dirty = true
        end
    end

    return dirty, add_group, delete_group
end

local function draw_buff(grouping_name, buff)
    local grouping_id = mod.string_to_id(grouping_name)

    Imgui.begin_child_window(buff.template.name .. '_' .. grouping_id .. '_child_window', BUFF_WINDOW_SIZE[1], BUFF_WINDOW_SIZE[2], false)

    Imgui.image_button(buff.template.cached_icon, BUFF_IMAGE_SIZE[1], BUFF_IMAGE_SIZE[2], 255, 255, 255, 1)

    local remove = Imgui.button(mod:localize(REMOVE_BUFF_FROM_GROUPING_LOC_ID))

    Imgui.end_child_window()

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(buff.template.name)
        Imgui.end_tool_tip()
    end

    return remove
end

local function draw_buffs(grouping, buffs)
    local buffs_to_remove = {}

    if grouping.buffs then
        local same_line_flag = 1
        for _, buff_name in ipairs(grouping.buffs) do
            if same_line_flag > 1 then
                Imgui.same_line()
            end

            local remove_buff = draw_buff(grouping.name, buffs[buff_name])

            if remove_buff then
                table.insert(buffs_to_remove, buff_name)
            end

            same_line_flag = same_line_flag + 1
        end
    end

    return buffs_to_remove
end

local function draw_grouping(grouping, buffs)
    local dirty = false

    if Imgui.collapsing_header(grouping.name) then
        local child_window_id = grouping.name .. '_child_window'

        Imgui.begin_child_window(child_window_id, GROUPING_WINDOW_SIZE[1], GROUPING_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')

        local buffs_to_remove = draw_buffs(grouping, buffs)

        if #buffs_to_remove > 0 then
            dirty = true
        end

        for _, buff_name in ipairs(buffs_to_remove) do
            local buff_index = mod.find_index_by_value(grouping.buffs, buff_name)

            if buff_index then
                table.remove(grouping.buffs, buff_index)
            end
        end

        Imgui.end_child_window()
    end

    return dirty
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BuffGroupingsComponent.draw = function(buffs)
    local groupings = mod:get(GROUPINGS_SETTING_ID)

    local is_dirty, add_group, delete_group = draw_groupings_inputs(groupings)

    for _, grouping in ipairs(groupings) do
        if grouping.edit then
            local grouping_is_dirty = draw_grouping(grouping, buffs)

            if grouping_is_dirty then
                is_dirty = true
            end
        end
    end

    if add_group then
        local new_grouping = {
            name = BuffGroupingsComponent.add_grouping_name,
            edit = false,
            buffs = {}
        }
        table.insert(groupings, new_grouping)
        BuffGroupingsComponent.add_grouping_name = ''
    end

    if delete_group and BuffGroupingsComponent.selected_grouping_index > 1 then
        table.remove(groupings, BuffGroupingsComponent.selected_grouping_index - 1)
        BuffGroupingsComponent.selected_grouping_index = 1
    end

    if is_dirty then
        mod:set(GROUPINGS_SETTING_ID, groupings)
    end
end

return BuffGroupingsComponent