require "ISUI/ISInventoryPaneContextMenu"
require "UI/DrawMap/NIM_DrawMapWindow"
require "UI/TransferRegion/NIM_TransferRegionWindow"
require "TimedActions/SketchDrawingAction" 

NIM_HandmadeMapContext = {}

local function openAddRegionMenu(worldMap)
    NIM_TransferRegionWindow:open(worldMap)
end

local function openDrawMenu(playerObj)
    local isMinigamesDisabled = NIM.Config.disable_minigames
    
    if isMinigamesDisabled then
        local player = getPlayer()
        local playerInventory = player:getInventory()

        local sketch = nil

        if isClient() and not isServer() then 
            sendClientCommand(
                getPlayer(),
                "NIM",
                "CreateSketch",
                {}
            )
        else
            sketch = playerInventory:AddItem("Base.AreaSketch")    
            playerInventory:RemoveOneOf("Base.SheetPaper2")
        end
        
        local playerCell = player:getCell()
        local zIndex = player:getZ()
        local outside = player:isOutside()
        
        local playerCanSeeOutside = player:getSquare():isAdjacentToWindow()

        local pencilColor = NIM_GetRandomPenColor()

        NIM_GenerateMap(sketch, playerCell, outside, playerCanSeeOutside, zIndex, pencilColor)

        ISTimedActionQueue.add(SketchDrawingAction:new(player, 90, sketch))
    else
        NIM_DrawMapWindow:open()
    end
end

-- ##########################


-- Add new context menu options here:
NIM_HandmadeMapContext.inventoryMenu = function(playerid, context, items)
    local player = getSpecificPlayer(playerid)
    for _, v in ipairs(items) do
		local item = v
		if not instanceof(v, "InventoryItem") then
			item = v.items[1]
		end

		NIM_HandmadeMapContext:TrackPlayerPosition(item, nil, player, context)
        NIM_HandmadeMapContext:AddRegions(item, nil, player, context)
        NIM_HandmadeMapContext:SketchSurroundings(item, nil, player, context)
    end
end

function NIM_HandmadeMapContext:TrackPlayerPosition(item, index, player, context)
    if item and item:getFullType() == "Base.HandmadeMap" then
        local listEntry = context:addOption(getText("ContextMenu_LocateFunc"), item, NIM_GuessPosition);
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = getText("ContextMenu_LocateDesc")
        tooltip:setName(getText("ContextMenu_LocateFunc"))
        listEntry.toolTip = tooltip;
    end
end

function NIM_HandmadeMapContext:AddRegions(item, index, player, context)
    if item and item:getFullType() == "Base.HandmadeMap" then
        local listEntry = context:addOption(getText("ContextMenu_AddRegionFunc"), item, function() openAddRegionMenu(item) end);
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = getText("ContextMenu_AddRegionDesc")
        tooltip:setName(getText("ContextMenu_AddRegionFunc"))
        listEntry.toolTip = tooltip;
    end
end

function NIM_HandmadeMapContext:SketchSurroundings(item, index, player, context)
    if item and item:getFullType() == "Base.SheetPaper2" then
        local listEntry = context:addOption(getText("ContextMenu_SketchFunc"), item, function() openDrawMenu(player) end);
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = getText("ContextMenu_SketchDesc")
        tooltip:setName(getText("ContextMenu_SketchFunc"))
        listEntry.toolTip = tooltip;
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(NIM_HandmadeMapContext.inventoryMenu)