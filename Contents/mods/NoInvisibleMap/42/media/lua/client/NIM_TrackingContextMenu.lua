require "ISUI/ISInventoryPaneContextMenu"
require "TimedActions/ISBaseTimedAction"

NIM_ISMapTrackingContext = {}

NIM_ISMapTrackingContext.inventoryMenu = function(playerid, context, items)
    local player = getSpecificPlayer(playerid)
    for _, v in ipairs(items) do
		local item = v
		if not instanceof(v, "InventoryItem") then
			item = v.items[1]
		end

		NIM_ISMapTrackingContext:TrackPlayerPosition(item, nil, player, context)
    end
end

function NIM_ISMapTrackingContext:TrackPlayerPosition(item, index, player, context)
    if item and item:getFullType() == "Base.HandmadeMap" then
        local listEntry = context:addOption("Where am I?", item, NIM_GuessPosition);
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = "Guess your position on the world map. (You need to be in a known region)"
        tooltip:setName("Where am I?")
        listEntry.toolTip = tooltip;
    end
end

function NIM_GuessPosition()
    local player = getPlayer()
    local playerX = player:getX()
    local playerY = player:getY()

    local isPlayerInsideKnownRegion = false
    local isOutside = player:isOutside()
    local playerCanSeeOutside = player:getSquare():isAdjacentToWindow()

    local outsideErrMessages = {
        "I can't guess where I am. I need to take a look outside",
        "Can't do it inside, I need to check my surroundings"
    }

    local unknownErrMessages = {
        "I have no idea where I am",
        "I don't known this place"
    }

    local failedGuessErrMessages = {
        "Hmmmmm, somewhere around here?",
        "Maybe in this area..."
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
                b = newSymbol.b
            })

            map.haveNewSymbols = true
        end

        ISTimedActionQueue.clear(playerObj)
        ISTimedActionQueue.add(ISReadWorldMap:new(playerObj, x + offsetX, y + offsetY, zoomSize))
    end

    local map = player:getInventory():FindAll("HandmadeMap")

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
        if playerZ >= 2 then
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

Events.OnPreFillInventoryObjectContextMenu.Add(NIM_ISMapTrackingContext.inventoryMenu)