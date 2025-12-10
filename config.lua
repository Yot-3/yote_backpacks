-- ██    ██  ██████  ████████ ███████       ██████   █████   ██████ ██   ██ ██████   █████   ██████ ██   ██ ███████ 
-- ╚██  ██  ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██   ██ ██   ██ ██      ██  ██  ██      
--  ╚████   ██    ██    ██    █████         ██████  ███████ ██      █████   ██████  ███████ ██      █████   ███████ 
--   ╚██    ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██      ██   ██ ██      ██  ██       ██ 
--    ██     ██████     ██    ███████       ██████  ██   ██  ██████ ██   ██ ██      ██   ██  ██████ ██   ██ ███████ 

Config = {}

-- General Settings
Config.OneBagInInventory = true -- Allow only one bag in inventory?
Config.RemoveBagInVehicle = true -- Remove backpack visual when entering vehicle?

-- Backpack System Type
Config.UseInventoryBags = false -- Use inventory item backpacks with visual props?
Config.UseClothingBags = true -- Use clothing bags from illenium-appearance instead of inventory items?

-- Weight & Slot Settings (for inventory item backpacks)
Config.EnableWeightIncrease = true -- Enable weight increase when wearing backpack?
Config.EnableSlotIncrease = true -- Enable inventory slot increase when wearing backpack?

-- Illenium-Appearance Integration (for clothing bags)
Config.ClothingBagWeightIncrease = 10000 -- Weight increase when wearing a clothing bag
Config.ClothingBagSlotIncrease = 10 -- Slot increase when wearing a clothing bag

-- Backpack Attachment Settings (Default for all bags unless overridden)
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

Config.BackpackBone = 24818 -- Bone index for attachment

-- Timing Settings
Config.SpawnDelay = 4500 -- Delay after player connects before checking for backpack (ms)
Config.BackpackCheckDelay = 1000 -- Delay for duplicate backpack check (ms)

-- Custom Backpack Configurations (Only used if UseInventoryBags = true)
-- Add as many backpacks as you want here
Config.Backpacks = {
    ['backpack'] = {
        label = 'Backpack',
        model = `p_michael_backpack_s`,
        weightIncrease = 10000, -- Additional weight capacity (grams)
        slotIncrease = 10, -- Additional inventory slots
        offset = nil, -- nil = use default, or {x = 0.0, y = 0.0, z = 0.0}
        rotation = nil, -- nil = use default, or {x = 0.0, y = 0.0, z = 0.0}
    },
    ['duffel_bag'] = {
        label = 'Duffel Bag',
        model = `prop_cs_heist_bag_02`,
        weightIncrease = 15000,
        slotIncrease = 15,
        offset = {x = 0.10, y = -0.15, z = -0.10},
        rotation = {x = 0.0, y = 90.0, z = 175.0},
    },
}

Strings = { -- Notification strings
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1 backpack on!',
    too_much_weight = 'You are carrying too much weight. Remove items first.',
    items_in_extra_slots = 'You have items in extra slots. Move them first.',
    cannot_remove_backpack = 'Cannot Remove Backpack',
}
