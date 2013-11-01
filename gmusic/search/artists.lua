
SEARCH.title = "Artists"
SEARCH.icon = "BarArtists.png"

function SEARCH:Filter(result, callback)
    local dirs = {}

    local url = self.library.sj_url.."fetchartist"
    local params = {}
    params['alt'] = 'json'
    --params['nid'] = v.album.albumId
    params['include-albums'] = 'true'
    params['num-top-tracks'] = 0
    params['num-related-artists'] = 0

    local album_url = self.library.sj_url.."fetchalbum"
    local album_params = {}
    album_params['include-tracks'] = 'true'

    for k,v in pairs(result) do
        if v.artist then
            local d_artist = self.library.directory:new()
            table.insert(dirs, d_artist)
            d_artist.title = v.artist.name
            d_artist.style = "album"
            function d_artist:loaditems(callback)
                params['nid'] = v.artist.artistId
                self.library.session:get(url, params, function(response)
                    local json = http.json.decode(response.body)
                    local albums = {}
                    for k, album in pairs(json.albums) do
                        local d_album = self.library.directory:new()
                        d_album.image_url = album.albumArtRef
                        function d_album:loaditems(callback)
                            album_params['nid'] = album.albumId
                            self.library.session:get(album_url, album_params, function(response)
                                local json = http.json.decode(response.body)
                                local songs = {}
                                for k, v in pairs(json.tracks) do
                                    local song = self.library.song:new()
                                    song:SetInfo(v)
                                    song.track_number = k
                                    table.insert(songs, song)
                                end
                                callback(songs)
                            end)
                        end
                        d_album.title = album.name
                        d_album.subtitle = v.artist.name
                        table.insert(albums, d_album)
                    end
                    callback(albums)
                end)
            end
        end
    end
    callback(dirs)
end
