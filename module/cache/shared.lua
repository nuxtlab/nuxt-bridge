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
            lib.logger:error('73921')
        end
    else
        lib.logger:error('50846')
    end
end

---@param name string
---@param handler function
function cache:watch(name, handler)
    if name and type(name) == 'string' then
        if handler and type(handler) == 'function' then
            lib.event:register(('%s:cache:set:%s'):format(lib.name, name), handler)
        else
            lib.logger:error('62478')
        end
    else
        lib.logger:error('91735')
    end
end

return cache