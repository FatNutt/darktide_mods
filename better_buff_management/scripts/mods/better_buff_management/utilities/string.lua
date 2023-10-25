function string.capitalize(self)
    return self:sub(1,1):upper() .. self:sub(2):lower()
end

function string.is_whitespace(self)
    return string.match(self, '^%s*$') ~= nil
end

function string.is_nil_or_whitespace(self)
    return self == nil or string.is_whitespace(self)
end

function string.to_snake_case(self)
    local retVal = self:lower()
    retVal = retVal:gsub(" ", "_")

    return retVal
end

function string.to_pascal_case(self, delimiter)
    if string.is_nil_or_whitespace(delimiter) then
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

function string.sanitize(self, pattern)
    return self:gsub(pattern, '')
end