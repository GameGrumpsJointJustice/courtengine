function NewTitleScene()
    local self = {}
    self.image = love.graphics.newImage("main_logo.png")

    self.update = function (self, dt)
        if love.keyboard.isDown("p") then
            LoadEpisode("scripts/episode1.meta")
        end
    end

    self.draw = function (self, dt)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.image, 0, 0, 0, 0.16, 0.16)
        love.graphics.setColor(1,0,0)
        love.graphics.print("Press P to start", 80, 150,0 ,1,1)
    end

    return self
end
