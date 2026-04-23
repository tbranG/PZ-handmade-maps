function NIM_ISMapOverrides()
    -- nim override
    -- we need to add each added symbol to the sketch mod data
    function ISWorldMapSymbolTool_AddSymbol:addSymbol(x, y)
        local newSymbol = {}
        local scale = ISMap.SCALE
        local sym = self.symbolsUI.selectedSymbol
        newSymbol.x = self.mapAPI:uiToWorldX(x, y)
        newSymbol.y = self.mapAPI:uiToWorldY(x, y)
        newSymbol.symbol = sym.tex
        newSymbol.r = self.symbolsUI.currentColor:getR()
        newSymbol.g = self.symbolsUI.currentColor:getG()
        newSymbol.b = self.symbolsUI.currentColor:getB()
        local textureSymbol = self.symbolsAPI:addTexture(newSymbol.symbol, newSymbol.x, newSymbol.y)
        textureSymbol:setRGBA(newSymbol.r, newSymbol.g, newSymbol.b, 1.0)
        textureSymbol:setAnchor(0.5, 0.5)
        textureSymbol:setScale(ISMap.SCALE)
        if self.symbolsUI.character then
            self.symbolsUI.character:playSoundLocal("MapAddSymbol")
        end

        if self.mapUI.mapObj then
            local mapData = self.mapUI.mapObj:getModData()
            local mapSymbols = mapData.symbols
    
            if mapSymbols == nil then
                local data = {}
                table.insert(data, {
                    symbol = newSymbol.symbol,
                    x = newSymbol.x,
                    y = newSymbol.y,
                    r = newSymbol.r,
                    g = newSymbol.g,
                    b = newSymbol.b,
                    scale = textureSymbol:getScale(),
                    rotation = textureSymbol:getRotation()
                })
    
                mapData.symbols = data
            else
                table.insert(mapSymbols, {
                    symbol = newSymbol.symbol,
                    x = newSymbol.x,
                    y = newSymbol.y,
                    r = newSymbol.r,
                    g = newSymbol.g,
                    b = newSymbol.b,
                    scale = textureSymbol:getScale(),
                    rotation = textureSymbol:getRotation()
                })
            end
        end
    end

    -- nim override
    -- we need to add each added note to the sketch mod data
    function ISWorldMapSymbolTool_AddNote:onNoteAdded(button, playerNum)
        self.modal = nil
        if button.internal == "OK" then
            local text = string.trim(button.parent.entry:getText())
            if text == "" then return end
            local newNote = {}
            newNote.text = text
            newNote.x = self.symbolsUI.noteX
            newNote.y = self.symbolsUI.noteY
            newNote.r = button.parent.currentColor:getR()
            newNote.g = button.parent.currentColor:getG()
            newNote.b = button.parent.currentColor:getB()
            newNote.a = 1.0
            if button.parent.useLayerColor then
                newNote.r = 0
                newNote.g = 0
                newNote.b = 0
                newNote.a = 0
            end
            local textSymbol
            local layerID = button.parent.chosenFont or self.symbolsAPI:getDefaultTextLayerID()
            local font = self.styleAPI:getLayerByName(layerID):getFont()
            local FONT_HGT = getTextManager():getFontHeight(font)
            if button.parent:isTranslation() then
                textSymbol = self.symbolsAPI:addUntranslatedText(newNote.text, layerID, newNote.x, newNote.y)
            else
                textSymbol = self.symbolsAPI:addTranslatedText(newNote.text, layerID, newNote.x, newNote.y)
            end
            textSymbol:setRGBA(newNote.r, newNote.g, newNote.b, newNote.a)
            textSymbol:setAnchor(0.5, 0.5)
            textSymbol:setScale(button.parent.scale or ISMap.SCALE)
            textSymbol:setRotation(button.parent.rotation or 0.0)
            textSymbol:setMatchPerspective(button.parent:isMatchPerspective())
            textSymbol:setMinZoom(button.parent.minZoom or 0.0)
            textSymbol:setMaxZoom(button.parent.maxZoom or 24.0)
            if self.symbolsUI.character then
                self.symbolsUI.character:playSoundLocal("MapAddNote")
            end
            -- Center on the edited symbol
            local isJoypad = JoypadState.players[self.symbolsUI.playerNum+1]
            if isJoypad then
                local worldX = newNote.x
                local worldY = newNote.y
                self.mapAPI:centerOn(worldX, worldY)
            end

            if self.mapUI.mapObj then
                local mapData = self.mapUI.mapObj:getModData()
                local mapNotes = mapData.notes

				if mapNotes == nil then
					local data = {}
					table.insert(data, {
						text = newNote.text,
						x = newNote.x,
						y = newNote.y,
						r = newNote.r,
						g = newNote.g,
						b = newNote.b,
                        scale = textSymbol:getScale(),
                        rotation = textSymbol:getRotation()
					})

					mapData.notes = data
				else
					table.insert(mapNotes, {
						text = symbol:getUntranslatedText() or symbol:getTranslatedText(),
						x = symbol:getWorldX(),
						y = symbol:getWorldY(),
						r = symbol:getRed(),
						g = symbol:getGreen(),
						b = symbol:getBlue(),
                        scale = symbol:getScale(),
                        rotation = symbol:getRotation()
					})
				end
            end
        end
    end
end

Events.OnGameStart.Add(NIM_ISMapOverrides)