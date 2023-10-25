local mod = get_mod('better_buff_management')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/string')
mod:io_dofile('better_buff_management/scripts/mods/better_buff_management/utilities/table')

local MOD_NAME = mod:localize('mod_name')

local ERROR_PREFIX = ('[%s][%s]'):format(MOD_NAME, 'Imgui')
local ERRORS = {
    COMBO = {
        ID_MUST_BE_STRING = ('%s combo_id must be a string'):format(ERROR_PREFIX),
        ID_CANNOT_BE_WHITESPACE = ('%s combo_id cannot be whitespace'):format(ERROR_PREFIX),
        ARG2_MUST_BE_STRING_OR_TABLE = ('%s arg2 must be a string or table'):format(ERROR_PREFIX),
        ITEMS_MUST_BE_AN_ARRAY = ('%s combo_items must be an array'):format(ERROR_PREFIX),
        ARG3_MUST_BE_NUMBER_OR_TABLE = ('%s arg3 must be a number or table but got %s'):format(ERROR_PREFIX, '%s'),
        ARG3_IS_NUMBER_BUT_TABLE_EXPECTED = ('%s arg3 is number but table expected'):format(ERROR_PREFIX),
        ARG4_MUST_BE_NUMBER_OR_TABLE = ('%s arg4 must be a number or boolean but got %s'):format(ERROR_PREFIX, '%s'),
        SELECTED_INDEX_OUT_OF_RANGE = ('%s selected_index is out of range'):format(ERROR_PREFIX),
        SELECTED_INDEX_MUST_BE_NUMBER = ('%s selected_index must be a number'):format(ERROR_PREFIX),
        ADD_EMPTY_ENTRY_FLAG_MUST_BE_BOOLEAN = ('%s add_empty_entry must be a boolean'):format(ERROR_PREFIX)
    },
    INPUT_TEXT = {
        ID_MUST_BE_STRING = ('%s input_id must be a string'):format(ERROR_PREFIX),
        ID_CANNOT_BE_WHITESPACE = ('%s input_id cannot be whitespace, [%s]'):format(ERROR_PREFIX, '%s'),
    }
}

local function validate_combo_params(args)
    local arg1_type = type(args[1])
    local arg2_type = type(args[2])
    local arg3_type = type(args[3])
    local arg4_type = type(args[4])
    local arg5_type = type(args[5])

    -- combo_id = string
    local function validate_arg1()
        if arg1_type ~= 'string' then
            error(ERRORS.COMBO.ID_MUST_BE_STRING, 2)
        elseif string.is_whitespace(args[1]) then
            error(ERRORS.COMBO.ID_CANNOT_BE_WHITESPACE, 2)
        end
    end

    -- combo_label = string or combo_items = array<string>
    local function validate_arg2()
        if arg2_type ~= 'string' and arg2_type ~= 'table' then
            error(ERRORS.COMBO.ARG2_MUST_BE_STRING_OR_TABLE, 2)
        elseif arg2_type == 'table' and not table.is_array(args[2]) then
            error(ERRORS.COMBO.ITEMS_MUST_BE_AN_ARRAY, 2)
        end
    end

    -- combo_items = array<string> or selected_index = nil|number
    local function validate_arg3()
        if arg3_type ~= 'nil' then
            if arg3_type ~= 'number' and arg3_type ~= 'table' then
                error(ERRORS.COMBO.ARG3_MUST_BE_NUMBER_OR_TABLE:format(arg3_type), 2)
            elseif arg3_type == 'table' and not table.is_array(args[3]) then
                error(ERRORS.COMBO.ITEMS_MUST_BE_AN_ARRAY, 2)
            elseif arg3_type == 'number' and arg2_type == 'string' then
                error(ERRORS.COMBO.ARG3_IS_NUMBER_BUT_TABLE_EXPECTED, 2)
            elseif arg3_type == 'number' and (args[3] < 1 or args[3] > #args[2]) then
                error(ERRORS.COMBO.SELECTED_INDEX_OUT_OF_RANGE, 2)
            end
        end
    end

    -- selected_index = nil|number or add_empty_entry = boolean(defaults true)
    local function validate_arg4()
        if arg4_type ~= 'nil' then
            if arg4_type ~= 'number' and arg4_type ~= 'boolean' then
                error(ERRORS.COMBO.ARG4_MUST_BE_NUMBER_OR_TABLE:format(arg4_type), 2)
            elseif arg4_type == 'number' and (args[4] < 1 or args[4] > #args[3]) then
                error(ERRORS.COMBO.SELECTED_INDEX_OUT_OF_RANGE, 2)
            end
        end
    end

    -- add_empty_entry = boolean(defaults true)
    local function validate_arg5()
        if arg5_type ~= 'nil' then
            if arg5_type ~= 'boolean' then
                error(ERRORS.COMBO.ADD_EMPTY_ENTRY_FLAG_MUST_BE_BOOLEAN, 2)
            elseif not args[5] and arg4_type == 'nil' then
                error(ERRORS.COMBO.SELECTED_INDEX_MUST_BE_NUMBER, 2)
            end
        end
    end

    validate_arg1()

    if #args >= 2 then
        validate_arg2()
    end

    if #args >= 3 then
        validate_arg3()
    end

    if #args >= 4 then
        validate_arg4()
    end

    if #args >= 5 then
        validate_arg5()
    end
end

-- combo_id = string, combo_label = string, combo_items = array<string>, selected_index = nil|number, add_empty_entry = boolean(defaults true)
-- arg1 = combo_id, arg2 = combo_label|combo_items, arg3 = combo_items|selected_index, arg4 = selected_index
Imgui.combo = function(...)
    local args = {...}
    validate_combo_params(args)

    local id = args[1]
    local label = ''
    local combo_items = nil
    local selected_index = nil
    local add_empty_entry = true

    if type(args[2]) == 'string' then
        label = args[2]
    elseif type(args[2]) == 'table' then
        combo_items = args[2]
    end

    if type(args[3]) == 'table' then
        combo_items = args[3]
    elseif type(args[3]) == 'number' then
        selected_index = args[3]
    end

    if type(args[4]) == 'number' then
        selected_index = args[4]
    elseif type(args[4]) == 'boolean' then
        add_empty_entry = args[4]
    end

    if type(args[5]) == 'boolean' then
        add_empty_entry = args[5]
    end

    local selected_text = ''
    if combo_items and selected_index then
        selected_text = combo_items[selected_index]
    end

    Imgui.push_id(id)
    if Imgui.begin_combo(label, selected_text) then
        if not table.is_nil_or_empty(combo_items) then
            if add_empty_entry then
                local is_selected_index_nil = selected_index == nil
                if Imgui.selectable('', is_selected_index_nil) then
                    selected_index = nil
                end
    
                if is_selected_index_nil then
                    Imgui.set_item_default_focus()
                end
            end

            for index, text in ipairs(combo_items) do
                local is_item_selected = selected_index == index

                if Imgui.selectable(text, is_item_selected) then
                    selected_index = index
                end

                if is_item_selected then
                    Imgui.set_item_default_focus()
                end
            end
        end
        Imgui.end_combo()
    end
    Imgui.pop_id()

    return selected_index
end

local function validate_input_text_params(args)
    local arg1_type = type(args[1])

    if arg1_type ~= 'string' then
        return error(ERRORS.INPUT_TEXT.ID_MUST_BE_STRING, 2)
    elseif string.is_whitespace(args[1]) then
        return error(ERRORS.INPUT_TEXT.ID_CANNOT_BE_WHITESPACE:format(args[1]), 2)
    end
end

-- input_id = string, input_label = nil|string, value = nil|string
-- arg1 = input_id, arg2 = input_label|value, arg3 = value
Imgui.ided_input_text = function(...)
    local args = {...}
    validate_input_text_params(args)

    local id = args[1]
    local label = ''
    local value = ''
    if #args == 2 then
        value = args[2]
    elseif #args >= 3 then
        if args[2] ~= nil then
            label = args[2]
        end

        if args[3] ~= nil then
            value = args[3]
        end
    end

    Imgui.push_id(id)
    ---@diagnostic disable-next-line: cast-local-type
    value = Imgui.input_text(label, value)
    Imgui.pop_id()

    return value
end