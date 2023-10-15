local mod = get_mod('BetterBuffManagement')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/ui/helpers/combo')

local BuffModData = mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/models/buff_mod_data')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local GROUPINGS_SETTING_ID = 'bbm_groupings'
local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local CREATE_GROUPING_BUTTON_LOC_ID = 'create_grouping_button'
local DELETE_GROUPING_BUTTON_LOC_ID = 'delete_grouping_button'
local REMOVE_BUFF_FROM_GROUPING_LOC_ID = 'remove_buff_from_grouping'
local GROUPING_NAME_LOC_ID = 'grouping_name'
local ADD_GROUPING_LOC_ID = 'add_grouping'

local GROUPING_WINDOW_SIZE = { 0, 125 }
local BUFF_WINDOW_SIZE = { 75, 100 }
local BUFF_BUTTON_SIZE = { 64, 64 }

local BuffGroupingsComponent = {
    add_grouping_name = '',
    selected_grouping_index = 0
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
local function id_to_grouping_id(id)
    return id .. '_grouping'
end

local function draw_add_grouping()
    local add_grouping = Imgui.button(mod:localize(CREATE_GROUPING_BUTTON_LOC_ID))
    Imgui.same_line()
    BuffGroupingsComponent.add_grouping_name = Imgui.input_text(' ', BuffGroupingsComponent.add_grouping_name)

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

local function draw_buff_button(is_selected, cached_icon)
    local is_clicked = false
    if is_selected then
        is_clicked = Imgui.image_button(cached_icon, BUFF_BUTTON_SIZE[1], BUFF_BUTTON_SIZE[2], 266, 200, 0, 1)
    else
        is_clicked = Imgui.image_button(cached_icon, BUFF_BUTTON_SIZE[1], BUFF_BUTTON_SIZE[2], 255, 255, 255, 1)
    end

    return is_clicked
end

local function draw_buff(grouping_id, is_selected, buff_name, cached_icon)
    Imgui.begin_child_window(buff_name .. '_' .. grouping_id .. '_child_window', BUFF_WINDOW_SIZE[1], BUFF_WINDOW_SIZE[2], false)

    local is_clicked = draw_buff_button(is_selected, cached_icon)

    local remove = Imgui.button(mod:localize(REMOVE_BUFF_FROM_GROUPING_LOC_ID))

    Imgui.end_child_window()

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(buff_name)
        Imgui.end_tool_tip()
    end

    return is_clicked, remove
end

local function draw_buffs(grouping, buffs)
    local buffs_to_remove = {}
    local is_dirty = false

    if grouping.buffs then
        local grouping_id = mod.string_to_id(grouping.name)
        local same_line_flag = 1
        for buff_index, buff_name in ipairs(grouping.buffs) do
            if same_line_flag > 1 then
                Imgui.same_line()
            end

            local is_selected = grouping.selected_buff_index == buff_index
            local select_buff, remove_buff = draw_buff(grouping_id, is_selected, buff_name, buffs[buff_name].template.cached_icon)

            if select_buff and not is_selected then
                grouping.selected_buff_index = buff_index
                is_dirty = true
            end

            if remove_buff then
                table.insert(buffs_to_remove, buff_name)
            end

            same_line_flag = same_line_flag + 1
        end
    end

    return is_dirty, buffs_to_remove
end

local function draw_grouping(grouping, buffs)
    local dirty = false
    local grouping_id = mod.name_to_grouping_id(grouping.name)

    if Imgui.collapsing_header(grouping.name) then
        local child_window_id = grouping_id .. '_child_window'

        Imgui.begin_child_window(child_window_id, GROUPING_WINDOW_SIZE[1], GROUPING_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')

        local is_dirty, buffs_to_remove = draw_buffs(grouping, buffs)

        if is_dirty then
            dirty = is_dirty
        end

        if #buffs_to_remove > 0 then
            dirty = true
        end

        for _, buff_name in ipairs(buffs_to_remove) do
            local buff_index = mod.find_index_by_value(grouping.buffs, buff_name)

            if buff_index then
                table.remove(grouping.buffs, buff_index)
            end

            if #grouping.buffs > 0 and buff_index == grouping.selected_buff_index then
                grouping.selected_buff_index = 1
                buffs[grouping_id].template = buffs[grouping.buffs[1]].template
            else
                grouping.selected_buff_index = 0
                buffs[grouping_id].template = nil
            end
        end

        Imgui.end_child_window()
    end

    return dirty
end

local function add_group_to_groupings(groupings, buffs)
    local new_grouping = {
        name = BuffGroupingsComponent.add_grouping_name,
        edit = false,
        buffs = {},
        selected_buff_index = 0
    }

    table.insert(groupings, new_grouping)
    buffs[mod.name_to_grouping_id(new_grouping.name)] = {
        template = nil,
        data = BuffModData:new({
            name = mod.name_to_grouping_id(new_grouping.name),
            display_name = new_grouping.name,
            is_grouping = true
        })
    }

    BuffGroupingsComponent.add_grouping_name = ''
end

local function delete_group_from_groupings(groupings, buffs)
    local grouping_index = BuffGroupingsComponent.selected_grouping_index - 1
    local grouping = groupings[grouping_index]
    local grouping_id = mod.name_to_grouping_id(grouping.name)

    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
    for _, bar in ipairs(buff_bars) do
        local buff_index = mod.find_index_by_value(bar.buffs, grouping_id)

        if buff_index then
            table.remove(bar.buffs, buff_index)
        end
    end
    mod:set(BUFF_BARS_SETTING_ID, buff_bars)

    buffs[grouping_id] = nil
    table.remove(groupings, grouping_index)
    BuffGroupingsComponent.selected_grouping_index = 1
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


    if add_group and not mod.string_is_null_or_whitespace(BuffGroupingsComponent.add_grouping_name) then
        add_group_to_groupings(groupings, buffs)
        is_dirty = true
    end

    if delete_group and BuffGroupingsComponent.selected_grouping_index > 1 then
        delete_group_from_groupings(groupings, buffs)
        is_dirty = true
    end

    if is_dirty then
        for _, grouping in ipairs(groupings) do
            local grouping_id = mod.name_to_grouping_id(grouping.name)
            if grouping.buffs and #grouping.buffs == 0 then
                buffs[grouping_id].template = nil
            end

            if grouping.buffs and #grouping.buffs > 0 and grouping.selected_buff_index > 0 then
                local grouping_buff = buffs[grouping_id]
                local selected_buff_name = grouping.buffs[grouping.selected_buff_index]

                grouping_buff.template = buffs[selected_buff_name].template
            end
        end

        mod:set(GROUPINGS_SETTING_ID, groupings)
    end
end

return BuffGroupingsComponent