local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = private_key or dofile(path)

--actual class
SEARCH.title = "Songs"
SEARCH.icon = "BarSongs.png"

function SEARCH:Search(query, callback)

    local url = 'https://api.soundcloud.com/tracks.json'
    local params = {
        q = query,
        client_id = private_key,
    }
    if not self.library.session then
        self.library.session = http.session:new()
    end
    self.library.session:get(url, params, function(result)
        if result.failed then
            callback(false, "idk", result)
            return
        end

        local json = http.json.decode(result.body)
        local songs = {}
        for k,v in pairs(json) do
            if v.streamable then
                local song = self.library.song:new()
                song:SetInfo(v)
                song.library = self
                table.insert(songs, song)
            end
        end
        callback(songs)
    end)

end
