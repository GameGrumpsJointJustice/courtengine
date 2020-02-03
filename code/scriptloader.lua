function LoadScript(scene, scriptPath)
    scene.stack = {}
    scene.definitions = {}
    scene.type = ""

    local stack = scene.stack
    local definitions = {}

    local queuedSpeak = nil
    local queuedInterruptedSpeak = nil
    local queuedThink = nil
    local queuedTypewriter = nil
    local witnessQueue = nil
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

            if witnessQueue ~= nil then
                if #lineParts > 0 then
                    for i=1, #lineParts do
                        table.insert(witnessQueue, lineParts[i])
                    end
                else
                    AddToStack(stack, NewWitnessEvent(witnessQueue), lineParts)
                    witnessQueue = nil
                end

                canExecuteLine = false
            end

            if choiceQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_CHOICE" then
                    for i=1, #lineParts do
                        table.insert(choiceQueue, lineParts[i])
                    end
                else
                    AddToStack(stack, NewChoiceEvent(choiceQueue), lineParts)
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
                    AddToStack(stack, NewFakeChoiceEvent(fakeChoiceQueue), lineParts)
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
                    AddToStack(stack, NewInvestigationMenuEvent(invMenuQueue), lineParts)
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
                    AddToStack(stack, NewExamineEvent(examinationQueue), lineParts)
                    examinationQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                AddToStack(stack, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2], queuedSpeak[3]), {"SPEAK "..queuedSpeak[1], unpack(lineParts)})
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedInterruptedSpeak ~= nil then
                AddToStack(stack, NewInterruptedSpeakEvent(queuedInterruptedSpeak[1], lineParts[1], queuedInterruptedSpeak[2], queuedInterruptedSpeak[3]), {"queuedInterruptedSpeak "..queuedInterruptedSpeak[1], unpack(lineParts)})
                queuedInterruptedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedThink ~= nil then
                AddToStack(stack, NewThinkEvent(queuedThink[1], lineParts[1], queuedThink[2], queuedThink[3]), {"THINK "..queuedThink[1], unpack(lineParts)})
                queuedThink = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedTypewriter ~= nil then
                AddToStack(stack, NewTypeWriterEvent(lineParts[1]), {"TYPEWRITER", unpack(lineParts)})
                queuedTypewriter = nil

                canExecuteLine = false
            end

            if canExecuteLine and evidenceAddQueue ~= nil then
                AddToStack(stack, NewAddToCourtRecordAnimationEvent(lineParts[1], evidenceAddQueue[1]), {"COURT_RECORD_ADD EVIDENCE "..evidenceAddQueue[1], unpack(lineParts)})
                evidenceAddQueue = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    AddToStack(stack, NewCharInitEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    AddToStack(stack, NewCharLocationEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    AddToStack(stack, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]), lineParts)
                end
                if lineParts[1] == "PROFILE_INITIALIZE" then
                    -- 2: internal name, 3: in-game title (character name), 4: age, 5: description, 6: profile icon
                    AddToStack(stack, NewProfileInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5], lineParts[6]), lineParts)
                end
                if lineParts[1] == "COURT_RECORD_ADD" then
                    -- 2: court record item type (evidence or profile), 3: internal name of initialized item
                    AddToStack(stack, NewCourtRecordAddEvent(lineParts[2], lineParts[3]), lineParts)
                end

                if lineParts[1] == "SET_SCENE_TYPE" then
                    scene.type = lineParts[2]
                end
                if lineParts[1] == "END_SCENE" then
                    AddToStack(stack, NewSceneEndEvent(), lineParts)
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    stack = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    stack = scene.stack
                end
                if lineParts[1] == "JUMP" then
                    AddToStack(stack, NewClearExecuteDefinitionEvent(lineParts[2]), lineParts)
                end

                if lineParts[1] == "JUMPCUT" then
                    AddToStack(stack, NewCutToEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "PAN" then
                    AddToStack(stack, NewPanEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "POSE" then
                    AddToStack(stack, NewPoseEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "WAIT" then
                    AddToStack(stack, NewWaitEvent(lineParts[2]))
                end
                if lineParts[1] == "ANIMATION" then
                    if #lineParts == 4 then
                        AddToStack(stack, NewAnimationEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                    else
                        AddToStack(stack, NewAnimationEvent(lineParts[2], lineParts[3]), lineParts)
                    end
                end
                if lineParts[1] == "PLAY_MUSIC" then
                    AddToStack(stack, NewPlayMusicEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "STOP_MUSIC" then
                    AddToStack(stack, NewStopMusicEvent(), lineParts)
                end
                if lineParts[1] == "SFX" then
                    AddToStack(stack, NewPlaySoundEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    AddToStack(stack, NewIssuePenaltyEvent(), lineParts)
                end
                if lineParts[1] == "GAME_OVER" then
                    AddToStack(stack, NewGameOverEvent(), lineParts)
                end

                if lineParts[1] == "SHOUT" then
                    AddToStack(stack, NewShoutEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "WIDESHOT" then
                    AddToStack(stack, NewWideShotEvent(), lineParts)
                end
                if lineParts[1] == "GAVEL" then
                    AddToStack(stack, NewGavelEvent(), lineParts)
                end
                if lineParts[1] == "FADE_TO_BLACK" then
                    AddToStack(stack, NewFadeToBlackEvent(), lineParts)
                end
                if lineParts[1] == "SCREEN_SHAKE" then
                    AddToStack(stack, NewScreenShakeEvent(), lineParts)
                end
                if lineParts[1] == "WITNESS_EVENT" then
                    witnessQueue = {lineParts[2], lineParts[3], lineParts[4]}
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
                    AddToStack(stack, NewSetFlagEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "IF"
                and lineParts[3] == "IS"
                and lineParts[5] == "THEN" then
                    AddToStack(stack, NewIfEvent(lineParts[2], lineParts[4], lineParts[6]), lineParts)
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal", lineParts[3]}
                end
                if lineParts[1] == "THINK" then
                    queuedThink = {lineParts[2], "literal", nil}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    AddToStack(stack, NewCutToEvent(lineParts[2]), {"SPEAK_FROM", unpack(lineParts)})
                    queuedSpeak = {lineParts[2], "location", lineParts[3]}
                end
                if lineParts[1] == "THINK_FROM" then
                    AddToStack(stack, NewCutToEvent(lineParts[2]), {"THINK_FROM", unpack(lineParts)})
                    queuedThink = {lineParts[2], "location", nil}
                end
                if lineParts[1] == "TYPEWRITER" then
                    queuedTypewriter = {}
                end
                if lineParts[1] == "COURT_RECORD_ADD_ANIMATION" then
                    AddToStack(stack, NewCourtRecordAddEvent(lineParts[2]), lineParts)
                    local displayName = lineParts[2]
                    if lineParts[3] then
                        displayName = lineParts[3]
                    end
                    AddToStack(stack, NewAddToCourtRecordAnimationEvent(lineParts[2], displayName), lineParts)
                end
                if lineParts[1] == "CLEAR_LOCATION" then
                    AddToStack(stack, NewClearLocationEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "HIDE_TEXT" then
                    AddToStack(stack, NewHideTextEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "INTERRUPTED_SPEAK" then
                    queuedInterruptedSpeak = {lineParts[2], "literal", lineParts[3]}
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

function AddToStack(stack, event, lineParts)
    -- Save just enough info for us to return to this
    -- state if we choose to skip around the game
    local stackContext = {
        lineParts = lineParts,
        event = event
    }

    table.insert(stack, stackContext)
end
