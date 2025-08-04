-- entities/Enemy.lua

local Types = require('types.Types')
local Globals = require('core.Globals')

local Enemy = {}

-- Crea un nuovo nemico
function Enemy.new()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local type = Types.randomType()
    local info = Types.data[type]

    local enemy = {
        x = math.random(50, screenWidth - 50),
        y = math.random(50, screenHeight - 50),
        radius = 15,
        color = info.color,
        speed = 80,
        alive = true,
        type = type,
        name = info.name,
        img = Types.images[type],
        dirX = 0,
        dirY = 0,
        directionChangeTimer = 0,
        directionChangeInterval = math.random(1, 4)
    }

    function enemy.updateDirection()
        local angle = math.random() * 2 * math.pi
        enemy.dirX = math.cos(angle)
        enemy.dirY = math.sin(angle)
        enemy.directionChangeTimer = 0
        enemy.directionChangeInterval = math.random(1, 4)
    end

    enemy.updateDirection()

    function enemy.update(dt)
        if not enemy.alive then return end
        enemy.directionChangeTimer = enemy.directionChangeTimer + dt
        if enemy.directionChangeTimer >= enemy.directionChangeInterval then
            enemy.updateDirection()
        end
        enemy.x = enemy.x + enemy.dirX * enemy.speed * dt
        enemy.y = enemy.y + enemy.dirY * enemy.speed * dt
        local bounced = false
        if enemy.x - enemy.radius < 0 then
            enemy.x = enemy.radius
            enemy.dirX = -enemy.dirX
            bounced = true
        elseif enemy.x + enemy.radius > screenWidth then
            enemy.x = screenWidth - enemy.radius
            enemy.dirX = -enemy.dirX
            bounced = true
        end
        if enemy.y - enemy.radius < 0 then
            enemy.y = enemy.radius
            enemy.dirY = -enemy.dirY
            bounced = true
        elseif enemy.y + enemy.radius > screenHeight then
            enemy.y = screenHeight - enemy.radius
            enemy.dirY = -enemy.dirY
            bounced = true
        end
        if bounced then
            enemy.directionChangeTimer = 0
        end
    end

    function enemy.draw()
        if enemy.alive then
            if enemy.img then
                love.graphics.stencil(function()
                    love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                end, "replace", 1)
                love.graphics.setStencilTest("greater", 0)
                local scale = (enemy.radius * 2) / enemy.img:getWidth()
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    enemy.img,
                    enemy.x - enemy.radius,
                    enemy.y - enemy.radius,
                    0,
                    scale,
                    scale
                )
                love.graphics.setStencilTest()
            else
                love.graphics.setColor(enemy.color)
                love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", enemy.x, enemy.y, enemy.radius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(enemy.type, enemy.x - 12, enemy.y - 8)
        end
    end

    function enemy.die()
        enemy.alive = false
        print("Un nemico " .. enemy.type .. " è stato eliminato!")
    end

    return enemy
end

-- Aggiorna tutti i nemici
function Enemy.updateAll(dt)
    for _, enemy in ipairs(Globals.enemies) do
        if enemy.alive then
            enemy.update(dt)
        end
    end
    -- Pulisci nemici morti
    local living = {}
    for _, enemy in ipairs(Globals.enemies) do
        if enemy.alive then table.insert(living, enemy) end
    end
    Globals.enemies = living
end

-- Disegna tutti i nemici
function Enemy.drawAll()
    for _, enemy in ipairs(Globals.enemies) do
        enemy.draw()
    end
end

-- Permette di chiamare Enemy() per creare un nuovo nemico
return setmetatable(Enemy, { __call = function(_, ...) return Enemy.new(...) end })