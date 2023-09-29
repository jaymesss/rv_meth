Config = {}
Config.CoreName = "qb-core"
Config.TargetName = "qb-target"
Config.FuelResource = 'cdn-fuel'
Config.MethLabItem = 'meth_lab_system'
Config.LithiumItem = 'lithium'
Config.AmmoniaItem = 'ammonia'
Config.PhosphorusItem = 'phosphorus'
Config.RawMethItem = 'raw_meth'
Config.MethBaggyItem = 'meth_baggy'
Config.Boat = {
    Deposit = 500,
    Model = 'longfin',
    Ped = {
        Coords = vector4(-1612.26, 5261.56, 2.97, 199.14),
        Model = 'a_m_m_eastsa_01'
    },
    Target = {
        Coords = vector3(-1612.26, 5261.56, 3.97),
        Heading = 22,
    },
    Spawn = {
        Coords = vector4(-1600.78, 5260.43, 0.11, 27.58),
    }
}
Config.MethLabShop = {
    Ped = {
        Coords = vector4(569.03, 2796.58, 41.02, 275.51),
        Model = 'a_m_o_acult_02'
    },
    Target = {
        Coords = vector3(569.16, 2796.59, 42.02),
        Heading = 85,
    },
    Label = 'Meth Shop',
    Slots = 40,
    Items = {
        { name = 'meth_lab_system', price = 5000, amount = 50, type = "item", slot = 1, info = {} },
    }
}
Config.DivingLocations = {
    {
        {
            Coords = vector4(-905.06, 6603.71, -33.78, 285.47),
            Rewards = {
                { itemName = 'lithium', amountMin = 3, amountMax = 8}
            }
        },
        {
            Coords = vector4(-896.1, 6601.38, -34.36, 76.85),
            Rewards = {
                { itemName = 'ammonia', amountMin = 3, amountMax = 8}
            }
        },
        {
            Coords = vector4(-898.99, 6612.53, -33.41, 132.38),
            Rewards = {
                { itemName = 'phosphorus', amountMin = 3, amountMax = 8}
            }
        },
    }

}