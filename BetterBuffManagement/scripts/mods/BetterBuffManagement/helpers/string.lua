function string.to_snake_case(self)
    self = self:lower()
    self = self:gsub(" ", "_")

    return self
end

function string.is_null_or_whitespace(self)
    if self == nil then
        return true
    end

    return self:match('^%s*$') ~= nil
end
