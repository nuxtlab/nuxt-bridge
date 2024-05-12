local lib = setmetatable({
    name = 'nuxt-lib',
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
                object = 'lib'
            }))
        end
    end
})

---@param resource string
---@param path string
---@return any
function lib:import(resource, path)
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
                        lib.logger:error(lib.locale('module_failed_to_run', {
                            module = path,
                            resource = resource
                        }))
                    end
                -- else
                    -- lib.logger:error(lib.locale('module_not_found', {
                    --     module = path,
                    --     resource = resource
                    -- }))
                end
            else
                lib.logger:error(lib.locale('uninitialized_resource_used'))
            end
        else
            lib.logger:error(lib.locale('param_not_found_or_incorrect_type', {
                param = 'path',
                func = 'lib:import()'
            }))
        end
    else
        lib.logger:error(lib.locale('param_not_found_or_incorrect_type', {
            param = 'resource',
            func = 'lib:import()'
        }))
    end
end

lib.data = setmetatable({}, {
    __index = function (self, index)
        local payload = {}
        local path = ('data/%s.lua'):format(index)
        local chunk = lib:import(lib.resourceName, path)
        local shared = lib:import(lib.name, path)

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
            lib.logger:error(lib.locale('element_not_fount_in_object', {
                element = index,
                object = 'lib.data'
            }))
        end
    end
})

lib.locale = setmetatable({}, {
    __index = function (self, index)
        local path = ('locale/%s.lua'):format(lib.data.config.locale)
        local payload = lib:import(lib.resourceName, path)

        if payload then
            self[index] = payload[index]

            return self[index]
        else
            lib.logger:error(('Locale "%s" not found.'):format(lib.data.config.locale))
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
                        lib.logger:error(lib.locale('locale_variable_not_found', {
                            variable = match,
                            locale = index
                        }))
                    end
                else
                    lib.logger:error(lib.locale('locale_variables_not_found', {
                        locale = index
                    }))
                end
            end

            return string
        else
            lib.logger:error(lib.locale('locale_param_not_found', {
                param = index,
                locale = locale
            }))
        end
    end
})

CreateThread(function ()
    local framework

    for key, value in pairs(lib.data.framework) do
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

    if framework then
        lib.framework = framework

        lib.logger:success(lib.locale('framework_found', {
            framework = lib.framework.name
        }))
    else
        lib.logger:error(lib.locale('framework_not_found'))
    end
end)

_ENV.lib = lib
