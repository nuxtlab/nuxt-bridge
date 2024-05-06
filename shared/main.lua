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
            self.logger:error('50238')
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
                        lib.logger:error('71492')
                    end
                -- else
                    -- lib.logger:error('36805')
                end
            else
                lib.logger:error('92641')
            end
        else
            lib.logger:error('59173')
        end
    else
        lib.logger:error('74268')
    end
end

lib.data = setmetatable({}, {
    __index = function (self, index)
        local path = ('data/%s.lua'):format(index)
        local payload = lib:import(lib.resourceName, path)

        if payload then
            self[index] = payload

            return self[index]
        else
            lib.logger:error('76521')
        end
    end
})

CreateThread(function ()
    -- Init locale.
    local locale = lib.data.config.locale

    if locale then
        local path = ('locale/%s.lua'):format(lib.data.config.locale)
        local payload = lib:import(lib.resourceName, path)

        if payload then
            lib.locale = setmetatable(payload, {
                __call = function (self, index, variables)
                    local string = self[index]

                    if string then
                        for match in string:gmatch('@([%w_]+)') do
                            if variables then
                                if variables[match] then
                                    string = string:gsub(('@%s'):format(match), variables[match])
                                else
                                    lib.logger:error('72309')
                                end
                            else
                                lib.logger:error('200016')
                            end
                        end

                        return string
                    else
                        lib.logger:error('52313')
                    end
                end
            })
        else
            lib.logger:error('10008')
        end
    else
        lib.logger:error('23481')
    end

    -- Init framework.
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
        end
    end

    if framework then
        lib.logger:success('46782')
    else
        lib.logger:error('58273')
    end

    lib.framework = framework

    if lib.context == 'server' then
        Wait(100)

        lib.event:trigger('nuxt-lib:server:connect', lib.resourceName)
    end
end)

_ENV.lib = lib
