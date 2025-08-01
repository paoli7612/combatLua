function Weapon(playerRadius, attackType)
    local attackColors = {
        fire = {1, 0.3, 0.3, 0.7},
        water = {0.3, 0.5, 1, 0.7},
        grass = {0.2, 0.8, 0.3, 0.7}
    }
    local weapon = {
        active = false,
        duration = 0.3,
        timer = 0,
        radius = 50,
        angleSpread = math.pi / 3,
        playerRadius = playerRadius,
        direction = {x = 0, y = -1},
        type = attackType or "fire",
        color = attackColors[attackType or "fire"]
    }

    function weapon.action(direction)
        weapon.active = true
        weapon.timer = 0
        weapon.direction.x = direction.x
        weapon.direction.y = direction.y
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
            love.graphics.setColor(weapon.color)
            local innerRadius = weapon.playerRadius + 5
            local outerRadius = weapon.playerRadius + weapon.radius
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

    function weapon.isActive()
        return weapon.active
    end

    function weapon.setType(newType)
        local attackColors = {
            fire = {1, 0.3, 0.3, 0.7},
            water = {0.3, 0.5, 1, 0.7},
            grass = {0.2, 0.8, 0.3, 0.7}
        }
        weapon.type = newType
        weapon.color = attackColors[newType]
    end

    return weapon
end

return Weapon