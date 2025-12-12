local ox_inventory = exports.ox_inventory

local function GetOriginalCapacity(inventory, isClothingBag, backpackConfig)
    if isClothingBag then
        return {
            weight = inventory.maxWeight - Config.ClothingBagWeightIncrease,
            slots = inventory.slots - Config.ClothingBagSlotIncrease
        }
    else
        return {
            weight = inventory.maxWeight - (backpackConfig.weightIncrease or 0),
            slots = inventory.slots - (backpackConfig.slotIncrease or 0)
        }
    end
end

local function CanRemoveBag(source, originalWeight, originalSlots, excludeSlot)
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return false, nil end
    
    if Config.EnableWeightIncrease and inventory.weight > originalWeight then
        return false, 'weight'
    end
    
    if Config.EnableSlotIncrease then
        local playerItems = ox_inventory:GetInventoryItems(source)
        for _, item in pairs(playerItems) do
            if item.slot > originalSlots and item.slot ~= excludeSlot then
                return false, 'slots'
            end
        end
    end
    
    return true, nil
end

-- Inventory bag handlers
RegisterNetEvent('yote_backpack:increaseCapacity', function(itemName)
    if not Config.UseInventoryBags then return end
    
    local backpackConfig = Config.Backpacks[itemName]
    if not backpackConfig then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    if Config.EnableWeightIncrease and backpackConfig.weightIncrease then
        ox_inventory:SetMaxWeight(source, inventory.maxWeight + backpackConfig.weightIncrease)
    end
    
    if Config.EnableSlotIncrease and backpackConfig.slotIncrease then
        ox_inventory:SetSlotCount(source, inventory.slots + backpackConfig.slotIncrease)
    end
end)

RegisterNetEvent('yote_backpack:decreaseCapacity', function(itemName)
    if not Config.UseInventoryBags then return end
    
    local backpackConfig = Config.Backpacks[itemName]
    if not backpackConfig then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    if Config.EnableWeightIncrease and backpackConfig.weightIncrease then
        ox_inventory:SetMaxWeight(source, inventory.maxWeight - backpackConfig.weightIncrease)
    end
    
    if Config.EnableSlotIncrease and backpackConfig.slotIncrease then
        ox_inventory:SetSlotCount(source, inventory.slots - backpackConfig.slotIncrease)
    end
end)

-- Clothing bag handlers
RegisterNetEvent('yote_backpack:increaseClothingBag', function()
    if not Config.UseClothingBags then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    if Config.EnableWeightIncrease then
        ox_inventory:SetMaxWeight(source, inventory.maxWeight + Config.ClothingBagWeightIncrease)
    end
    
    if Config.EnableSlotIncrease then
        ox_inventory:SetSlotCount(source, inventory.slots + Config.ClothingBagSlotIncrease)
    end
end)

RegisterNetEvent('yote_backpack:decreaseClothingBag', function()
    if not Config.UseClothingBags then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    if Config.EnableWeightIncrease then
        ox_inventory:SetMaxWeight(source, inventory.maxWeight - Config.ClothingBagWeightIncrease)
    end
    
    if Config.EnableSlotIncrease then
        ox_inventory:SetSlotCount(source, inventory.slots - Config.ClothingBagSlotIncrease)
    end
end)

RegisterNetEvent('yote_backpack:canRemoveClothingBag', function()
    if not Config.UseClothingBags then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    local original = GetOriginalCapacity(inventory, true)
    local canRemove, reason = CanRemoveBag(source, original.weight, original.slots)
    
    if canRemove then
        TriggerClientEvent('yote_backpack:allowRemoveBag', source)
    else
        TriggerClientEvent('yote_backpack:cannotRemoveBag', source, reason)
    end
end)

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do Wait(500) end
    
    if not Config.UseInventoryBags then return end
    
    local backpackItemFilter = {}
    for itemName in pairs(Config.Backpacks) do
        backpackItemFilter[itemName] = true
    end
    
    -- Prevent removing backpack with excess weight/items
    local backpackRemovalHook = ox_inventory:registerHook('swapItems', function(payload)
        local itemName = payload.fromSlot.name
        local backpackConfig = Config.Backpacks[itemName]
        
        if backpackConfig and payload.fromType == 'player' then
            local inventory = ox_inventory:GetInventory(payload.source)
            local original = GetOriginalCapacity(inventory, false, backpackConfig)
            local canRemove, reason = CanRemoveBag(payload.source, original.weight, original.slots, payload.fromSlot.slot)
            
            if not canRemove then
                local messages = {
                    weight = Strings.too_much_weight,
                    slots = Strings.items_in_extra_slots
                }
                
                TriggerClientEvent('ox_lib:notify', payload.source, {
                    type = 'error',
                    title = Strings.cannot_remove_backpack,
                    description = messages[reason]
                })
                return false
            end
        end
        
        return true
    end, {
        print = false,
        itemFilter = backpackItemFilter,
    })
    
    -- Enforce one backpack limit on swap
    local swapHook = ox_inventory:registerHook('swapItems', function(payload)
        if not Config.OneBagInInventory then return true end
        
        if payload.toType == 'player' and payload.toInventory ~= payload.fromInventory and Config.Backpacks[payload.fromSlot.name] then
            for itemName in pairs(Config.Backpacks) do
                local count = ox_inventory:GetItem(payload.source, itemName, nil, true)
                if count > 0 then
                    TriggerClientEvent('ox_lib:notify', payload.source, {
                        type = 'error',
                        title = Strings.action_incomplete,
                        description = Strings.one_backpack_only
                    })
                    return false
                end
            end
        end
        
        return true
    end, {
        print = false,
        itemFilter = backpackItemFilter,
    })
    
    -- Enforce one backpack limit on creation/receiving
    local createHook
    if Config.OneBagInInventory then
        createHook = ox_inventory:registerHook('createItem', function(payload)
            if not Config.Backpacks[payload.item.name] then return end
            
            local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)
            local existingBag = nil
            local existingSlot = nil
            
            for _, item in pairs(playerItems) do
                if Config.Backpacks[item.name] then
                    existingBag = item.name
                    existingSlot = item.slot
                    break
                end
            end
            
            if existingBag then
                CreateThread(function()
                    Wait(Config.BackpackCheckDelay)
                    
                    local currentItems = ox_inventory:GetInventoryItems(payload.inventoryId)
                    for _, item in pairs(currentItems) do
                        if Config.Backpacks[item.name] and item.slot ~= existingSlot then
                            local success = ox_inventory:RemoveItem(payload.inventoryId, item.name, 1, nil, item.slot)
                            if success then
                                TriggerClientEvent('ox_lib:notify', payload.inventoryId, {
                                    type = 'error',
                                    title = Strings.action_incomplete,
                                    description = Strings.one_backpack_only
                                })
                            end
                            break
                        end
                    end
                end)
            end
        end, {
            print = false,
            itemFilter = backpackItemFilter
        })
    end
    
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            ox_inventory:removeHooks(backpackRemovalHook)
            ox_inventory:removeHooks(swapHook)
            if createHook then
                ox_inventory:removeHooks(createHook)
            end
        end
    end)
end)
