local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/imgui')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/components/base_buff_component')
local UiSettings = mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/ui/settings')

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

local function _update_buffs(window_id, buffs)
    local same_line_flag = false
    for _, buff in pairs(buffs) do
        if same_line_flag then
            Imgui.same_line()
        end

        local buff_id = string.to_pascal_case(buff.name, '_')
        local buff_window_id = ('%s_%s'):format(window_id, buff_id)
        Imgui.begin_child_window(buff_window_id, UiSettings.BUFF_WINDOW_SIZE[1], UiSettings.BUFF_WINDOW_SIZE[2], false)

        Imgui.image_button(buff.icon, UiSettings.BUFF_IMAGE_SIZE[1], UiSettings.BUFF_IMAGE_SIZE[2], 255, 255, 255, 1)

        local remove = Imgui.button(mod:localize(REMOVE_BUFF_FROM_BUFF_BAR_LOC_ID))

        Imgui.end_child_window()

        if Imgui.is_item_hovered() then
            Imgui.begin_tool_tip()
            Imgui.text(buff.name)
            Imgui.end_tool_tip()
        end

        if remove then
            buff.bar_name = ''
        end
        same_line_flag = true
    end
end

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------
local BuffBarsComponent = class(CLASS_NAME, 'BaseBuffComponent')
function BuffBarsComponent:init(buffs_data)
    BuffBarsComponent.super.init(self, buffs_data)

    self._bars = mod:get(BARS_SETTING_ID)
    self._new_bar_name = ''
    self._selected_bar_index = nil
end

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

function BuffBarsComponent:_update_create_bar()
    local create_bar = Imgui.button(mod:localize(CREATE_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.same_line()
    self._new_bar_name = Imgui.ided_input_text(self.__class_name .. '_BAR_NAME_INPUT', self._new_bar_name)

    if not string.is_nil_or_whitespace(self._new_bar_name) and create_bar then
        if self._bars == nil or #self._bars == 0 then
            self._bars = { self._new_bar_name }
        elseif not table.contains(self._bars, self._new_bar_name) then
            table.insert(self._bars, self._new_bar_name)
        end

        mod:set(BARS_SETTING_ID, self._bars)
        self._new_bar_name = ''
    end
end

function BuffBarsComponent:_update_clear_or_delete_bar()
    self._selected_bar_index = Imgui.combo(self.__class_name .. '_SELECT_BAR_INPUT', mod:localize(SELECT_BUFF_BAR_LABEL_LOC_ID), self._bars, self._selected_bar_index)
    Imgui.same_line()
    Imgui.push_id(self.__class_name .. '_' .. CLEAR_BUFF_BAR_BUTTON_LOC_ID:upper())
    local clear_bar = Imgui.button(mod:localize(CLEAR_BUFF_BAR_BUTTON_LOC_ID))
    Imgui.pop_id()

    Imgui.same_line()
    local delete_bar = Imgui.button(mod:localize(DELETE_BUFF_BAR_BUTTON_LOC_ID))

    if self._selected_bar_index then
        if not table.is_nil_or_empty(self._buffs_data) and (clear_bar or delete_bar) then
            local selected_bar = self._bars[self._selected_bar_index]
            for _, data in pairs(self._buffs_data) do
                if data.bar_name == selected_bar then
                    data.bar_name = ''
                end
            end

            if clear_bar then
                self._selected_bar_index = nil
            end
        end
    
        if delete_bar then
            table.remove(self._bars, self._selected_bar_index)
            mod:set(BARS_SETTING_ID, self._bars)
            self._selected_bar_index = nil
        end
    end
end

function BuffBarsComponent:_update_bar_windows()
    if self._bars == nil or #self._bars == 0 then
        return
    end

    for _, bar in ipairs(self._bars) do
        Imgui.push_id(('%s_%s'):format(self.__class_name, string.to_pascal_case(bar, ' ')))
        if Imgui.collapsing_header(bar) then
            if not table.is_nil_or_empty(self._buffs_data) then
                local bar_id = string.to_pascal_case(bar, ' '):upper()
                local buffs_for_bar = table.filter(self._buffs_data, function(data)
                    return data.bar_name == bar
                end)

                local sorted_data = table.sorted_by_value(buffs_for_bar, function(dataA, dataB)
                    return dataA.name < dataB.name
                end)

                local window_id = ('%s_%s'):format(self.__class_name, bar_id)
                Imgui.begin_child_window(window_id, UiSettings.BAR_WINDOW_SIZE[1], UiSettings.BAR_WINDOW_SIZE[2], true, 'always_auto_resize', 'horizontal_scrollbar')

                if not table.is_nil_or_empty(buffs_for_bar) then
                    _update_buffs(window_id, sorted_data)
                end

                Imgui.end_child_window()
            end
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
