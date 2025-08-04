-- core/GameState.lua

local Types = require('types.Types')
local Player = require('entities.Player')
local Enemy = require('entities.Enemy')
local Projectile = require('entities.Projectile')
local Globals = require('core.Globals')

local GameState = {}

local state = "choose_type"
local selectedTypeIndex = 1

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
    state = "choose_type"
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
    elseif state == "gameover" then
        if key == "return" or key == "space" then
            GameState.load()
        elseif key == "escape" then
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

        -- COLLISIONE NEMICO-PLAYER (DANNO)
        for _, enemy in ipairs(Globals.enemies) do
            if enemy.alive and Globals.player.alive then
                local dx = enemy.x - Globals.player.x
                local dy = enemy.y - Globals.player.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist < enemy.radius + Globals.player.radius then
                    -- Danno al player
                    Globals.player:takeDamage(1)
                    enemy.die()
                    if Globals.player.hp <= 0 then
                        Globals.player.alive = false
                        state = "gameover"
                    end
                end
            end
        end
    end
end

function GameState.draw()
    if state == "choose_type" then
        love.graphics.clear(0.1, 0.1, 0.2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Scegli il tuo elemento:", 0, 40, love.graphics.getWidth(), "center")

        -- Spiegazione parametri
        local explainY = 80
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.printf(
            "Energia = Vita massima   |   Inerzia = Velocità   |   Persistenza = Durata attacco   |   Recupero = Cooldown attacchi",
            0, explainY, love.graphics.getWidth(), "center"
        )

        for i, type in ipairs(Types.list) do
            local info = Types.data[type]
            local y = 140 + (i-1)*100
            if i == selectedTypeIndex then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 220, y-12, 440, 92, 10, 10)
            end
            -- Immagine
            Types.drawTypeImage(type, love.graphics.getWidth()/2 - 200, y, 64)
            -- Nome e ruolo
            love.graphics.setColor(info.color)
            love.graphics.printf(
                string.upper(type) .. "  (" .. info.name .. ") - " .. info.role,
                love.graphics.getWidth()/2 - 120, y+8, 320, "left"
            )
            love.graphics.setColor(1, 1, 1)
            -- Parametri
            local statsY = y + 36
            love.graphics.print("Energia:     " .. tostring(info.energia), love.graphics.getWidth()/2 - 120, statsY)
            love.graphics.print("Inerzia:     " .. tostring(info.inerzia), love.graphics.getWidth()/2, statsY)
            love.graphics.print("Persistenza: " .. tostring(info.persistenza), love.graphics.getWidth()/2 - 120, statsY + 20)
            love.graphics.print("Recupero:    " .. tostring(info.recupero), love.graphics.getWidth()/2, statsY + 20)
        end

        love.graphics.setColor(1, 1, 1)
        local h = love.graphics.getHeight()
        love.graphics.printf("Usa A o D per scegliere, INVIO/SPACE per confermare", 0, h - 60, love.graphics.getWidth(), "center")
        love.graphics.printf("ESC per uscire", 0, h - 30, love.graphics.getWidth(), "center")
    elseif state == "playing" then
        -- ... (resto invariato)
    elseif state == "gameover" then
        -- ... (resto invariato)
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