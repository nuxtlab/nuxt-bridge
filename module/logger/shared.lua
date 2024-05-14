local logger = {}

---@param ... any
function logger:inform(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^5[INFORM]^7 %s'):format(text)

        print(formattedText)
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = '...',
            func = 'bridge.logger:inform()'
        }))
    end
end

---@param ... any
function logger:success(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^2[SUCCESS]^7 %s'):format(text)

        print(formattedText)
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = '...',
            func = 'bridge.logger:success()'
        }))
    end
end

---@param ... any
function logger:error(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^1[ERROR]^7 %s'):format(text)

        print(formattedText)
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = '...',
            func = 'bridge.logger:error()'
        }))
    end
end

return logger
