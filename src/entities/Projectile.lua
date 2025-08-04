-- entities/Projectile.lua

local Globals = require('core.Globals')

local Projectile = {}

-- Crea e aggiunge un nuovo proiettile
function Projectile.spawn(player)
    local dir = {x = player.lastDirection.x, y = player.lastDirection.y}
    local len = math.sqrt(dir.x * dir.x + dir.y * dir.y)
    if len == 0 then dir.x, dir.y = 1, 0 end
    table.insert(Globals.projectiles, {
        x = player.x,
        y = player.y,
        dirX = dir.x,
        dirY = dir.y,
        speed = 500,
        radius = 10,
        alive = true
    })
end

-- Aggiorna tutti i proiettili e gestisce le collisioni
function Projectile.updateAll(dt)
    for _, proj in ipairs(Globals.projectiles) do
        if proj.alive then
            proj.x = proj.x + proj.dirX * proj.speed * dt
            proj.y = proj.y + proj.dirY * proj.speed * dt
            if proj.x < 0 or proj.x > love.graphics.getWidth() or proj.y < 0 or proj.y > love.graphics.getHeight() then
                proj.alive = false
            end
        end
    end

    -- Collisione proiettile-nemico
    for _, proj in ipairs(Globals.projectiles) do
        if proj.alive then
            for _, enemy in ipairs(Globals.enemies) do
                if enemy.alive then
                    local dx = enemy.x - proj.x
                    local dy = enemy.y - proj.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < enemy.radius + proj.radius then
                        enemy.die()
                        proj.alive = false
                        Globals.score = Globals.score + 100
                        break
                    end
                end
            end
        end
    end

    -- Pulisci proiettili morti
    local living = {}
    for _, proj in ipairs(Globals.projectiles) do
        if proj.alive then table.insert(living, proj) end
    end
    Globals.projectiles = living
end

-- Disegna tutti i proiettili
function Projectile.drawAll()
    for _, proj in ipairs(Globals.projectiles) do
        if proj.alive then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", proj.x, proj.y, proj.radius)
        end
    end
end

return Projectile