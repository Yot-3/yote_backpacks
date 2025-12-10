-- ██    ██  ██████  ████████ ███████       ██████   █████   ██████ ██   ██ ██████   █████   ██████ ██   ██ ███████ 
-- ╚██  ██  ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██   ██ ██   ██ ██      ██  ██  ██      
--  ╚████   ██    ██    ██    █████         ██████  ███████ ██      █████   ██████  ███████ ██      █████   ███████ 
--   ╚██    ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██      ██   ██ ██      ██  ██       ██ 
--    ██     ██████     ██    ███████       ██████  ██   ██  ██████ ██   ██ ██      ██   ██  ██████ ██   ██ ███████ 

Config = {}

-- General Settings
Config.OneBagInInventory = true -- One bag limit
Config.RemoveBagInVehicle = true -- Remove visual in vehicle

-- System Type
Config.UseInventoryBags = true -- Inventory items with props
Config.UseClothingBags = false -- illenium-appearance clothing

-- Debug
Config.EnableDebugCommand = true
Config.DebugCommandName = 'checkbag'

-- Capacity Settings
Config.EnableWeightIncrease = true
Config.EnableSlotIncrease = true

-- Clothing Bag Capacity
Config.ClothingBagWeightIncrease = 10000 -- Grams
Config.ClothingBagSlotIncrease = 10

-- Clothing Bag Blacklist
Config.ClothingBagBlacklist = {
    [0] = true, -- Block drawable 0 (no bag/default)
    -- [1] = {0, 1, 2}, -- Block specific textures of drawable 1
}

-- Default Attachment (override per backpack)
Config.DefaultBackpackOffset = {
    x = 0.07,
    y = -0.11,
    z = -0.05
}

Config.DefaultBackpackRotation = {
    x = 0.0,
    y = 90.0,
    z = 175.0
}

Config.BackpackBone = 24818

-- Timing
Config.SpawnDelay = 4500 -- Player connect delay (ms)
Config.BackpackCheckDelay = 1000 -- Duplicate check delay (ms)

-- Backpack Configurations (UseInventoryBags only)
Config.Backpacks = {
    ['backpack'] = {
        label = 'Backpack',
        model = `p_michael_backpack_s`,
        weightIncrease = 10000,
        slotIncrease = 10,
        offset = nil, -- nil = use default
        rotation = nil,
    },
    ['duffel_bag'] = {
        label = 'Duffel Bag',
        model = `prop_cs_heist_bag_02`,
        weightIncrease = 15000,
        slotIncrease = 15,
        offset = {x = 0.10, y = -0.15, z = -0.10},
        rotation = {x = 0.0, y = 90.0, z = 175.0},
    }
}

-- Notification Strings
Strings = {
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1 backpack on!',
    too_much_weight = 'You are carrying too much weight. Remove items first.',
    items_in_extra_slots = 'You have items in extra slots. Move them first.',
    cannot_remove_backpack = 'Cannot Remove Backpack',
}
