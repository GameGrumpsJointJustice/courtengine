function LoadScript(scene, scriptPath)
    scene.events = {}
    scene.sceneScript = {}
    scene.definitions = {}
    scene.type = ""

    local events = scene.events
    local sceneScript = scene.sceneScript
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
                    AddToStack(events, sceneScript, NewCrossExaminationEvent(crossExaminationQueue), lineParts)
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
                    AddToStack(events, sceneScript, NewChoiceEvent(choiceQueue), lineParts)
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
                    AddToStack(events, sceneScript, NewFakeChoiceEvent(fakeChoiceQueue), lineParts)
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
                    AddToStack(events, sceneScript, NewInvestigationMenuEvent(invMenuQueue), lineParts)
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
                    AddToStack(events, sceneScript, NewExamineEvent(examinationQueue), lineParts)
                    examinationQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                AddToStack(events, sceneScript, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2], queuedSpeak[3]), {"queuedSpeak "..queuedSpeak[1], unpack(lineParts)})
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedThink ~= nil then
                AddToStack(events, sceneScript, NewThinkEvent(queuedThink[1], lineParts[1], queuedThink[2], queuedThink[3]), {"queuedThink "..queuedThink[1], unpack(lineParts)})
                queuedThink = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedTypewriter ~= nil then
                AddToStack(events, sceneScript, NewTypeWriterEvent(lineParts[1]), {"queuedTypewriter", unpack(lineParts)})
                queuedTypewriter = nil

                canExecuteLine = false
            end

            if canExecuteLine and evidenceAddQueue ~= nil then
                AddToStack(events, sceneScript, NewAddToCourtRecordAnimationEvent(lineParts[1], evidenceAddQueue[1]), {"evidenceAddQueue "..evidenceAddQueue[1], unpack(lineParts)})
                evidenceAddQueue = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    AddToStack(events, sceneScript, NewCharInitEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    AddToStack(events, sceneScript, NewCharLocationEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    AddToStack(events, sceneScript, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]), lineParts)
                end
                if lineParts[1] == "COURT_RECORD_ADD" then
                    AddToStack(events, sceneScript, NewCourtRecordAddEvent(lineParts[2]), lineParts)
                end

                if lineParts[1] == "SET_SCENE_TYPE" then
                    scene.type = lineParts[2]
                end
                if lineParts[1] == "END_SCENE" then
                    AddToStack(events, sceneScript, NewSceneEndEvent(), lineParts)
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    events = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    events = scene.events
                end
                if lineParts[1] == "JUMP" then
                    AddToStack(events, sceneScript, NewClearExecuteDefinitionEvent(lineParts[2]), lineParts)
                end

                if lineParts[1] == "JUMPCUT" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "PAN" then
                    AddToStack(events, sceneScript, NewPanEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "POSE" then
                    AddToStack(events, sceneScript, NewPoseEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "ANIMATION" then
                    if #lineParts == 4 then
                        AddToStack(events, sceneScript, NewAnimationEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                    else
                        AddToStack(events, sceneScript, NewAnimationEvent(lineParts[2], lineParts[3]), lineParts)
                    end
                end
                if lineParts[1] == "PLAY_MUSIC" then
                    AddToStack(events, sceneScript, NewPlayMusicEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "STOP_MUSIC" then
                    AddToStack(events, sceneScript, NewStopMusicEvent(), lineParts)
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    AddToStack(events, sceneScript, NewIssuePenaltyEvent(), lineParts)
                end
                if lineParts[1] == "GAME_OVER" then
                    AddToStack(events, sceneScript, NewGameOverEvent(), lineParts)
                end

                if lineParts[1] == "OBJECTION" then
                    AddToStack(events, sceneScript, NewObjectionEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "HOLD_IT" then
                    AddToStack(events, sceneScript, NewHoldItEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "WIDESHOT" then
                    AddToStack(events, sceneScript, NewWideShotEvent(), lineParts)
                end
                if lineParts[1] == "GAVEL" then
                    AddToStack(events, sceneScript, NewGavelEvent(), lineParts)
                end
                if lineParts[1] == "FADE_TO_BLACK" then
                    AddToStack(events, sceneScript, NewFadeToBlackEvent(), lineParts)
                end
                if lineParts[1] == "SCREEN_SHAKE" then
                    AddToStack(events, sceneScript, NewScreenShakeEvent(), lineParts)
                end

                if lineParts[1] == "CROSS_EXAMINATION" then
                    crossExaminationQueue = {lineParts[2], lineParts[3], lineParts[4]}
                end
                if lineParts[1] == "CHOICE" then
                    choiceQueue = {}
                end
                if lineParts[1] == "FAKE_CHOICE" then
                    fakeChoiceQueue = {}
                end
                if lineParts[1] == "INVESTIGATION_MENU" then
                    invMenuQueue = {}
                end
                if lineParts[1] == "EXAMINE" then
                    examinationQueue = {}
                end

                if lineParts[1] == "SET_FLAG" then
                    AddToStack(events, sceneScript, NewSetFlagEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "IF"
                and lineParts[3] == "IS"
                and lineParts[5] == "THEN" then
                    AddToStack(events, sceneScript, NewIfEvent(lineParts[2], lineParts[4], lineParts[6]), lineParts)
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal", lineParts[3]}
                end
                if lineParts[1] == "THINK" then
                    queuedThink = {lineParts[2], "literal", nil}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), {"SPEAK_FROM", unpack(lineParts)})
                    queuedSpeak = {lineParts[2], "location", lineParts[3]}
                end
                if lineParts[1] == "THINK_FROM" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), {"THINK_FROM", unpack(lineParts)})
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
    local openQuote = true

    local i = 1
    while i <= #line do
        local thisChar = string.sub(line, i,i)
        local thisDoubleChar = string.sub(line, i,i+1)
        local canAddToWord = true

        if thisDoubleChar == "//" then
            isComment = true
        end

        if isComment then
            canAddToWord = false
        end

        if thisDoubleChar == "$q" then
            canAddToWord = false
            if openQuote then
                -- backtick corresponds to open quotation marks in the font image
                wordBuild = wordBuild .. '`'
            else
                -- quotation marks correspond to closed quotation marks in the font image
                wordBuild = wordBuild .. '"'
            end

            openQuote = not openQuote
            i=i+1
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

        i=i+1
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

-- initializes all character files based on folder
function NewCharInitEvent(name, location, gender)
    local self = {}
    self.name = name
    self.gender = gender

    -- allows for characters to be placed in characters/ or a custom directory
    if string.match(location,"/") then
        self.location = location
    else
        self.location = "characters/"..location
    end

    -- grabs the files in the character directory
    self.files = love.filesystem.getDirectoryItems(self.location)

    self.poses = {}
    self.animations = {}
    self.sounds = {}

    -- sorts files by type and adds them to the scene
    for b, i in ipairs(self.files) do
        if string.match(i,".png") then
            --print(self.location.."/"..i)

            if string.match(i,"_ani") then
                local a = i:gsub(".png","")
                local a = a:gsub("_ani","")

                --print(a)

                self.animations[a] = NewAnimation(self.location.."/"..i, false)
            elseif string.match(i,"_un") then
                local a = i:gsub(".png","")
                local a = a:gsub("_un","")

                --print(a)

                self.poses[a] = NewAnimation(self.location.."/"..i, false)
            else
                local a = i:gsub(".png","")
                local isTalking = string.match(i, "Talking")

                --print(a)

                self.poses[a] = NewAnimation(self.location.."/"..i, not isTalking)
            end

        elseif string.match(i,".wav") then
            local a = i:gsub(".wav","")
            --print("LOWERCASE WAV"..i)
            self.sounds[a] = love.audio.newSource(self.location.."/"..i, "static")
            self.sounds[a]:setVolume(0.25)

        elseif string.match(i,".WAV") then
            local a = i:gsub(".WAV","")
            --print("UPPERCASE WAV"..i)
            self.sounds[a] = love.audio.newSource(self.location.."/"..i, "static")
            self.sounds[a]:setVolume(0.25)
        end
    end

    self.update = function (self, scene, dt)
        scene.characters[self.name] = {
            poses = self.poses,
            animations = self.animations,
            sounds = self.sounds,

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

function AddToStack(events, sceneScript, event, lineParts)
    -- This is used by the engine to see what event should
    -- be run right now
    table.insert(events, event)

    -- Save just enough info for us to return to this
    -- state if we choose to skip around the game
    local eventContext = {
        lineParts = lineParts,
        event = event
    }

    table.insert(sceneScript, #events, eventContext)
end
