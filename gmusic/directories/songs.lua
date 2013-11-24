DIR.header = "All Songs"
DIR.title = "Songs"
DIR.icon = "BarSongs.png"

function DIR:init(songs)
    local start = os.clock()
    --alphabetize that shit
    table.sort(songs, function(a, b)
        return a.info.titleNorm < b.info.titleNorm
    end)

    local result = {}

    for k,song in pairs(songs) do
        table.insert(result, song)
    end
    return result
end
