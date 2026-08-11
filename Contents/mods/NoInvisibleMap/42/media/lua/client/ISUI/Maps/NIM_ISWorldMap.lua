function NIM_ISWorldMapOverrides()
    -- nim override
    -- we also need to wipe the map modData
    function ISWorldMap:onConfirmForget(button)
        self.forgetUI = nil
        if button.internal ~= "YES" then return end
        self.mapAPI:getSymbolsAPI():clearUserAnnotations()
        WorldMapVisited.getInstance():forget()

        local map = getPlayer():getInventory():getFirstEvalRecurse(function(item) return item:getFullType() == "Base.HandmadeMap" end)
        local data = map:getModData()
        if data ~= nil then
            for k, v in pairs(data) do
                data[k] = nil
            end
        end

        sendClientCommand(getPlayer(), "map", "forget", {});
    end

    -- function override
    -- removes vanilla world map
    function ISWorldMap.ToggleWorldMap(playerNum)
        return
    end

    -- function override
    -- removes vanilla No world map
    function ISWorldMap.HideWorldMap(playerNum)
        return
    end
end

Events.OnGameStart.Add(NIM_ISWorldMapOverrides)