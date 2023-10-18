-- local mod = get_mod('better_buff_management')

-- local _fake_requires = {}
-- function mod:add_fake_require_path(path, fake_value)
--     _fake_requires[path] = fake_value
-- end

-- function mod:remove_fake_require_path(path)
--     _fake_requires[path] = nil
-- end

-- mod:hook(_G, "require", function (func, path, ...)
--     if _fake_requires[path] then
--       return _fake_requires[path]
--     else
--       local result = func(path, ...)
  
--       -- Apply any file hooks to the newly-required file
--       local require_store = get_require_store(path)
--       if require_store then
--         dmf.apply_hooks_to_file(require_store, path, #require_store)
--       end
  
--       return result
--     end
-- end)