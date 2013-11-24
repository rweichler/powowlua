
DIR.header = false
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
                    local num_all_access = 0
                    for k,v in pairs(self.plentries) do
                        local id = v.trackId
                        if string.sub(id, 1, 1) == 'T' then
                            num_all_access = num_all_access + 1
                            local song = self.library.song:new()
                            table.insert(songs, song)

                            local session = http.session:new()
                            session.headers['Authorization'] = self.library.session.headers['Authorization']
                            session.headers['Content-Type'] = 'application/json'
                            local url = self.library.sj_url..'fetchtrack'
                            local params = {
                                alt = 'json',
                                nid = id,
                            }
                            session:get(url, params, function(result)
                                local json = http.json.decode(result.body)
                                song:SetInfo(json)
                                song.plentry = v
                                num_all_access = num_all_access - 1
                                if num_all_access == 0 then
                                    callback(songs)
                                end
                            end)

                        else
                            local song = self.library.song_from_id[id]
                            if song then
                                local song2 = {}
                                song2.plentry = v
                                setmetatable(song2, song)
                                table.insert(songs, song2)
                            end
                        end
                    end
                    if num_all_access == 0 then
                        callback(songs)
                    end
                end
            end
        end

        callback(playlists)
    end)
end
