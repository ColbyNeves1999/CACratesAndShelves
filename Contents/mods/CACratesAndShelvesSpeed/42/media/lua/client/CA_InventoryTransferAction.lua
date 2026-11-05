require "TimedActions/ISInventoryTransferAction"

-- Variable to hold the original ISInventoryTransferAction:new method
local _originalTransferAction =  ISInventoryTransferAction.new

-- Speed Multipliers for the different storage types.
local storageSpeedMultipliers = {
    ["metal_shelves"] = 0.1,
    ["shelves"] = 0.1,
    ["crate"] = 3.0,
    ["smallcrate"] = 2.0
}

-- Crate Types
local crateTypes = {
    ["crate"] = true,
    ["smallcrate"] = true
}

-- Shelf Types
-- Added for potential future expansion, but currently not used in the code.
local shelfTypes = {
    ["metal_shelves"] = true,
    ["shelves"] = true
}

-- Helper function to identify the number of crates on top of each other in a stack
local function getCrateStackPenalty(container)

    -- Identifies the Parent, their height, and all objects within the tile itself.
    local containerParent = container:getParent()
    local containerParentHeight = containerParent:getRenderYOffset()
    local objectsInSquare = containerParent:getSquare():getObjects()

    -- Initializes the number of crates and it's initial influence.
    local crateCount = 0
    local crateInfluence = 1.0

    -- Loops through all the objects in the square to identify how many crates are stacked on top of the given container.
    for i = 0, objectsInSquare:size()-1 do

        local object = objectsInSquare:get(i)
        local objectContainer = object:getContainer()

        if objectContainer ~= nil and object:getRenderYOffset() > containerParentHeight and crateTypes[objectContainer:getType()] then
            crateCount = crateCount + 1
        end

    end

    -- Adjusts the influence based on the number of crates stacked on top of the given container.
    if crateCount == 1 then
        crateInfluence = 1.25
    elseif crateCount == 2 then
        crateInfluence = 1.5
    elseif crateCount >= 3 then
        -- >= 3 shouldn't happen often, but in case they ever add something else it's to verify.
        crateInfluence = 1.75
    end

    return crateInfluence

end

-- Wrapper function to override the original ISInventoryTransferAction:new method
function ISInventoryTransferAction:new(...)

    -- Call the original constructor to create the action
    local action = _originalTransferAction(self, ...)

    -- Verifies if the action has a maxTime greater than 1 and both source and destination containers are defined
    if action.maxTime > 1 and action.srcContainer and action.destContainer then

        -- Get the speed multipliers for the source and destination containers
        local srcMultiplier = storageSpeedMultipliers[action.srcContainer:getType()] or 1
        local destMultiplier = storageSpeedMultipliers[action.destContainer:getType()] or 1
        local tileInfluence = 1.0

        -- Adjust the maxTime of the action based on the multiplier for the source
        if crateTypes[action.srcContainer:getType()] then
            tileInfluence = getCrateStackPenalty(action.srcContainer)
        end

        action.maxTime = action.maxTime * srcMultiplier * tileInfluence

        tileInfluence = 1.0

        -- Adjust the maxTime of the action based on the multiplier for the destination
        if crateTypes[action.destContainer:getType()] then
            tileInfluence = getCrateStackPenalty(action.destContainer)
        end

        action.maxTime = action.maxTime * destMultiplier * tileInfluence

        -- Ensure that the action's queueList is updated with the new maxTime if it exists
        if action.queueList and action.queueList[1] ~= nil then
            action.queueList[1].time = action.maxTime
        end

    end

    return action

end