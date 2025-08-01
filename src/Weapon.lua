-- Weapon.lua

-- La funzione Weapon è un costruttore che ritorna una tabella con le proprietà e i metodi dell'arma
-- Accetta il raggio del giocatore come argomento per il posizionamento e il disegno
function Weapon(playerRadius)
    local weapon = {
        active = false,                 -- Indica se l'attacco è attualmente in corso
        duration = 0.3,                 -- Durata dell'animazione dell'attacco (secondi)
        timer = 0,                      -- Timer per l'animazione dell'attacco
        radius = 50,                    -- Raggio dell'arco/settore dell'attacco (distanza dal giocatore)
        thickness = 15,                 -- Spessore visivo dell'arco (non usato direttamente con il nuovo disegno)
        angleSpread = math.pi / 3,      -- Ampiezza dell'arco (60 gradi)
        color = {1, 0.3, 0.3, 0.7},     -- Colore rosso semi-trasparente per l'attacco
        playerRadius = playerRadius,    -- Salva il raggio del giocatore ricevuto dal costruttore
        direction = {x = 0, y = -1}     -- Direzione in cui l'attacco è stato lanciato
    }

    -- Metodo per attivare l'attacco
    -- Ora accetta la 'direction' del giocatore al momento dell'attacco
    function weapon.action(direction)
        weapon.active = true
        weapon.timer = 0
        -- Salva la direzione ricevuta, così l'arco punta nella direzione corretta
        -- anche se il giocatore si muove subito dopo
        weapon.direction.x = direction.x
        weapon.direction.y = direction.y
    end

    -- Metodo update per gestire la logica temporale dell'arma
    function weapon.update(dt)
        if weapon.active then
            weapon.timer = weapon.timer + dt
            -- Disattiva l'arma quando la durata è scaduta
            if weapon.timer >= weapon.duration then
                weapon.active = false
                -- Non resettiamo il timer qui, verrà resettato in action() se necessario
            end
        end
    end

    -- Metodo draw per disegnare l'arma
    -- Ora accetta la posizione (x, y) del giocatore
function weapon.draw(playerX, playerY)
    if weapon.active then
        -- Calcola l'angolo basato sulla direzione salvata
        local directionAngle = math.atan2(weapon.direction.y, weapon.direction.x)
        local startAngle = directionAngle - weapon.angleSpread / 2
        local endAngle = directionAngle + weapon.angleSpread / 2

        -- === 1. AREA ROSSA DELL'ATTACCO (come prima) ===
        love.graphics.setColor(weapon.color)
        local innerRadius = weapon.playerRadius + 5
        local outerRadius = weapon.playerRadius + weapon.radius
        local segments = 20
        for i = 0, segments - 1 do
            local angle1 = startAngle + (endAngle - startAngle) * (i / segments)
            local angle2 = startAngle + (endAngle - startAngle) * ((i + 1) / segments)

            -- Vertici dell'arco interno
            local x1_inner = playerX + math.cos(angle1) * innerRadius
            local y1_inner = playerY + math.sin(angle1) * innerRadius
            local x2_inner = playerX + math.cos(angle2) * innerRadius
            local y2_inner = playerY + math.sin(angle2) * innerRadius

            -- Vertici dell'arco esterno
            local x1_outer = playerX + math.cos(angle1) * outerRadius
            local y1_outer = playerY + math.sin(angle1) * outerRadius
            local x2_outer = playerX + math.cos(angle2) * outerRadius
            local y2_outer = playerY + math.sin(angle2) * outerRadius

            love.graphics.polygon("fill", x1_inner, y1_inner, x2_inner, y2_inner, x2_outer, y2_outer, x1_outer, y1_outer)
        end

        -- Bordi dell'arco (opzionale)
        love.graphics.setColor(1, 0.5, 0.5, 0.9)
        love.graphics.setLineWidth(2)
        love.graphics.arc("line", "open", playerX, playerY, innerRadius, startAngle, endAngle)
        love.graphics.arc("line", "open", playerX, playerY, outerRadius, startAngle, endAngle)
        local x1_inner_start = playerX + math.cos(startAngle) * innerRadius
        local y1_inner_start = playerY + math.sin(startAngle) * innerRadius
        local x1_outer_start = playerX + math.cos(startAngle) * outerRadius
        local y1_outer_start = playerY + math.sin(startAngle) * outerRadius
        love.graphics.line(x1_inner_start, y1_inner_start, x1_outer_start, y1_outer_start)
        local x2_inner_end = playerX + math.cos(endAngle) * innerRadius
        local y2_inner_end = playerY + math.sin(endAngle) * innerRadius
        local x2_outer_end = playerX + math.cos(endAngle) * outerRadius
        local y2_outer_end = playerY + math.sin(endAngle) * outerRadius
        love.graphics.line(x2_inner_end, y2_inner_end, x2_outer_end, y2_outer_end)
        love.graphics.setLineWidth(1)

      
    end
    end

    -- Metodo per sapere se l'arma è attiva
    function weapon.isActive()
        return weapon.active
    end

    -- Ritorna la tabella dell'arma creata
    return weapon
end

-- Esporta la funzione Weapon
return Weapon