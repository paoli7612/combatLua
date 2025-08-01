-- Richiede il modulo Weapon
local Weapon = require('Weapon')

-- La funzione Player è un costruttore che ritorna una tabella con le proprietà e i metodi del giocatore
function Player(startX, startY)
    -- Ottieni le dimensioni dello schermo una sola volta
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Crea la tabella del giocatore
    local player = {
        x = startX,
        y = startY,
        speed = 200,                       -- Velocità di movimento (pixel/secondo)
        color = {0.2, 0.8, 0.3},          -- Colore verde
        lastDirection = {x = 0, y = -1},   -- Direzione di movimento (iniziale: su)
        radius = 20,                       -- Raggio del giocatore per il disegno e collisioni
        alive = true,                      -- Stato del giocatore
        -- Crea l'istanza dell'arma, passando il raggio del giocatore come argomento
        weapon = Weapon(20) -- Il costruttore Weapon ora si aspetta il raggio del giocatore
    }

    -- Metodo update del giocatore
    function player.update(dt)
        -- Aggiorna l'arma associata
        player.weapon.update(dt)

        -- Controlla l'input per il movimento
        local moving = false
        local dirX, dirY = 0, 0

        -- Gestione input movimento (J, L, I, K)
        if love.keyboard.isDown("j") then  -- Sinistra
            dirX = dirX - 1
            moving = true
        end
        if love.keyboard.isDown("l") then  -- Destra
            dirX = dirX + 1
            moving = true
        end
        if love.keyboard.isDown("i") then  -- Su
            dirY = dirY - 1
            moving = true
        end
        if love.keyboard.isDown("k") then  -- Giù
            dirY = dirY + 1
            moving = true
        end

        -- Aggiorna la posizione solo se il giocatore si sta muovendo
        if moving then
            -- Normalizza la direzione per movimenti diagonali corretti
            local length = math.sqrt(dirX * dirX + dirY * dirY)
            if length > 0 then
                player.lastDirection.x = dirX / length
                player.lastDirection.y = dirY / length
            end

            -- Applica il movimento alla posizione
            player.x = player.x + player.lastDirection.x * player.speed * dt
            player.y = player.y + player.lastDirection.y * player.speed * dt
        end

        -- Gestisce l'input per l'attacco (tasto Q)
        if love.keyboard.isDown("q") then
            -- Chiama l'azione dell'arma, passando la direzione corrente del giocatore
            player.weapon.action(player.lastDirection)
        end

        -- Limita il giocatore entro i bordi dello schermo
        -- Sinistra
        if player.x - player.radius < 0 then
            player.x = player.radius
        -- Destra
        elseif player.x + player.radius > screenWidth then
            player.x = screenWidth - player.radius
        end
        -- Sopra
        if player.y - player.radius < 0 then
            player.y = player.radius
        -- Sotto
        elseif player.y + player.radius > screenHeight then
            player.y = screenHeight - player.radius
        end
    end

    -- Metodo draw del giocatore
    function player.draw()
        -- Chiama il metodo draw dell'arma, passando la posizione corrente del giocatore
        player.weapon.draw(player.x, player.y)

        -- Disegna il corpo del giocatore (cerchio pieno)
        love.graphics.setColor(player.color)
        love.graphics.circle("fill", player.x, player.y, player.radius)

        -- Disegna il bordo del giocatore (cerchio linea bianca)
        love.graphics.setColor(1, 1, 1) -- Ritorna a bianco
        love.graphics.circle("line", player.x, player.y, player.radius)
    end

    -- Ritorna la tabella del giocatore creata
    return player
end

-- Esporta la funzione Player
return Player