-- main.lua

-- Assicurati di richiedere tutti i moduli necessari all'inizio
local Player = require('Player')
local Enemy = require('Enemy') -- Richiedi il modulo Enemy

function love.load()
    -- Inizializzazione delle variabili globali
    score = 0
    enemies = {} -- Tabella per contenere tutti i nemici attivi

    -- Inizializzazione del generatore di numeri casuali
    math.randomseed(os.time()) 

    -- Crea l'istanza del giocatore
    player = Player(100, 100)

    -- Imposta il titolo della finestra
    love.window.setTitle("Gioco con Nemici")

    -- Timer e intervallo per la generazione dei nemici
    enemySpawnTimer = 0
    enemySpawnInterval = 3 -- Genera un nemico ogni 3 secondi (inizialmente)
end

function love.update(dt)
    -- Aggiorna il giocatore
    player.update(dt)

    -- Aggiorna tutti i nemici attivi
    for i, enemy in ipairs(enemies) do
        -- Controlla se l'attacco del giocatore colpisce questo nemico
        if love.keyboard.isDown("q") and player.weapon.isActive() then -- Controlla se l'arma è attiva
           
            local dx = enemy.x - player.x
            local dy = enemy.y - player.y
            local distance = math.sqrt(dx*dx + dy*dy)

            -- Distanza di attivazione dell'arma e raggio del nemico
            local weaponHitRange = player.radius + 5 + player.weapon.radius -- Raggio esterno dell'arco
            local weaponInnerRange = player.radius + 5 -- Raggio interno dell'arco
            
            -- Soglia dell'angolo di attacco
            local attackAngleThreshold = player.weapon.angleSpread

            -- Controlla se il nemico è nella distanza dell'attacco
            if distance >= weaponInnerRange and distance <= weaponHitRange then
                -- Calcola l'angolo del nemico rispetto al giocatore
                local enemyAngle = math.atan2(dy, dx)
                -- Calcola l'angolo della direzione dell'attacco del giocatore (USO QUELLA SALVATA NELL'ARMA)
                local playerAttackAngle = math.atan2(player.weapon.direction.y, player.weapon.direction.x)

                -- Calcola la differenza assoluta tra gli angoli
                local angleDiff = math.abs(enemyAngle - playerAttackAngle)

                -- Gestisci il "wrap-around" dell'angolo (es. tra 350 gradi e 10 gradi)
                if angleDiff > math.pi then
                    angleDiff = 2 * math.pi - angleDiff
                end

                -- Se la differenza angolare è minore o uguale a metà dell'ampiezza dell'arco, il nemico è colpito
                if angleDiff <= attackAngleThreshold / 2 then
                    enemy.die() -- Uccidi il nemico
                    score = score + 100 -- Aumenta il punteggio
                    break -- Assumiamo che un attacco colpisca un solo nemico alla volta
                end
            end
        end
        
        -- Aggiorna il nemico se è vivo
        if enemy.alive then
             enemy.update(dt)
        end
    end

    -- Gestione della generazione dei nemici
    enemySpawnTimer = enemySpawnTimer + dt
    if enemySpawnTimer >= enemySpawnInterval then
        -- Crea un nuovo nemico
        local newEnemy = Enemy()
        table.insert(enemies, newEnemy) -- Aggiungi il nuovo nemico alla tabella

        -- Resetta il timer
        enemySpawnTimer = 0
        -- Riduci l'intervallo per aumentare la difficoltà (es. ogni 5 nemici generati)
        if #enemies % 5 == 0 and enemySpawnInterval > 1.0 then
             enemySpawnInterval = enemySpawnInterval - 0.2 
             if enemySpawnInterval < 1.0 then enemySpawnInterval = 1.0 end -- Limita intervallo minimo
             print("Intervallo di spawn ridotto a: " .. string.format("%.1f", enemySpawnInterval))
        end
    end
    
    -- Pulisci la tabella dai nemici morti (ottimizzazione)
    -- Crea una nuova tabella contenente solo i nemici vivi
    local livingEnemies = {}
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            table.insert(livingEnemies, enemy)
        end
    end
    enemies = livingEnemies -- Sostituisci la vecchia tabella con quella aggiornata

end

function love.draw()
    -- Pulisce lo schermo
    love.graphics.clear(0.1, 0.1, 0.2)

    -- Disegna il giocatore (che a sua volta disegna l'arma)
    player.draw()

    -- Disegna tutti i nemici attivi
    for i, enemy in ipairs(enemies) do
        enemy.draw()
    end

    -- Disegna la UI
    love.graphics.setColor(1, 1, 1) -- Colore bianco per il testo
    love.graphics.print("Punteggio: " .. score, 10, love.graphics.getHeight() - 60)
    love.graphics.print("Nemici: " .. #enemies, 10, love.graphics.getHeight() - 40) -- Mostra il numero di nemici attivi
    love.graphics.print("IJKL: movimento | Q: attacco | ESC: esci", 10, 10)
end

function love.keypressed(key)
    -- Gestisce la pressione dei tasti
    if key == "escape" then
        love.event.quit() -- Chiude il gioco se viene premuto ESC
    end
    -- L'azione di attacco ('q') è gestita in player.update() per permettere il controllo continuo
end

function love.quit()
    print("Uscita dal gioco.")
end