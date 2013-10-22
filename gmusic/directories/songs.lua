
DIR.all_songs = true
DIR.title = "Songs"
DIR.icon = "BarSongs.png"

function DIR:init(songs)
    local start = os.clock()
    --alphabetize that shit
    table.sort(songs, function(a, b)
        return a.titleNorm < b.titleNorm
    end)

    local result = {}

    for k,v in pairs(songs) do
        local song = self.library.song:new()
        song:SetInfo(v)
        table.insert(result, song)
    end

    NSLog("directory_songs.lua took "..(os.clock() - start).." seconds")

    return result
end
