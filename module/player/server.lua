local player = {}

---@param query table
---@return Player?
function player:find(query)
    if query and type(query) == 'table' then
        local players = {}

        if bridge.framework.name == 'esx' then
            players = bridge.framework.Players
        elseif bridge.framework.name == 'qb' then
            players = bridge.framework.Players
        end

        local result
        local transformedQuery = bridge:transform(query, bridge.data.schema.player, bridge.framework.schema.player)

        for key, value in pairs(players) do
            local matches = true
            local stack = { { data = value, query = transformedQuery } }

            repeat
                local current = table.remove(stack)

                for k, v in pairs(current.query) do
                    if type(v) == 'table' and type(current.data[k]) == 'table' then
                        stack[#stack+1] = { data = current.data[k], query = v }
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
                result = bridge:transform(value, bridge.framework.schema.player, bridge.data.schema.player)

                break
            end
        end

        return result
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'query',
            func = 'bridge.player:find()'
        }))
    end
end

return player
