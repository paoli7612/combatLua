-- main.lua (nella root del progetto)

local GameState = require('core.GameState')

function love.load()
    GameState.load()
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState.draw()
end

function love.keypressed(key)
    GameState.keypressed(key)
end

function love.quit()
    print("Uscita dal gioco.")
end