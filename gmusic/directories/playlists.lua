
DIR.title = "Playlists"
DIR.icon = "BarPlaylists.png"

function DIR:loaditems(callback)
    local url = self.library.sj_url.."playlistfeed"
    local params = {}
    self.library.session:post(url, params, function(result)

        local playlists = {}
        local id_to_playlist = {}

        local loaded_that_shit = false

        local json = http.json.decode(result.body)
        for k,v in pairs(json.data.items) do
            local playlist = self.library.directory:new()
            table.insert(playlists, playlist)

            playlist.title = v.name
            playlist.subtitle = v.ownerName
            playlist.id = v.id
            id_to_playlist[v.id] = playlist
            function playlist:loaditems(callback)
                if not loaded_that_shit then
                    loaded_that_shit = true
                    local url = self.library.sj_url.."plentryfeed"
                    self.library.session:post(url, params, function(result)
                        local json = http.json.decode(result.body)
                        for k,v in pairs(json.data.items)do
                            local plist = id_to_playlist[v.playlistId]
                            if type(plist) == "table" then
                                if not plist.plentries then
                                    plist.plentries = {}
                                end
                                table.insert(plist.plentries, v)
                            end
                        end
                        self:loaditems(callback)
                    end)
                else
                    self.plentries = self.plentries or {}
                    table.sort(self.plentries, function(a,b)
                        return a.absolutePosition < b.absolutePosition
                    end)

                    local songs = {}
                    for k,v in pairs(self.plentries) do
                        local song = self.library.song:new()
                        local info = self.library.song_from_id[v.trackId]
                        if not info then
                            local count = 0
                            for k,v in pairs(self.library.song_from_id) do
                                count = count + 1
                            end
                            NSLog('id is nil! '..v.id.." "..(count).." IJFOSDJ")
                        else
                            song:SetInfo(info)
                            table.insert(songs, song)
                        end
                    end
                    callback(songs)
                end
            end
        end

        callback(playlists)
    end)
end
