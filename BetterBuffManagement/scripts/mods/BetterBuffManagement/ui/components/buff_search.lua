local mod = get_mod('BetterBuffManagement')
mod:io_dofile('BetterBuffManagement/scripts/mods/BetterBuffManagement/helpers/misc')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------
local GROUPINGS_SETTING_ID = 'bbm_groupings'
local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local ADD_SELECTED_BUFFS_GROUP_LOC_ID = 'add_selected_buffs_group'
local ADD_SELECTED_BUFFS_BAR_LOC_ID = 'add_selected_buffs_bar'
local UNHIDE_VISIBLE_ICONS_LOC_ID = 'unhide_all_icons'
local HIDE_VISIBLE_ICONS_LOC_ID = 'hide_all_icons'
local DESELECT_VISIBLE_ICONS_LOC_ID = 'unselect_all_icons'
local SELECT_VISIBLE_ICONS_LOC_ID = 'select_all_icons'

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

local function draw_inputs()
    BuffSearchComponent.unhide_all = Imgui.small_button(mod:localize(UNHIDE_VISIBLE_ICONS_LOC_ID))
    Imgui.same_line()
    BuffSearchComponent.hide_all = Imgui.small_button(mod:localize(HIDE_VISIBLE_ICONS_LOC_ID))

    BuffSearchComponent.unselect_all = Imgui.small_button(mod:localize(DESELECT_VISIBLE_ICONS_LOC_ID))
    Imgui.same_line()
    BuffSearchComponent.select_all = Imgui.small_button(mod:localize(SELECT_VISIBLE_ICONS_LOC_ID))

    BuffSearchComponent.search = Imgui.input_text("Search", BuffSearchComponent.search)
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

local function draw_buff(buff)
    Imgui.begin_child_window(buff.template.name .. '_search_child_window', BUFF_WINDOW_SIZE[1], BUFF_WINDOW_SIZE[2], false)

    draw_buff_button(buff.data:get_search_item(), buff.template.cached_icon)

    buff.data.is_hidden = Imgui.checkbox('Hidden', buff.data.is_hidden or false)

    Imgui.end_child_window()

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(buff.template.name)
        Imgui.end_tool_tip()
    end
end

local function draw_buffs(buffs)
    local search = BuffSearchComponent.search

    local same_line_flag = 1
    Imgui.begin_child_window('buffs_search_child_window', SEARCH_WINDOW_SIZE[1], SEARCH_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')
    
    for _, buff in pairs(buffs) do
        if same_line_flag > 1 then
            Imgui.same_line()
        end

        if search == '' or #search > 0 and string.find(buff.template.name, search) then
            draw_buff(buff)
        end

        same_line_flag = same_line_flag + 1
    end

    Imgui.end_child_window()
end

local function draw_combo(combo_name, combo_items, selected_index)
    local selected_grouping_text = ''

    if selected_index > 1 then
        selected_grouping_text = combo_items[selected_index - 1]
    end

    if Imgui.begin_combo(combo_name, selected_grouping_text) then
        if combo_items and #combo_items > 0 then
            local is_selected = selected_index == 1
            if Imgui.selectable('', is_selected) then
                selected_index = 1
            end

            if is_selected then
                Imgui.set_item_default_focus()
            end

            for index, item in ipairs(combo_items) do
                is_selected = index == selected_index - 1

                if Imgui.selectable(item, is_selected) then
                    selected_index = index + 1
                end

                if is_selected then
                    Imgui.set_item_default_focus()
                end
            end
        end

        Imgui.end_combo()
    end

    return selected_index
end

local function draw_add_to_inputs()
    BuffSearchComponent.add_to_group = Imgui.button(mod:localize(ADD_SELECTED_BUFFS_GROUP_LOC_ID))
    Imgui.same_line()

    local groupings = mod:get(GROUPINGS_SETTING_ID)
    local groupings_names = mod.unpack_values_from_tables(groupings, 'name')
    BuffSearchComponent.selected_grouping_index = draw_combo('', groupings_names, BuffSearchComponent.selected_grouping_index)

    BuffSearchComponent.add_to_buff_bar = Imgui.button(mod:localize(ADD_SELECTED_BUFFS_BAR_LOC_ID))
    Imgui.same_line()

    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
    local buff_bars_names = mod.unpack_values_from_tables(buff_bars, 'name')
    BuffSearchComponent.selected_buff_bar_index = draw_combo(' ', buff_bars_names, BuffSearchComponent.selected_buff_bar_index)
end

local function toggle_hidden_for_visible_buffs(buffs, flag)
    local search = BuffSearchComponent.search
    for _, buff in pairs(buffs) do    
        if search == '' or #search > 0 and string.find(buff.template.name, search) then
            buff.data.is_hidden = flag
        end
    end
end

local function toggle_selected_for_visible_buffs(buffs, flag)
    local search = BuffSearchComponent.search
    for _, buff in pairs(buffs) do    
        if search == '' or #search > 0 and string.find(buff.template.name, search) then
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
        local groupings = mod:get(GROUPINGS_SETTING_ID)
        local selected_group = groupings[BuffSearchComponent.selected_grouping_index - 1]

        if not selected_group.buffs then
            selected_group.buffs = {}
        end

        add_selected_to_table(selected_group.buffs, buffs)

        mod:set(GROUPINGS_SETTING_ID, groupings)
    elseif BuffSearchComponent.add_to_buff_bar then
        local buff_bars = mod:get(BUFF_BARS_SETTING_ID)
        local selected_buff_bar = buff_bars[BuffSearchComponent.selected_buff_bar_index - 1]

        if not selected_buff_bar.buffs then
            selected_buff_bar.buffs = {}
        end

        add_selected_to_table(selected_buff_bar.buffs, buffs)

        mod:set(BUFF_BARS_SETTING_ID, buff_bars)
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BuffSearchComponent.draw = function(buffs)
    draw_inputs()
    draw_buffs(buffs)
    local add_to_group, add_to_buff_bar = draw_add_to_inputs()

    update(buffs)
end

return BuffSearchComponent