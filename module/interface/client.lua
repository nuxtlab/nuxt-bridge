local interface = {}

---@param text string
---@param style 'inform' | 'success' | 'error'
---@param duration number?
function interface:notify(text, style, duration)
    if text and type(text) == 'string' then
        if style and type(style) == 'string' then
            if not duration then
                duration = 3000
            end

            if bridge.framework.name == 'esx' then
                bridge.framework.ShowNotification(text, style, duration)
            elseif bridge.framework.name == 'qb' then
                bridge.framework.Functions.Notify(text, style == 'inform' and 'primary' or style, duration)
            end
        else
            bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
                param = 'type',
                func = 'bridge.interface:notify()'
            }))
        end
    else
        bridge.logger:error(bridge.locale('param_not_found_or_incorrect_type', {
            param = 'text',
            func = 'bridge.interface:notify()'
        }))
    end
end

return interface
