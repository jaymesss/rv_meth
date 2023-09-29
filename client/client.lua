local QBCore = exports[Config.CoreName]:GetCoreObject()
local Boat = nil
local Mission = nil
local Blip = nil
local ReturnBoat = false
local Untied = 0

Citizen.CreateThread(function()
    -- BOAT
    RequestModel(GetHashKey(Config.Boat.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.Boat.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.Boat.Ped.Model), Config.Boat.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports[Config.TargetName]:AddBoxZone('meth-boat', Config.Boat.Target.Coords, 1.5, 1.6, {
        name = "meth-boat",
        heading = Config.Boat.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_meth:client:StartMission",
                icon = "fas fa-flask",
                label = Locale.Info.start_meth_job
            }
        }
    })
    -- METH LAB PURCHASE
    RequestModel(GetHashKey(Config.MethLabShop.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.MethLabShop.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.MethLabShop.Ped.Model), Config.MethLabShop.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports[Config.TargetName]:AddBoxZone('meth-lab-shop', Config.MethLabShop.Target.Coords, 1.5, 1.6, {
        name = "meth-lab-shop",
        heading = Config.MethLabShop.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_meth:client:MethLabShop",
                icon = "fas fa-flask",
                label = Locale.Info.purchase_lab
            }
        }
    })
    -- LABS SETUP
    LoadModel(GetHashKey('prop_box_wood02a_pu'))
    local model = -2059889071
    local p = promise.new()
    local labs
    QBCore.Functions.TriggerCallback('rv_meth:server:GetLabs', function(result)
        p:resolve(result)
    end)
    labs = Citizen.Await(p)
    for k,v in pairs(labs) do
        local old = GetClosestObjectOfType(v.x, v.y, v.z, 3.0, model, false, false, false)
        if old ~= nil then
            RemoveMethLabTarget(vector3(v.x, v.y, v.z), v.heading)
            SetEntityAsMissionEntity(old)
            DeleteObject(old)
        end
        local lab = CreateObject(model, v.x, v.y, v.z, false, false, false)
        SetEntityHeading(lab, v.heading)
        SetEntityInvincible(lab, true)
        FreezeEntityPosition(lab, true)
        AddMethLabTarget(vector3(v.x, v.y, v.z), v.heading)
    end
end)

function AddMethLabTarget(coords, heading) 
    exports[Config.TargetName]:AddBoxZone('meth-lab' .. coords.x .. coords.y .. coords.z .. heading, coords, 2.5, 2.6, {
        name = 'meth-lab' .. coords.x .. coords.y .. coords.z .. heading,
        heading = heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_meth:client:CookMeth",
                icon = "fas fa-flask",
                label = Locale.Info.cook_meth
            },
            {
                type = "client",
                event = "rv_meth:client:PackageMeth",
                icon = "fas fa-bag-shopping",
                label = Locale.Info.package_meth
            },
            {
                type = "client",
                action = function()
                    TriggerEvent('animations:client:EmoteCommandStart', {"hammer"})
                    QBCore.Functions.Progressbar("destroying", Locale.Info.destroying_lab, math.random(10000, 20000), false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        RemoveMethLabTarget(coords, heading)
                        TriggerServerEvent('rv_meth:server:RemoveLab', coords, heading)
                        SetEntityAsMissionEntity(old)
                        DeleteObject(old)
                        TriggerServerEvent('rv_meth:server:GiveBackLab')
                    end, function() -- Cancel
                    end)
                end,
                icon = "fas fa-x",
                label = Locale.Info.destroy_lab
            }
        }
    })
end

function RemoveMethLabTarget(coords, heading)
    exports[Config.TargetName]:RemoveZone('meth-lab' .. coords.x .. coords.y .. coords.z .. heading)
end

Citizen.CreateThread(function()
    while true do
        if ReturnBoat then
            local coords = GetEntityCoords(PlayerPedId(), false)
            local boatCoords = Config.Boat.Spawn.Coords
            if GetDistanceBetweenCoords(coords, boatCoords) < 10 and GetEntitySpeed(Boat) < 15 then
                DrawMarker(2,vector3(boatCoords.x, boatCoords.y, boatCoords.z + 1), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                DrawText3Ds(vector3(boatCoords.x, boatCoords.y, boatCoords.z + 1), '~g~E~w~ - ' .. Locale.Info.return_boat) 
                if IsControlJustReleased(0, 38) then
                    QBCore.Functions.Progressbar("returning", Locale.Info.returning_boat, 2000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        SetEntityAsMissionEntity(Boat, true, true)
                        DeleteVehicle(Boat)
                        RemoveBlip(Blip)
                        TriggerServerEvent('rv_meth:server:ReturnBoat')
                        Boat = nil
                        Mission = nil
                        Blip = nil
                        ReturnBoat = false
                        Untied = 0
                    end, function() -- Cancel
                    end)
                end
            end
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('rv_meth:client:CreateLab', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"hammer"})
    QBCore.Functions.Progressbar("setting_up", Locale.Info.setting_up_lab, math.random(10000, 20000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        LoadModel(GetHashKey('prop_box_wood02a_pu'))
        local model = -2059889071
        local old = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, model, false, false, false)
        if old ~= nil then
            RemoveMethLabTarget(GetEntityCoords(old), GetEntityHeading(old))
            DeleteObject(old)
        end
        TriggerServerEvent('rv_meth:server:RegisterLab', GetEntityCoords(ped), GetEntityHeading(ped))
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_meth:client:SyncCreateLab', function(coords, heading)
    local model = -2059889071
    local lab = CreateObject(model, coords.x, coords.y, coords.z - 1, false, false, false)
    SetEntityHeading(lab, heading)
    SetEntityInvincible(lab, true)
    FreezeEntityPosition(lab, true)
    AddMethLabTarget(GetEntityCoords(lab), GetEntityHeading(lab))
end)

RegisterNetEvent('rv_meth:client:SyncDeleteLab', function(coords, heading)
    local model = -2059889071
    local old = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, model, false, false, false)
    if old ~= nil then
        RemoveMethLabTarget(vector3(coords.x, coords.y, coords.z), heading)
        SetEntityAsMissionEntity(old)
        DeleteObject(old)
    end
end)

RegisterNetEvent('rv_meth:client:CookMeth', function()
    local p = promise.new()
    local amount
    QBCore.Functions.TriggerCallback('rv_meth:server:HasCookingSupplies', function(result)
        p:resolve(result)
    end)
    amount = Citizen.Await(p)
    if amount <= 0 then
        return
    end
    TriggerEvent('animations:client:EmoteCommandStart', {"beer3"})
    local duration = 5000 + (amount * 5000)
    QBCore.Functions.Progressbar("cooking_meth", Locale.Info.cooking_meth, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('rv_meth:server:CookMeth', amount)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_meth:client:PackageMeth', function()
    local p = promise.new()
    local amount
    QBCore.Functions.TriggerCallback('rv_meth:server:GetRawMeth', function(result)
        p:resolve(result)
    end)
    amount = Citizen.Await(p)
    if amount <= 0 then
        return
    end
    TriggerEvent('animations:client:EmoteCommandStart', {"bong2"})
    local duration = 5000 + (amount * 1500)
    QBCore.Functions.Progressbar("packaging_meth", Locale.Info.packaging_meth, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('rv_meth:server:PackageMeth', amount)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_meth:client:StartMission', function()
    lib.registerContext({
        id = 'meth_boat',
        title = Locale.Info.job_listing,
        options = {
            {
                title = Locale.Info.start_job,
                description = Locale.Info.start_job_description,
                icon = 'money-bill',
                onSelect = function()
                    local p = promise.new()
                    local allowed
                    QBCore.Functions.TriggerCallback('rv_meth:server:CanAffordMission', function(result)
                        p:resolve(result)
                    end)
                    allowed = Citizen.Await(p)
                    if not allowed then
                        return
                    end
                    if Boat ~= nil then
                        QBCore.Functions.Notify(Locale.Error.already_have_mission, 'error', 5000)
                        return
                    end
                    QBCore.Functions.Notify(Locale.Info.head_over, 'success', 5000)
                    SpawnBoat()
                end
            },
            {
                title = Locale.Info.dont_start,
                description = Locale.Info.dont_start_description,
                icon = 'x',
                onSelect = function()
                    QBCore.Functions.Notify(Locale.Error.backed_out, 'error', 5000)
                end
            },           
        },
    })
    lib.showContext('meth_boat')
end)

RegisterNetEvent('rv_meth:client:MethLabShop', function()
    local items = {
        label = Config.MethLabShop.Label,
        slots = Config.MethLabShop.Slots,
        items = Config.MethLabShop.Items
    }
    TriggerServerEvent('inventory:server:OpenInventory', 'shop', Config.MethLabShop.Label, items)
end)


function SpawnBoat()
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netid)
        local vehicle = NetToVeh(netid)
        exports[Config.FuelResource]:SetFuel(vehicle, 100)
        SetEntityHeading(vehicle, Config.Boat.Spawn.Coords.w)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        Boat = vehicle
    end, Config.Boat.Model, Config.Boat.Spawn.Coords, false)
    while Boat == nil do
        Citizen.Wait(1)
    end
    Mission = Config.DivingLocations[math.random(#Config.DivingLocations)]
    LoadModel(GetHashKey('prop_box_wood02a_pu'))
    for k,v in pairs(Mission) do
        local crate = CreateObject(-1861623876, v.Coords.x, v.Coords.y, v.Coords.z, false, false, false)
        SetEntityHeading(crate, v.Coords.w)
        SetEntityInvincible(crate, true)
        FreezeEntityPosition(crate, true)
        exports[Config.TargetName]:AddBoxZone('meth-crate' .. v.Coords.x .. v.Coords.y .. v.Coords.z, v.Coords, 1.5, 1.6, {
            name = 'meth-crate' .. v.Coords.x .. v.Coords.y .. v.Coords.z,
            heading = v.Coords.w,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        QBCore.Functions.Progressbar("untying", Locale.Info.untying_crate, math.random(2000, 4500), false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            Untied = Untied + 1
                            exports[Config.TargetName]:RemoveZone('meth-crate' .. v.Coords.x .. v.Coords.y .. v.Coords.z)
                            if Untied == #Mission then
                                ReturnBoat = true
                                RemoveBlip(Blip)
                                Blip = AddBlipForCoord(Config.Boat.Spawn.Coords)
                                SetBlipSprite(Blip, 427)
                                SetBlipScale(Blip, 0.9)
                                SetBlipColour(Blip, 4)
                                SetBlipDisplay(Blip, 4)
                                SetBlipAsShortRange(Blip, false)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentSubstringPlayerName("Return Boat")
                                EndTextCommandSetBlipName(Blip)
                                QBCore.Functions.Notify(Locale.Info.return_boat, 'success', 5000)
                            end
                            SetEntityAsMissionEntity(crate, true, true)
                            DeleteEntity(crate)
                            TriggerServerEvent('rv_meth:server:CrateReward', v)
                        end, function() -- Cancel
                        end)
                    end,
                    icon = "fas fa-flask",
                    label = Locale.Info.untie_crate
                }
            }
        })
    end
    Blip = AddBlipForCoord(Mission[1].Coords)
    SetBlipSprite(Blip, 94)
    SetBlipScale(Blip, 0.9)
    SetBlipColour(Blip, 4)
    SetBlipDisplay(Blip, 4)
    SetBlipAsShortRange(Blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(#Mission .. " Underwater Crates")
    EndTextCommandSetBlipName(Blip)
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x,coords.y,coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end