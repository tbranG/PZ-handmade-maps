NIM_TransferRegionWindow = ISPanel:derive("NIM_TransferRegionWindow");

local WINDOW_WIDTH = 340
local WINDOW_HEIGHT = 150

-- Method responsible for adding visited regions to the world map
 local function NIM_TransferRegions(item)
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

-- #######################

function NIM_TransferRegionWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.zOffsetSmallFont = 25;
    return o;
end

function NIM_TransferRegionWindow:initialise()
    ISPanel.initialise(self)
    self:create()
    NIM_TransferRegionWindow.instance = self
end

function NIM_TransferRegionWindow:create()
end

function NIM_TransferRegionWindow:close()
    -- ISTimedActionQueue.clear(self.character)
    NIM_TransferRegionWindow.instance = nil
    ISPanel.close(self)
end

function NIM_TransferRegionWindow:open()
    local modal = NIM_TransferRegionWindow:new(
        Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, 
        Core:getInstance():getScreenHeight()/2 - 500/2,
        WINDOW_WIDTH, 
        WINDOW_HEIGHT
    )
    modal:initialise()
    modal:addToUIManager()
end

function NIM_TransferRegionWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end