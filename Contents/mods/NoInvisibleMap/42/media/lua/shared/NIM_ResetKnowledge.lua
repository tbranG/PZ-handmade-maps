local function RemoveOldVisitedRegions() 
    local forgetChance = ZombRand(5) == 0
    if forgetChance then
        local playerObj = getPlayer()
        local playerModData = playerObj:getModData()
    
        if playerModData.visitedRegions == nil or {} then return end
        NIM.Utils.RemoveRandomElement(playerModData.visitedRegions)
    end
end 

Events.EveryHours.Add(RemoveOldVisitedRegions)