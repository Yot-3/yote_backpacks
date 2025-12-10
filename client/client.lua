local bagEquipped, bagObj, currentBagType
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true
local clothingBagActive = false
local canRemoveClothingBag = true
local checkingRemoval = false
local lastBagDrawable = 0
local lastBagTexture = 0

local function GetBackpackConfig(itemName)
    return Config.Backpacks[itemName]
end

local function PutOnBag(itemName)
    if bagEquipped then return end
    
    local backpackConfig = GetBackpackConfig(itemName)
    if not backpackConfig then return end
    
    local hash = backpackConfig.model
    local offset = backpackConfig.offset or Config.DefaultBackpackOffset
    local rotation = backpackConfig.rotation or Config.DefaultBackpackRotation
    
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.5))
    lib.requestModel(hash, 100)
    bagObj = CreateObjectNoOffset(hash, x, y, z, true, false)
    AttachEntityToEntity(bagObj, ped, GetPedBoneIndex(ped, Config.BackpackBone), 
        offset.x, offset.y, offset.z, 
        rotation.x, rotation.y, rotation.z, 
        true, true, false, true, 1, true)
    bagEquipped = true
    currentBagType = itemName
    
    -- Increase player carrying capacity
    TriggerServerEvent('yote_backpack:increaseCapacity', itemName)
end

local function RemoveBag()
    if DoesEntityExist(bagObj) then
        DeleteObject(bagObj)
    end
    if currentBagType then
        local backpackConfig = GetBackpackConfig(currentBagType)
        if backpackConfig then
            SetModelAsNoLongerNeeded(backpackConfig.model)
        end
    end
    bagObj = nil
    bagEquipped = nil
    
    -- Decrease player carrying capacity
    TriggerServerEvent('yote_backpack:decreaseCapacity', currentBagType)
    currentBagType = nil
end

local function CheckForBackpack()
    for itemName, _ in pairs(Config.Backpacks) do
        local count = ox_inventory:Search('count', itemName)
        if count > 0 then
            return itemName
        end
    end
    return nil
end

-- Check if player is wearing a clothing bag (component 5)
local function CheckClothingBag()
    if not Config.UseClothingBags then return false end
    
    local drawable = GetPedDrawableVariation(ped, 5) -- Component 5 is bags
    return drawable > 0 -- 0 means no bag equipped
end

-- Handle clothing bag capacity changes
local function UpdateClothingBagCapacity()
    local currentDrawable = GetPedDrawableVariation(ped, 5)
    local currentTexture = GetPedTextureVariation(ped, 5)
    local hasClothingBag = currentDrawable > 0
    
    if hasClothingBag and not clothingBagActive then
        -- Player just equipped a clothing bag
        clothingBagActive = true
        lastBagDrawable = currentDrawable
        lastBagTexture = currentTexture
        TriggerServerEvent('yote_backpack:increaseClothingBag')
    elseif not hasClothingBag and clothingBagActive then
        -- Player is trying to remove clothing bag - check if allowed
        if not checkingRemoval then
            checkingRemoval = true
            TriggerServerEvent('yote_backpack:canRemoveClothingBag')
        end
    elseif hasClothingBag and clothingBagActive then
        -- Update the last known bag if player changed bags
        lastBagDrawable = currentDrawable
        lastBagTexture = currentTexture
    end
end

-- Server responses for clothing bag removal
RegisterNetEvent('yote_backpack:cannotRemoveBag', function(reason)
    checkingRemoval = false
    
    -- Force the bag back on using the last known drawable and texture
    SetPedComponentVariation(ped, 5, lastBagDrawable, lastBagTexture, 0)
    
    if reason == 'weight' then
        lib.notify({
            type = 'error',
            title = Strings.cannot_remove_backpack,
            description = Strings.too_much_weight
        })
    elseif reason == 'slots' then
        lib.notify({
            type = 'error',
            title = Strings.cannot_remove_backpack,
            description = Strings.items_in_extra_slots
        })
    end
end)

RegisterNetEvent('yote_backpack:allowRemoveBag', function()
    checkingRemoval = false
    clothingBagActive = false
    lastBagDrawable = 0
    lastBagTexture = 0
    TriggerServerEvent('yote_backpack:decreaseClothingBag')
end)

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if not Config.UseInventoryBags then return end -- Skip if not using inventory bags
    
    if justConnect then
        Wait(Config.SpawnDelay)
        TriggerServerEvent('yote_backpack:playerLoaded')
        justConnect = nil
    end
    
    for k, v in pairs(changes) do
        if type(v) == 'table' or type(v) == 'boolean' then
            local foundBag = CheckForBackpack()
            
            if foundBag and not bagEquipped then
                PutOnBag(foundBag)
            elseif not foundBag and bagEquipped then
                RemoveBag()
            elseif foundBag and bagEquipped and foundBag ~= currentBagType then
                -- Different bag equipped, swap it
                RemoveBag()
                Wait(100)
                PutOnBag(foundBag)
            end
        end
    end
end)

lib.onCache('ped', function(value)
    ped = value
    if Config.UseClothingBags then
        Wait(500)
        UpdateClothingBagCapacity()
    end
end)

lib.onCache('vehicle', function(value)
    if not Config.UseInventoryBags then return end -- Skip if not using inventory bags
    
    if GetResourceState('ox_inventory') ~= 'started' then return end
    if value and Config.RemoveBagInVehicle then
        RemoveBag()
    else
        local foundBag = CheckForBackpack()
        if foundBag then
            PutOnBag(foundBag)
        end
    end
end)

-- Check for clothing bag changes
if Config.UseClothingBags then
    CreateThread(function()
        while true do
            Wait(500) -- Check every half second
            if not checkingRemoval then
                UpdateClothingBagCapacity()
            end
        end
    end)
end

