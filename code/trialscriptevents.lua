function NewObjectionEvent(who)
    local self = {}
    self.timer = 0
    self.x,self.y = 0,0
    self.who = who

    self.update = function (self, scene, dt)
        scene.textHidden = true
        scene.characters[self.who].sounds.objection:play()
        self.timer = self.timer + dt
        self.x = self.x + love.math.random()*choose{1,-1}*2
        self.y = self.y + love.math.random()*choose{1,-1}*2

        return self.timer < 0.5
    end

    self.draw = function (self, scene)
        love.graphics.draw(ObjectionSprite, self.x,self.y)
    end

    return self
end

function NewHoldItEvent(who)
    local self = {}
    self.timer = 0
    self.x,self.y = 0,0
    self.who = who

    self.update = function (self, scene, dt)
        scene.textHidden = true
        scene.characters[self.who].sounds.holdit:play()
        self.timer = self.timer + dt
        self.x = self.x + love.math.random()*choose{1,-1}*2
        self.y = self.y + love.math.random()*choose{1,-1}*2

        return self.timer < 0.5
    end

    self.draw = function (self, scene)
        love.graphics.draw(HoldItSprite, self.x,self.y)
    end

    return self
end

function NewCrossExaminationEvent(queue)
    local self = {}
    self.queue = queue
    self.textScroll = 1
    self.textIndex = 2
    self.wasPressing = true
    self.who = queue[1]
    self.timer = 0
    self.animationTime = 1.5

    self.advanceText = function (self)
        if self.textIndex == 2 then
            self.textIndex = 4
        else
            self.textIndex = self.textIndex + 4
        end

        self.textScroll = 1
        self.wasPressing = true

        if self.textIndex > #self.queue then
            self.textIndex = 4
        end
    end

    self.update = function (self, scene, dt)
        self.timer = self.timer + dt

        local text = self.queue[self.textIndex]

        local lastScroll = self.textScroll
        self.textScroll = math.min(self.textScroll + dt*TextScrollSpeed, #text)

        local inTitle = self.textIndex == 2

        if inTitle then
            scene.textColor = {1,0.5,0}
            scene.textCentered = true
        else
            scene.characters[self.who].frame = self.queue[self.textIndex+3]
            if self.textScroll < #text then
                scene.characterTalking = true
            end

            scene.textColor = {0,1,0.25}
        end
        scene.text = string.sub(text, 1, math.floor(self.textScroll))
        scene.fullText = text
        scene.textTalker = self.who

        local currentChar = string.sub(text, math.floor(self.textScroll), math.floor(self.textScroll))
        if self.textScroll > lastScroll
        and currentChar ~= " "
        and currentChar ~= ","
        and currentChar ~= "-" then
            if scene.characters[scene.textTalker].gender == "MALE" then
                Sounds.MALETALK:play()
            else
                Sounds.FEMALETALK:play()
            end
        end


        local canAdvance = self.textScroll >= #text and self.timer > self.animationTime

        local pressing = love.keyboard.isDown("x")
        if pressing
        and not self.wasPressing
        and canAdvance then
            self:advanceText()
        end
        self.wasPressing = pressing

        if love.keyboard.isDown("c")
        and canAdvance
        and not inTitle then
            scene:runDefinition(self.queue[self.textIndex+1])
            self:advanceText()
        end

        if love.keyboard.isDown("up")
        and scene.showCourtRecord
        and not inTitle then
            scene.showCourtRecord = false

            if scene.courtRecord[scene.courtRecordIndex].name == self.queue[self.textIndex+2] then
                return false
            else
                scene:runDefinition(self.queue[3])
                self:advanceText()
            end
        end

        return true
    end

    self.draw = function (self, scene)
        if self.timer < self.animationTime then
            love.graphics.draw(CrossExaminationSprite, GraphicsWidth()/2,GraphicsHeight()/2 -24, 0, 1,1, CrossExaminationSprite:getWidth()/2,CrossExaminationSprite:getHeight()/2)
        else
            love.graphics.setColor(1,1,1)
            for i=1, scene.penalties do
                love.graphics.draw(PenaltySprite, (i-1)*12 +2,2)
            end
        end
    end

    return self
end

function NewIssuePenaltyEvent()
    local self = {}

    self.update = function (self, scene, dt)
        scene.penalties = scene.penalties - 1

        if scene.penalties <= 0 then
            scene:runDefinition("TRIAL_FAIL")
        end

        return false
    end

    return self
end

function NewGameOverEvent()
    local self = {}

    self.update = function (self, scene, dt)
        love.event.push("quit")
        return false
    end

    return self
end

function NewWideShotEvent()
    local self = {}
    self.timer = 0
    self.hasPlayed = false
    self.sources = {}
    self.headAnim = 1
    self.frameCounter = 0

    self.update = function (self, scene, dt)
        self.timer = self.timer + dt
        self.frameCounter = self.frameCounter + dt

        while self.frameCounter >= 2/15 do
            self.frameCounter = self.frameCounter - 2/15
            self.headAnim = self.headAnim + 1
            if self.headAnim > 4 then
                self.headAnim = 1
            end
        end

        scene.textHidden = true

        if not self.hasPlayed then
            --self.sources = love.audio.pause()
            Sounds.MUTTER:play()
            self.hasPlayed = true
        end

        scene.textHidden = true
        scene.canShowCourtRecord = false

        if self.timer >= 2 then
            Sounds.MUTTER:stop()
            for i,v in pairs(self.sources) do
                v:play()
            end
            return false
        end

        return true
    end

    self.draw = function (self, scene)
        love.graphics.draw(WideShotSprite)
        love.graphics.draw(TalkingHeadAnimation[self.headAnim])

        for i,v in pairs(scene.characters) do
            love.graphics.draw(v.wideshot.source)
        end
    end

    return self
end

function NewGavelEvent()
    local self = {}
    self.timer = 0
    self.index = 1
    self.hasPlayed = false
    self.muted = false
    self.sources = {}

    self.update = function (self, scene, dt)
        self.timer = self.timer + dt
        scene.textHidden = true
        scene.canShowCourtRecord = false

        if not self.muted then
            self.muted = true
            --self.sources = love.audio.pause()
        end

        if self.timer > 0.3 then
            self.index = 2
        end

        if self.timer > 0.35 then
            self.index = 3

            if not self.hasPlayed then
                self.hasPlayed = true
                Sounds.GAVEL:play()
            end
        end

        if self.timer >= 1.3 then
            for i,v in pairs(self.sources) do
                v:play()
            end
            return false
        end
        return true
    end

    self.draw = function (self, scene)
        local spr = GavelAnimation[self.index]
        love.graphics.draw(spr, 0,0, 0, GraphicsWidth()/spr:getWidth(),GraphicsHeight()/spr:getHeight())
    end
    return self
end
