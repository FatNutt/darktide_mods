Imgui.draw_combo = function(combo_name, combo_items, selected_index)
    local selected_item_text = ''

    if selected_index > 1 then
        selected_item_text = combo_items[selected_index - 1]
    end

    if Imgui.begin_combo(combo_name, selected_item_text) then
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