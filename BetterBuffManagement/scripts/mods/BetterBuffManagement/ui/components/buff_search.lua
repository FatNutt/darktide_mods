-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local SEARCH_WINDOW_SIZE = { 0, 125 }
local BUFF_WINDOW_SIZE = { 75, 120 }
local BUFF_BUTTON_SIZE = { 64, 64 }

local BuffSearchComponent = {
    _search = '',
    unhide_all = false,
    hide_all = false
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function draw_inputs()
    BuffSearchComponent._search = Imgui.input_text("Search", BuffSearchComponent._search)

    Imgui.same_line()
    BuffSearchComponent.unhide_all = Imgui.small_button('Uncheck all hidden icons') -- TODO: Do something with this

    Imgui.same_line()
    BuffSearchComponent.hide_all = Imgui.small_button('Check all hidden icons') -- TODO: Do something with this

    Imgui.button('Add to grouping')
    Imgui.button('Add to buff bar')
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
    local search = BuffSearchComponent._search

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

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BuffSearchComponent.draw = function(buffs)
    draw_inputs()
    draw_buffs(buffs)
end

return BuffSearchComponent