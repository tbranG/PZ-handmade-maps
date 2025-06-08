require "ISUI/ISInventoryPaneContextMenu"
require "TimedActions/ISBaseTimedAction"

NIM_ISMapTrackingContext = {}

-- Add new context menu options here:
NIM_ISMapTrackingContext.inventoryMenu = function(playerid, context, items)
    local player = getSpecificPlayer(playerid)
    for _, v in ipairs(items) do
		local item = v
		if not instanceof(v, "InventoryItem") then
			item = v.items[1]
		end

		NIM_ISMapTrackingContext:TrackPlayerPosition(item, nil, player, context)
        NIM_ISMapTrackingContext:AddRegionsFromMemory(item, nil, player, context)
    end
end

function NIM_ISMapTrackingContext:TrackPlayerPosition(item, index, player, context)
    if item and item:getFullType() == "Base.HandmadeMap" then
        local listEntry = context:addOption("Locate yourself", item, NIM_GuessPosition);
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = "Guess your position on the world map. (You need to be in a known region)"
        tooltip:setName("Locate yourself")
        listEntry.toolTip = tooltip;
    end
end

function NIM_ISMapTrackingContext:AddRegionsFromMemory(item, index, player, context)
    if item and item:getFullType() == "Base.HandmadeMap" then
        local haveNeededItems = false

        local multicolorItem = player:HasItem("Crayons") or player:HasItem("PenMultiColor")
        
        if multicolorItem then 
            haveNeededItems = true 
        else
            local blackPen = player:HasItem("Pen") or player:HasItem("Pencil") or player:HasItem("PenFancy") or player:HasItem("PenSpiffo")
            local redPen = player:HasItem("RedPen")
            local bluePen = player:HasItem("BluePen")
            local greenPen = player:HasItem("GreenPen")

            if blackPen and redPen and bluePen and greenPen then
                haveNeededItems = true
            end
        end

        if haveNeededItems then
            local listEntry = context:addOption("Add Region", item, function() NIM_TransferRegions(item) end);
            local tooltip = ISInventoryPaneContextMenu.addToolTip();
            tooltip.description = "Add regions to the World map from memory. (Regions that you have visited)"
            tooltip:setName("Add Region")
            listEntry.toolTip = tooltip;
        end
    end
end

-- Method responsible for pinpointing player position on the world map
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

-- Method responsible for adding visited regions to the world map
function NIM_TransferRegions(item)
    local mapModData = item:getModData()
    local playerModData = getPlayer():getModData()

    for _, v in pairs(playerModData.visitedRegions) do
        if mapModData.mapRegions == nil then
            mapModData.mapRegions = {}
        end

        local isRegionAlreadyOnMap = false
        local offset = 32

        for _, k in pairs(mapModData.mapRegions) do
            if v.minX >= k.minX - offset then
                if v.maxX <= k.maxX + offset then
                    if v.minY >= k.minY - offset then
                        if v.maxY <= k.maxY + offset then
                            isRegionAlreadyOnMap = true
                        end
                    end
                end
            end
        end
        
        if not isRegionAlreadyOnMap then
            table.insert(mapModData.mapRegions, v)
            mapModData.haveNewRegions = true
        end
    end

    local playerObj = getPlayer()
    playerModData.visitedRegions = {}

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISReadWorldMap:new(playerObj))
end

Events.OnPreFillInventoryObjectContextMenu.Add(NIM_ISMapTrackingContext.inventoryMenu)