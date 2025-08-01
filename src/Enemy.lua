function Enemy()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local types = {"fire", "water", "grass"}
    local type = types[math.random(1, #types)]
    local colorTable = {
        fire = {1, 0.3, 0.3},
        water = {0.3, 0.5, 1},
        grass = {0.2, 0.8, 0.3}
    }
    local color = colorTable[type]

    local enemy = {
        x = math.random(50, screenWidth - 50),
        y = math.random(50, screenHeight - 50),
        radius = 15,
        color = color,
        speed = 80,
        alive = true,
        type = type,
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
            love.graphics.setColor(enemy.color)
            love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", enemy.x, enemy.y, enemy.radius)
            -- Disegna il tipo sopra il nemico
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

return Enemy