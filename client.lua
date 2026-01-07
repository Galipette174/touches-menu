local function BuildOptions(filter)
    local options = {}
    local f = filter and filter:lower() or nil

    for _, v in ipairs(Config.Keybinds) do
        local title = tostring(v.title or "")
        local desc  = tostring(v.description or "")

        if not f
            or title:lower():find(f, 1, true)
            or desc:lower():find(f, 1, true)
        then
            options[#options + 1] = {
                title = title,
                description = desc,
                icon = 'keyboard'
            }
        end
    end

    if #options == 0 then
        options[1] = {
            title = "Aucun resultat",
            description = "Aucune touche ne correspond a ta recherche.",
            icon = 'circle-xmark'
        }
    end

    return options
end

local function OpenKeybindMenu(filter)
    local options = {}

    -- Bouton recherche en haut
    options[#options + 1] = {
        title = "Rechercher",
        description = filter and ("Filtre actuel : " .. filter) or "Tape un mot (ex: F2, inventaire, vehicule...)",
        icon = 'magnifying-glass',
        onSelect = function()
            local input = lib.inputDialog("Recherche", {
                {
                    type = "input",
                    label = "Mot-clé",
                    description = "Recherche dans la touche et la description",
                    placeholder = "ex: inventaire / F2 / véhicule",
                    default = filter or ""
                }
            })

            if not input then return end
            local value = (input[1] or ""):gsub("^%s*(.-)%s*$", "%1") -- trim

            if value == "" then
                OpenKeybindMenu(nil) -- reset filtre
            else
                OpenKeybindMenu(value)
            end
        end
    }

    -- Bouton reset filtre
    if filter then
        options[#options + 1] = {
            title = "? Réinitialiser la recherche",
            description = "Afficher toutes les touches",
            icon = 'rotate-left',
            onSelect = function()
                OpenKeybindMenu(nil)
            end
        }
    end

    -- Séparateur
    options[#options + 1] = { title = "Touches du serveur ", disabled = true }

    -- Liste filtrée
    local list = BuildOptions(filter)
    for _, opt in ipairs(list) do
        options[#options + 1] = opt
    end

    lib.registerContext({
        id = 'fiveui_keybinds_menu',
        title = Config.Menu.title,
        description = Config.Menu.description,
        options = options
    })

    lib.showContext('fiveui_keybinds_menu')
end

-- Ouverture avec touche
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.OpenControl) then
            OpenKeybindMenu(nil)
        end
    end
end)

-- Commande optionnelle
RegisterCommand('touches', function()
    OpenKeybindMenu(nil)
end, false)
