local Player = require('Player')

function love.load()
    player = Player(100, 100)
end

function love.update(dt)
    player.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.2)
    player.draw()
    
    -- Interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("IJKL: movimento | Q: attacco | ESC: esci", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end