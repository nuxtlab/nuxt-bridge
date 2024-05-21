local database = {}

---@param name string
function database:createCollectionIfNotExist(name)
    if name and type(name) == 'string' then
        local filePath = ('collection/%s.json'):format(name)
        local collectionFile = LoadResourceFile(bridge.name, filePath)

        if not collectionFile then
            local data = '[]'

            SaveResourceFile(bridge.name, filePath, data, #data)
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.database:createCollectionIfNotExist()'
        }))
    end
end

---@param name string
---@param payload table
function database:insertTableToCollection(name, payload)
    if name and type(name) == 'string' then
        if payload and type(payload) == 'table' then
            local filePath = ('collection/%s.json'):format(name)
            local collectionFile = LoadResourceFile(bridge.name, filePath)

            if collectionFile then
                local collectionData = json.decode(collectionFile)

                table.insert(collectionData, payload)

                local data = json.encode(collectionData, { indent = true })

                SaveResourceFile(bridge.name, filePath, data, #data)
            else
                bridge.logger:error(bridge.locale('collection_not_found', {
                    collection = name,
                    func = 'bridge.database:insertTableToCollection()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'table',
                func = 'bridge.database:insertTableToCollection()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.database:insertTableToCollection()'
        }))
    end
end

---@param name string
---@param query table
function database:deleteTableToCollection(name, query)
    if name and type(name) == 'string' then
        if query and type(query) == 'table' then
            local filePath = ('collection/%s.json'):format(name)
            local collectionFile = LoadResourceFile(bridge.name, filePath)

            if collectionFile then
                local collectionData = json.decode(collectionFile)
                local queryData = {}

                for key, value in pairs(collectionData) do
                    local matches = true
                    local stack = {{ data = value, query = query }}

                    repeat
                        local current = table.remove(stack)

                        for k, v in pairs(current.query) do
                            if type(v) == 'table' and type(current.data[k]) == 'table' then
                                table.insert(stack, { data = current.data[k], query = v })
                            elseif current.data[k] ~= v then
                                matches = false

                                break
                            end
                        end

                        if not matches then
                            break
                        end
                    until #stack == 0

                    if not matches then
                        table.insert(queryData, value)
                    end
                end

                local data = json.encode(queryData, { indent = true })

                SaveResourceFile(bridge.name, filePath, data, #data)
            else
                bridge.logger:error(bridge.locale('collection_not_found', {
                    collection = name,
                    func = 'bridge.database:deleteTableToCollection()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('collection_not_found', {
                collection = name,
                func = 'bridge.database:deleteTableToCollection()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'query',
            func = 'bridge.database:deleteTableToCollection()'
        }))
    end
end

---@param name string
---@param query table
---@param update table
function database:updateTableToCollection(name, query, update)
    if name and type(name) == 'string' then
        if query and type(query) == 'table' then
            if update and type(update) == 'table' then
                local filePath = ('collection/%s.json'):format(name)
                local collectionFile = LoadResourceFile(bridge.name, filePath)

                if collectionFile then
                    local collectionData = json.decode(collectionFile)

                    for key, value in pairs(collectionData) do
                        local matches = true
                        local stack = {{ data = value, query = query }}

                        repeat
                            local current = table.remove(stack)

                            for k, v in pairs(current.query) do
                                if type(v) == 'table' and type(current.data[k]) == 'table' then
                                    table.insert(stack, { data = current.data[k], query = v })
                                elseif current.data[k] ~= v then
                                    matches = false

                                    break
                                end
                            end

                            if not matches then
                                break
                            end
                        until #stack == 0

                        if matches then
                            local updateStack = {{ data = value, updates = update }}

                            repeat
                                local currentUpdate = table.remove(updateStack)

                                for k, v in pairs(currentUpdate.updates) do
                                    if type(v) == 'table' and type(currentUpdate.data[k]) == 'table' then
                                        table.insert(updateStack, { data = currentUpdate.data[k], updates = v })
                                    else
                                        currentUpdate.data[k] = v
                                    end
                                end
                            until #updateStack == 0
                        end
                    end

                    local data = json.encode(collectionData, { indent = true })

                    SaveResourceFile(bridge.name, filePath, data, #data)
                else
                    bridge.logger:error(bridge.locale('collection_not_found', {
                        collection = name,
                        func = 'bridge.database:updateTableToCollection()'
                    }))
                end
            else
                bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                    param = 'update',
                    func = 'bridge.database:updateTableToCollection()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'query',
                func = 'bridge.database:updateTableToCollection()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.database:updateTableToCollection()'
        }))
    end
end

---@param name string
---@param query table
---@return table?
function database:getTableToCollection(name, query)
    if name and type(name) == 'string' then
        if query and type(query) == 'table' then
            local filePath = ('collection/%s.json'):format(name)
            local collectionFile = LoadResourceFile(bridge.name, filePath)

            if collectionFile then
                local queryData = {}
                local collectionData = json.decode(collectionFile)

                for key, value in pairs(collectionData) do
                    local matches = true
                    local stack = {{ data = value, query = query }}

                    repeat
                        local current = table.remove(stack)

                        for k, v in pairs(current.query) do
                            if type(v) == 'table' and type(current.data[k]) == 'table' then
                                table.insert(stack, { data = current.data[k], query = v })
                            elseif current.data[k] ~= v then
                                matches = false

                                break
                            end
                        end

                        if not matches then
                            break
                        end
                    until #stack == 0

                    if matches then
                        queryData[#queryData + 1] = value
                    end
                end

                return queryData
            else
                bridge.logger:error(bridge.locale('collection_not_found', {
                    collection = name,
                    func = 'bridge.database:getTableToCollection()'
                }))
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'query',
                func = 'bridge.database:getTableToCollection()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'name',
            func = 'bridge.database:getTableToCollection()'
        }))
    end
end

return database
