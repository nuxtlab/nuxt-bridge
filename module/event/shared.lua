local event = {}

---@param name string
---@param handler function
function event:register(name, handler)
    if name and type(name) == 'string' then
        if handler and type(handler) == 'function' then
            local eventName = ('%s:event:%s'):format(bridge.name, name)

            RegisterNetEvent(eventName, function (callback, ...)
                local stack = { handler(...) }

                if callback then
                    callback(table.unpack(stack))
                else
                    if bridge.context == 'client' then
                        TriggerServerEvent(eventName, table.unpack(stack))
                    else
                        TriggerClientEvent(eventName, source, table.unpack(stack))
                    end
                end
            end)
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'handler',
                func = 'bridge.event:register()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.event:register()'
        }))
    end
end

---@param name string
---@param ... any
---@return any?
function event:trigger(name, ...)
    if name and type(name) == 'string' then
        local promise = promise:new()

        local function callback(...)
            promise:resolve({ ... })
        end

        local eventName = ('%s:event:%s'):format(bridge.name, name)

        TriggerEvent(eventName, callback, ...)

        return table.unpack(Citizen.Await(promise))
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.event:trigger()'
        }))
    end
end

if bridge.context == 'client' then
    ---@param name string
    ---@param ... any
    ---@return any?
    function event:triggerServer(name, ...)
        if name and type(name) == 'string' then
            local promise = promise:new()

            local eventName = ('%s:event:%s'):format(bridge.name, name)

            RegisterNetEvent(eventName, function (...)
                promise:resolve({ ... })
            end)

            TriggerServerEvent(eventName, nil, ...)

            return table.unpack(Citizen.Await(promise))
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'name',
                func = 'bridge.event:triggerServer()'
            }))
        end
    end
else
    ---@param name string
    ---@param source number
    ---@param ... any
    ---@return any?
    function event:triggerClient(name, source, ...)
        if name and type(name) == 'string' then
            if source and type(source) == 'number' then
                local promise = promise:new()

                local eventName = ('%s:event:%s'):format(bridge.name, name)

                RegisterNetEvent(eventName, function (...)
                    promise:resolve({ ... })
                end)

                TriggerClientEvent(eventName, source, nil, ...)

                return table.unpack(Citizen.Await(promise))
            else
                bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                    param = 'source',
                    func = 'bridge.event:triggerClient()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'name',
                func = 'bridge.event:triggerClient()'
            }))
        end
    end
end

return event
