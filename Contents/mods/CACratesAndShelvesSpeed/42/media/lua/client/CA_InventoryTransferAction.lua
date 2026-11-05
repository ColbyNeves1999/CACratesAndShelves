require "TimedActions/ISInventoryTransferAction"

local _originalTransferAction =  ISInventoryTransferAction.new

local shelvingList = {"metal_shelves"}
local crateList = {"crate"}

function ISInventoryTransferAction:new(...)

    local action = _originalTransferAction(self, ...)

    print("CA Transfer wrapper 1")

    if action.maxTime > 1 and action.srcContainer and action.destContainer then
        if action.srcContainer:getType() == "metal_shelves" or action.destContainer:getType() == "metal_shelves" then
    
            action.maxTime = action.maxTime * 0.1
            print("CA Transfer wrapper 2")

        elseif action.srcContainer:getType() == "crate" or action.destContainer:getType() == "crate" then
        
            action.maxTime = action.maxTime * 10
            print("CA Transfer wrapper 3")

        end

        print("CA Transfer wrapper 4")

        if action.queueList and action.queueList[1] ~= nil then
            action.queueList[1].time = action.maxTime
        end

    end

    print("CA Transfer wrapper 5")

    return action

end