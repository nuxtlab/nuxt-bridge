local logger = {}

---@param ... any
function logger:inform(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^5[INFORM]^7 %s'):format(text)

        print(formattedText)
    else
        lib.logger:error('39456')
    end
end

---@param ... any
function logger:success(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^2[SUCCESS]^7 %s'):format(text)

        print(formattedText)
    else
        lib.logger:error('87023')
    end
end

---@param ... any
function logger:error(...)
    local text = table.concat({ ... }, ' ')

    if text and type(text) == 'string' then
        local formattedText = ('^1[ERROR]^7 %s'):format(text)

        print(formattedText)
    else
        lib.logger:error('56139')
    end
end

return logger
