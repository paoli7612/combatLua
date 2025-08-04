-- types/Types.lua

local Types = {}

Types.list = {
    "meccanica",
    "biologica",
    "termica",
    "elettrica"
}

Types.data = {
    meccanica = {
        name = "Talpa corazzata",
        role = "Tank",
        color = {0.38, 0.42, 0.45},
        img = "assets/img/meccanica.png",
        energia = 10,
        inerzia = 8,
        persistenza = 7,
        recupero = 5
    },
    biologica = {
        name = "Cervo mutante",
        role = "Healer",
        color = {0.41, 0.61, 0.34},
        img = "assets/img/biologica.png",
        energia = 7,
        inerzia = 6,
        persistenza = 10,
        recupero = 8
    },
    termica = {
        name = "Gatto di fuoco",
        role = "DPS",
        color = {0.77, 0.33, 0.24},
        img = "assets/img/termica.png",
        energia = 8,
        inerzia = 10,
        persistenza = 5,
        recupero = 7
    },
    elettrica = {
        name = "Anguilla elettrica",
        role = "Scout",
        color = {0.82, 0.63, 0.33},
        img = "assets/img/elettrica.png",
        energia = 6,
        inerzia = 7,
        persistenza = 8,
        recupero = 10
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