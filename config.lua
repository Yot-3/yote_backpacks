-- ██    ██  ██████  ████████ ███████       ██████   █████   ██████ ██   ██ ██████   █████   ██████ ██   ██ ███████ 
-- ╚██  ██  ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██   ██ ██   ██ ██      ██  ██  ██      
--  ╚████   ██    ██    ██    █████         ██████  ███████ ██      █████   ██████  ███████ ██      █████   ███████ 
--   ╚██    ██    ██    ██    ██            ██   ██ ██   ██ ██      ██  ██  ██      ██   ██ ██      ██  ██       ██ 
--    ██     ██████     ██    ███████       ██████  ██   ██  ██████ ██   ██ ██      ██   ██  ██████ ██   ██ ███████ 

Config = {}

-- ═══════════════════════════════════════════════════════════════
--                         GENERAL SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.OneBagInInventory = true -- One bag limit
Config.RemoveBagInVehicle = true -- Remove visual in vehicle

-- Debug
Config.EnableDebugCommand = false -- Enable debug command to check current bag drawable/texture
Config.DebugCommandName = 'baginfo' -- Command name for debugging
-- Command gives info about current bag drawable/texture

-- ═══════════════════════════════════════════════════════════════
--                      BACKPACK SYSTEM TYPE
-- ═══════════════════════════════════════════════════════════════

-- Choose ONE system - do not enable both at the same time (We are working on making these work with both enabled, but it's not ready yet)
Config.UseInventoryBags = true -- Inventory items with props
Config.UseClothingBags = false -- illenium-appearance clothing

-- ═══════════════════════════════════════════════════════════════
--                    WEIGHT & SLOT SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.EnableWeightIncrease = true
Config.EnableSlotIncrease = true

-- ═══════════════════════════════════════════════════════════════
--              ILLENIUM-APPEARANCE INTEGRATION
-- ═══════════════════════════════════════════════════════════════

Config.ClothingBagWeightIncrease = 10000 -- Grams
Config.ClothingBagSlotIncrease = 10

-- Clothing Bag Blacklist
Config.ClothingBagBlacklist = {
    [0] = true, -- Block drawable 0 (no bag/default)
    -- [1] = {0, 1, 2}, -- Block specific textures of drawable 1
}

-- ═══════════════════════════════════════════════════════════════
--                       TIMING SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.SpawnDelay = 4500 -- Player connect delay (ms)
Config.BackpackCheckDelay = 1000 -- Duplicate check delay (ms)

-- ═══════════════════════════════════════════════════════════════
--                  BACKPACK ATTACHMENT SETTINGS
-- ═══════════════════════════════════════════════════════════════

-- Default settings for all bags unless overridden per backpack
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

-- ═══════════════════════════════════════════════════════════════
--                CUSTOM BACKPACK CONFIGURATIONS
-- ═══════════════════════════════════════════════════════════════

-- Only used if UseInventoryBags = true
-- Add as many backpacks as you want here
Config.Backpacks = {
    ['backpack'] = {
        label = 'Backpack',
        model = `sf_prop_sf_backpack_03a`,
        weightIncrease = 10000, -- Additional weight capacity (grams)
        slotIncrease = 10, -- Additional inventory slots
        offset = nil, -- nil = use default, or {x = 0.0, y = 0.0, z = 0.0}
        rotation = nil, -- nil = use default, or {x = 0.0, y = 0.0, z = 0.0}
    },
    ['duffel_bag'] = {
        label = 'Duffel Bag',
        model = `h4_p_h4_m_bag_var22_arm_s`,
        weightIncrease = 15000,
        slotIncrease = 10,
        offset = {x = -0.28, y = -0.02, z = -0.04},
        rotation = {x = 0.0, y = 90.0, z = 175.0},
    },
}

-- ═══════════════════════════════════════════════════════════════
--                    NOTIFICATION STRINGS
-- ═══════════════════════════════════════════════════════════════

Strings = {
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1 backpack on!',
    too_much_weight = 'You are carrying too much weight. Remove items first.',
    items_in_extra_slots = 'You have items in extra slots. Move them first.',
    cannot_remove_backpack = 'Cannot Remove Backpack',
}

-- Thank you @sugaa for the amazing suggestions!
