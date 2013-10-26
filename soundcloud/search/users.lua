local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = private_key or dofile(path)

--actual class
SEARCH.title = "Users"
SEARCH.icon = "BarArtists.png"

function SEARCH:Search(query, callback)

    local url = 'https://api.soundcloud.com/users.json'
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
        local songs = {}
        local json = http.json.decode(result.body)
        local count = 0
        for k,v in pairs(json) do
            count = count + 1
            local url = "https://api.soundcloud.com/users/"..v.id.."/tracks.json"
            local params = {
                client_id = private_key
            }

            self.library.session:get(url, params, function(result)
                local json = http.json.decode(result.body)
                local user = {}
                for k,v in pairs(json) do
                    if v.streamable then
                        local song = self.library.song:new()
                        song:SetInfo(v)
                        song.library = self
                        table.insert(user, song)
                    end
                end
                table.insert(songs, user)

                count = count - 1
                if count == 0 then
                    callback(songs)
                end
            end)
        end
    end)
end
