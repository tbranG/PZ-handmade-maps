require "PZAPI/ui/atoms/Text"
require "PZAPI/ui/molecules/TextButton"
require "PZAPI/ui/organisms/Window"
require "PZAPI/ui/molecules/ScrollBarVertical"

--
-- Handmade maps override v2.0
-- Chenges at
--[[
    246...: Flyers no longer reveal a new area in the map. Instead they will put a question mark
]]

local UI = PZAPI.UI

local function getMapZoom(len)
    if len < 75 then return 17 end
    if len < 75*3 then return 16.5 end
    if len < 75*3*3 then return 16.0 end
    if len < 75*3*3*3 then return 15.5 end
    if len < 75*3*3*3*3 then return 14.5 end
    return 14
end

local revealOnMapTemplate = UI.Panel{
    enabled = false,
    visible = false,
    y = -46,
    height = 40, width = 40,
    children = {
        icon = UI.Texture{
            x = 20, y = 20,
            width = 32, height = 32,
            pivotX = 0.5, pivotY = 0.5,
            texture = getTexture("media/textures/Item_Map.png"),
        }
    },
    onLeftClick = function() end
}

UI.PrintMedia = UI.Window{
    width = 790, height = 824,
    isPin = false,
    children = {
        body = UI.Window.children.body{
            isStencil = true,
            children = {
                printMedia = UI.Node{
                    width = 480, height = 720,
                    children = {},
                    onLeftDrag = function(self, data, dx, dy)
                        self:setX(self.x + dx)
                        self:setY(self.y + dy)
                    end,
                    init = function(self)
                        if self.parent.parent.data then
                            local elements = string.split(self.parent.parent.data, "<")
                            for i, val in ipairs(elements) do
                                if val ~= "" then
                                    local data = string.split(val, ">")
                                    local params = {}
                                    local paramsData = string.split(data[1], ",")
                                    local incorrectElement = nil
                                    for _, v in ipairs(paramsData) do
                                        local temp = string.split(v, ":")
                                        if temp[1] == nil or temp[2] == nil then
                                            incorrectElement = v
                                        else
                                            params[string.trim(temp[1])] = string.trim(temp[2])
                                        end
                                    end

                                    if incorrectElement then
                                        print("RICH TEXT ERROR: Incorrect string: " .. incorrectElement)
                                        break
                                    end

                                    if params["type"] == "parent" then
                                        for key, value in pairs(params) do
                                            if key ~= "type" then
                                                if key == "width" then
                                                    local val2 = loadstring("return " .. value)()
                                                    self:setWidth(val2)
                                                elseif key == "height" then
                                                    local val2 = loadstring("return " .. value)()
                                                    self:setHeight(val2)
                                                end
                                            end
                                        end
                                    elseif params["type"] == "text" then
                                        self.children["element_" .. i] = UI.Text{}
                                        for key, value in pairs(params) do
                                            if key ~= "type" then
                                                self.children["element_" .. i][key] = loadstring("return " .. value)()
                                            end
                                        end

                                        local str = ""
                                        for j = 1, #data[2] do
                                            local ch = string.sub(data[2], j, j)
                                            if ch == "^" then
                                                str = str .. "\n"
                                            else
                                                str = str .. ch
                                            end
                                        end
                                        self.children["element_" .. i].text = str
                                        UI._addChild(self, self.children["element_" .. i])
                                    elseif params["type"] == "texture" then
                                        self.children["element_" .. i] = UI.Texture{}
                                        for key, value in pairs(params) do
                                            if key ~= "type" then
                                                self.children["element_" .. i][key] = loadstring("return " .. value)()
                                            end
                                        end
                                        UI._addChild(self, self.children["element_" .. i])
                                    end
                                end
                            end
                        end
                        self.parent.parent:updateSize()
                    end
                },
                textNode = UI.Panel{
                    isStencil = true,
                    enabled = false,
                    visible = false,
                    r = 0, g = 0, b = 0, a = 0.96,
                    children = {
                        container = UI.Node{
                            anchorLeft = 0, anchorRight = -11,
                            children = {
                                title = UI.Text{
                                    x = 50, y = 35,
                                    scaleX = 0.8, scaleY = 0.8,
                                    r = 1, g = 1, b = 1, a = 1,
                                    text = "",
                                    font = UIFont.SdfOldBold,
                                },

                                line = UI.Texture{
                                    x = 50, y = 70,
                                    width = 500, height = 2,
                                    r = 1, g = 1, b = 1, a = 1,
                                },

                                text = UI.Text{
                                    x = 50, y = 100,
                                    r = 1, g = 1, b = 1, a = 1,
                                    scaleX = 0.5, scaleY = 0.5,
                                    text = ""
                                },
                            },
                            onScroll = function(self, percent)
                                self.parent.children.scrollBar:updateBar(percent)
                            end,
                            updateSize = function(self)
                                local h = self.children.text.javaObj:getTextHeight() * self.children.text.scaleY + self.children.text.y + 100
                                self:setHeight(h)

                                local y = self.children.title.y + self.children.title.javaObj:getTextHeight() + 20
                                self.children.line:setY(y)
                                self.children.text:setY(y + 20)
                                self.parent.children.scrollBar:setBarSize(self.parent.height / h)
                                self.parent.children.scrollBar:updateBar(0)
                            end,
                            init = function(self)
                                self.parent.children.scrollBar.container = self
                                self.children.title:setText(self.parent.parent.parent.textTitle)
                                self.children.text:setText(self.parent.parent.parent.textData)
                                self:updateSize()
                            end
                        },
                        scrollBar = UI.ScrollBarVertical{}
                    },
                    updateSize = function(self, width, height)
                        self:setWidth(width)
                        self:setHeight(height)
                        self.children.container.children.title.javaObj:setAutoWidth((width)/self.children.container.children.title.scaleX - 250)
                        self.children.container.children.text.javaObj:setAutoWidth((width)/self.children.container.children.text.scaleX - 250)
                        self.children.container.children.line:setWidth(width - 250)

                        self.children.container:updateSize()
                    end
                }
            },
            onMouseWheel = function(self, del)
                if not ((self.children.printMedia.scaleY - del*0.1) < 0.25 or (self.children.printMedia.scaleX - del*0.1) < 0.25) then
                    if not ((self.children.printMedia.scaleY - del*0.1) > 4 or (self.children.printMedia.scaleX - del*0.1) > 4) then
                        self.children.printMedia:setScaleX(self.children.printMedia.scaleX - del*0.1)
                        self.children.printMedia:setScaleY(self.children.printMedia.scaleY - del*0.1)
                    end
                end
                return true
            end
        },
        bottomBar = UI.Window.children.bottomBar{
            children = {
                revealOnMap1 = revealOnMapTemplate{ anchorRight = -6 },
                revealOnMap2 = revealOnMapTemplate{ anchorRight = -6*2 - 40 },
                revealOnMap3 = revealOnMapTemplate{ anchorRight = -6*3 - 40*2 },
                revealOnMap4 = revealOnMapTemplate{ anchorRight = -6*4 - 40*3 },
                revealOnMap5 = revealOnMapTemplate{ anchorRight = -6*5 - 40*4 },
                readNewspaper = UI.Panel{
                    enabled = true,
                    visible = true,
                    isClosed = true,
                    height = 40, width = 40,
                    y = -46,
                    anchorLeft = 6,
                    children = {
                        icon = UI.Texture{
                            x = 20, y = 20,
                            width = 32, height = 32,
                            pivotX = 0.5, pivotY = 0.5,
                            texture = getTexture("media/textures/Item_Notebook.png"),
                        }
                    },
                    onLeftClick = function(self)
                        local body = self.parent.parent.children.body
                        body.children.textNode:updateSize(body.width - 20, body.height - 30 - 32)
                        if self.isClosed then
                            body.children.textNode.javaObj:setEnabled(true)
                            body.children.textNode.javaObj:setVisible(true)
                        else
                            body.children.textNode.javaObj:setEnabled(false)
                            body.children.textNode.javaObj:setVisible(false)
                        end
                        self.isClosed = not self.isClosed
                    end
                }
            }
        }
    },
    init = function(self)
        if self.media_id and PrintMediaDefinitions.MiscDetails[self.media_id] then
            local details = PrintMediaDefinitions.MiscDetails[self.media_id]
            for i = 1, 5 do
                local revealButton = self.children.bottomBar.children["revealOnMap" .. i]
                local locationData = details["location" .. i]
                if locationData == nil then break end
                revealButton.onLeftClick = function()
                    local xx = 0
                    local yy = 0
                    local maxLen = 0
                    for _, sqData in ipairs(locationData) do
                        --WorldMapVisited.getInstance():setKnownInSquares(sqData.x1, sqData.y1, sqData.x2, sqData.y2)
                        xx = xx + sqData.x1 + sqData.x2
                        yy = yy + sqData.y1 + sqData.y2
                        maxLen = math.max((sqData.x2 - sqData.x1), (sqData.y2 - sqData.y1), maxLen)
                        
                        local newSymbol = {}
                        newSymbol.symbol = "Question"
                        newSymbol.x = math.ceil((sqData.x1 + sqData.x2) / 2)
                        newSymbol.y = math.ceil((sqData.y1 + sqData.y2) / 2)
                        newSymbol.r = 0.129
                        newSymbol.g = 0.129
                        newSymbol.b = 0.129

                        local modData = getPlayer():getModData()
                        local pointsOfInterest = modData.pointsOfInterest

                        local isPOInew = true

                        if pointsOfInterest == nil then
                            local data = {}
                            table.insert(data, {
                                symbol = newSymbol.symbol,
                                x = newSymbol.x,
                                y = newSymbol.y,
                                r = newSymbol.r,
                                g = newSymbol.g,
                                b = newSymbol.b
                            })

                            modData.pointsOfInterest = data
                        else
                            for _, v in pairs(pointsOfInterest) do
                                local sameX = newSymbol.x == v.x
                                local sameY = newSymbol.y == v.y

                                if sameX and sameY then
                                    isPOInew = false
                                end
                            end
                            
                            if isPOInew then
                                table.insert(pointsOfInterest, {
                                    symbol = newSymbol.symbol,
                                    x = newSymbol.x,
                                    y = newSymbol.y,
                                    r = newSymbol.r,
                                    g = newSymbol.g,
                                    b = newSymbol.b
                                })
                            end
                        end
                        
                        if isPOInew then    
                            modData.haveNewPointOfInterest = true
                        end
                    end
                    local centerX = xx / (#locationData * 2)
                    local centerY = yy / (#locationData * 2)
                    local playerObj = getPlayer()
                    ISTimedActionQueue.clear(playerObj)
                    ISTimedActionQueue.add(ISReadWorldMap:new(playerObj, centerX, centerY, getMapZoom(maxLen)))
                end
                revealButton:setEnabled(true)
                revealButton:setVisible(true)
            end
        end
    end,
    onResize = function(self)
        if not self.children.bottomBar.children.readNewspaper.isClosed then
            self.children.bottomBar.children.readNewspaper:onLeftClick()
        end
    end,
    updateSize = function(self)
        local w = self.children.body.children.printMedia.width
        local h = self.children.body.children.printMedia.height

        if h > getCore():getScreenHeight() * 0.8 then
            local scale = getCore():getScreenHeight() * 0.8 / h
            w = w * scale
            h = getCore():getScreenHeight() * 0.8
            self.children.body.children.printMedia:setScaleX(scale)
            self.children.body.children.printMedia:setScaleY(scale)
        end

        self:setWidth(w)
        self:setHeight(h + 24 + 4)

        self.children.body.children.textNode:setX(10)
        self.children.body.children.textNode:setY(10)
        self.children.body.children.textNode:updateSize(w - 20, h - 30)
    end,
    onKeyRelease = function(self, key)
        if key ~= Keyboard.KEY_ESCAPE then return false end
        UIManager.RemoveElement(self.javaObj)
        return true
    end
}

UI.PrintMedia.children.bar.children.name = UI.Text{
    text = "",
    pivotX = 0.5, pivotY = 0.5,
    scaleX = 0.36, scaleY = 0.36,
    anchorLeft = 0, anchorRight = 0, anchorTop = 0, anchorDown = 0
}

