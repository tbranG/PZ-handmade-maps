function NIM_GetDistance(a, b)
    return math.sqrt((math.abs(a.x - b.x))^2 + (math.abs(a.y - b.y))^2)
end

function NIM_GetGreater(a, b)
    if a > b then
        return a
    else
        return b
    end
end

function NIM_GetLower(a, b)
    if a > b then
        return b
    else
        return a
    end
end

function NIM_GetRandomPenColor()
    local playerInv = getPlayer():getInventory()

    local hasMulticolorItem = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Crayons" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenMultiColor" end) ~= nil
    end
    local hasBlack = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.Pencil" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenFancy" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.PenSpiffo" end) ~= nil or
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlack" end) ~= nil
    end
    local hasRed = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.RedPen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerRed" end) ~= nil
    end
    local hasBlue = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.BluePen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerBlue" end) ~= nil
    end
    local hasGreen = function()
        return playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.GreenPen" end) ~= nil or 
            playerInv:getFirstEvalRecurse(function(item) return item:getFullType() == "Base.MarkerGreen" end) ~= nil
    end

    local availableColors = {}

    if hasMulticolorItem() then
        availableColors = { "black", "red", "blue", "green" }
    else
        if hasBlack() then
            table.insert(availableColors, "black")
        end
        if hasRed() then
            table.insert(availableColors, "red")
        end
        if hasBlue() then
            table.insert(availableColors, "blue")
        end
        if hasGreen() then
            table.insert(availableColors, "green")
        end
    end

    return availableColors[ZombRand(#availableColors) + 1]
end