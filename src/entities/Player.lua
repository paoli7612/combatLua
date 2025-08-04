-- entities/Player.lua

local Types = require('types.Types')
local Weapon = require('types.Weapon')
local Globals = require('core.Globals')
local Projectile = require('entities.Projectile')

function Player(startX, startY, type)
    local info = Types.data[type or "meccanica"]

    local player = {
        x = startX,
        y = startY,
        speed = 200,
        lastDirection = {x = 0, y = -1},
        radius = 20,
        alive = true,
        type = type,
        energia = info.energia,
        inerzia = info.inerzia,
        persistenza = info.persistenza,
        recupero = info.recupero,
        weapon = Weapon(20),
        img = Types.images[type or "meccanica"],
        rangedCooldown = false,
        hp = 5, -- HP iniziali
        maxHp = 5,
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
            Projectile.spawn(player)
        end
        if not love.keyboard.isDown("w") then
            player.rangedCooldown = false
        end

        -- Limiti schermo
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
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

    function player:takeDamage(amount)
        self.hp = self.hp - amount
        if self.hp < 0 then self.hp = 0 end
    end

    function player.draw()
        player.weapon.draw(player.x, player.y)
        if player.img then
            love.graphics.stencil(function()
                love.graphics.circle("fill", player.x, player.y, player.radius)
            end, "replace", 1)
            love.graphics.setStencilTest("greater", 0)

            local scale = (player.radius * 2) / player.img:getWidth()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                player.img,
                player.x - player.radius,
                player.y - player.radius,
                0,
                scale,
                scale
            )

            love.graphics.setStencilTest()
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", player.x, player.y, player.radius)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", player.x, player.y, player.radius)

        -- Mostra i parametri del player
        local y = love.graphics.getHeight() - 120
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Energia: " .. tostring(player.energia), 200, y)
        love.graphics.print("Inerzia: " .. tostring(player.inerzia), 200, y + 16)
        love.graphics.print("Persistenza: " .. tostring(player.persistenza), 200, y + 32)
        love.graphics.print("Recupero: " .. tostring(player.recupero), 200, y + 48)

        -- Barra della vita
        local barWidth = 200
        local barHeight = 18
        local barX = 10
        local barY = love.graphics.getHeight() - 100
        local hpRatio = player.hp / player.maxHp
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 6, 6)
        love.graphics.setColor(0.8, 0.1, 0.1)
        love.graphics.rectangle("fill", barX, barY, barWidth * hpRatio, barHeight, 6, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 6, 6)
        love.graphics.print("Vita: " .. player.hp .. " / " .. player.maxHp, barX + 8, barY + 1)
    end

    return player
end

return Player