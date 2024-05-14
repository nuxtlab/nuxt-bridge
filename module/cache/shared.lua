local cache = {}

---@param name string
---@param value any
function cache:set(name, value)
    if name and type(name) == 'string' then
        if value then
            if value ~= cache[name] then
                bridge.event:trigger(('%s:cache:set:%s'):format(bridge.name, name), value, cache[name])

                cache[name] = value
            end
        else
            bridge.logger:error(bridge.locale('cache_value_not_found', {
                cache = name
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found', {
            param = 'name',
            func = 'bridge.cache:set()'
        }))
    end
end

---@param name string
---@param handler function
function cache:watch(name, handler)
    if name and type(name) == 'string' then
        if handler and type(handler) == 'function' then
            bridge.event:register(('%s:cache:set:%s'):format(bridge.name, name), handler)
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'handler',
                func = 'bridge.cache:watch()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found', {
            param = 'name',
            func = 'bridge.cache:watch()'
        }))
    end
end

return cache
