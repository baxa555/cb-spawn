if Config.Settings['Framework'] == "esx" or Config.Settings['Framework'] == "oldesx" then
    ESX.RegisterServerCallback('n-spawn-selector:server:getlastlocation', function(source, cb)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local result = Execute_Sql('SELECT position FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
        if result[1] then
            cb(json.decode(result[1].position))
        else
            cb(nil)
        end
    end)
    
    
    ESX.RegisterServerCallback('n-spawn-selector:server:isdead', function(source, cb)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local result = Execute_Sql('SELECT is_dead FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
        if result[1] then
            cb(result[1].is_dead)
        else
            cb(nil)
        end
    end)
end