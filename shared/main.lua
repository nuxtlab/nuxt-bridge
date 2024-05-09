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
            self.logger:error('18742')
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
                        lib.logger:error('50236')
                    end
                -- else
                    -- lib.logger:error('93614')
                end
            else
                lib.logger:error('72406')
            end
        else
            lib.logger:error('50389')
        end
    else
        lib.logger:error('61824')
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
            lib.logger:error('93756')
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
            lib.logger:error('64513')
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
                        lib.logger:error('95602')
                    end
                else
                    lib.logger:error('85438')
                end
            end

            return string
        else
            lib.logger:error('65429')
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

        lib.logger:success('31203', framework.name)
    else
        lib.logger:error('42399')
    end
end)

_ENV.lib = lib
