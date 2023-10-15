local mod = get_mod('better_buff_management')

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

function SearchItem:toggle_selected(flag)
    self._is_selected = flag
end

function SearchItem:clicked()
    self._is_selected = not self._is_selected
end

function SearchItem:is_selected()
    return self._is_selected
end

return SearchItem