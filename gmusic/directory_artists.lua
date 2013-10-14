
DIR.all_songs = false
DIR.title = "Artists"
DIR.icon = "BarArtists.png"

function DIR:init(songs)
    --organize that shit
    table.sort(songs, function(a, b)
        if a.artistNorm == b.artistNorm then
            if a.albumNorm == b.albumNorm then
                return a.track < b.track
            else
                return a.albumNorm < b.albumNorm
            end
        else
            return a.artistNorm < b.artistNorm
        end
    end)

    local result = {}
    local last_artist
    local last_album
    for k,v in pairs(songs) do
        if not last_artist or last_artist[1][1].artistNorm ~= v.artistNorm then
            last_artist = {}
            table.insert(result, last_artist)
        end
        if not last_album or last_album[1].albumNorm ~= v.albumNorm then
            last_album = {}
            table.insert(last_artist, last_album)
        end

        local song = self.library.song:new()
        song:SetInfo(v)
        table.insert(last_album, song)
    end
    return result
end
