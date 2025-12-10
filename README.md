# yote_backpacks

A highly configurable backpack system for FiveM using ox_inventory with visual backpack props, inventory management, and illenium-appearance integration.

**Say goodbye to secondary inventories and hello to an expandable inventory!**

This script removes the fear of powergaming by NOT creating a separate backpack inventory. Instead, it dynamically increases your main ox_inventory slots and/or weight capacity. All items remain in your primary inventory, just with expanded capacity when wearing a backpack.

## Why This Matters

Traditional backpack systems create separate inventories that:
- Can be exploited for powergaming (hiding items during searches)
- Create confusion about where items are stored
- Require additional UI elements and inventory management
- Can cause item duplication or loss bugs

**yote_backpacks solves this by:**
- ✅ Expanding your MAIN inventory when wearing a backpack
- ✅ Keeping all items in ONE inventory that's searchable by police/admins
- ✅ No hidden storage or secondary containers
- ✅ Simple, clean, and exploit-proof
- ✅ Seamless integration with existing ox_inventory features

## Features

- **0.0 ms Usage** - Optimized performance with no resource drain
- **Single Inventory System** - No secondary inventories, just expanded main inventory
- **Dual Mode System** - Choose between inventory item backpacks with props OR clothing bags from illenium-appearance
- **Multiple Backpack Types** - Configure unlimited custom backpacks with unique models, weights, and slots
- **Weight & Slot Increase** - Configurable weight and inventory slot bonuses per backpack
- **Smart Removal Prevention** - Can't remove backpack if overweight or using extra slots
- **Disconnection Protection** - Items in extra slots are saved and restored on reconnect
- **Vehicle Integration** - Optional backpack removal when entering vehicles
- **Single Backpack Limit** - Optional enforcement of one backpack per player
- **Fully Configurable** - All settings, positions, and strings in config.lua
- **Framework Compatible** - Works with ox_core, ESX, QBCore, and any framework using ox_inventory

## Installation

1. Download this script
2. Add the backpack items to your inventory (see below)
3. Add backpack images to `ox_inventory/web/images/` (found in `yote_backpacks/_inventory_images/`)
4. Place script in your `resources` directory
5. Ensure `yote_backpacks` **after** `ox_lib` but **before** `ox_inventory`
6. Configure `config.lua` to choose your backpack system mode

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [illenium-appearance](https://github.com/iLLeniumStudios/illenium-appearance) (Optional - only if using clothing bags)

## Configuration

All settings can be found in `config.lua`:

### System Type Selection
```lua
Config.UseInventoryBags = true -- Use inventory item backpacks with visual props?
Config.UseClothingBags = false -- Use clothing bags from illenium-appearance?
```
**Note**: You can enable one, both, or neither system

### General Settings
```lua
Config.OneBagInInventory = true -- Allow only one bag in inventory?
Config.RemoveBagInVehicle = true -- Remove backpack visual in vehicles?
```

### Weight & Slot Settings (Inventory Bags)
```lua
Config.EnableWeightIncrease = true -- Enable weight increase?
Config.EnableSlotIncrease = true -- Enable slot increase?
```

### Illenium-Appearance Integration (Clothing Bags)
```lua
Config.ClothingBagWeightIncrease = 10000 -- Weight increase when wearing clothing bag
Config.ClothingBagSlotIncrease = 10 -- Slot increase when wearing clothing bag
```

### Backpack Attachment Settings
```lua
Config.DefaultBackpackOffset = { x = 0.07, y = -0.11, z = -0.05 }
Config.DefaultBackpackRotation = { x = 0.0, y = 90.0, z = 175.0 }
Config.BackpackBone = 24818 -- Bone index for attachment
```

### Custom Backpack Configurations
```lua
Config.Backpacks = {
    ['backpack'] = {
        label = 'Backpack',
        model = `p_michael_backpack_s`,
        weightIncrease = 10000, -- grams
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
    },
    -- Add as many custom backpacks as you want!
}
```

### Timing Settings
```lua
Config.SpawnDelay = 4500 -- Delay after player connects (ms)
Config.BackpackCheckDelay = 1000 -- Delay for duplicate check (ms)
```

## Item Configuration

### For Inventory Item Backpacks
Add these to `ox_inventory/data/items.lua`:

```lua
['backpack'] = {
    label = 'Backpack',
    weight = 220,
    stack = false,
    consume = 0,
},

['duffel_bag'] = {
    label = 'Duffel Bag',
    weight = 350,
    stack = false,
    consume = 0,
},
```

## How It Works

### The Core Concept: Expanded Main Inventory
Unlike traditional backpack systems that create a separate container, yote_backpacks modifies your main inventory's capacity:

**Without Backpack:**
- Inventory: 50 slots, 30kg capacity
- All items visible in main inventory

**With Backpack:**
- Inventory: 60 slots (+10), 40kg capacity (+10kg)
- **Still one inventory**, just with more space
- Police can search and see ALL items
- No hidden compartments or secondary storage

### Inventory Item Backpacks
1. **Equipping**: When a player has a backpack in their inventory, it automatically appears on their back
2. **Visual Prop**: Backpack model is spawned and attached to the player
3. **Weight Bonus**: Player's max weight increases by the backpack's configured amount
4. **Slot Bonus**: Player gains additional inventory slots based on backpack type
5. **Removal Protection**: Can't remove backpack if:
   - Current weight exceeds original max weight
   - Items are in the extra slots provided by the backpack
6. **Vehicle Handling**: Backpack visual can be automatically removed when entering vehicles

### Clothing Bag Integration (illenium-appearance)
1. **Clothing Component**: Uses the existing bag clothing component (component 5) from character creator
2. **Automatic Detection**: Script detects when player equips/removes a clothing bag
3. **Weight & Slot Bonus**: Applies configured bonuses when wearing any clothing bag
4. **Removal Protection**: Can't remove clothing bag via appearance menu if:
   - Current weight exceeds original max weight
   - Items are in the extra slots provided by the bag
5. **Forced Restoration**: If player somehow removes the bag while restricted, it's automatically put back on

### Disconnection Protection
- When a player disconnects with items in extra slots, those items are saved to a JSON file
- Items are automatically restored when the player reconnects with the same backpack
- Prevents item loss from unexpected disconnections or server restarts

## Usage Modes

### Mode 1: Inventory Items Only
```lua
Config.UseInventoryBags = true
Config.UseClothingBags = false
```
Players use backpack items from inventory with visual props

### Mode 2: Clothing Bags Only
```lua
Config.UseInventoryBags = false
Config.UseClothingBags = true
```
Players use clothing bags from illenium-appearance character creator

### Mode 3: Both Systems
```lua
Config.UseInventoryBags = true
Config.UseClothingBags = true
```
Players can use both inventory backpacks AND clothing bags simultaneously

### Mode 4: Disabled
```lua
Config.UseInventoryBags = false
Config.UseClothingBags = false
```
Script is effectively disabled (useful for testing)

## Anti-Powergaming Features

### Why This System Can't Be Exploited

1. **Single Inventory**: All items remain in your main inventory
   - Police searches show EVERYTHING
   - Admin tools can see ALL items
   - No "hidden" backpack inventory to abuse

2. **Removal Prevention**: Can't drop backpack to avoid searches
   - System prevents removal if slots are in use
   - Forced to keep backpack on if using extra capacity
   - No quick-drop exploits

3. **Visual Confirmation**: Backpack is visible on player
   - Officers can see if someone has expanded capacity
   - Prop appears on player's back (inventory bags mode)
   - Clothing bag visible in appearance (clothing mode)

4. **Transparent System**: Everything uses ox_inventory's native features
   - No custom inventory containers
   - No hidden storage compartments
   - Works with all existing ox_inventory features

## Customization

### Adding New Backpack Types
Simply add a new entry to `Config.Backpacks`:
```lua
['your_backpack'] = {
    label = 'Your Custom Backpack',
    model = `prop_model_hash`, -- Find models in CodeWalker
    weightIncrease = 12000,
    slotIncrease = 12,
    offset = {x = 0.0, y = 0.0, z = 0.0}, -- Adjust for proper positioning
    rotation = {x = 0.0, y = 0.0, z = 0.0},
},
```

### Customizing Messages
Edit the `Strings` table in `config.lua`:
```lua
Strings = {
    action_incomplete = 'Action Incomplete',
    one_backpack_only = 'You can only have 1 backpack on!',
    too_much_weight = 'You are carrying too much weight. Remove items first.',
    items_in_extra_slots = 'You have items in extra slots. Move them first.',
    cannot_remove_backpack = 'Cannot Remove Backpack',
}
```

### Adjusting Backpack Position
Each backpack can have custom offset and rotation, or use defaults:
- `offset` - Position relative to player (x, y, z in meters)
- `rotation` - Rotation angles (x, y, z in degrees)
- Set to `nil` to use `Config.DefaultBackpackOffset` and `Config.DefaultBackpackRotation`

## Performance

- **Client**: 0.00ms idle, 0.01ms when checking inventory changes
- **Server**: Minimal resource usage, event-driven architecture
- **Resmon**: Consistently shows 0.00ms in most scenarios
- **Optimizations**: Uses ox_lib caching, minimal loops, event-based updates

## Support

For support, bug reports, or feature requests:
- Join our Discord: [Your Discord Link]
- GitHub Issues: [Your GitHub Link]
- Documentation: This README

## Credits

- Originally inspired by wasabi_backpack
- Heavily modified and enhanced by yote_backpacks
- Uses ox_lib and ox_inventory by Overextended
- Compatible with illenium-appearance by iLLenium Studios

## License

This project is open source and available for modification and redistribution.
Feel free to modify and use in your server, but please provide credit to the original creator.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Tested On**: FiveM Build 6683, ox_inventory v2.x, illenium-appearance v1.x
