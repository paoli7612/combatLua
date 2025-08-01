-- Enemy.lua

-- La funzione Enemy è un costruttore che ritorna una tabella con le proprietà e i metodi del nemico
function Enemy()
    -- Ottieni le dimensioni dello schermo una sola volta
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Crea la tabella del nemico
    local enemy = {
        -- Posizione iniziale casuale
        x = math.random(50, screenWidth - 50),
        y = math.random(50, screenHeight - 50),
        radius = 15,                    -- Raggio del nemico
        color = {0.8, 0.3, 0.3},       -- Colore rosso
        speed = 80,                     -- Velocità di movimento del nemico
        alive = true,                   -- Stato del nemico
        
        -- Variabili per il movimento casuale
        dirX = 0,
        dirY = 0,
        directionChangeTimer = 0,
        -- Intervallo casuale tra 1 e 4 secondi per cambiare direzione
        directionChangeInterval = math.random(1, 4) 
    }

    -- Funzione helper per impostare una nuova direzione casuale
    function enemy.updateDirection()
        -- Genera un angolo casuale tra 0 e 2*pi
        local angle = math.random() * 2 * math.pi
        -- Calcola le componenti x e y della direzione normalizzata
        enemy.dirX = math.cos(angle)
        enemy.dirY = math.sin(angle)
        -- Resetta il timer e imposta un nuovo intervallo casuale
        enemy.directionChangeTimer = 0
        enemy.directionChangeInterval = math.random(1, 4) 
    end

    -- Imposta la direzione iniziale quando il nemico viene creato
    enemy.updateDirection()

    -- Metodo update del nemico
    function enemy.update(dt)
        -- Se il nemico è morto, non fare nulla
        if not enemy.alive then return end

        -- Aggiorna il timer per il cambio di direzione
        enemy.directionChangeTimer = enemy.directionChangeTimer + dt

        -- Se è ora di cambiare direzione
        if enemy.directionChangeTimer >= enemy.directionChangeInterval then
            enemy.updateDirection()
        end

        -- Muove il nemico secondo la sua direzione attuale
        enemy.x = enemy.x + enemy.dirX * enemy.speed * dt
        enemy.y = enemy.y + enemy.dirY * enemy.speed * dt

        -- Limita il nemico entro i bordi dello schermo e fallo rimbalzare
        local bounced = false
        -- Controlla i bordi orizzontali
        if enemy.x - enemy.radius < 0 then
            enemy.x = enemy.radius
            enemy.dirX = -enemy.dirX -- Inverti direzione X
            bounced = true
        elseif enemy.x + enemy.radius > screenWidth then
            enemy.x = screenWidth - enemy.radius
            enemy.dirX = -enemy.dirX -- Inverti direzione X
            bounced = true
        end
        -- Controlla i bordi verticali
        if enemy.y - enemy.radius < 0 then
            enemy.y = enemy.radius
            enemy.dirY = -enemy.dirY -- Inverti direzione Y
            bounced = true
        elseif enemy.y + enemy.radius > screenHeight then
            enemy.y = screenHeight - enemy.radius
            enemy.dirY = -enemy.dirY -- Inverti direzione Y
            bounced = true
        end

        -- Se il nemico è rimbalzato, resetta il timer per evitare cambi di direzione immediati
        if bounced then
            enemy.directionChangeTimer = 0
        end
    end

    -- Metodo draw del nemico
    function enemy.draw()
        -- Disegna solo se il nemico è vivo
        if enemy.alive then
            love.graphics.setColor(enemy.color)
            love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
            -- Disegna un bordo bianco per definizione
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", enemy.x, enemy.y, enemy.radius)
        end
    end

    -- Metodo per "uccidere" il nemico (impostandolo come non vivo)
    function enemy.die()
        enemy.alive = false
        -- Qui potresti aggiungere effetti sonori o visivi per la morte
        print("Un nemico è stato eliminato!")
    end

    -- Ritorna la tabella del nemico creata
    return enemy
end

-- Esporta la funzione Enemy
return Enemy