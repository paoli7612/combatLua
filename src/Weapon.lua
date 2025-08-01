function Weapon(playerRadius)
    local weapon = {
        active = false,
        duration = 0.25,
        timer = 0,
        radius = 60,
        angleSpread = math.rad(40), -- arco stretto
        playerRadius = playerRadius,
        direction = {x = 0, y = -1},
        sweepStart = 0,
        sweepEnd = 0,
        sweepDir = 1, -- 1 = destra->sinistra, -1 = sinistra->destra
        type = "melee"
    }

    function weapon.actionMelee(direction)
        weapon.active = true
        weapon.timer = 0
        weapon.direction.x = direction.x
        weapon.direction.y = direction.y
        local baseAngle = math.atan2(direction.y, direction.x)
        local sweepWidth = math.rad(100) -- quanto "spazza" la spada (es. 100°)
        weapon.sweepStart = baseAngle + sweepWidth/2
        weapon.sweepEnd = baseAngle - sweepWidth/2
        weapon.sweepDir = -1 -- da destra a sinistra
        weapon.type = "melee"
    end

    function weapon.update(dt)
        if weapon.active then
            weapon.timer = weapon.timer + dt
            if weapon.timer >= weapon.duration then
                weapon.active = false
            end
        end
    end

    function weapon.draw(playerX, playerY)
        if weapon.active then
            -- Calcola la posizione attuale della spada nella spazzata
            local t = weapon.timer / weapon.duration
            if t > 1 then t = 1 end
            local currentAngle = weapon.sweepStart + (weapon.sweepEnd - weapon.sweepStart) * t
            local startAngle = currentAngle - weapon.angleSpread/2
            local endAngle = currentAngle + weapon.angleSpread/2

            love.graphics.setColor(1, 1, 1, 0.25)
            local innerRadius = weapon.playerRadius + 10
            local outerRadius = innerRadius + weapon.radius
            local segments = 16
            for i = 0, segments - 1 do
                local angle1 = startAngle + (endAngle - startAngle) * (i / segments)
                local angle2 = startAngle + (endAngle - startAngle) * ((i + 1) / segments)
                local x1_inner = playerX + math.cos(angle1) * innerRadius
                local y1_inner = playerY + math.sin(angle1) * innerRadius
                local x2_inner = playerX + math.cos(angle2) * innerRadius
                local y2_inner = playerY + math.sin(angle2) * innerRadius
                local x1_outer = playerX + math.cos(angle1) * outerRadius
                local y1_outer = playerY + math.sin(angle1) * outerRadius
                local x2_outer = playerX + math.cos(angle2) * outerRadius
                local y2_outer = playerY + math.sin(angle2) * outerRadius
                love.graphics.polygon("fill", x1_inner, y1_inner, x2_inner, y2_inner, x2_outer, y2_outer, x1_outer, y1_outer)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    function weapon.isActive()
        return weapon.active
    end

    -- Per collisione: restituisce i parametri attuali dell'attacco
    function weapon.getAttackArea()
        if not weapon.active then return nil end
        local t = weapon.timer / weapon.duration
        if t > 1 then t = 1 end
        local currentAngle = weapon.sweepStart + (weapon.sweepEnd - weapon.sweepStart) * t
        local startAngle = currentAngle - weapon.angleSpread/2
        local endAngle = currentAngle + weapon.angleSpread/2
        local innerRadius = weapon.playerRadius + 10
        local outerRadius = innerRadius + weapon.radius
        return innerRadius, outerRadius, startAngle, endAngle, currentAngle
    end

    return weapon
end

return Weapon