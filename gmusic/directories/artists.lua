
DIR.header = false
DIR.title = "Artists"
DIR.icon = "BarArtists.png"

function DIR:init(songs)
    --organize that shit
    table.sort(songs, function(a, b)
        if a.info.artistNorm == b.info.artistNorm then
            if a.info.albumNorm == b.info.albumNorm then
                if not a.info.track then
                    return true
                elseif not b.info.track then
                    return false
                end
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

local function comp_artist(a, b)
    --directories don't have artist attribute
    local a_artist = a.artist or a.title
    local b_artist = b.artist or b.title
    return string.lower(a_artist) < string.lower(b_artist)
end

local function comp_album(a, b)
    --directories don't have album attribute
    local a_album = a.album or a.title
    local b_album = b.album or b.title
    return string.lower(a_album) < string.lower(b_album)
end

local function comp_title(a, b)
    return string.lower(a.title) < string.lower(b.title)
end

function DIR:add(song)
    --find artist directory
    local index = table.bininsert(self.items, song, comp_artist)
    local artist
    if #self.items > index then
        artist = self.items[index]
    end
    if not artist or string.lower(artist.title) ~= string.lower(song.artist) then --need to create new dir
        artist = self.library.directory:new()
        artist.title = song.artist
        table.insert(self.items, index, artist)
    end

    local index = table.bininsert(artist, song, comp_album)
    local album
    if #artist > index then
        album = artist[index]
    end
    if not album or string.lower(album.title) ~= string.lower(song.album) then --need to create new dir
        album = self.library.directory:new()
        album.title = song.album
        table.insert(artist, index, album)
    end

    local index = table.bininsert(album, song, comp_title)
    table.insert(album, index, song)
end

function DIR:remove(song)
    local index = table.binsert(self.items, song, comp_artist)
    local artist
    if #self.items <= index or string.lower(self.items[index].title) ~= string.lower(song.artist) then
        return false
    else
        artist = self.items[index]
    end

    local index = table.binsert(artist, song, comp_album)
    local album
    if #artist <= index or string.lower(artist[index].title) ~= string.lower(song.album) then
        return false
    else
        album = artist[index]
    end

    local index = table.bininsert(album, song, comp_title)
    if #album <= index or string.lower(album[index].title) ~= string.lower(song.title) then
        return false
    end
    table.remove(album, index)
    return true
end
