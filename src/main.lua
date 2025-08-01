local Player = require('Player')
local Enemy = require('Enemy')

-- Tipi di attacco disponibili
attackTypes = {"fire", "water", "grass"}
attackColors = {
    fire = {1, 0.3, 0.3, 0.7},   -- rosso
    water = {0.3, 0.5, 1, 0.7},  -- blu
    grass = {0.2, 0.8, 0.3, 0.7} -- verde
}
currentAttackType = "fire" -- default

function isAttackEffective(attackType, enemyType)
    return (attackType == "fire" and enemyType == "grass") or
           (attackType == "water" and enemyType == "fire") or
           (attackType == "grass" and enemyType == "water")
end

function love.load()
    score = 0
    enemies = {}
    math.randomseed(os.time())
    player = Player(100, 100, currentAttackType)
    love.window.setTitle("Gioco con Nemici Elementali")
    enemySpawnTimer = 0
    enemySpawnInterval = 3
end

function love.update(dt)
    player.update(dt)

    for i, enemy in ipairs(enemies) do
        if player.weapon.isActive() then
            local dx = enemy.x - player.x
            local dy = enemy.y - player.y
            local distance = math.sqrt(dx*dx + dy*dy)

            local weaponHitRange = player.radius + 5 + player.weapon.radius + enemy.radius
            local weaponInnerRange = player.radius + 5 - enemy.radius
            local attackAngleThreshold = player.weapon.angleSpread

            if distance >= weaponInnerRange and distance <= weaponHitRange then
                local enemyAngle = math.atan2(dy, dx)
                local playerAttackAngle = math.atan2(player.weapon.direction.y, player.weapon.direction.x)
                local angleDiff = math.abs(enemyAngle - playerAttackAngle)
                if angleDiff > math.pi then
                    angleDiff = 2 * math.pi - angleDiff
                end
                if angleDiff <= attackAngleThreshold / 2 then
                    if isAttackEffective(player.weapon.type, enemy.type) then
                        enemy.die()
                        score = score + 100
                        break
                    end
                end
            end
        end
        if enemy.alive then
            enemy.update(dt)
        end
    end

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

    local livingEnemies = {}
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            table.insert(livingEnemies, enemy)
        end
    end
    enemies = livingEnemies
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.2)
    player.draw()
    for i, enemy in ipairs(enemies) do
        enemy.draw()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Punteggio: " .. score, 10, love.graphics.getHeight() - 60)
    love.graphics.print("Nemici: " .. #enemies, 10, love.graphics.getHeight() - 40)

    -- Spiegazione tasti attacco, con colori
    local y = 30
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Tasti attacco:", 10, y)
    y = y + 18

    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.print("Q = Fuoco (colpisce nemici ERBA)", 10, y)
    y = y + 18

    love.graphics.setColor(0.3, 0.5, 1)
    love.graphics.print("W = Acqua (colpisce nemici FUOCO)", 10, y)
    y = y + 18

    love.graphics.setColor(0.2, 0.8, 0.3)
    love.graphics.print("E = Erba (colpisce nemici ACQUA)", 10, y)
    y = y + 18

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("IJKL: movimento | ESC: esci", 10, y)
    y = y + 18

    -- Mostra attacco attivo
    local attackNames = {fire = "Fuoco", water = "Acqua", grass = "Erba"}
    local attackColors = {
        fire = {1, 0.3, 0.3},
        water = {0.3, 0.5, 1},
        grass = {0.2, 0.8, 0.3}
    }
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Attacco attivo:", 10, love.graphics.getHeight() - 80)
    love.graphics.setColor(attackColors[player.weapon.type])
    love.graphics.print(attackNames[player.weapon.type], 130, love.graphics.getHeight() - 80)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "q" then
        currentAttackType = "fire"
        player.setAttackType("fire")
        player.weapon.action(player.lastDirection)
    elseif key == "w" then
        currentAttackType = "water"
        player.setAttackType("water")
        player.weapon.action(player.lastDirection)
    elseif key == "e" then
        currentAttackType = "grass"
        player.setAttackType("grass")
        player.weapon.action(player.lastDirection)
    end
end

function love.quit()
    print("Uscita dal gioco.")
end