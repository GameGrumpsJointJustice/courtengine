require "code/courtscene"
require "code/scriptloader"
require "code/scriptevents"
require "code/trialscriptevents"
require "code/investigationscriptevents"
require "code/utils"
require "code/assets"
require "code/controlscriptevents"
require "code/drawutils"
require "code/titlescene"


function love.load(arg)
    love.window.setMode(GraphicsWidth()*4, GraphicsHeight()*4, {})
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")
    Renderable = love.graphics.newCanvas(GraphicsWidth(), GraphicsHeight())
    MasterVolume = 0.25
    TextScrollSpeed = 30
    ScreenShake = 0

    LoadAssets()
    CurrentScene = NewTitleScene()

    local argIndex = 1
    while argIndex <= #arg do
        if arg[argIndex] == "script" then
            CurrentScene = NewScene(arg[argIndex+1])
            CurrentScene:update(0)
        end

        if arg[argIndex] == "skip" then
            for i=1, tonumber(arg[argIndex+1]) do
                table.remove(CurrentScene.events, 1)
                CurrentScene.currentEventIndex = CurrentScene.currentEventIndex + 1
            end
        end
        argIndex = argIndex + 1
    end
end

function LoadEpisode(episodePath)
    -- set up the current scene
    Episode = {}
    
    for line in love.filesystem.lines(episodePath) do
        table.insert(Episode, line)
    end
    SceneIndex = 0
    NextScene()
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

-- the constants for the internal resolution of the game
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
    if not game_paused then
        CurrentScene:update(dt)
    end
end

-- basic pause functionality
function love.keypressed(key)
    if key == "escape" then
        NavigationIndex = CurrentScene.currentEventIndex
        game_paused = not game_paused
    elseif game_paused then
        -- Let the user navigate
        if key == "up" and NavigationIndex > 1 then
            NavigationIndex = NavigationIndex - 1
        elseif key == "down" and NavigationIndex < #CurrentScene.sceneScript then
            NavigationIndex = NavigationIndex + 1
        elseif key == "return" then
            -- TODO: Implement some sort of navigation tool
        end
    end
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

    love.graphics.draw(
        Renderable, 
        dx*love.graphics.getWidth()/GraphicsWidth(),
        dy*love.graphics.getHeight()/GraphicsHeight(), 
        0, 
        love.graphics.getWidth()/GraphicsWidth(), 
        love.graphics.getHeight()/GraphicsHeight()
    )

    -- Added pause, additional cleaner graphics can be added in the future
    if game_paused then
        DrawPauseScreen()
    end
end
