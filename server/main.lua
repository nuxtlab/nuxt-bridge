CreateThread(function ()
    lib.event:register('nuxt-lib:server:connect', function (resourceName)
        -- Version control system taken from ox_lib. (https://github.com/overextended/ox_lib)

        local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

        if currentVersion then
            currentVersion = currentVersion:match('%d+%.%d+%.%d+')

            PerformHttpRequest(('https://api.github.com/repos/nuxtlab/%s/releases/latest'):format(resourceName), function(status, response)
                if status == 200 then
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
                                return lib.logger:inform('33721', resourceName, currentVersion, response.html_url)
                            else break end
                        end
                    end
                else
                    lib.logger:error('98662')
                end
            end, 'GET')
        else
            lib.logger:error('98762')
        end
    end)
end)
