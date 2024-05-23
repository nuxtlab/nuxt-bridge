CreateThread(function ()
    if next(bridge.framework) then
        bridge.logger:success(bridge.locale('framework_found', {
            framework = bridge.framework.name
        }))
    else
        bridge.logger:error(bridge.locale('framework_not_found'))
    end

    bridge.event:register('nuxt-bridge:server:connect', function (resourceName)
        if resourceName ~= bridge.name then
            bridge.logger:success(bridge.locale('resource_connected', {
                resource = resourceName
            }))
        end

        -- Version control systems taken from https://github.com/overextended.

        local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

        if currentVersion then
            currentVersion = currentVersion:match('%d+%.%d+%.%d+')

            PerformHttpRequest(('https://api.github.com/repos/nuxtlab/%s/releases/latest'):format(resourceName), function(status, response)
                if status ~= 200 then return end

                response = json.decode(response)

                if response.prerelease then return end

                local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
                if not latestVersion or latestVersion == currentVersion then return end

                local cv = { string.strsplit('.', currentVersion) }
                local lv = { string.strsplit('.', latestVersion) }

                for i = 1, #cv do
                    local current, minimum = tonumber(cv[i]), tonumber(lv[i])

                    if current ~= minimum then
                        if current < minimum then
                            return bridge.logger:inform(bridge.locale('new_version_found', {
                                resource = resourceName,
                                url = GetResourceMetadata(resourceName, 'repository', 0) and response.html_url or ('https://keymaster.fivem.net/asset-grants?search=%s'):format(resourceName)
                            }))
                        else break end
                    end
                end
            end, 'GET')
        else
            bridge.logger:error(bridge.locale('current_version_not_found', {
                resource = resourceName
            }))
        end
    end)
end)
