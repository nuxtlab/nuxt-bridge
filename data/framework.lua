return {
    esx = {
        resourceName = 'es_extended',
        init = function ()
            local payload = {}

            -- TODO

            return payload
        end
    },
    qb = {
        resourceName = 'qb-core',
        init = function ()
            local payload = exports['qb-core']:GetCoreObject()

            payload.object = {
                player = {
                    PlayerData = {
                        source = 'source',
                        citizenid = 'identifier',
                        charinfo = {
                            firstname = 'firstname',
                            lastname = 'lastname'
                        }
                    }
                }
            }

            -- TODO: Eventler.

            return payload
        end
    },
    ox = {
        resourceName = 'ox_core',
        init = function ()
            local payload = {}

            -- TODO

            return payload
        end
    }
}
