function NIM_ResetPlayerMapKnowledge(playerNum, timeOfDay)
    local playerObj = getSpecificPlayer(playerNum)
    local playerModData = playerObj:getModData()

    if playerModData.visitedRegions ~= nil or {} then
        playerModData.visitedRegions = {}
    end
end

Events.OnSleepingTick.Add(NIM_ResetPlayerMapKnowledge)