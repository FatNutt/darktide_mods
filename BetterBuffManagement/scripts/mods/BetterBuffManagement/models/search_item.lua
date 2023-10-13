local mod = get_mod('BetterBuffManagement')

local SearchItem = class('SearchItem')

-- -------------------------------
-- ---------- Constants ----------
-- -------------------------------

-- -------------------------------
-- ------- Local Functions -------
-- -------------------------------

-- -------------------------------
-- --------- Constructor ---------
-- -------------------------------

function SearchItem:init()
    self._is_selected = false
    self._click_count = 0
end

-- -------------------------------
-- ---- Overloaded Functions -----
-- -------------------------------

-- -------------------------------
-- ------ Private Functions ------
-- -------------------------------

-- -------------------------------
-- ------- Public Functions ------
-- -------------------------------

function SearchItem:clicked()
    self._click_count = self._click_count + 1

    if self._click_count == 1 then
        self._is_selected = true
    elseif self._click_count == 2 then
        self._click_count = 0
        self._is_selected = false
    end
end

function SearchItem:is_selected()
    return self._is_selected
end

return SearchItem