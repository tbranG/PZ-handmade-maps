-- Method responsible for pinpointing player position on the world map
function NIM_GuessPosition()
    local player = getPlayer()
    local playerX = player:getX()
    local playerY = player:getY()

    local isPlayerInsideKnownRegion = false
    local isOutside = player:isOutside()
    local playerCanSeeOutside = player:getSquare():isAdjacentToWindow()

    local outsideErrMessages = {
        getText("IGUI_isInsideF"),
        getText("IGUI_isInsideS")
    }

    local unknownErrMessages = {
        getText("IGUI_unknownRegionF"),
        getText("IGUI_unknownRegionS")
    }

    local failedGuessErrMessages = {
        getText("IGUI_failedGuessF"),
        getText("IGUI_failedGuessS")
    }

    if not isOutside and not playerCanSeeOutside then
        local selectedMessage = outsideErrMessages[ZombRand(2) + 1]
        player:Say(selectedMessage)
        return 
    end

    local markPositionOnMap = function (playerObj, x, y, map, failed)
        local multiplierX = 0
        local multiplierY = 0
        local offsetX = 0
        local offsetY = 0

        local zoomSize = 250

        if failed then
            multiplierX = ZombRand(10) + 1
            multiplierY = ZombRand(10) + 1

            if ZombRand(2) == 0 then
                multiplierX = -multiplierX
            end

            if ZombRand(2) == 0 then
                multiplierY = -multiplierY
            end

            zoomSize = 900
            offsetX = 8 * multiplierX
            offsetY = 8 * multiplierY
        else
            local newSymbol = {}
            newSymbol.symbol = "Circle"
            newSymbol.x = x
            newSymbol.y = y
            newSymbol.r = 0.129
            newSymbol.g = 0.129
            newSymbol.b = 0.129

            table.insert(map.symbols, {
                symbol = newSymbol.symbol,
                x = newSymbol.x,
                y = newSymbol.y,
                r = newSymbol.r,
                g = newSymbol.g,
                b = newSymbol.b,
                scale = 1.0,
                rotation = 0
            })

            map.haveNewSymbols = true
        end

        ISTimedActionQueue.clear(playerObj)
        ISTimedActionQueue.add(ISReadWorldMap:new(playerObj, x + offsetX, y + offsetY, zoomSize))
    end

    local map = player:getInventory():getAllTypeRecurse("HandmadeMap")

	if map ~= nil then
		map = map:get(0)
		local mapData = map:getModData()
		
		if mapData.mapRegions ~= nil then
			for _, v in pairs(mapData.mapRegions) do
				if playerX >= v.minX and playerX < v.maxX then
                    if playerY >= v.minY and playerY < v.maxY then
                        isPlayerInsideKnownRegion = true
                        break
                    end
                end
			end
		end

        if not isPlayerInsideKnownRegion then 
            local selectedMessage = unknownErrMessages[ZombRand(2) + 1]
            player:Say(selectedMessage)
            return 
        end   

        local playerZ = player:getZ()
        if playerZ >= 1 then
            markPositionOnMap(player, playerX, playerY, map:getModData(), false)
            return
        end

        local chance = ZombRand(5)
        if chance == 0 then
            markPositionOnMap(player, playerX, playerY, map:getModData(), false)
        else
            local selectedMessage = failedGuessErrMessages[ZombRand(2) + 1]
            player:Say(selectedMessage)

            markPositionOnMap(player, playerX, playerY, map:getModData(), true)
        end
    end
end