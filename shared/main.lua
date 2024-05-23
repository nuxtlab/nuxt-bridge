local bridge = setmetatable({
    name = 'nuxt-bridge',
    resourceName = GetCurrentResourceName(),
    context = IsDuplicityVersion() and 'server' or 'client'
}, {
    __index = function (self, index)
        local directory = ('module/%s'):format(index)
        local payload = self:import(self.name, ('%s/shared.lua'):format(directory)) or self:import(self.name, ('%s/%s.lua'):format(directory, self.context))

        if payload then
            self[index] = payload

            return self[index]
        else
            self.logger:error(self.locale('element_not_fount_in_object', {
                element = index,
                object = 'bridge'
            }))
        end
    end
})

---@param resource string
---@param path string
---@return any
function bridge:import(resource, path)
    if resource and type(resource) == 'string' then
        if path and type(path) == 'string' then
            local resourceState = GetResourceState(resource)

            if resourceState:find('start') then
                local payload = LoadResourceFile(resource, path)

                if payload then
                    local module, error = load(payload, ('@@%s/%s'):format(resource, path))

                    if module and not error then
                        return module()
                    else
                        bridge.logger:error(bridge.locale('module_failed_to_run', {
                            module = path,
                            resource = resource
                        }))
                    end
                -- else
                    -- bridge.logger:error(bridge.locale('module_not_found', {
                    --     module = path,
                    --     resource = resource
                    -- }))
                end
            else
                bridge.logger:error(bridge.locale('uninitialized_resource_used'))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'path',
                func = 'bridge:import()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'resource',
            func = 'bridge:import()'
        }))
    end
end

---@param data table
---@param from table
---@param to table
---@return table?
function bridge:transform(data, from, to)
    if data and type(data) == 'table' then
        if from and type(from) == 'table' then
            if to and type(to) == 'table' then
                local result = {}
                local stack = { { data = data, schema = from, result = result } }

                repeat
                    local current = table.remove(stack)

                    for key, value in pairs(current.schema) do
                        if type(value) == 'table' then
                            stack[#stack + 1] = {
                                data = current.data[key],
                                schema = value,
                                result = current.result
                            }
                        else
                            current.result[value] = current.data[key]
                        end
                    end
                until #stack == 0

                local finalResult = {}
                local finalStack = { { data = result, schema = to, result = finalResult } }

                repeat
                    local current = table.remove(finalStack)

                    for key, value in pairs(current.schema) do
                        if type(value) == 'table' then
                            current.result[key] = {}
                            finalStack[#finalStack+1] = { schema = value, data = current.data, result = current.result[key] }
                        else
                            current.result[key] = current.data[value]
                        end
                    end
                until #finalStack == 0

                return finalResult
            else
                bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                    param = 'to',
                    func = 'bridge:transform()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'from',
                func = 'bridge:transform()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'data',
            func = 'bridge:transform()'
        }))
    end
end

bridge.data = setmetatable({}, {
    __index = function (self, index)
        local payload = {}
        local path = ('data/%s.lua'):format(index)
        local chunk = bridge:import(bridge.resourceName, path)
        local shared = bridge:import(bridge.name, path)

        if chunk then
            for key, value in pairs(chunk) do
                payload[key] = value
            end
        end

        if shared then
            for key, value in pairs(shared) do
                payload[key] = value
            end
        end

        if next(payload) then
            self[index] = payload

            return self[index]
        else
            bridge.logger:error(bridge.locale('element_not_fount_in_object', {
                element = index,
                object = 'bridge.data'
            }))
        end
    end
})

bridge.locale = setmetatable({}, {
    __index = function (self, index)
        local payload
        local path = ('locale/%s.lua'):format(bridge.data.config.locale)
        local chunk = bridge:import(bridge.resourceName, path)
        local shared = bridge:import(bridge.name, path)

        if chunk and chunk[index] then
            payload = chunk[index]
        end

        if shared and shared[index] then
            payload = shared[index]
        end

        if payload then
            self[index] = payload

            return self[index]
        else
            bridge.logger:error(('Locale "%s" not found.'):format(bridge.data.config.locale))
        end
    end,
    __call = function (self, index, variables)
        local string = self[index]

        if string then
            for match in string:gmatch('@([%w_]+)') do
                if variables then
                    if variables[match] then
                        string = string:gsub(('@%s'):format(match), variables[match])
                    else
                        bridge.logger:error(bridge.locale('locale_variable_not_found', {
                            variable = match,
                            locale = index
                        }))
                    end
                else
                    bridge.logger:error(bridge.locale('locale_variables_not_found', {
                        locale = index
                    }))
                end
            end

            return string
        else
            bridge.logger:error(bridge.locale('locale_param_not_found', {
                param = index,
                locale = bridge.data.config.locale
            }))
        end
    end
})

CreateThread(function ()
    local framework

    for key, value in pairs(bridge.data.framework) do
        local resourceState = GetResourceState(value.resourceName)

        if resourceState == 'started' then
            framework = {
                name = key
            }

            local payload = value.init()

            for index, item in pairs(payload) do
                framework[index] = item
            end

            break
        end
    end

    bridge.framework = framework or {}

    if bridge.context == 'client' then
        -- TODO: useLocale
        RegisterNuiCallback('useLocale', function (data, callback)
            print(json.encode(data))

            -- callback('OK')
        end)
    else
        Wait(500)

        bridge.event:trigger('nuxt-bridge:server:connect', bridge.resourceName)
    end
end)

_ENV.bridge = bridge
