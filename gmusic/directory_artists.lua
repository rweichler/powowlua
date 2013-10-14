
DIR.class = "gmusic"
DIR.all_songs = true
DIR.title = "Artists"
DIR.icon = "BarArtists.png"

function DIR:init(songs)
    --alphabetize that shit
    table.sort(songs, function(a, b)
        return a.artistNorm < b.artistNorm
    end)

    local result = {}
    local last_artistNorm
    local last_artist

    for k,v in pairs(songs) do
        if last_artistNorm ~= v.artistNorm then
            if last_artist then
                local dir = self.library.directory:new()
                dir:init(last_artist)
                table.insert(result, last_artist)
            end
            last_artist = {}
            last_artistNorm = v.artistNorm
        end
        local song = self.library.song:new()
        song:SetInfo(v)
        song.library = self.library
        table.insert(last_artist, song)
    end
    return result
end
