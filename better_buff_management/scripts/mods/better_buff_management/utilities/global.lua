if _G._bbm_global_initialized then return end
_G._bbm_global_initialized = true

_G.ternary = function(condition, trueValue, falseValue)
    if condition then return trueValue else return falseValue end
end
