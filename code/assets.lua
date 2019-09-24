function LoadBackgrounds()
    Backgrounds = {
        NONE = {},
    }

    files = love.filesystem.getDirectoryItems("backgrounds/")

    for b, i in ipairs(files) do
        if string.match(i,".png") then
            if string.match(i,"_1") then
                local a = i:gsub(".png","")
                local a = a:gsub("_1","")
                Backgrounds[a] = {love.graphics.newImage("backgrounds/"..i)}
            elseif string.match(i,"_2") then
                local a = i:gsub(".png","")
                local a = a:gsub("_2","")
                table.insert(Backgrounds[a],love.graphics.newImage("backgrounds/"..i))
            else
                local a = i:gsub(".png","")
                Backgrounds[a] = {love.graphics.newImage("backgrounds/"..i)}
            end
        end
    end
end

function LoadMusic()
    Music = {}

    files = love.filesystem.getDirectoryItems("music/")

    for b, i in ipairs(files) do
        if string.match(i,".mp3") then
            local a = i:gsub(".mp3",""):upper()
            Music[a] = love.audio.newSource("music/"..i, "static")
        elseif string.match(i,".wav") then
            local a = i:gsub(".wav",""):upper()
            Music[a] = love.audio.newSource("music/"..i, "static")
        end
    end

    for i,v in pairs(Music) do
        v:setLooping(true)
        v:setVolume(MasterVolume)
    end
end

function LoadSprites()
    Sprites = {}

    files = love.filesystem.getDirectoryItems("sprites/")

    for b, i in ipairs(files) do
        if string.match(i,".png") then
            if string.match(i,"_") then
                if string.match(i,"_1") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_1","")
                    local a = a.."Animation"
                    Sprites[a] = {love.graphics.newImage("sprites/"..i)}
                elseif string.match(i,"_2") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_2","")
                    local a = a.."Animation"
                    table.insert(Sprites[a],love.graphics.newImage("sprites/"..i))
                elseif string.match(i,"_3") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_3","")
                    local a = a.."Animation"
                    table.insert(Sprites[a],love.graphics.newImage("sprites/"..i))
                elseif string.match(i,"_4") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_4","")
                    local a = a.."Animation"
                    table.insert(Sprites[a],love.graphics.newImage("sprites/"..i))
                elseif string.match(i,"_5") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_5","")
                    local a = a.."Animation"
                    table.insert(Sprites[a],love.graphics.newImage("sprites/"..i))
                elseif string.match(i,"_6") then
                    local a = i:gsub(".png","")
                    local a = a:gsub("_6","")
                    local a = a.."Animation"
                    table.insert(Sprites[a],love.graphics.newImage("sprites/"..i))
                end
            elseif string.match(i,"Font") then
                False = false
            else
                local a = i:gsub(".png","")
                Sprites[a] = love.graphics.newImage("sprites/"..i)
            end
        end
    end
end

function LoadShouts()
    Shouts = {}

    files = love.filesystem.getDirectoryItems("sprites/shouts/")

    for b, i in ipairs(files) do
        if string.match(i,".png") then
            local a = i:gsub(".png","")
            Shouts[a] = love.graphics.newImage("sprites/shouts/"..i)
        end
    end
end

function LoadSFX()
    Sounds = {}

    files = love.filesystem.getDirectoryItems("sounds/")

    for b, i in ipairs(files) do
        if string.match(i,".mp3") then
            local a = i:gsub(".mp3",""):upper()
            Sounds[a] = love.audio.newSource("sounds/"..i, "static")
        elseif string.match(i,".wav") then
            local a = i:gsub(".wav",""):upper()
            Sounds[a] = love.audio.newSource("sounds/"..i, "static")
        end
    end

    for i,v in pairs(Sounds) do
        v:setVolume(MasterVolume/2)
    end
end

function LoadMisc()
    GameFont = love.graphics.newImageFont("sprites/FontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():,-'*" .. '`"', 2)
    SmallFont = love.graphics.newImageFont("sprites/SmallFontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():", 1)
    love.graphics.setFont(GameFont)
end

function LoadAssets()
    LoadBackgrounds()
    LoadMusic()
    LoadSprites()
    LoadShouts()
    LoadSFX()
    LoadMisc()
end
