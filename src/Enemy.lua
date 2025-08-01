    enemies = {}
    enemySpawnTimer = 0
    enemySpawnInterval = 3  -- Spawn ogni 3 secondi

-- Disegna i nemici
        for _, enemy in ipairs(enemies) do
            love.graphics.setColor(enemy.color)
            love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
            love.graphics.setColor(0.6, 0.1, 0.1)  -- Bordo più scuro
            love.graphics.circle("line", enemy.x, enemy.y, enemy.radius)
        end

        function spawnEnemy()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Posizione casuale ai bordi dello schermo
    local side = math.random(1, 4)
    local enemy = {
        radius = 15,
        speed = 80,  -- Più lento del giocatore
        color = {0.8, 0.2, 0.2}  -- Rosso
    }
    
    if side == 1 then -- Sopra
        enemy.x = math.random(enemy.radius, screenWidth - enemy.radius)
        enemy.y = -enemy.radius
    elseif side == 2 then -- Destra
        enemy.x = screenWidth + enemy.radius
        enemy.y = math.random(enemy.radius, screenHeight - enemy.radius)
    elseif side == 3 then -- Sotto
        enemy.x = math.random(enemy.radius, screenWidth - enemy.radius)
        enemy.y = screenHeight + enemy.radius
    else -- Sinistra
        enemy.x = -enemy.radius
        enemy.y = math.random(enemy.radius, screenHeight - enemy.radius)
    end
    
    table.insert(enemies, enemy)
end

function isEnemyInAttackArea(enemy)
    if not attack.active then return false end
    
    -- Distanza dal giocatore
    local dx = enemy.x - player.x
    local dy = enemy.y - player.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Controlla se è nella giusta distanza
    if distance < player.radius + 5 or distance > player.radius + attack.radius then
        return false
    end
    
    -- Calcola l'angolo del nemico rispetto al giocatore
    local enemyAngle = math.atan2(dy, dx)
    local directionAngle = math.atan2(player.lastDirection.y, player.lastDirection.x)
    
    -- Normalizza gli angoli
    local angleDiff = enemyAngle - directionAngle
    while angleDiff > math.pi do angleDiff = angleDiff - 2 * math.pi end
    while angleDiff < -math.pi do angleDiff = angleDiff + 2 * math.pi end
    
    -- Controlla se è nell'area dell'arco
    return math.abs(angleDiff) <= attack.angleSpread / 2
end