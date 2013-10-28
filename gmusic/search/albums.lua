
SEARCH.title = "Albums"
SEARCH.icon = "BarAlbums.png"

function SEARCH:Filter(result, callback)
    local dirs = {}

    local url = self.library.sj_url.."fetchalbum"
    local params = {}
    params['alt'] = 'json'
    --params['nid'] = v.album.albumId
    params['include-tracks'] = 'true'

    for k,v in pairs(result) do
        if v.album then
            local directory = self.library.directory:new()
            function directory:loaditems(callback)
                params['nid'] = v.album.albumId
                self.library.session:get(url, params, function(response)
                    local songs = {}
                    local json = http.json.decode(response.body)
                    for k,v in pairs(json.tracks) do
                        local song = self.library.song:new()
                        song:SetInfo(v)
                        table.insert(songs, song)
                    end
                    callback(songs)
                end)
            end
            directory.title = v.album.name
            directory.subtitle = v.album.albumArtist
            table.insert(dirs, directory)
        end
    end
    callback(dirs)
end
