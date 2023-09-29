local QBCore = exports[Config.CoreName]:GetCoreObject()

QBCore.Functions.CreateCallback('rv_meth:server:CanAffordMission', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetMoney('cash') > Config.Boat.Deposit then
        Player.Functions.RemoveMoney('cash', Config.Boat.Deposit)
        cb(true)
        return
    end
    TriggerClientEvent('QBCore:Notify', src, Locale.Error.cannot_afford, 'error')
    cb(false)
end)

QBCore.Functions.CreateCallback('rv_meth:server:HasCookingSupplies', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.LithiumItem)
    local amount = 0
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_lithium, 'error')
        cb(0)
        return
    end
    amount = item.amount
    local item = Player.Functions.GetItemByName(Config.AmmoniaItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_ammonia, 'error')
        cb(0)
        return
    end
    if item.amount < amount then
        amount = item.amount
    end
    local item = Player.Functions.GetItemByName(Config.PhosphorusItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_phosphorus, 'error')
        cb(0)
        return
    end
    if item.amount < amount then
        amount = item.amount
    end
    cb(amount)
end)

QBCore.Functions.CreateCallback('rv_meth:server:GetRawMeth', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.RawMethItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_raw_meth, 'error')
        cb(0)
        return
    end
    cb(item.amount)
end)

QBCore.Functions.CreateCallback('rv_meth:server:GetLabs', function(source, cb)
    local src = source
    local response = MySQL.query.await('SELECT * FROM rv_meth_labs')
    cb(response)
end)

QBCore.Functions.CreateUseableItem(Config.MethLabItem, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('rv_meth:client:CreateLab', src)
    Player.Functions.RemoveItem(Config.MethLabItem)
end)

RegisterNetEvent('rv_meth:server:RegisterLab', function(coords, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.insert.await('INSERT INTO `rv_meth_labs` (citizenid, x, y, z, heading) VALUES (?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid, coords.x, coords.y, coords.z - 1, heading
    })
    TriggerClientEvent('rv_meth:client:SyncCreateLab', -1, coords, heading)
end)

RegisterNetEvent('rv_meth:server:RemoveLab', function(coords, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.Async.execute('DELETE FROM `rv_meth_labs` WHERE citizenid = ? AND x = ? AND y = ? AND z = ? AND heading = ?', {
        Player.PlayerData.citizenid, coords.x, coords.y, coords.z, heading
    })
    TriggerClientEvent('rv_meth:client:SyncDeleteLab', -1, coords, heading)
end)

RegisterNetEvent('rv_meth:server:CrateReward', function(crate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local reward = crate.Rewards[math.random(#crate.Rewards)]
    Player.Functions.AddItem(reward.itemName, math.random(reward.amountMin, reward.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.itemName], 'add')
end)

RegisterNetEvent('rv_meth:server:GiveBackLab', function(crate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.MethLabItem)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MethLabItem], 'add')
end)

RegisterNetEvent('rv_meth:server:CookMeth', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PhosphorusItem)
    if item == nil or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.missing_items, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.PhosphorusItem, amount)
    Player.Functions.RemoveItem(Config.AmmoniaItem, amount)
    Player.Functions.RemoveItem(Config.LithiumItem, amount)
    Player.Functions.AddItem(Config.RawMethItem, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RawMethItem], 'add')
end)

RegisterNetEvent('rv_meth:server:PackageMeth', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.RawMethItem)
    if item == nil or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_raw_meth, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.RawMethItem, amount)
    Player.Functions.AddItem(Config.MethBaggyItem, math.floor(amount / 2))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MethBaggyItem], 'add')
end)

RegisterNetEvent('rv_meth:server:ReturnBoat', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', Config.Boat.Deposit)
end)