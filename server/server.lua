local ox_inventory = exports.ox_inventory

RegisterServerEvent('yote_backpack:increaseCapacity')
AddEventHandler('yote_backpack:increaseCapacity', function(itemName)
    local source = source
    local backpackConfig = Config.Backpacks[itemName]
    if not backpackConfig then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if inventory then
        if Config.EnableWeightIncrease and backpackConfig.weightIncrease then
            ox_inventory:SetMaxWeight(source, inventory.maxWeight + backpackConfig.weightIncrease)
        end
        
        if Config.EnableSlotIncrease and backpackConfig.slotIncrease then
            ox_inventory:SetSlotCount(source, inventory.slots + backpackConfig.slotIncrease)
        end
    end
end)

RegisterServerEvent('yote_backpack:decreaseCapacity')
AddEventHandler('yote_backpack:decreaseCapacity', function(itemName)
    local source = source
    local backpackConfig = Config.Backpacks[itemName]
    if not backpackConfig then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if inventory then
        if Config.EnableWeightIncrease and backpackConfig.weightIncrease then
            ox_inventory:SetMaxWeight(source, inventory.maxWeight - backpackConfig.weightIncrease)
        end
        
        if Config.EnableSlotIncrease and backpackConfig.slotIncrease then
            ox_inventory:SetSlotCount(source, inventory.slots - backpackConfig.slotIncrease)
        end
    end
end)

-- Clothing bag capacity handlers
RegisterServerEvent('yote_backpack:increaseClothingBag')
AddEventHandler('yote_backpack:increaseClothingBag', function()
    local source = source
    local inventory = ox_inventory:GetInventory(source)
    if inventory then
        if Config.EnableWeightIncrease then
            ox_inventory:SetMaxWeight(source, inventory.maxWeight + Config.ClothingBagWeightIncrease)
        end
        
        if Config.EnableSlotIncrease then
            ox_inventory:SetSlotCount(source, inventory.slots + Config.ClothingBagSlotIncrease)
        end
    end
end)

RegisterServerEvent('yote_backpack:decreaseClothingBag')
AddEventHandler('yote_backpack:decreaseClothingBag', function()
    local source = source
    local inventory = ox_inventory:GetInventory(source)
    if inventory then
        if Config.EnableWeightIncrease then
            ox_inventory:SetMaxWeight(source, inventory.maxWeight - Config.ClothingBagWeightIncrease)
        end
        
        if Config.EnableSlotIncrease then
            ox_inventory:SetSlotCount(source, inventory.slots - Config.ClothingBagSlotIncrease)
        end
    end
end)

-- Check if player can remove clothing bag
RegisterNetEvent('yote_backpack:canRemoveClothingBag', function()
    local source = source
    if not Config.UseClothingBags then return end
    
    local inventory = ox_inventory:GetInventory(source)
    if not inventory then return end
    
    local originalMaxWeight = inventory.maxWeight - Config.ClothingBagWeightIncrease
    local originalSlots = inventory.slots - Config.ClothingBagSlotIncrease
    
    -- Check if player is over original weight limit
    if Config.EnableWeightIncrease and inventory.weight > originalMaxWeight then
        TriggerClientEvent('yote_backpack:cannotRemoveBag', source, 'weight')
        return
    end
    
    -- Check if player has items in extra slots
    if Config.EnableSlotIncrease then
        local playerItems = ox_inventory:GetInventoryItems(source)
        for _, item in pairs(playerItems) do
            if item.slot > originalSlots then
                TriggerClientEvent('yote_backpack:cannotRemoveBag', source, 'slots')
                return
            end
        end
    end
    
    -- If we get here, player can remove the bag
    TriggerClientEvent('yote_backpack:allowRemoveBag', source)
end)

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do Wait(500) end
    
    if not Config.UseInventoryBags then return end -- Skip hook setup if not using inventory bags
    
    -- Build item filter from configured backpacks
    local backpackItemFilter = {}
    for itemName, _ in pairs(Config.Backpacks) do
        backpackItemFilter[itemName] = true
    end
    
    -- Hook to check if backpack can be removed/swapped
    local backpackRemovalHook = ox_inventory:registerHook('swapItems', function(payload)
        local itemName = payload.fromSlot.name
        local backpackConfig = Config.Backpacks[itemName]
        
        -- Check if trying to remove a configured backpack from inventory
        if backpackConfig and payload.fromType == 'player' then
            local source = payload.source
            local inventory = ox_inventory:GetInventory(source)
            local originalMaxWeight = inventory.maxWeight - (backpackConfig.weightIncrease or 0)
            local originalSlots = inventory.slots - (backpackConfig.slotIncrease or 0)
            
            -- Check if player is over original weight limit
            if Config.EnableWeightIncrease and backpackConfig.weightIncrease and inventory.weight > originalMaxWeight then
                TriggerClientEvent('ox_lib:notify', source, {
                    type = 'error', 
                    title = Strings.cannot_remove_backpack, 
                    description = Strings.too_much_weight
                })
                return false
            end
            
            -- Check if player has items in extra slots
            if Config.EnableSlotIncrease and backpackConfig.slotIncrease then
                local playerItems = ox_inventory:GetInventoryItems(source)
                for _, item in pairs(playerItems) do
                    if item.slot > originalSlots then
                        TriggerClientEvent('ox_lib:notify', source, {
                            type = 'error', 
                            title = Strings.cannot_remove_backpack, 
                            description = Strings.items_in_extra_slots
                        })
                        return false
                    end
                end
            end
        end
        
        return true
    end, {
        print = false,
        itemFilter = backpackItemFilter,
    })
    
    local swapHook = ox_inventory:registerHook('swapItems', function(payload)
        if Config.OneBagInInventory then
            -- Check if player already has a backpack
            for itemName, _ in pairs(Config.Backpacks) do
                local count = ox_inventory:GetItem(payload.source, itemName, nil, true)
                if count > 0 and payload.toType == 'player' and payload.toInventory ~= payload.fromInventory then
                    -- Check if they're trying to add another backpack
                    if Config.Backpacks[payload.fromSlot.name] then
                        TriggerClientEvent('ox_lib:notify', payload.source, {
                            type = 'error', 
                            title = Strings.action_incomplete, 
                            description = Strings.one_backpack_only
                        }) 
                        return false
                    end
                end
            end
        end
        
        return true
    end, {
        print = false,
        itemFilter = backpackItemFilter,
    })
    
    local createHook
    if Config.OneBagInInventory then
        createHook = exports.ox_inventory:registerHook('createItem', function(payload)
            local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)
            local existingBag = nil
            local existingSlot = nil
            
            -- Find existing backpack
            for i, item in pairs(playerItems) do
                if Config.Backpacks[item.name] then
                    existingBag = item.name
                    existingSlot = item.slot
                    break
                end
            end
            
            -- If player has a backpack and received a new one
            if existingBag and Config.Backpacks[payload.item.name] then
                Citizen.CreateThread(function()
                    local inventoryId = payload.inventoryId
                    local dontRemove = existingSlot
                    Citizen.Wait(Config.BackpackCheckDelay)
    
                    for i, item in pairs(ox_inventory:GetInventoryItems(inventoryId)) do
                        if Config.Backpacks[item.name] and dontRemove ~= nil and item.slot ~= dontRemove then
                            local success = ox_inventory:RemoveItem(inventoryId, item.name, 1, nil, item.slot)
                            if success then
                                TriggerClientEvent('ox_lib:notify', inventoryId, {
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
            if Config.OneBagInInventory then
                ox_inventory:removeHooks(createHook)
            end
        end
    end)
end)
