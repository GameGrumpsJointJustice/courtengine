function LoadScript(scene, scriptPath)
    scene.events = {}
    scene.definitions = {}
    scene.type = ""

    local events = scene.events
    local definitions = {}

    local queuedSpeak = nil
    local queuedThink = nil
    local queuedTypewriter = nil
    local crossExaminationQueue = nil
    local choiceQueue = nil
    local fakeChoiceQueue = nil
    local invMenuQueue = nil
    local evidenceAddQueue = nil
    local examinationQueue = nil

    for line in love.filesystem.lines(scriptPath) do
        if line == nil then
            canRead = false
        else
            local lineParts = DisectLine(line)
            local canExecuteLine = true

            if crossExaminationQueue ~= nil then
                if #lineParts > 0 then
                    for i=1, #lineParts do
                        table.insert(crossExaminationQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewCrossExaminationEvent(crossExaminationQueue))
                    crossExaminationQueue = nil
                end

                canExecuteLine = false
            end

            if choiceQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_CHOICE" then
                    for i=1, #lineParts do
                        table.insert(choiceQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewChoiceEvent(choiceQueue))
                    choiceQueue = nil
                end

                canExecuteLine = false
            end

            if fakeChoiceQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_CHOICE" then
                    for i=1, #lineParts do
                        table.insert(fakeChoiceQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewFakeChoiceEvent(fakeChoiceQueue))
                    fakeChoiceQueue = nil
                end

                canExecuteLine = false
            end

            if invMenuQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_INVESTIGATION_MENU" then
                    for i=1, #lineParts do
                        table.insert(invMenuQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewInvestigationMenuEvent(invMenuQueue))
                    invMenuQueue = nil
                end

                canExecuteLine = false
            end

            if examinationQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_EXAMINATION" then
                    for i=1, #lineParts do
                        table.insert(examinationQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewExamineEvent(examinationQueue))
                    examinationQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                table.insert(events, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2], queuedSpeak[3]))
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedThink ~= nil then
                table.insert(events, NewThinkEvent(queuedThink[1], lineParts[1], queuedThink[2], queuedThink[3]))
                queuedThink = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedTypewriter ~= nil then
                table.insert(events, NewTypeWriterEvent(lineParts[1]))
                queuedTypewriter = nil

                canExecuteLine = false
            end

            if canExecuteLine and evidenceAddQueue ~= nil then
                table.insert(events, NewAddToCourtRecordAnimationEvent(lineParts[1], evidenceAddQueue[1]))
                evidenceAddQueue = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    table.insert(events, NewCharInitEvent(lineParts[2], lineParts[3], lineParts[4]))
                end
                if lineParts[1] == "CHARACTER_INITIALIZE_POSE" then
                    if #lineParts < 4 then
                        table.insert(events, NewCharPoseInitEvent(lineParts[2], lineParts[3]))
                    else
                        table.insert(events, NewCharPoseInitEvent(lineParts[2], lineParts[3], lineParts[4]))
                    end
                end
                if lineParts[1] == "CHARACTER_INITIALIZE_ANIMATION" then
                    table.insert(events, NewCharAnimationInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_INITIALIZE_SOUND" then
                    table.insert(events, NewCharSoundInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    table.insert(events, NewCharLocationEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    table.insert(events, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]))
                end
                if lineParts[1] == "COURT_RECORD_ADD" then
                    table.insert(events, NewCourtRecordAddEvent(lineParts[2]))
                end

                if lineParts[1] == "SET_SCENE_TYPE" then
                    scene.type = lineParts[2]
                end
                if lineParts[1] == "END_SCENE" then
                    table.insert(events, NewSceneEndEvent())
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    events = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    events = scene.events
                end
                if lineParts[1] == "JUMP" then
                    table.insert(events, NewClearExecuteDefinitionEvent(lineParts[2]))
                end

                if lineParts[1] == "JUMPCUT" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                end
                if lineParts[1] == "POSE" then
                    table.insert(events, NewPoseEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "ANIMATION" then
                    if #lineParts == 4 then
                        table.insert(events, NewAnimationEvent(lineParts[2], lineParts[3], lineParts[4]))
                    else
                        table.insert(events, NewAnimationEvent(lineParts[2], lineParts[3]))
                    end
                end
                if lineParts[1] == "PLAY_MUSIC" then
                    table.insert(events, NewPlayMusicEvent(lineParts[2]))
                end
                if lineParts[1] == "STOP_MUSIC" then
                    table.insert(events, NewStopMusicEvent())
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    table.insert(events, NewIssuePenaltyEvent())
                end
                if lineParts[1] == "GAME_OVER" then
                    table.insert(events, NewGameOverEvent())
                end

                if lineParts[1] == "OBJECTION" then
                    table.insert(events, NewObjectionEvent(lineParts[2]))
                end
                if lineParts[1] == "HOLD_IT" then
                    table.insert(events, NewHoldItEvent(lineParts[2]))
                end
                if lineParts[1] == "WIDESHOT" then
                    table.insert(events, NewWideShotEvent())
                end
                if lineParts[1] == "GAVEL" then
                    table.insert(events, NewGavelEvent())
                end
                if lineParts[1] == "FADE_TO_BLACK" then
                    table.insert(events, NewFadeToBlackEvent())
                end
                if lineParts[1] == "SCREEN_SHAKE" then
                    table.insert(events, NewScreenShakeEvent())
                end

                if lineParts[1] == "CROSS_EXAMINATION" then
                    crossExaminationQueue = {lineParts[2], lineParts[3], lineParts[4]}
                end
                if lineParts[1] == "CHOICE" then
                    choiceQueue = {}
                end
                if lineParts[1] == "INVESTIGATION_MENU" then
                    invMenuQueue = {}
                end
                if lineParts[1] == "EXAMINE" then
                    examinationQueue = {}
                end

                if lineParts[1] == "SET_FLAG" then
                    table.insert(events, NewSetFlagEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "IF"
                and lineParts[3] == "IS"
                and lineParts[5] == "THEN" then
                    table.insert(events, NewIfEvent(lineParts[2], lineParts[4], lineParts[6]))
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal", lineParts[3]}
                end
                if lineParts[1] == "THINK" then
                    queuedThink = {lineParts[2], "literal", nil}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                    queuedSpeak = {lineParts[2], "location", lineParts[3]}
                end
                if lineParts[1] == "THINK_FROM" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                    queuedThink = {lineParts[2], "location", nil}
                end
                if lineParts[1] == "TYPEWRITER" then
                    queuedTypewriter = {}
                end
                if lineParts[1] == "COURT_RECORD_ADD_ANIMATION" then
                    evidenceAddQueue = {lineParts[2]}
                end
            end
        end
    end
end

function DisectLine(line)
    local words = {}
    local isDialogue = false
    local isComment = false
    local wordBuild = ""

    for i=1, #line do
        local thisChar = string.sub(line, i,i)
        local thisDoubleChar = string.sub(line, i,i+1)
        local canAddToWord = true

        if thisDoubleChar == "//" then
            isComment = true
        end

        if isComment then
            canAddToWord = false
        end

        if canAddToWord 
        and thisChar == "@"
        and not isDialogue then
            canAddToWord = false

            table.insert(words, "@")
        end

        if canAddToWord and thisChar == '"' then
            canAddToWord = false

            if isDialogue then
                table.insert(words, wordBuild)
                wordBuild = ""
            end

            isDialogue = not isDialogue
        end

        if canAddToWord and not isDialogue and thisChar == " " then
            canAddToWord = false

            if #wordBuild > 0 then
                table.insert(words, wordBuild)
                wordBuild = ""
            end
        end

        if canAddToWord then
            wordBuild = wordBuild .. thisChar
        end
    end

    if #wordBuild > 0 then
        table.insert(words, wordBuild)
        wordBuild = ""
    end

    return words
end

function NewAnimation(file, holdFirst)
    local animation = {}
    local source = love.graphics.newImage(file) 

    animation.source = source
    animation.anim = {}

    if holdFirst then
        for i=1, 20 do
            animation.anim[i] = love.graphics.newQuad(0,0, GraphicsWidth(),GraphicsHeight(), source:getWidth(), source:getHeight())
        end
    end

    for i=1, source:getWidth()/GraphicsWidth() do
        local x = (i-1)*GraphicsWidth()
        animation.anim[#animation.anim+1] = love.graphics.newQuad(x,0, GraphicsWidth(),GraphicsHeight(), source:getWidth(), source:getHeight())
    end

    return animation
end

function NewCharInitEvent(name, location, gender)
    local self = {}
    self.name = name
    self.location = location
    self.gender = gender

    self.update = function (self, scene, dt)
        scene.characters[self.name] = {
            poses = {
                Normal = NewAnimation(self.location.."/Normal.png", true),
                NormalTalking = NewAnimation(self.location.."/NormalTalking.png", false),
            },
            animations = {},
            sounds = {},

            location = self.location,
            wideshot = NewAnimation(self.location .. "/wideshot.png", false),
            name = self.name,
            gender = self.gender,
            frame = "Normal",
        }

        return false
    end

    return self
end

function NewCharPoseInitEvent(name, pose, padding)
    local self = {}
    self.name = name
    self.pose = pose

    if padding == nil then
        padding = "PADDED"
    end
    self.padding = padding

    self.update = function(self, scene, dt)
        local location = scene.characters[self.name].location
        local padding = self.padding == "PADDED"
        scene.characters[self.name].poses[self.pose] = NewAnimation(location .. "/" .. self.pose .. ".png", padding)
        scene.characters[self.name].poses[self.pose.."Talking"] = NewAnimation(location .. "/" .. self.pose .. "Talking.png", false)

        return false
    end

    return self
end

function NewCharAnimationInitEvent(name, animation)
    local self = {}
    self.name = name
    self.animation = animation

    self.update = function(self, scene, dt)
        local location = scene.characters[self.name].location
        scene.characters[self.name].animations[self.animation] = NewAnimation(location .. "/" .. self.animation .. ".png", false)

        return false
    end

    return self
end

function NewCharSoundInitEvent(name, sound)
    local self = {}
    self.name = name
    self.sound = sound

    self.update = function(self, scene, dt)
        local location = scene.characters[self.name].location
        scene.characters[self.name].sounds[self.sound] = love.audio.newSource(location .. "/" .. self.sound .. ".wav", "static")
        scene.characters[self.name].sounds[self.sound]:setVolume(MasterVolume/2)

        return false
    end

    return self
end

function NewEvidenceInitEvent(name, externalName, info, file)
    local self = {}
    self.name = name
    self.externalName = externalName
    self.info = info
    self.file = file

    self.update = function (self, scene, dt)
        scene.evidence[self.name] = {
            name = self.name,
            externalName = self.externalName,
            info = self.info,
            sprite = love.graphics.newImage(self.file),
        }

        return false
    end

    return self
end
