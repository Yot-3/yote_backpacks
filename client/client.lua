local bagEquipped, bagObj, currentBagType
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true
local clothingBagActive = false
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
    
    lib.requestModel(hash, 1000)
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.5)
    bagObj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, true, false, false)
    AttachEntityToEntity(bagObj, ped, GetPedBoneIndex(ped, Config.BackpackBone), 
        offset.x, offset.y, offset.z, 
        rotation.x, rotation.y, rotation.z, 
        true, true, false, true, 1, true)
    
    bagEquipped = true
    currentBagType = itemName
    TriggerServerEvent('yote_backpack:increaseCapacity', itemName)
end

local function RemoveBag()
    if not bagEquipped then return end
    
    if DoesEntityExist(bagObj) then
        DeleteObject(bagObj)
        bagObj = nil
    end
    
    if currentBagType then
        local backpackConfig = GetBackpackConfig(currentBagType)
        if backpackConfig then
            SetModelAsNoLongerNeeded(backpackConfig.model)
        end
        TriggerServerEvent('yote_backpack:decreaseCapacity', currentBagType)
    end
    
    bagEquipped = false
    currentBagType = nil
end

local function CheckForBackpack()
    for itemName in pairs(Config.Backpacks) do
        if ox_inventory:Search('count', itemName) > 0 then
            return itemName
        end
    end
    return nil
end

local function IsClothingBagBlacklisted(drawable, texture)
    local blacklistEntry = Config.ClothingBagBlacklist[drawable]
    if not blacklistEntry then return false end
    
    if type(blacklistEntry) == "table" then
        for _, blockedTexture in ipairs(blacklistEntry) do
            if blockedTexture == texture then
                return true
            end
        end
        return false
    end
    
    return true
end

local function UpdateClothingBagCapacity()
    if not Config.UseClothingBags or checkingRemoval then return end
    
    local currentDrawable = GetPedDrawableVariation(ped, 5)
    local currentTexture = GetPedTextureVariation(ped, 5)
    local hasValidBag = currentDrawable > 0 and not IsClothingBagBlacklisted(currentDrawable, currentTexture)
    
    if hasValidBag and not clothingBagActive then
        clothingBagActive = true
        lastBagDrawable = currentDrawable
        lastBagTexture = currentTexture
        TriggerServerEvent('yote_backpack:increaseClothingBag')
    elseif not hasValidBag and clothingBagActive then
        checkingRemoval = true
        TriggerServerEvent('yote_backpack:canRemoveClothingBag')
    elseif hasValidBag and clothingBagActive and (currentDrawable ~= lastBagDrawable or currentTexture ~= lastBagTexture) then
        lastBagDrawable = currentDrawable
        lastBagTexture = currentTexture
    end
end

RegisterNetEvent('yote_backpack:cannotRemoveBag', function(reason)
    checkingRemoval = false
    SetPedComponentVariation(ped, 5, lastBagDrawable, lastBagTexture, 0)
    
    local messages = {
        weight = Strings.too_much_weight,
        slots = Strings.items_in_extra_slots
    }
    
    if messages[reason] then
        lib.notify({
            type = 'error',
            title = Strings.cannot_remove_backpack,
            description = messages[reason]
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
    if not Config.UseInventoryBags then return end
    
    if justConnect then
        Wait(Config.SpawnDelay)
        TriggerServerEvent('yote_backpack:playerLoaded')
        justConnect = false
    end
    
    for k, v in pairs(changes) do
        if type(v) == 'table' or type(v) == 'boolean' then
            local foundBag = CheckForBackpack()
            
            if foundBag ~= currentBagType then
                if bagEquipped then
                    RemoveBag()
                    Wait(100)
                end
                if foundBag then
                    PutOnBag(foundBag)
                end
            end
            break
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
    if not Config.UseInventoryBags or GetResourceState('ox_inventory') ~= 'started' then return end
    
    if value and Config.RemoveBagInVehicle then
        RemoveBag()
    else
        local foundBag = CheckForBackpack()
        if foundBag then
            PutOnBag(foundBag)
        end
    end
end)

if Config.UseClothingBags then
    CreateThread(function()
        while true do
            Wait(500)
            UpdateClothingBagCapacity()
        end
    end)
end

if Config.EnableDebugCommand then
    RegisterCommand(Config.DebugCommandName, function()
        local drawable = GetPedDrawableVariation(ped, 5)
        local texture = GetPedTextureVariation(ped, 5)
        local blacklisted = IsClothingBagBlacklisted(drawable, texture)
        print(string.format('Current Bag - Drawable: %d, Texture: %d, Blacklisted: %s', drawable, texture, tostring(blacklisted)))
        lib.notify({
            type = 'info',
            description = string.format('Drawable: %d | Texture: %d | Blacklisted: %s', drawable, texture, tostring(blacklisted))
        })
    end)
end

