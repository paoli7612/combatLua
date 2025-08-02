local Types = {}

Types.list = {
    "meccanica",
    "biologica",
    "termica",
    "elettrica"
    --"batterica",
    --"elica"
}

Types.data = {
    meccanica = {
        name = "Talpa corazzata",
        role = "Tank",
        color = {0.38, 0.42, 0.45},
        img = "img/meccanica.png"
    },
    biologica = {
        name = "Cervo mutante",
        role = "Healer",
        color = {0.41, 0.61, 0.34},
        img = "img/biologica.png"
    },
    termica = {
        name = "Gatto di fuoco",
        role = "DPS",
        color = {0.77, 0.33, 0.24},
        img = "img/termica.png"
    },
    elettrica = {
        name = "Anguilla elettrica",
        role = "Scout",
        color = {0.82, 0.63, 0.33},
        img = "img/elettrica.png"
    }
}

Types.images = {}

function Types.loadImages()
    for _, type in ipairs(Types.list) do
        local path = Types.data[type].img
        if path then
            Types.images[type] = love.graphics.newImage(path)
        end
    end
end

function Types.drawTypeImage(type, x, y, size)
    local img = Types.images[type]
    if img then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, x, y, 0, size / img:getWidth(), size / img:getHeight())
    end
end

function Types.randomType()
    local idx = math.random(1, #Types.list)
    return Types.list[idx]
end

return Types