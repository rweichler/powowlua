local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = dofile(path) or private_key

--actual class

local JSON = dofile(bundle_path.."libs/json.lua")

LIB.title = "SoundCloud"
LIB.short_title = "SCloud"
LIB.color = {255, 77, 25}

function LIB:Search(query, callback)

    local url = 'https://api.soundcloud.com/tracks.json'
    local params = {
        q = query,
        client_id = private_key,
    }
    if not self.session then
        self.session = http.session:new()
    end
    self.session:get(url, params, function(result)
        if result.failed then
            callback(false, "idk", result)
            return
        end

        local json = JSON:decode(result.body)
        local songs = {}
        for k,v in pairs(json) do
            if v.streamable then
                local song = self.song:new()
                song:SetInfo(v)
                song.library = self
                table.insert(songs, song)
            end
        end
        callback(songs)
    end)

end
