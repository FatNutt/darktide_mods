local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/imgui')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_buff_component')
local UiSettings = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/settings')

local BuffsProvider = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/lib/buffs_provider')
local BuffBarsProvider = mod:io_dofile(
    'better_buff_management/scripts/mods/better_buff_management/lib/buff_bars_provider')

local BuffBar = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/models/buff_bar')

local MOD_NAME = mod:localize('mod_name')
local CLASS_NAME = 'BuffBarsComponent'

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, CLASS_NAME)
local ERRORS = {
}

local BARS_SETTING_ID = 'bars'
local CREATE_BUFF_BAR_BUTTON_LOC_ID = 'create_buff_bar_button'
local SELECT_BUFF_BAR_LABEL_LOC_ID = 'select_buff_bar_label'
local CLEAR_BUFF_BAR_BUTTON_LOC_ID = 'clear_buff_bar_button'
local DELETE_BUFF_BAR_BUTTON_LOC_ID = 'delete_buff_bar_button'
local REMOVE_BUFF_FROM_BUFF_BAR_LOC_ID = 'remove_buff_from_buff_bar'

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffBarsComponent = class(CLASS_NAME, 'BaseBuffComponent')
function BuffBarsComponent:init(params)
    BuffBarsComponent.super.init(self, params)

    self._buffs_provider = params and params.buffs_provider or BuffsProvider:new()
    self._bars_provider = params and params.bars_provider or BuffBarsProvider:new(self._buffs_provider)

    self._new_bar_name = ''
    self._selected_bar_index = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function BuffBarsComponent:_bar_names()
    local bar_names = table.keys(self._bars)
    table.sort(bar_names)

    return bar_names
end

function BuffBarsComponent:_update_buffs(window_id, bar_data)
    local same_line_flag = false

    table.sort(bar_data.filter)
    for _, buff_name in pairs(bar_data.filter) do
        local buff_data = self._buffs_provider:try_get_buff(buff_name)

        if buff_data ~= nil then
            if same_line_flag then
                Imgui.same_line()
            end

            local buff_id = Imgui.make_id(buff_name)
            local buff_window_id = ('%s_%s'):format(window_id, buff_id)
            Imgui.begin_child_window(buff_window_id, UiSettings.BUFF_WINDOW_SIZE[1], UiSettings.BUFF_WINDOW_SIZE[2],
                false)

            Imgui.image_button(buff_data.icon, UiSettings.BUFF_IMAGE_SIZE[1], UiSettings.BUFF_IMAGE_SIZE[2], 255, 255,
                255, 1)

            local remove = Imgui.button(mod:localize(REMOVE_BUFF_FROM_BUFF_BAR_LOC_ID))

            Imgui.end_child_window()

            if Imgui.is_item_hovered() then
                Imgui.begin_tool_tip()
                Imgui.text(buff_name)
                Imgui.end_tool_tip()
            end

            if remove then
                bar_data.filter[buff_name] = nil
            end
            same_line_flag = true
        end
    end
end

function BuffBarsComponent:_update_create_bar()
    local create_bar = Imgui.button(mod:localize(CREATE_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.same_line()
    self._new_bar_name = Imgui.ided_input_text(self.__class_name .. '_BAR_NAME_INPUT', self._new_bar_name)

    if not string.is_nil_or_whitespace(self._new_bar_name) and create_bar then
        if not table.contains(self:_bar_names(), self._new_bar_name) then
            self._bars[self._new_bar_name] = BuffBar:new({
                filter = {},
                direction = BuffBar.DIRECTIONS.HORIZONTAL,
                alignment = BuffBar.ALIGNMENTS.LEFT
            })
        end

        self._new_bar_name = ''
    end
end

function BuffBarsComponent:_update_clear_or_delete_bar()
    local bar_names = self:_bar_names()

    self._selected_bar_index = Imgui.combo(self.__class_name .. '_SELECT_BAR_INPUT',
        mod:localize(SELECT_BUFF_BAR_LABEL_LOC_ID), bar_names, self._selected_bar_index)
    Imgui.same_line()
    Imgui.push_id(self.__class_name .. '_' .. CLEAR_BUFF_BAR_BUTTON_LOC_ID:upper())
    local clear_bar = Imgui.button(mod:localize(CLEAR_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.pop_id()

    Imgui.same_line()
    local delete_bar = Imgui.button(mod:localize(DELETE_BUFF_BAR_BUTTON_LOC_ID))

    if self._selected_bar_index then
        if not table.is_nil_or_empty(self._bars) and (clear_bar or delete_bar) then
            local selected_bar_name = bar_names[self._selected_bar_index]

            if clear_bar then
                self._bars[selected_bar_name].filter = {}
            end

            if delete_bar then
                self._bars[selected_bar_name] = nil
            end

            self._selected_bar_index = nil
        end
    end
end

function BuffBarsComponent:_update_bar_windows()
    if table.is_nil_or_empty(self._bars) then
        return
    end

    for bar_name, bar_data in pairs(self._bars) do
        local bar_id = Imgui.make_id(bar_name)

        Imgui.push_id(('%s_%s'):format(self.__class_name, bar_id))
        if Imgui.collapsing_header(bar_name) then
            local window_id = ('%s_%s'):format(self.__class_name, bar_id)
            Imgui.begin_child_window(window_id, UiSettings.BAR_WINDOW_SIZE[1], UiSettings.BAR_WINDOW_SIZE[2], true,
                'always_auto_resize', 'horizontal_scrollbar')

            if not table.is_nil_or_empty(bar_data) then
                self:_update_buffs(window_id, bar_data)
            end

            Imgui.end_child_window()
        end
        Imgui.pop_id()
    end
end

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function BuffBarsComponent:update()
    self:_update_create_bar()
    self:_update_clear_or_delete_bar()
    self:_update_bar_windows()
end

return BuffBarsComponent
