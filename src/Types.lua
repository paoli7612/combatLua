local Types = {}

Types.list = {
    "meccanica",
    "biologica",
    "termica",
    "elettrica",
    "batterica",
    "elica"
}

Types.data = {
    meccanica = {
        name = "Talpa corazzata",
        role = "Tank",
        color = {0.38, 0.42, 0.45} -- 606B73
    },
    biologica = {
        name = "Cervo mutante",
        role = "Healer",
        color = {0.41, 0.61, 0.34} -- 699C56
    },
    termica = {
        name = "Gatto di fuoco",
        role = "DPS",
        color = {0.77, 0.33, 0.24} -- C5533D
    },
    elettrica = {
        name = "Anguilla elettrica",
        role = "Scout",
        color = {0.82, 0.63, 0.33} -- D1A054
    },
    batterica = {
        name = "Ragno velenoso",
        role = "DPS",
        color = {0.53, 0.42, 0.63} -- 866AA1
    },
    elica = {
        name = "Drone solare",
        role = "Healer",
        color = {0.73, 0.84, 0.91} -- B9D6E8
    }
}

function Types.randomType()
    local idx = math.random(1, #Types.list)
    return Types.list[idx]
end

return Types