
SEARCH.title = "Albums"
SEARCH.icon = "BarAlbums.png"

function SEARCH:Filter(result, callback)
    local songs = {}
    local finished = false
    local count = 0
    for k,v in pairs(result) do
        if v.album then
            count = count + 1
            local url = self.library.sj_url.."fetchalbum"
            local params = {}
            params['alt'] = 'json'
            params['nid'] = v.album.albumId
            params['include-tracks'] = 'true'
            self.library.session:get(url, params, function(response)
                local album = {}
                local json = http.json.decode(response.body)
                for k,v in pairs(json.tracks) do
                    local song = self.library.song:new()
                    song:SetInfo(v)
                    table.insert(album, song)
                end
                table.insert(songs, album)
                count = count - 1
                if count == 0 and finished then
                    callback(songs)
                end
            end)
        end
    end
    finished = true
    if count == 0 then
        callback(songs)
    end
end
