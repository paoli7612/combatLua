local Types = require('Types')
local Weapon = require('Weapon')

function Player(startX, startY, type)
    local info = Types.data[type or "meccanica"]

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local player = {
        x = startX,
        y = startY,
        speed = 200,
        color = info.color,
        lastDirection = {x = 0, y = -1},
        radius = 20,
        alive = true,
        type = type,  -- <-- Qui salviamo il tipo scelto!
        energia = info.energia,
        inerzia = info.inerzia,
        persistenza = info.persistenza,
        recupero = info.recupero,
        weapon = Weapon(20)
    }

    function player.update(dt)
        player.weapon.update(dt)
        local moving = false
        local dirX, dirY = 0, 0
        if love.keyboard.isDown("j") then dirX = dirX - 1; moving = true end
        if love.keyboard.isDown("l") then dirX = dirX + 1; moving = true end
        if love.keyboard.isDown("i") then dirY = dirY - 1; moving = true end
        if love.keyboard.isDown("k") then dirY = dirY + 1; moving = true end

        if moving then
            local length = math.sqrt(dirX * dirX + dirY * dirY)
            if length > 0 then
                player.lastDirection.x = dirX / length
                player.lastDirection.y = dirY / length
            end
            player.x = player.x + player.lastDirection.x * player.speed * dt
            player.y = player.y + player.lastDirection.y * player.speed * dt
        end

        -- Attacco corpo a corpo con Q
        if love.keyboard.isDown("q") then
            player.weapon.actionMelee(player.lastDirection)
        end
        -- Attacco a distanza con W
        if love.keyboard.isDown("w") and not player.rangedCooldown then
            player.rangedCooldown = true
            -- Calcola la direzione
            local dir = {x = player.lastDirection.x, y = player.lastDirection.y}
            -- Normalizza
            local len = math.sqrt(dir.x*dir.x + dir.y*dir.y)
            if len == 0 then dir.x, dir.y = 1, 0 end
            -- Crea il proiettile
            table.insert(projectiles, {
                x = player.x,
                y = player.y,
                dirX = dir.x,
                dirY = dir.y,
                speed = 500,
                radius = 10,
                alive = true
            })
        end
        if not love.keyboard.isDown("w") then
            player.rangedCooldown = false
        end

        -- Limiti schermo
        if player.x - player.radius < 0 then
            player.x = player.radius
        elseif player.x + player.radius > screenWidth then
            player.x = screenWidth - player.radius
        end
        if player.y - player.radius < 0 then
            player.y = player.radius
        elseif player.y + player.radius > screenHeight then
            player.y = screenHeight - player.radius
        end
    end

    function player.draw()
        player.weapon.draw(player.x, player.y)
        love.graphics.setColor(player.color)
        love.graphics.circle("fill", player.x, player.y, player.radius)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", player.x, player.y, player.radius)

        -- Mostra i parametri del player
        local y = love.graphics.getHeight() - 120
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Energia: " .. tostring(player.energia), 200, y)
        love.graphics.print("Inerzia: " .. tostring(player.inerzia), 200, y + 16)
        love.graphics.print("Persistenza: " .. tostring(player.persistenza), 200, y + 32)
        love.graphics.print("Recupero: " .. tostring(player.recupero), 200, y + 48)
    end

    return player
end

return Player