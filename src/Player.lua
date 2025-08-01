local Weapon = require('Weapon')

function Player(startX, startY, attackType)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local player = {
        x = startX,
        y = startY,
        speed = 200,
        color = {0.8, 0.8, 0.8},
        lastDirection = {x = 0, y = -1},
        radius = 20,
        alive = true,
        attackType = attackType or "fire",
        weapon = Weapon(20, attackType or "fire")
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
    end

    function player.setAttackType(newType)
        player.attackType = newType
        player.weapon.setType(newType)
    end

    return player
end

return Player