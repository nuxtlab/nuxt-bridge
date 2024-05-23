return {
    esx = {
        resourceName = 'es_extended',
        init = function ()
            local framework = exports['es_extended']:getSharedObject()

            framework.schema = {
                player = {}
            }

            -- TODO: Eventler.

            return framework
        end
    },
    qb = {
        resourceName = 'qb-core',
        init = function ()
            local framework = exports['qb-core']:GetCoreObject()

            framework.schema = {
                player = {}
            }

            -- TODO: Eventler.

            return framework
        end
    }
}
