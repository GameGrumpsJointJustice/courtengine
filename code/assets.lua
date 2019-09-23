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
    CourtPanSprite = love.graphics.newImage("backgrounds/courtpan.png")

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

    GameFont = love.graphics.newImageFont("sprites/FontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():,-'*" .. '`"', 2)
    SmallFont = love.graphics.newImageFont("sprites/SmallFontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():", 1)
    love.graphics.setFont(GameFont)
end
