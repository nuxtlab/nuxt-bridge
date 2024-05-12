local cache = {}

---@param name string
---@param value any
function cache:set(name, value)
    if name and type(name) == 'string' then
        if value then
            if value ~= cache[name] then
                lib.event:trigger(('%s:cache:set:%s'):format(lib.name, name), value, cache[name])

                cache[name] = value
            end
        else
            lib.logger:error(lib.locale('cache_value_not_found', {
                cache = name
            }))
        end
    else
        lib.logger:error(lib.locale('param_not_found', {
            param = 'name',
            func = 'lib.cache:set()'
        }))
    end
end

---@param name string
---@param handler function
function cache:watch(name, handler)
    if name and type(name) == 'string' then
        if handler and type(handler) == 'function' then
            lib.event:register(('%s:cache:set:%s'):format(lib.name, name), handler)
        else
            lib.logger:error(lib.locale('param_not_found_or_incorrect_type', {
                param = 'handler',
                func = 'lib.cache:watch()'
            }))
        end
    else
        lib.logger:error(lib.locale('param_not_found', {
            param = 'name',
            func = 'lib.cache:watch()'
        }))
    end
end

return cache
