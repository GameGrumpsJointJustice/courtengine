require "code/courtscene"
require "code/scriptloader"
require "code/scriptevents"
require "code/trialscriptevents"
require "code/investigationscriptevents"

function love.load(arg)
    love.window.setMode(GraphicsWidth()*4, GraphicsHeight()*4, {})
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")
    Renderable = love.graphics.newCanvas(GraphicsWidth(), GraphicsHeight())
    MasterVolume = 0.25
    TextScrollSpeed = 30
    ScreenShake = 0

    LoadAssets()

    -- set up the current scene
    Episode = {}
    for line in love.filesystem.lines("scripts/episode1.meta") do
        table.insert(Episode, line)
    end
    SceneIndex = 0
    NextScene()

    local argIndex = 1

    while argIndex <= #arg do
        if arg[argIndex] == "script" then
            CurrentScene = NewScene(arg[argIndex+1])
            CurrentScene:update(0)
        end

        if arg[argIndex] == "skip" then
            for i=1, tonumber(arg[argIndex+1]) do
                table.remove(CurrentScene.events, 1)
            end
        end
        argIndex = argIndex + 1
    end
end

function NextScene()
    SceneIndex = SceneIndex + 1

    for i,v in pairs(Music) do
        v:stop()
    end
    
    if SceneIndex <= #Episode then
        CurrentScene = NewScene(Episode[SceneIndex])
        CurrentScene:update(0)
    else
        love.event.push("quit")
    end
end

function LoadAssets()
    Backgrounds = {
        NONE = {},
        BLACK_SCREEN = {love.graphics.newImage("backgrounds/blackscreen.png")},
        LOBBY = {love.graphics.newImage("backgrounds/lobby.png")},
        COURT_DEFENSE = {love.graphics.newImage("backgrounds/defenseempty.png"), love.graphics.newImage("backgrounds/defensedesk.png")},
        COURT_PROSECUTION = {love.graphics.newImage("backgrounds/prosecutorempty.png"), love.graphics.newImage("backgrounds/prosecutiondesk.png")},
        COURT_JUDGE = {love.graphics.newImage("backgrounds/judgestand.png")},
        COURT_WITNESS = {love.graphics.newImage("backgrounds/witnessempty.png"), love.graphics.newImage("backgrounds/stand.png")},
        COURT_ASSISTANT = {love.graphics.newImage("backgrounds/helperstand.png")},
    }

    Music = {
        TRIAL = love.audio.newSource("music/trial.mp3", "static"),
        OBJECTION = love.audio.newSource("music/objection.mp3", "static"),
        SUSPENCE = love.audio.newSource("music/suspence.mp3", "static"),
        QUESTIONING_ALLEGRO = love.audio.newSource("music/questioning_allegro.mp3", "static"),
        QUESTIONING = love.audio.newSource("music/questioning.mp3", "static"),
        PRELUDE = love.audio.newSource("music/prelude.mp3", "static"),
        LOGIC_AND_TRICK = love.audio.newSource("music/logic_and_trick.mp3", "static"),
    }

    for i,v in pairs(Music) do
        v:setLooping(true)
        v:setVolume(MasterVolume)
    end
    
    TextBoxSprite = love.graphics.newImage("sprites/chatbox.png")
    AnonTextBoxSprite = love.graphics.newImage("sprites/chatbox_headless.png")
    ObjectionSprite = love.graphics.newImage("sprites/objection.png")
    HoldItSprite = love.graphics.newImage("sprites/holdit.png")
    CrossExaminationSprite = love.graphics.newImage("sprites/cross_examination.png")
    WideShotSprite = love.graphics.newImage("backgrounds/wideshot.png")
    PenaltySprite = love.graphics.newImage("sprites/exclamation.png")

    GavelAnimation = {
        love.graphics.newImage("sprites/gavel1.png"),
        love.graphics.newImage("sprites/gavel2.png"),
        love.graphics.newImage("sprites/gavel3.png"),
    }
    TalkingHeadAnimation = {
        love.graphics.newImage("sprites/talkingheads1.png"),
        love.graphics.newImage("sprites/talkingheads2.png"),
        love.graphics.newImage("sprites/talkingheads3.png"),
        love.graphics.newImage("sprites/talkingheads2.png"),
    }

    Sounds = {
        MUTTER = love.audio.newSource("sounds/sfx-gallery.wav", "static"),
        GAVEL = love.audio.newSource("sounds/sfx-gavel.wav", "static"),
        MALETALK = love.audio.newSource("sounds/sfx-blipmale.wav", "static"),
        FEMALETALK = love.audio.newSource("sounds/sfx-blipfemale.wav", "static"),
        TYPEWRITER = love.audio.newSource("sounds/sfx-typewriter.wav", "static"),
    }

    for i,v in pairs(Sounds) do
        v:setVolume(MasterVolume/2)
    end

    GameFont = love.graphics.newImageFont("sprites/FontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():,-'*", 2)
    SmallFont = love.graphics.newImageFont("sprites/SmallFontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():", 1)
    love.graphics.setFont(GameFont)
end

-- the constants for the resolution of the game
function GraphicsWidth()
    return 256
end
function GraphicsHeight()
    return 192
end

-- love.update and love.draw get called 60 times per second
-- transfer the update and draw over to the current game scene 
function love.update(dt)
    ScreenShake = math.max(ScreenShake - dt, 0)
    CurrentScene:update(dt)
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas(Renderable)
    love.graphics.clear(1,1,1)
    CurrentScene:draw()

    love.graphics.setCanvas()

    local dx,dy = 0,0

    if ScreenShake > 0 then
        dx = love.math.random()*choose{1,-1}*2
        dy = love.math.random()*choose{1,-1}*2
    end
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(Renderable, dx*love.graphics.getWidth()/GraphicsWidth(),dy*love.graphics.getHeight()/GraphicsHeight(), 0, love.graphics.getWidth()/GraphicsWidth(), love.graphics.getHeight()/GraphicsHeight())
end

-- utility functions 
function Clamp(n,min,max)
    return math.max(math.min(n,max), min)
end
function choose(arr)
    return arr[math.floor(love.math.random()*(#arr))+1]
end
function rand(min,max, interval)
    local interval = interval or 1
    local c = {}
    local index = 1
    for i=min, max, interval do
        c[index] = i
        index = index + 1
    end

    return choose(c)
end

function GetSign(n)
    if n > 0 then
        return 1
    end
    if n < 0 then
        return -1
    end
    return 0
end
function Lerp(a,b,t) return (1-t)*a + t*b end
function DeltaLerp(a,b,t, dt)
    return Lerp(a,b, 1 - t^(dt))
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
