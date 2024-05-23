local player = {}

---@return Player
function player:get()
    local data

    if bridge.framework.name == 'esx' then
        data = bridge.framework.GetPlayerData()
    elseif bridge.framework.name == 'qb' then
        data = bridge.framework.Functions.GetPlayer()
    end

    local transformedData = bridge:transform(data, bridge.framework.schema.player, bridge.data.schema.player) --[[@as Player]]

    return transformedData
end

return player
