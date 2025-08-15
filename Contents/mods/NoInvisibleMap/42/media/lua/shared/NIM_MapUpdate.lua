-- Utils ########################################################################

local function NIM_GetDistance(a, b)
    return math.sqrt((math.abs(a.x - b.x))^2 + (math.abs(a.y - b.y))^2)
end

local function NIM_GetGreater(a, b)
    if a > b then
        return a
    else
        return b
    end
end

local function NIM_GetLower(a, b)
    if a > b then
        return b
    else
        return a
    end
end

-- ###############################################################################

function NIM_CreateMemoryRegion(playerObj, playerModData)
    local bminX = playerObj:getX() - 48
    local bminY = playerObj:getY() - 48
    local bmaxX = playerObj:getX() + 48
    local bmaxY = playerObj:getY() + 48

    local playerX = playerObj:getX()
    local playerY = playerObj:getY()

    local newBox = {
        minX = bminX,
        maxX = bmaxX,
        minY = bminY,
        maxY = bmaxY
    }

    if playerModData.visitedRegions == nil or #playerModData.visitedRegions == 0 then
        playerModData.visitedRegions = { newBox }
        return
    end

    for _, v in pairs(playerModData.visitedRegions) do
        --Central distance check
        local newBox_central_point = {
            x = math.floor(newBox.maxX - newBox.minX),
            y = math.floor(newBox.maxY - newBox.minY)
        }

        local v_central_point = {
            x = math.floor(v.maxX - v.minX),
            y = math.floor(v.maxY - v.minY)
        }

        if NIM_GetDistance(newBox_central_point, v_central_point) <= 128 then
            v.minX = NIM_GetLower(newBox.minX, v.minX)
            v.maxX = NIM_GetGreater(newBox.maxX, v.maxX)
            v.minY = NIM_GetLower(newBox.minY, v.minY)
            v.maxY = NIM_GetGreater(newBox.maxY, v.maxY)
            return
        end

        --Border distance check
    end 

    table.insert(playerModData.visitedRegions, newBox)
end

function NIM_OnTickMapUpdate()
    local playerObj = getPlayer()
    local playerModData = playerObj:getModData()

    local worldMapVisitedInstance = WorldMapVisited.getInstance()
    local minX = playerObj:getX() - 32
    local minY = playerObj:getY() - 32
    local maxX = playerObj:getX() + 32
    local maxY = playerObj:getY() + 32

    if not playerModData.isWorldMapOpen then
        NIM_CreateMemoryRegion(playerObj, playerModData)
    end
    
    local topIsKnown = false
    local bottomIsKnown = false
    local leftIsKnown = false
    local rightIsKnown = false

    local border_counter = 0

    if worldMapVisitedInstance:isVisited(playerObj:getX(), playerObj:getY() - 128) then
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

Events.OnPlayerUpdate.Add(NIM_OnTickMapUpdate);