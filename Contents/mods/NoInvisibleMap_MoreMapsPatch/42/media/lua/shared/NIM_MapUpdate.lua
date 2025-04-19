function NIM_OnTickMapUpdate(tick)
    local playerObj = getPlayer()
    local playerModData = playerObj:getModData()
    local playerInventory = playerObj:getInventory()

    if playerModData.isWorldMapOpen == nil then playerModData.isWorldMapOpen = false end

    if playerModData.isWorldMapOpen then
        WorldMapVisited.getInstance():forget()

        local map = playerInventory:FindAll("HandmadeMap")

        if map ~= nil then
            map = map:get(0)
            local mapData = map:getModData()
            
            if mapData.mapRegions ~= nil then
                for _, v in pairs(mapData.mapRegions) do
                    WorldMapVisited.getInstance():setVisitedInSquares(v.minX, v.minY, v.maxX, v.maxY)
                end
            end
        end
    end
end

function NIM_OnTickMapUpdate2()
    local playerObj = getPlayer()
    local playerModData = playerObj:getModData()

    if playerModData.isWorldMapOpen then
        local worldMapVisitedInstance = WorldMapVisited.getInstance()
        local minX = playerObj:getX() - 32
        local minY = playerObj:getY() - 32
        local maxX = playerObj:getX() + 32
        local maxY = playerObj:getY() + 32

        local topIsKnown = false
        local bottomIsKnown = false
        local leftIsKnown = false
        local rightIsKnown = false

        local border_counter = 0

        if worldMapVisitedInstance:isVisited(playerObj:getX(), playerObj:getY() - 64) then
            topIsKnown = true
            border_counter = border_counter + 1
        end
        if worldMapVisitedInstance:isVisited(playerObj:getX() + 64, playerObj:getY()) then
            rightIsKnown = true
            border_counter = border_counter + 1
        end
        if border_counter < 2 and worldMapVisitedInstance:isVisited(playerObj:getX(), playerObj:getY() + 64) then
            bottomIsKnown = true
            border_counter = border_counter + 1
        end
        if border_counter < 2 and worldMapVisitedInstance:isVisited(playerObj:getX() - 64, playerObj:getY()) then
            leftIsKnown = true
            border_counter = border_counter + 1
        end

        if border_counter >= 2 then return end

        worldMapVisitedInstance:clearKnownInSquares(
            minX,
            minY,
            maxX,
            maxY
        )
        worldMapVisitedInstance:clearVisitedInSquares(
            minX,
            minY,
            maxX,
            maxY
        )
    end
end

Events.OnPlayerUpdate.Add(NIM_OnTickMapUpdate2);