function NewInvestigationMenuEvent(options)
    local self = NewChoiceEvent(options)

    self.parentUpdate = self.update
    self.update = function (self, scene, dt)
        scene.textHidden = true
        return self.parentUpdate(self, scene, dt)
    end

    return self
end

function NewExamineEvent(examinables)
    local self = {}
    self.x = GraphicsWidth()/2
    self.y = GraphicsHeight()/2
    self.examinables = examinables
    self.wasPressingX = false

    self.update = function (self, scene, dt)
        scene.textHidden = true
        scene.canShowCourtRecord = false
        scene.canShowCharacter = false

        local moveSpeed = 2*(dt*60)
        if love.keyboard.isDown("right") then
            self.x = self.x + moveSpeed
        end
        if love.keyboard.isDown("left") then
            self.x = self.x - moveSpeed
        end
        if love.keyboard.isDown("up") then
            self.y = self.y - moveSpeed
        end
        if love.keyboard.isDown("down") then
            self.y = self.y + moveSpeed
        end

        if love.keyboard.isDown("z") then
            return false
        end

        local pressingX = love.keyboard.isDown("x")
        if not self.wasPressingX and pressingX then
            for i=1, #self.examinables, 5 do
                if  self.x >= tonumber(self.examinables[i])
                and self.y >= tonumber(self.examinables[i+1])
                and self.x <= tonumber(self.examinables[i+2])
                and self.y <= tonumber(self.examinables[i+3]) then
                    --print(self.examinables[i+4])
                    scene:runDefinition(self.examinables[i+4])
                end
            end
        end
        self.wasPressingX = pressingX

        self.x = math.max(math.min(self.x, GraphicsWidth()), 0)
        self.y = math.max(math.min(self.y, GraphicsHeight()), 0)

        return true
    end

    self.draw = function (self, scene)
        love.graphics.setColor(0,0.2,1, 1)

        for i=1, #self.examinables, 5 do
            if  self.x >= tonumber(self.examinables[i])
            and self.y >= tonumber(self.examinables[i+1])
            and self.x <= tonumber(self.examinables[i+2])
            and self.y <= tonumber(self.examinables[i+3]) then
                love.graphics.setColor(1,1,0)
            end
        end

        local rad = 4
        love.graphics.rectangle("line", self.x-rad,self.y-rad,rad*2,rad*2)
        love.graphics.line(self.x,self.y-rad,self.x,self.y+rad)
        love.graphics.line(self.x-rad,self.y,self.x+rad,self.y)
    end

    return self
end