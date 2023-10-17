local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/helpers/combo')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

local BUFF_BARS_SETTING_ID = 'bbm_buff_bars'

local CREATE_BUFF_BAR_BUTTON_LOC_ID = 'create_buff_bar_button'
local DELETE_BUFF_BAR_BUTTON_LOC_ID = 'delete_buff_bar_button'
local REMOVE_BUFF_FROM_BUFF_BAR_LOC_ID = 'remove_buff_from_buff_bar'
local BUFF_BAR_NAME_LOC_ID = 'buff_bar_name'
local ADD_BUFF_BAR_LOC_ID = 'add_buff_bar'

local BUFF_BAR_WINDOW_SIZE = { 0, 125 }
local BUFF_WINDOW_SIZE = { 75, 100 }
local BUFF_IMAGE_SIZE = { 64, 64 }

local BuffBuffBarsComponent = {
    add_buff_bar_name = '',
    selected_buff_bar_index = 1
}

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------
local function draw_add_buff_bar()
    local add_buff_bar = Imgui.button(mod:localize(CREATE_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.same_line()
    BuffBuffBarsComponent.add_buff_bar_name = Imgui.input_text('   ', BuffBuffBarsComponent.add_buff_bar_name)

    return add_buff_bar
end

local function draw_delete_buff_bar(buff_bars)
    local delete_group = Imgui.button(mod:localize(DELETE_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.same_line()

    local buff_bars_names = mod.unpack_values_from_tables(buff_bars, 'name')
    BuffBuffBarsComponent.selected_buff_bar_index = Imgui.draw_combo('    ', buff_bars_names, BuffBuffBarsComponent.selected_buff_bar_index)

    return delete_group
end

local function draw_buff_bars_inputs(buff_bars)
    local dirty = false

    local add_group = draw_add_buff_bar()
    local delete_group = draw_delete_buff_bar(buff_bars)

    if add_group or delete_group then
        dirty = true
    end

    for index, buff_bar in ipairs(buff_bars) do
        if index > 1 then
            Imgui.same_line()
        end

        local old_flag = buff_bar.edit or false
        buff_bar.edit = Imgui.checkbox(buff_bar.name, old_flag)

        if buff_bar.edit ~= old_flag then
            dirty = true
        end
    end

    return dirty, add_group, delete_group
end

local function draw_buff(buff_bar_name, buff_name, buff)
    local buff_bar_id = buff_bar_name:to_snake_case()

    Imgui.begin_child_window(buff_name .. '_' .. buff_bar_id .. '_child_window', BUFF_WINDOW_SIZE[1], BUFF_WINDOW_SIZE[2], false)

    Imgui.image_button(buff.template.cached_icon, BUFF_IMAGE_SIZE[1], BUFF_IMAGE_SIZE[2], 255, 255, 255, 1)

    local remove = Imgui.button(mod:localize(REMOVE_BUFF_FROM_BUFF_BAR_LOC_ID))

    Imgui.end_child_window()

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(buff_name)
        Imgui.end_tool_tip()
    end

    return remove
end

local function draw_buffs(buff_bar, buffs)
    local buffs_to_remove = {}

    if buff_bar.buffs then
        local same_line_flag = 1
        for _, buff_name in ipairs(buff_bar.buffs) do
            if same_line_flag > 1 then
                Imgui.same_line()
            end

            local remove_buff = draw_buff(buff_bar.name, buff_name, buffs[buff_name])

            if remove_buff then
                table.insert(buffs_to_remove, buff_name)
            end

            same_line_flag = same_line_flag + 1
        end
    end

    return buffs_to_remove
end

local function draw_buff_bar(buff_bar, buffs)
    local dirty = false

    if Imgui.collapsing_header(buff_bar.name) then
        local child_window_id = buff_bar.name .. '_child_window'

        Imgui.begin_child_window(child_window_id, BUFF_BAR_WINDOW_SIZE[1], BUFF_BAR_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')

        local buffs_to_remove = draw_buffs(buff_bar, buffs)

        if #buffs_to_remove > 0 then
            dirty = true
        end

        for _, buff_name in ipairs(buffs_to_remove) do
            local buff_index = mod.find_index_by_value(buff_bar.buffs, buff_name)

            if buff_index then
                table.remove(buff_bar.buffs, buff_index)
            end
        end

        Imgui.end_child_window()
    end

    return dirty
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

BuffBuffBarsComponent.draw = function(buffs)
    local buff_bars = mod:get(BUFF_BARS_SETTING_ID)


    local is_dirty, add_buff_bar, delete_buff_bar = draw_buff_bars_inputs(buff_bars)

    for _, buff_bar in ipairs(buff_bars) do
        if buff_bar.edit then
            local buff_bar_is_dirty = draw_buff_bar(buff_bar, buffs)

            if buff_bar_is_dirty then
                is_dirty = true
            end
        end
    end


    if add_buff_bar and not string.is_null_or_whitespace(BuffBuffBarsComponent.add_buff_bar_name) then
        local new_buff_bar = {
            name = BuffBuffBarsComponent.add_buff_bar_name,
            edit = false,
            buffs = {}
        }
        table.insert(buff_bars, new_buff_bar)
        BuffBuffBarsComponent.add_buff_bar_name = ''
    end

    if delete_buff_bar and BuffBuffBarsComponent.selected_buff_bar_index > 1 then
        table.remove(buff_bars, BuffBuffBarsComponent.selected_buff_bar_index - 1)
        BuffBuffBarsComponent.selected_buff_bar_index = 1
    end

    if is_dirty then
        mod:set(BUFF_BARS_SETTING_ID, buff_bars)
    end

    return is_dirty
end

return BuffBuffBarsComponent