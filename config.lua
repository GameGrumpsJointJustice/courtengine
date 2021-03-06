settings = {
    --[[
        setting this to true speeds up the scrollSpeed without needing to hold down "lshift"
        this can also be set by running the startup command of `love . debug`
    ]]
    debug = false; -- scriptevents.lua

    master_volume = 0.25;
    text_scroll_speed = 30;

    background_directory = "backgrounds/";
    character_directory = "characters/";
    music_directory = "music/";
    sprite_directory = "sprites/";
    shouts_directory = "sprites/shouts/";
    sfx_directory = "sounds/";

    main_logo_path = "main_logo_1024_flipped.png";
    episode_path = "scripts/episode1.meta";
}

-- Keybindings used by the onKeyPresseds in screens/index
controls = {
    start_button = "return";
    pause = "escape";
    pause_nav_up = "up";
    pause_nav_down = "down";
    pause_confirm = "return";
    press_court_record = "z";
    press_right = "right";
    press_left = "left";
    press_confirm = "up";
    press_toggle_profiles = "down";
}

dimensions = {
    graphics_scale = 4;
    window_width = 1280;
    window_height = 720;
}

colors = {
    white = {1, 1, 1};
    black = {0, 0, 0};
    red = {1, 0, 0};
    ltblue = {0, 0.75, 1};
    green = {0, 1, 0.25};
}

-- Override default display names for keyboard keys
key_display_names = {
    ['escape'] = 'Esc';
    ['backspace'] = 'Back';
    ['return'] = 'Enter';
    ['delete'] = 'Del';
    ['rctrl'] = 'Ctrl (R)';
    ['lctrl'] = 'Ctrl (L)';
    ['rshift'] = 'Shift (R)';
    ['lshift'] = 'Shfit (L)';
}

function InitGlobalConfigVariables()
    GraphicsWidth = dimensions.window_width / dimensions.graphics_scale
    GraphicsHeight = dimensions.window_height / dimensions.graphics_scale
    WindowWidth = dimensions.window_width
    WindowHeight = dimensions.window_height

    MasterVolume = settings.master_volume
    TextScrollSpeed = settings.text_scroll_speed
end
