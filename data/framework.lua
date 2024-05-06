return {
    esx = {
        resourceName = 'es_extended',
        init = function ()
            return {
                getPlayerData = function ()
                    return {
                        name = 'Jhon',
                        surname = 'Doe'
                    }
                end
            }
        end
    },
    qb = {
        resourceName = 'qb-core',
        init = function ()
            return {}
        end
    }
}
