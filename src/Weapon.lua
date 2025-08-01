function Weapon(playerRadius)
    local weapon = {
        active = false,
        duration = 0.3,
        timer = 0,
        radius = 50,         -- default, sovrascritto dagli attacchi
        angleSpread = math.pi / 3,
        playerRadius = playerRadius,
        direction = {x = 0, y = -1},
        offset = 0,          -- distanza dal centro del player
        type = "melee"       -- "melee" o "ranged"
    }

    function weapon.actionMelee(direction)
        weapon.active = true
        weapon.timer = 0
        weapon.direction.x = direction.x
        weapon.direction.y = direction.y
        weapon.radius = 50         -- area grande
        weapon.angleSpread = math.pi / 2  -- 90 gradi
        weapon.offset = 10         -- vicino al player
        weapon.type = "melee"
    end

    function weapon.actionRanged(direction)
        weapon.active = true
        weapon.timer = 0
        weapon.direction.x = direction.x
        weapon.direction.y = direction.y
        weapon.radius = 30         -- area più piccola
        weapon.angleSpread = math.pi / 6  -- 30 gradi
        weapon.offset = 60         -- più lontano dal player
        weapon.type = "ranged"
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
            local directionAngle = math.atan2(weapon.direction.y, weapon.direction.x)
            local startAngle = directionAngle - weapon.angleSpread / 2
            local endAngle = directionAngle + weapon.angleSpread / 2
            love.graphics.setColor(1, 1, 1, 0.2)
            local innerRadius = weapon.playerRadius + weapon.offset
            local outerRadius = innerRadius + weapon.radius
            local segments = 20
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
        local innerRadius = weapon.playerRadius + weapon.offset
        local outerRadius = innerRadius + weapon.radius
        local angleSpread = weapon.angleSpread
        local direction = weapon.direction
        return innerRadius, outerRadius, angleSpread, direction
    end

    return weapon
end

return Weapon