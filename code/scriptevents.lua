function NewCharLocationEvent(name, location)
    local self = {}
    self.name = name
    self.location = location

    self.update = function (self, scene, dt)
        scene.characterLocations[self.location] = scene.characters[self.name]

        return false
    end

    return self
end

function NewPoseEvent(name, pose)
    local self = {}
    self.name = name
    self.pose = pose

    self.update = function (self, scene, dt)
        scene.characters[self.name].frame = self.pose

        return false
    end

    return self
end

function NewAnimationEvent(name, animation, speed)
    local self = {}
    self.name = name
    self.animation = animation
    self.timer = 0
    self.animIndex = 1

    if speed == nil then
        speed = 10
    end
    self.speed = speed

    self.update = function (self, scene, dt)
        scene.canShowCharacter = false
        scene.canShowCourtRecord = false
        scene.textHidden = true

        self.timer = self.timer + dt*self.speed
        self.animIndex = math.max(math.floor(self.timer +0.5), 1)

        local animation = scene.characters[self.name].animations[self.animation]
        if self.animIndex <= #animation.anim then
            return true
        end

        scene.canShowCharacter = true
        return false
    end

    self.characterDraw = function (self, scene)
        local animation = scene.characters[self.name].animations[self.animation]
        love.graphics.draw(animation.source, animation.anim[self.animIndex])
    end

    return self
end

function NewCutToEvent(cutTo)
    local self = {}
    self.cutTo = cutTo

    self.update = function (self, scene, dt)
        scene.location = self.cutTo
        return false
    end

    return self
end

function NewSpeakEvent(who, text, locorlit, color)
    local self = {}
    self.text = text
    self.textScroll = 1
    self.wasPressing = true
    self.who = who
    self.locorlit = locorlit

    if color == nil then
        color = "WHITE"
    end
    self.color = color
    self.animates = true
    self.speaks = true

    self.update = function (self, scene, dt)
        scene.fullText = self.text

        local lastScroll = self.textScroll
        local scrollSpeed = TextScrollSpeed
        if love.keyboard.isDown("lshift") then
            scrollSpeed = scrollSpeed*8
        end
        self.textScroll = math.min(self.textScroll + dt*scrollSpeed, #self.text)

        if self.textScroll < #self.text then
            scene.characterTalking = self.animates
        end

        if self.locorlit == "literal" then
            scene.textTalker = self.who
        else
            scene.textTalker = scene.characterLocations[self.who].name
        end

        if self.textScroll > lastScroll and self.speaks then
            if scene.characters[scene.textTalker].gender == "MALE" then
                Sounds.MALETALK:play()
            else
                Sounds.FEMALETALK:play()
            end
        end

        if self.color == "WHITE" then
            scene.textColor = {1,1,1}
        end
        if self.color == "LTBLUE" then
            scene.textColor = {0,0.75,1}
        end
        if self.color == "GREEN" then
            scene.textColor = {0,1,0.25}
        end
        
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))

        local pressing = love.keyboard.isDown("x")
        if pressing and not self.wasPressing and self.textScroll >= #self.text then
            return false
        end
        self.wasPressing = pressing

        return true
    end

    return self
end

function NewThinkEvent(who, text, locorlit)
    local self = NewSpeakEvent(who, text, locorlit)
    self.color = "LTBLUE"
    self.animates = false
    self.speaks = false

    return self
end

function NewTypeWriterEvent(text)
    local self = {}
    self.text = text
    self.textScroll = 1
    self.wasPressing = true

    self.update = function (self, scene, dt)
        local lastScroll = self.textScroll
        self.textScroll = math.min(self.textScroll + dt*TextScrollSpeed, #self.text)

        if self.textScroll > lastScroll then
            Sounds.TYPEWRITER:play()
        end

        scene.fullText = self.text
        scene.textCentered = true
        scene.textColor = {0,1,0}
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))
        scene.textTalker = ""
        scene.textBoxSprite = AnonTextBoxSprite

        local pressing = love.keyboard.isDown("x")
        if pressing and not self.wasPressing and self.textScroll >= #self.text then
            return false
        end
        self.wasPressing = pressing

        return true
    end

    self.draw = function (self, scene)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('fill', 0,0,GraphicsWidth(),GraphicsHeight())
    end

    return self
end

function NewAddToCourtRecordAnimationEvent(text, evidence)
    local self = {}
    self.text = text
    self.textScroll = 1
    self.evidence = evidence
    self.wasPressing = true

    self.update = function (self, scene, dt)
        self.textScroll = math.min(self.textScroll + dt*TextScrollSpeed, #self.text)
        scene.fullText = self.text
        scene.textCentered = true
        scene.textColor = {0,0.2,1}
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))
        scene.textTalker = ""
        scene.textBoxSprite = AnonTextBoxSprite

        local pressing = love.keyboard.isDown("x")
        if pressing and not self.wasPressing and self.textScroll >= #self.text then
            return false
        end
        self.wasPressing = pressing

        return true
    end

    self.draw = function (self, scene)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(scene.evidence[self.evidence].sprite, 16,16)
    end

    return self
end

function NewPlayMusicEvent(music)
    local self = {}
    self.music = music

    self.update = function (self, scene, dt)
        for i,v in pairs(Music) do
            v:stop()
        end

        Music[self.music]:play()

        return false
    end

    return self
end

function NewCourtRecordAddEvent(evidence)
    local self = {}
    self.evidence = evidence

    self.update = function (self, scene, dt)
        table.insert(scene.courtRecord, scene.evidence[self.evidence])
        return false
    end

    return self
end

function NewExecuteDefinitionEvent(def)
    local self = {}
    self.def = def
    self.hasRun = false

    self.update = function (self, scene, dt)
        if not self.hasRun then
            self.hasRun = true
            scene:runDefinition(self.def)
        end

        return false
    end

    return self
end

function NewClearExecuteDefinitionEvent(def)
    local self = {}
    self.def = def
    self.hasRun = false

    self.update = function (self, scene, dt)
        if not self.hasRun then
            self.hasRun = true
            scene.events = {}
            scene:runDefinition(self.def, 2)
        end

        return false
    end

    return self
end

function NewChoiceEvent(options)
    local self = {}
    self.select = 1
    self.options = options

    self.wasPressingUp = false
    self.wasPressingDown = false
    self.wasPressingX = true

    -- this is for FakeChoiceEvent polymorphism
    -- if a choice is fake, then whatever option the player chooses still continues the script
    self.isFake = false

    self.update = function (self, scene, dt)
        local pressingUp = love.keyboard.isDown("up")
        local pressingDown = love.keyboard.isDown("down")

        if not self.wasPressingUp and pressingUp then
            self.select = self.select - 2

            if self.select < 1 then
                self.select = #self.options -1
            end
        end

        if not self.wasPressingDown and pressingDown then
            self.select = self.select + 2 

            if self.select > #self.options -1 then
                self.select = 1
            end
        end

        self.wasPressingUp = pressingUp
        self.wasPressingDown = pressingDown

        local pressingX = love.keyboard.isDown("x")

        if pressingX and not self.wasPressingX then
            if self.options[self.select+1] == "0" then
                return false
            else
                scene:runDefinition(self.options[self.select+1])

                if self.isFake then
                    return false
                end
            end
        end

        self.wasPressingX = pressingX

        return true
    end

    self.draw = function (self, scene)
        for i=1, #self.options, 2 do
            love.graphics.setColor(0.2,0.2,0.2)
            if self.select == i then
                love.graphics.setColor(0.8,0,0.2)
            end
            love.graphics.rectangle("fill", 146,30+(i-1)*16 -4, GraphicsWidth(),28)
            love.graphics.setColor(1,1,1)
            love.graphics.print(self.options[i], 150,30+(i-1)*16)
        end
    end

    return self
end

function NewFakeChoiceEvent(options)
    local self = NewChoiceEvent(options)
    self.isFake = true
    return self
end

function NewSceneEndEvent()
    local self = {}

    self.update = function (self, scene, dt)
        NextScene()
        return false
    end

    return self
end

function NewStopMusicEvent()
    local self = {}

    self.update = function (self, scene, dt)
        for i,v in pairs(Music) do
            v:stop()
        end

        return false
    end

    return self
end

function NewFadeToBlackEvent()
    local self = {}
    self.timer = 0

    self.update = function (self, scene, dt)
        scene.textHidden = true
        scene.canShowCourtRecord = false

        local lastTimer = self.timer 
        self.timer = self.timer + dt

        return self.timer <= 1 and lastTimer <= 1
    end

    self.draw = function (self, scene)
        love.graphics.setColor(0,0,0, self.timer)
        love.graphics.rectangle("fill", 0,0, GraphicsWidth(),GraphicsHeight())
    end

    return self
end

function NewScreenShakeEvent()
    local self = {}

    self.update = function (self, scene, dt)
        ScreenShake = 0.15
        return false
    end

    return self
end

function NewSetFlagEvent(flag, set)
    local self = {}
    self.flag = flag
    self.set = set

    self.update = function (self, scene, dt)
        scene.flags[self.flag] = self.set
        print("set " .. self.flag .. " to " .. self.set)
        return false
    end

    return self
end

function NewIfEvent(flag, test, def)
    local self = {}
    self.flag = flag
    self.test = test
    self.def = def

    self.update = function (self, scene, dt)
        if scene.flags[self.flag] == self.test then
            scene:runDefinition(self.def, 2)
        end

        return false
    end

    return self
end