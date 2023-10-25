local function filter(t, func)
    local copy = {}

    print(type(t))
    for k, v in pairs(t) do
        if func(v) then
            copy[k] = v
        end
    end

    return copy
end


local test_tbl1 = nil
local test_tbl2 = {}
local test_tbl3 = { 1, 2, 3, 4, 5}
local test_tbl4 = { one = 1, two = 2, three = 3, four = 4, five = 5}

local result1 = filter(test_tbl1, function(item)
    return true
end)
local result2 = filter(test_tbl2, function(item)
    return true
end)
local result3 = filter(test_tbl3, function(item)
    return true
end)
local result4 = filter(test_tbl4, function(item)
    return true
end)