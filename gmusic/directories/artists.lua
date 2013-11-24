
DIR.header = false
DIR.title = "Artists"
DIR.icon = "BarArtists.png"

function DIR:init(songs)
    --organize that shit
    table.sort(songs, function(a, b)
        if a.info.artistNorm == b.info.artistNorm then
            if a.info.albumNorm == b.info.albumNorm then
                return a.info.track < b.info.track
            else
                return a.info.albumNorm < b.info.albumNorm
            end
        else
            return a.info.artistNorm < b.info.artistNorm
        end
    end)

    local result = {}
    local last_artist
    local last_album
    local track_number
    for k,song in pairs(songs) do

        local last_artistNorm
        if type(last_artist) == "table" then
            last_artistNorm = last_artist.artistNorm
        end

        if not last_artist or last_artistNorm ~= song.info.artistNorm then
            last_artist = self.library.directory:new()
            last_artist.items = {}
            last_artist.title = song.artist
            last_artist.artistNorm = song.info.artistNorm
            last_artist.style = "album"
            table.insert(result, last_artist)
        end

        local last_albumNorm
        if type(last_album) == "table" then
            last_albumNorm = last_album.albumNorm
        end

        if not last_album or last_albumNorm ~= song.info.albumNorm or last_artistNorm ~= song.info.artistNorm then
            track_number = 0
            last_album = self.library.directory:new()
            last_album.items = {}
            last_album.title = song.album
            last_album.albumNorm = song.info.albumNorm
            last_album.image_url = song:ArtworkURL()
            table.insert(last_artist.items, last_album)
        end

        track_number = track_number + 1
        song.track_number = track_number
        table.insert(last_album.items, song)
    end
    return result
end
