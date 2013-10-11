
DIR.class = "gmusic"
DIR.all_songs = true
DIR.title = "Songs"
DIR.icon = "BarSongs.png"

function DIR:init(songs)
    --alphabetize that shit
    table.sort(songs, function(a, b)
        return a.titleNorm < b.titleNorm
    end)

    local result = {}

    for k,v in pairs(songs) do
        local song = self.library.song:new()
        song:SetInfo(v)
        song.library = self.library
        table.insert(result, song)
    end
    return result
end
