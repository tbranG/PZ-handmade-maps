local Commands = {}

function Commands.CreateSketch(player, args) 
    local playerInventory = player:getInventory()

    local sketch = playerInventory:AddItem("Base.AreaSketch")
    sendAddItemToContainer(playerInventory, sketch)

    local paper = playerInventory:RemoveOneOf("Base.SheetPaper2")
    sendRemoveItemFromContainer(playerInventory, paper)
end

function Commands.SyncMap(player, args)
    if type(args) == "table" and args.id then
        local playerInv = player:getInventory()
        local foundItem = nil
        local items = playerInv:getItems()
        for i = 0, items:size() - 1 do
            local it = items:get(i)
            local md = it:getModData()
            if md and md.id == args.id then
                foundItem = it
                break
            end
        end

        if foundItem then
            local destMd = foundItem:getModData()
            destMd = args.modData or destMd

            foundItem:transmitModData()
        else
            print("HandmadeMaps: could not find item with id " .. tostring(args.id) .. " for player " .. tostring(player:getDisplayName()))
        end
    end
end

local function OnClientCommand(player, module, command, args)
    --print("[NIM] mapSync called...")
    
    if not isServer() then return end
    if module ~= "NIM" then return end

    --print("HandmadeMaps: NIM command called by player " .. tostring(player and player:getDisplayName()) .. ", args type: " .. tostring(type(args)))

    if Commands[command] then
        Commands[command](player, args)
    end
end

print("[NIM][SERVER] Registrando OnClientCommand")
Events.OnClientCommand.Add(OnClientCommand)