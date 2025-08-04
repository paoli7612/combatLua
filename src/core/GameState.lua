-- core/GameState.lua

local Types = require('types.Types')
local Player = require('entities.Player')
local Enemy = require('entities.Enemy')
local Projectile = require('entities.Projectile')
local Globals = require('core.Globals')

local GameState = {}

-- Stato interno
local state = "choose_type"
local selectedTypeIndex = 1

-- Timer spawn nemici
GameState.enemySpawnTimer = 0
GameState.enemySpawnInterval = 3

function GameState.load()
    math.randomseed(os.time())
    love.window.setTitle("Gioco con Nemici - Scegli il tuo elemento")
    Types.loadImages()
    GameState.enemySpawnTimer = 0
    GameState.enemySpawnInterval = 3
    Globals.score = 0
    Globals.enemies = {}
    Globals.projectiles = {}
    Globals.player = nil
end

function GameState.keypressed(key)
    if state == "choose_type" then
        if key == "right" or key == "d" then
            selectedTypeIndex = selectedTypeIndex % #Types.list + 1
        elseif key == "left" or key == "a" then
            selectedTypeIndex = (selectedTypeIndex - 2) % #Types.list + 1
        elseif key == "return" or key == "space" then
            local playerType = Types.list[selectedTypeIndex]
            Globals.player = Player(100, 100, playerType)
            state = "playing"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif state == "playing" then
        if key == "escape" then
            love.event.quit()
        end
    end
end

function GameState.update(dt)
    if state == "playing" then
        if Globals.player and Globals.player.update then
            Globals.player.update(dt)
        end

        -- COLLISIONE ATTACCO CORPO A CORPO
        if Globals.player.weapon.isActive() and Globals.player.weapon.type == "melee" then
            local innerRadius, outerRadius, startAngle, endAngle, currentAngle = Globals.player.weapon.getAttackArea()
            for _, enemy in ipairs(Globals.enemies) do
                if enemy.alive then
                    local dx = enemy.x - Globals.player.x
                    local dy = enemy.y - Globals.player.y
                    local distance = math.sqrt(dx*dx + dy*dy)
                    if distance >= innerRadius - enemy.radius and distance <= outerRadius + enemy.radius then
                        local enemyAngle = math.atan2(dy, dx)
                        local function isAngleInArc(angle, arcStart, arcEnd)
                            local diff = (arcEnd - arcStart) % (2*math.pi)
                            local rel = (angle - arcStart) % (2*math.pi)
                            return rel >= 0 and rel <= diff
                        end
                        if isAngleInArc(enemyAngle, startAngle, endAngle) then
                            enemy.die()
                            Globals.score = Globals.score + 100
                        end
                    end
                end
            end
        end

        Projectile.updateAll(dt)
        Enemy.updateAll(dt)
        GameState.spawnEnemies(dt)
    end
end


function GameState.draw()
    if state == "choose_type" then
        love.graphics.clear(0.1, 0.1, 0.2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Scegli il tuo elemento:", 0, 60, love.graphics.getWidth(), "center")

        for i, type in ipairs(Types.list) do
            local info = Types.data[type]
            local y = 120 + (i-1)*80
            if i == selectedTypeIndex then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 180, y-8, 360, 72, 8, 8)
            end
            -- Disegna l'immagine a sinistra
            Types.drawTypeImage(type, love.graphics.getWidth()/2 - 160, y, 56)
            -- Scrivi il nome a destra dell'immagine
            love.graphics.setColor(info.color)
            love.graphics.printf(
                string.upper(type) .. "  (" .. info.name .. ")",
                love.graphics.getWidth()/2 - 90, y+12, 260, "left"
            )
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Usa ← → o A D per scegliere, INVIO/SPACE per confermare", 0, 400, love.graphics.getWidth(), "center")
        love.graphics.printf("ESC per uscire", 0, 430, love.graphics.getWidth(), "center")
    elseif state == "playing" then
        love.graphics.clear(0.1, 0.1, 0.2)
        if Globals.player and Globals.player.draw then
            Globals.player.draw()
        end
        Projectile.drawAll()
        Enemy.drawAll()
        -- UI
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Punteggio: " .. Globals.score, 10, love.graphics.getHeight() - 60)
        love.graphics.print("Nemici: " .. #Globals.enemies, 10, love.graphics.getHeight() - 40)
        love.graphics.print("IJKL: movimento | Q: corpo a corpo | W: proiettile | ESC: esci", 10, 10)
        love.graphics.print("Elemento scelto: " .. (Globals.player and Globals.player.type or ""), 10, love.graphics.getHeight() - 80)
    end
end

function GameState.spawnEnemies(dt)
    GameState.enemySpawnTimer = GameState.enemySpawnTimer + dt
    if GameState.enemySpawnTimer >= GameState.enemySpawnInterval then
        table.insert(Globals.enemies, Enemy())
        GameState.enemySpawnTimer = 0
        if #Globals.enemies % 5 == 0 and GameState.enemySpawnInterval > 1.0 then
            GameState.enemySpawnInterval = GameState.enemySpawnInterval - 0.2
            if GameState.enemySpawnInterval < 1.0 then GameState.enemySpawnInterval = 1.0 end
        end
    end
end

return GameState