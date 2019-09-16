function NewScene(scriptPath)
    local self = {}
    self.location = "NONE"
    self.characterLocations = {}
    self.characters = {}
    self.evidence = {}
    self.courtRecord = {}

    self.penalties = 5
    self.textHidden = false
    self.text = "empty"
    self.textTalker = ""
    self.textBoxSprite = TextBoxSprite
    self.textColor = {1,1,1}
    self.textCentered = false
    self.showCourtRecord = false
    self.wasPressingCourtRecord = false
    self.courtRecordIndex = 1

    self.wasPressingRight = false
    self.wasPressingLeft = false

    -- the script is loaded into the court scene's events table
    -- function definitions are stored in the court scene's definitions table
    -- the script is made up of individual "events"
    -- events are defined in scriptevents.lua
    LoadScript(self, scriptPath)

    -- run a function definition defined in the script
    self.runDefinition = function (self, defName, loc)
        if loc == nil then
            loc = 1
        end

        local definition = deepcopy(self.definitions[defName])
        for i=#definition, 1, -1 do
            table.insert(self.events, loc, definition[i])
        end
    end

    self.update = function (self, dt)
        -- update the active event
        self.textHidden = false
        self.canShowCourtRecord = true
        self.canShowCharacter = true
        self.textCentered = false
        self.textBoxSprite = TextBoxSprite
        while #self.events >= 1 and not self.events[1]:update(self, dt) do
            table.remove(self.events, 1)
        end

        -- open and close the court record
        local pressingCourtRecord = love.keyboard.isDown("z")
        if pressingCourtRecord and not self.wasPressingCourtRecord then
            self.showCourtRecord = not self.showCourtRecord
        end
        self.wasPressingCourtRecord = pressingCourtRecord

        if not self.canShowCourtRecord then
            self.showCourtRecord = false
        end

        if not self.showCourtRecord then
            self.courtRecordIndex = 1
        end

        -- move left and right through the court record
        local pressingRight = love.keyboard.isDown("right")
        local pressingLeft = love.keyboard.isDown("left")

        if pressingRight and not self.wasPressingRight then
            self.courtRecordIndex = self.courtRecordIndex + 1

            if self.courtRecordIndex > #self.courtRecord then
                self.courtRecordIndex = 1
            end
        end
        if pressingLeft and not self.wasPressingLeft then
            self.courtRecordIndex = self.courtRecordIndex - 1

            if self.courtRecordIndex < 1 then
                self.courtRecordIndex = #self.courtRecord
            end
        end

        self.wasPressingRight = pressingRight
        self.wasPressingLeft = pressingLeft
    end

    self.draw = function (self, dt)
        love.graphics.setColor(1,1,1)

        -- draw the background of the current location
        local background = Backgrounds[self.location]
        if background[1] ~= nil then
            love.graphics.draw(background[1])
        end

        -- draw the character who is at the current location
        local character = self.characterLocations[self.location]
        if character ~= nil 
        and self.characters[character.name].poses[character.frame] ~= nil
        and self.canShowCharacter then
            love.graphics.draw(self.characters[character.name].poses[character.frame])
        end

        -- draw the top layer of the environment, like desk on top of character
        if background[2] ~= nil then
            love.graphics.draw(background[2])
        end

        if self.type == "TRIAL" then
            love.graphics.setColor(0,0,0)
            local str = ""
            for i=1, self.penalties do
                str = str .. "!"
            end
            love.graphics.print(str)
        end

        -- if the current event has an associated graphic, draw it
        love.graphics.setColor(1,1,1)
        if #self.events >= 1 then
            if self.events[1].draw ~= nil then
                self.events[1]:draw(self)
            end
        end

        -- draw the court record
        if self.showCourtRecord then
            love.graphics.setColor(0.2,0.2,0.2)
            love.graphics.rectangle("fill", 0,24,GraphicsWidth(),92)

            love.graphics.setColor(1,1,1)
            if #self.courtRecord >= self.courtRecordIndex then
                local sprite = self.courtRecord[self.courtRecordIndex].sprite
                love.graphics.draw(sprite,GraphicsWidth()/2,GraphicsHeight()/2 - 48, 0, 1,1, sprite:getWidth()/2,sprite:getHeight()/2)

                local name = self.courtRecord[self.courtRecordIndex].externalName
                local rectWidth = #name*8
                love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2 -16, rectWidth, "center")

                local name = self.courtRecord[self.courtRecordIndex].info
                local rectWidth = #name*8
                love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2, rectWidth, "center")
            else
                love.graphics.printf("court record empty", 0,48, GraphicsWidth(), "center")
            end
        end

        -- draw the textbox
        if not self.textHidden then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(self.textBoxSprite,0,GraphicsHeight()-self.textBoxSprite:getHeight())

            -- draw who is talking
            love.graphics.print(self.textTalker, 4, GraphicsHeight()-self.textBoxSprite:getHeight())

            -- draw the current scrolling text
            love.graphics.setColor(unpack(self.textColor))

            if not self.textCentered then
                love.graphics.printf(self.text, 4, GraphicsHeight()-60, 224, "left")
            else
                local lineTable = {"", "", ""}
                local lineIndex = 1

                for i=1, #self.text do
                    local char = string.sub(self.text, i,i)

                    if char == "#" then
                        lineIndex = lineIndex + 1
                    else
                        lineTable[lineIndex] = lineTable[lineIndex] .. char
                    end
                end

                for i=1, #lineTable do
                    love.graphics.printf(lineTable[i], 0, GraphicsHeight()-60 + (i-1)*16, GraphicsWidth(), "center")
                end
            end
        end
    end

    return self
end
