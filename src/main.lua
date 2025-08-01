local Types = require('Types')
local Player = require('Player')
local Enemy = require('Enemy')

local gameState = "choose_type"
local selectedTypeIndex = 1
local playerType = nil

score = 0
enemies = {}
projectiles = {}

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Gioco con Nemici - Scegli il tuo elemento")
    enemySpawnTimer = 0
    enemySpawnInterval = 3
end

function love.keypressed(key)
    if gameState == "choose_type" then
        if key == "right" or key == "d" then
            selectedTypeIndex = selectedTypeIndex % #Types.list + 1
        elseif key == "left" or key == "a" then
            selectedTypeIndex = (selectedTypeIndex - 2) % #Types.list + 1
        elseif key == "return" or key == "space" then
            playerType = Types.list[selectedTypeIndex]
            player = Player(100, 100, playerType)
            gameState = "playing"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState == "playing" then
        if key == "escape" then
            love.event.quit()
        end
    end
end

function love.update(dt)
    if gameState == "playing" then
        player.update(dt)

        -- Attacco corpo a corpo (Q)
        if love.keyboard.isDown("q") then
            player.weapon.actionMelee(player.lastDirection)
        end

        -- Attacco a distanza (W) - spara proiettile
        if love.keyboard.isDown("w") and not player.rangedCooldown then
            player.rangedCooldown = true
            local dir = {x = player.lastDirection.x, y = player.lastDirection.y}
            local len = math.sqrt(dir.x*dir.x + dir.y*dir.y)
            if len == 0 then dir.x, dir.y = 1, 0 end
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

        -- Aggiorna proiettili
        for i, proj in ipairs(projectiles) do
            if proj.alive then
                proj.x = proj.x + proj.dirX * proj.speed * dt
                proj.y = proj.y + proj.dirY * proj.speed * dt
                if proj.x < 0 or proj.x > love.graphics.getWidth() or proj.y < 0 or proj.y > love.graphics.getHeight() then
                    proj.alive = false
                end
            end
        end

        -- Collisione proiettile-nemico
        for _, proj in ipairs(projectiles) do
            if proj.alive then
                for _, enemy in ipairs(enemies) do
                    if enemy.alive then
                        local dx = enemy.x - proj.x
                        local dy = enemy.y - proj.y
                        local dist = math.sqrt(dx*dx + dy*dy)
                        if dist < enemy.radius + proj.radius then
                            enemy.die()
                            proj.alive = false
                            score = score + 100
                            break
                        end
                    end
                end
            end
        end

        -- Attacco corpo a corpo: collisione area
        if player.weapon.isActive() and player.weapon.type == "melee" then
            local innerRadius, outerRadius, startAngle, endAngle, currentAngle = player.weapon.getAttackArea()
            for i, enemy in ipairs(enemies) do
                local dx = enemy.x - player.x
                local dy = enemy.y - player.y
                local distance = math.sqrt(dx*dx + dy*dy)
                if distance >= innerRadius - enemy.radius and distance <= outerRadius + enemy.radius then
                    local enemyAngle = math.atan2(dy, dx)
                    -- Gestione wrap-around
                    local function isAngleInArc(angle, arcStart, arcEnd)
                        local diff = (arcEnd - arcStart) % (2*math.pi)
                        local rel = (angle - arcStart) % (2*math.pi)
                        return rel >= 0 and rel <= diff
                    end
                    if isAngleInArc(enemyAngle, startAngle, endAngle) then
                        enemy.die()
                        score = score + 100
                        break
                    end
                end
            end
        end

        -- Aggiorna nemici
        for i, enemy in ipairs(enemies) do
            if enemy.alive then
                enemy.update(dt)
            end
        end

        -- Spawn nemici
        enemySpawnTimer = enemySpawnTimer + dt
        if enemySpawnTimer >= enemySpawnInterval then
            local newEnemy = Enemy()
            table.insert(enemies, newEnemy)
            enemySpawnTimer = 0
            if #enemies % 5 == 0 and enemySpawnInterval > 1.0 then
                enemySpawnInterval = enemySpawnInterval - 0.2 
                if enemySpawnInterval < 1.0 then enemySpawnInterval = 1.0 end
                print("Intervallo di spawn ridotto a: " .. string.format("%.1f", enemySpawnInterval))
            end
        end

        -- Pulisci nemici morti
        local livingEnemies = {}
        for _, enemy in ipairs(enemies) do
            if enemy.alive then
                table.insert(livingEnemies, enemy)
            end
        end
        enemies = livingEnemies

        -- Pulisci proiettili morti
        local livingProjectiles = {}
        for _, proj in ipairs(projectiles) do
            if proj.alive then
                table.insert(livingProjectiles, proj)
            end
        end
        projectiles = livingProjectiles
    end
end

function love.draw()
    if gameState == "choose_type" then
        love.graphics.clear(0.1, 0.1, 0.2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Scegli il tuo elemento:", 0, 60, love.graphics.getWidth(), "center")

        for i, type in ipairs(Types.list) do
            local info = Types.data[type]
            local y = 120 + (i-1)*40
            if i == selectedTypeIndex then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 160, y-4, 320, 36, 8, 8)
            end
            love.graphics.setColor(info.color)
            love.graphics.printf(
                string.upper(type) .. "  (" .. info.name .. ")",
                0, y, love.graphics.getWidth(), "center"
            )
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Usa ← → o A D per scegliere, INVIO/SPACE per confermare", 0, 400, love.graphics.getWidth(), "center")
        love.graphics.printf("ESC per uscire", 0, 430, love.graphics.getWidth(), "center")
    elseif gameState == "playing" then
        love.graphics.clear(0.1, 0.1, 0.2)
        player.draw()
        -- Disegna proiettili
        for i, proj in ipairs(projectiles) do
            if proj.alive then
                love.graphics.setColor(1, 1, 1)
                love.graphics.circle("fill", proj.x, proj.y, proj.radius)
            end
        end
        -- Disegna nemici
        for i, enemy in ipairs(enemies) do
            enemy.draw()
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Punteggio: " .. score, 10, love.graphics.getHeight() - 60)
        love.graphics.print("Nemici: " .. #enemies, 10, love.graphics.getHeight() - 40)
        love.graphics.print("IJKL: movimento | Q: corpo a corpo | W: proiettile | ESC: esci", 10, 10)
        love.graphics.print("Elemento scelto: " .. (player.type or ""), 10, love.graphics.getHeight() - 80)
    end
end

function love.quit()
    print("Uscita dal gioco.")
end