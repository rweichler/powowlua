function SAVE:CanSave(songs)
    for k,v in pairs(songs) do
        if v.class ~= self.class then
            return false
        end
    end
    return true
end

function SAVE:GetPlaylists(songs, callback)
    self.library.directories['playlists']:loaditems(callback)
end

local function save_songs_to_playlist(self, songs, id, callback)
    local url = 'https://play.google.com/music/services/addtoplaylist?u=0&xt='..http.urlencode(self.library.session.cookies['xt'])

    local params = {
        playlistId = id,
        songRefs = {}
    }
    for k, song in pairs(songs) do
        table.insert(params.songRefs, {
            id = song.id,
            type = 1,
        })
    end

    local body = "json="..http.urlencode(http.json.encode(params))
    self.library.session:post(url, body, function(response)
        if not response.failed then
            NSLog("save_songs_to_playlist succeeded: "..response.body)
            callback(true)
        else
            NSLog("save_songs_to_playlist failed: "..response.body)
            callback(false)
        end
    end)
end

function SAVE:SavePlaylist(songs, playlists, playlist, callback)

end

function SAVE:NewPlaylist(songs, name, callback)
    local url = self.library.sj_url.."playlistbatch?alt=json"
    local session = http.session:new()
    session.headers['Authorization'] = self.library.session.headers['Authorization']
    session.headers['Content-Type'] = 'application/json'
    
    local body = '{"mutations": [{"create": {"deleted": false, "type": "USER_GENERATED", "lastModifiedTimestamp": "0", "creationTimestamp": "-1", "name": "'..string.gsub(name, "\"", "\\\"")..'"}}]}'
    session:post(url, body, function(response)
        if not response.failed and response.status == 200 then
            local json = http.json.decode(response.body)
            local id = json['mutate_response'][1]['id']
            save_songs_to_playlist(self, songs, id, callback)
        else
            NSLog("ERROR CREATING PLAYLIST!")
            callback(false)
        end
    end)
end
