
DIR.header = nil
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
    local track_number
    for k,v in pairs(songs) do
        local song = self.library.song:new()
        song:SetInfo(v)

        local last_artistNorm
        if type(last_artist) == "table" then
            last_artistNorm = last_artist.artistNorm
        end

        if not last_artist or last_artistNorm ~= v.artistNorm then
            last_artist = self.library.directory:new()
            last_artist.items = {}
            last_artist.title = song.artist
            last_artist.artistNorm = v.artistNorm
            last_artist.style = "album"
            table.insert(result, last_artist)
        end

        local last_albumNorm
        if type(last_album) == "table" then
            last_albumNorm = last_album.albumNorm
        end

        if not last_album or last_albumNorm ~= v.albumNorm or last_artistNorm ~= v.artistNorm then
            track_number = 0
            last_album = self.library.directory:new()
            last_album.items = {}
            last_album.title = song.album
            last_album.albumNorm = v.albumNorm
            last_album.image_url = song:ArtworkURL()
            table.insert(last_artist.items, last_album)
        end

        track_number = track_number + 1
        song.track_number = track_number
        table.insert(last_album.items, song)
    end
    return result
end
