string.starts_with = function (str, start)
    return str:sub(1, #start) == start
end

table.dump = function(t)
    if type(t) == 'table' then
        local s = '{ '
        for k,v in pairs(t) do
           if type(k) ~= 'number' then k = '"'..k..'"' end
           s = s .. '['..k..'] = ' .. table.dump(v) .. ','
        end
        return s .. '} '
     else
        return tostring(t)
     end
end


table.index_of_condition = function (t, condition)
    for i = 1, #t do
        if condition(t[i]) then
            return i
        end
    end

    return -1
end
string.split = function (str, sep)
    local array = {}
    local reg = string.format("([^%s]+)", sep)

    for mem in string.gmatch(str, reg) do
        table.insert(array, mem)
    end

    return array
end

string.capitalize = function (self)
    return self:sub(1,1):upper() .. self:sub(2):lower()
end

string.is_null_or_whitespace = function (self)
    if self == nil then
        return true
    end

    return self:match('^%s*$') ~= nil
end

string.to_pascal_case = function (self, delimiter)
    if string.is_null_or_whitespace(delimiter) then
        delimiter = ' '
    end

    local words = {}
    for word in self:gmatch('([^' .. delimiter .. ']+)') do
        table.insert(words, word)
    end

    local retVal = ''
    for _, word in ipairs(words) do
        retVal = retVal .. word:capitalize()
    end

    return retVal
end

local function get_fake_class_name(fake_path)
    local fake_path_parts = fake_path:split('/')
    local raw_class_name = fake_path_parts[#fake_path_parts]
    local buff_bar_name = raw_class_name:gsub('hud_element_buff_bar_', ''):to_pascal_case('_')
    local fake_class_name = 'HudElementBuffBar_' .. buff_bar_name
    return fake_class_name
end

local fake_filename = 'better_buff_management/scripts/mods/better_buff_management/hud/hud_element_buff_bar_zealot'

print(get_fake_class_name(fake_filename))