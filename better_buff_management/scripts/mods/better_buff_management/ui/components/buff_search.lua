local mod = get_mod('BetterBuffManagement')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/helpers/misc')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/ui/helpers/combo')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------
local GROUPINGS_SETTING_ID = 'bbm_groupings'
local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local UNHIDE_VISIBLE_ICONS_LOC_ID = 'unhide_all_icons'
local HIDE_VISIBLE_ICONS_LOC_ID = 'hide_all_icons'
local DESELECT_VISIBLE_ICONS_LOC_ID = 'unselect_all_icons'
local SELECT_VISIBLE_ICONS_LOC_ID = 'select_all_icons'
local SEARCH_LOC_ID = 'search'
local CLEAR_SEARCH_LOC_ID = 'clear_search'
local ADD_SELECTED_BUFFS_GROUP_LOC_ID = 'add_selected_buffs_group'
local ADD_SELECTED_BUFFS_BAR_LOC_ID = 'add_selected_buffs_bar'

local SEARCH_WINDOW_SIZE = { 0, 125 }
local BUFF_WINDOW_SIZE = { 75, 100 }
local BUFF_BUTTON_SIZE = { 64, 64 }

local BuffSearchComponent = {
    unhide_all = false,
    hide_all = false,
    unselect_all = false,
    select_all = false,
    search = '',
    selected_grouping_index = 1,
    selected_buff_bar_index = 1,
    add_to_group = false, 
    add_to_buff_bar = false
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function should_display_buff(buff_name)
    local lower_search = string.lower(BuffSearchComponent.search)
    return lower_search == '' or #lower_search > 0 and string.find(buff_name, lower_search)
end

local function filter_out_buffs_in_groupings(buffs)
    local groupings = mod:get(GROUPINGS_SETTING_ID)

    local hidden_buffs = {}
    for _, grouping in ipairs(groupings) do
        for _, buff in ipairs(grouping.buffs) do
            hidden_buffs[buff] = true
        end
    end

    local filtered_buffs = {}
    for buff_name, buff in pairs(buffs) do
        if not hidden_buffs[buff_name] then
            filtered_buffs[buff_name] = buff
        end
    end

    return filtered_buffs
end

local function draw_inputs()
    BuffSearchComponent.unhide_all = Imgui.small_button(mod:localize(UNHIDE_VISIBLE_ICONS_LOC_ID))
    Imgui.same_line()
    BuffSearchComponent.hide_all = Imgui.small_button(mod:localize(HIDE_VISIBLE_ICONS_LOC_ID))

    BuffSearchComponent.unselect_all = Imgui.small_button(mod:localize(DESELECT_VISIBLE_ICONS_LOC_ID))
    Imgui.same_line()
    BuffSearchComponent.select_all = Imgui.small_button(mod:localize(SELECT_VISIBLE_ICONS_LOC_ID))

    BuffSearchComponent.search = Imgui.input_text(mod:localize(SEARCH_LOC_ID), BuffSearchComponent.search)
    Imgui.same_line()
    if Imgui.button(mod:localize(CLEAR_SEARCH_LOC_ID)) then
        BuffSearchComponent.search = ''
    end
end

local function draw_buff_button(search_item, cached_icon)
    local is_clicked = false
    if search_item:is_selected() then
        is_clicked = Imgui.image_button(cached_icon, BUFF_BUTTON_SIZE[1], BUFF_BUTTON_SIZE[2], 266, 200, 0, 1)
    else
        is_clicked = Imgui.image_button(cached_icon, BUFF_BUTTON_SIZE[1], BUFF_BUTTON_SIZE[2], 255, 255, 255, 1)
    end

    if is_clicked then
        search_item:clicked()
    end
end

local function draw_buff(buff_name, buff)
    Imgui.begin_child_window(buff_name .. '_search_child_window', BUFF_WINDOW_SIZE[1], BUFF_WINDOW_SIZE[2], false)

    draw_buff_button(buff.data:get_search_item(), buff.template.cached_icon)

    buff.data.is_hidden = Imgui.checkbox('Hidden', buff.data.is_hidden or false)

    Imgui.end_child_window()

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(buff_name)
        Imgui.end_tool_tip()
    end
end

local function draw_buffs(buffs)
    local search = BuffSearchComponent.search

    local same_line_flag = 1
    Imgui.begin_child_window('buffs_search_child_window', SEARCH_WINDOW_SIZE[1], SEARCH_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')
    
    for buff_name, buff in pairs(buffs) do
        if same_line_flag > 1 then
            Imgui.same_line()
        end

        if buff.template and should_display_buff(buff_name, search) then
            draw_buff(buff_name, buff)
        end

        same_line_flag = same_line_flag + 1
    end

    Imgui.end_child_window()
end

local function draw_add_to_inputs()
    BuffSearchComponent.add_to_group = Imgui.button(mod:localize(ADD_SELECTED_BUFFS_GROUP_LOC_ID))
    Imgui.same_line()

    local groupings = mod:get(GROUPINGS_SETTING_ID)
    local groupings_names = mod.unpack_values_from_tables(groupings, 'name')
    BuffSearchComponent.selected_grouping_index = Imgui.draw_combo('     ', groupings_names, BuffSearchComponent.selected_grouping_index)

    BuffSearchComponent.add_to_buff_bar = Imgui.button(mod:localize(ADD_SELECTED_BUFFS_BAR_LOC_ID))
    Imgui.same_line()

    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
    local buff_bars_names = mod.unpack_values_from_tables(buff_bars, 'name')
    BuffSearchComponent.selected_buff_bar_index = Imgui.draw_combo('      ', buff_bars_names, BuffSearchComponent.selected_buff_bar_index)
end

local function toggle_hidden_for_visible_buffs(buffs, flag)
    local search = BuffSearchComponent.search
    for buff_name, buff in pairs(buffs) do    
        if should_display_buff(buff_name, search) then
            buff.data.is_hidden = flag
        end
    end
end

local function toggle_selected_for_visible_buffs(buffs, flag)
    local search = BuffSearchComponent.search
    for buff_name, buff in pairs(buffs) do    
        if should_display_buff(buff_name, search) then
            buff.data:get_search_item():toggle_selected(flag)
        end
    end
end

local function add_selected_to_table(targetTbl, buffs)
    for buff_name, buff in pairs(buffs) do
        if buff.data:get_search_item():is_selected() and not mod.table_contains_value(targetTbl, buff_name) then
            table.insert(targetTbl, buff_name)
        end
    end
end

local function is_buff_addible_to_group(buff_name, buff_data, buffs_tbl)
    return not buff_data.is_grouping and 
        buff_data:get_search_item():is_selected() and 
        not mod.table_contains_value(buffs_tbl, buff_name)
end

local function add_selected_to_grouping(buffs)
    local groupings = mod:get(GROUPINGS_SETTING_ID)
    local selected_group = groupings[BuffSearchComponent.selected_grouping_index - 1]

    if not selected_group.buffs then
        selected_group.buffs = {}
    end

    for buff_name, buff in pairs(buffs) do
        if is_buff_addible_to_group(buff_name, buff.data, selected_group.buffs) then
            table.insert(selected_group.buffs, buff_name)
        end
    end

    mod:dump({ selected_group.buffs, selected_group.selected_buff_index })

    if #selected_group.buffs > 0 and selected_group.selected_buff_index == 0 then
        selected_group.selected_buff_index = 1
        local grouping_id = mod.name_to_grouping_id(selected_group.name)
        buffs[grouping_id].template = buffs[selected_group.buffs[1]].template
    end

    BuffSearchComponent.selected_grouping_index = 1

    mod:set(GROUPINGS_SETTING_ID, groupings)
end

local function add_selected_to_buff_bar(buffs)
    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
    local selected_buff_bar = buff_bars[BuffSearchComponent.selected_buff_bar_index - 1]

    if not selected_buff_bar.buffs then
        selected_buff_bar.buffs = {}
    end

    add_selected_to_table(selected_buff_bar.buffs, buffs)
    BuffSearchComponent.selected_buff_bar_index = 1

    mod:set(BUFF_BARS_SETTING_ID, buff_bars)
end

local function clear_selected(buffs)
    for _, buff in pairs(buffs) do
        local search_item = buff.data:get_search_item()
        if search_item:is_selected() then
            search_item:toggle_selected(false)
        end
    end
end

local function update(buffs)
    if BuffSearchComponent.unhide_all then
        toggle_hidden_for_visible_buffs(buffs, false)
    elseif BuffSearchComponent.hide_all then
        toggle_hidden_for_visible_buffs(buffs, true)
    end

    if BuffSearchComponent.unselect_all then
        toggle_selected_for_visible_buffs(buffs, false)
    elseif BuffSearchComponent.select_all then
        toggle_selected_for_visible_buffs(buffs, true)
    end

    if BuffSearchComponent.add_to_group and BuffSearchComponent.selected_grouping_index > 1 then
        add_selected_to_grouping(buffs)
    elseif BuffSearchComponent.add_to_buff_bar then
        add_selected_to_buff_bar(buffs)
    end

    if BuffSearchComponent.add_to_group or BuffSearchComponent.add_to_buff_bar then
        clear_selected(buffs)
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BuffSearchComponent.draw = function(buffs)
    local filtered_buffs = filter_out_buffs_in_groupings(buffs)


    draw_inputs()
    draw_buffs(filtered_buffs)
    local add_to_group, add_to_buff_bar = draw_add_to_inputs()


    update(filtered_buffs)
end

return BuffSearchComponent