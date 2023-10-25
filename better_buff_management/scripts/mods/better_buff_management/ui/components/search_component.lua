local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/imgui')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_buff_component')
local UiSettings = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/settings')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'SearchComponent'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
}

local BARS_SETTING_ID = 'bars'
local DESELECT_VISIBLE_ICONS_LOC_ID = 'unselect_all_icons'
local SELECT_VISIBLE_ICONS_LOC_ID = 'select_all_icons'
local SEARCH_LOC_ID = 'search'
local CLEAR_SEARCH_LOC_ID = 'clear_search'
local ADD_SELECTED_BUFFS_BAR_LOC_ID = 'add_selected_buffs_bar'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

local function _init_search_data(buffs_data)
    local search_data = {}
    for key, value in pairs(buffs_data) do
        search_data[key] = { buff = value, is_selected = false }
    end
    return search_data
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local SearchComponent = class(CLASS_NAME, 'BaseBuffComponent')
function SearchComponent:init(buffs_data)
    SearchComponent.super.init(self, buffs_data)

    self._search_data = _init_search_data(buffs_data)
    self._search_text = ''
    self._selected_bar_index = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function SearchComponent:_is_filtered_buff(buff_name)
    local lower_search = self._search_text:lower()
    local lower_buff_name = buff_name:lower()
    return lower_search == '' or (#lower_search > 0 and lower_buff_name:find(lower_search))
end

function SearchComponent:_toggle_all_selected(flag)
    for key, value in pairs(self._search_data) do
        if self:_is_filtered_buff(key) then
            value.is_selected = flag
        end
    end
end

function SearchComponent:_update_search_inputs()
    self._search_text = Imgui.input_text(mod:localize(SEARCH_LOC_ID), self._search_text)
    self._search_text = string.sanitize(self._search_text, '[^%w_]+')

    Imgui.same_line()
    Imgui.push_id(self.__class_name .. '_' .. CLEAR_SEARCH_LOC_ID:upper())
    if Imgui.button(mod:localize(CLEAR_SEARCH_LOC_ID)) then
        self._search_text = ''
    end
    Imgui.pop_id()

    if Imgui.button(mod:localize(SELECT_VISIBLE_ICONS_LOC_ID)) then
        self:_toggle_all_selected(true)
    end

    Imgui.same_line()

    if Imgui.button(mod:localize(DESELECT_VISIBLE_ICONS_LOC_ID)) then
        self:_toggle_all_selected(false)
    end
end

function SearchComponent:_get_bars()
    local bars = mod:get(BARS_SETTING_ID)

    if bars == nil then
        bars = {}
    end

    return bars
end

local debug = true
function SearchComponent:_draw_buff(search_data)
    local is_clicked = false

    local button_id = ('%s_%s_IMAGE_BUTTON'):format(self.__class_name, search_data.buff.name)
    Imgui.push_id(button_id)
    if search_data.is_selected then
        is_clicked = Imgui.image_button(search_data.buff.icon, UiSettings.BUFF_IMAGE_SIZE[1], UiSettings.BUFF_IMAGE_SIZE[2], 266, 200, 0, 1)
    else
        is_clicked = Imgui.image_button(search_data.buff.icon, UiSettings.BUFF_IMAGE_SIZE[1], UiSettings.BUFF_IMAGE_SIZE[2], 255, 255, 255, 1)
    end
    Imgui.pop_id()

    if is_clicked then
        search_data.is_selected = not search_data.is_selected
    end

    if Imgui.is_item_hovered() then
        Imgui.begin_tool_tip()
        Imgui.text(search_data.buff.name)
        Imgui.end_tool_tip()
    end
end

function SearchComponent:_update_search_window()
    local sorted_data = table.sorted_by_value(self._search_data, function(dataA, dataB)
        return dataA.buff.name < dataB.buff.name
    end)

    local same_line_flag = 1
    Imgui.begin_child_window(self.__class_name .. '_SEARCH_WINDOW', UiSettings.SEARCH_WINDOW_SIZE[1], UiSettings.SEARCH_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')
    for _, search_data in pairs(sorted_data) do
        if same_line_flag > 1 then
            Imgui.same_line()
        end

        if self:_is_filtered_buff(search_data.buff.name) then
            self:_draw_buff(search_data)
        end

        same_line_flag = same_line_flag + 1
    end

    Imgui.end_child_window()
end

function SearchComponent:_update_add_inputs()
    local bars = self:_get_bars()

    if Imgui.button(mod:localize(ADD_SELECTED_BUFFS_BAR_LOC_ID)) and self._selected_bar_index then
        local selected_bar = bars[self._selected_bar_index]
        for key, data in pairs(self._search_data) do
            if self:_is_filtered_buff(key) and data.is_selected then
                data.buff.bar_name = selected_bar
            end
        end
        self:_toggle_all_selected(false)
        self._selected_bar_index = nil
    end
    Imgui.same_line()

    self._selected_bar_index = Imgui.combo(self.__class_name .. '_SELECT_BAR_INPUT', bars, self._selected_bar_index)
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function SearchComponent:update()
    self:_update_search_inputs()
    self:_update_search_window()
    self:_update_add_inputs()
end

return SearchComponent