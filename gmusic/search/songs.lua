
SEARCH.title = "Songs"
SEARCH.icon = "BarSongs.png"

function SEARCH:Filter(result, callback)
    local songs = {}
    for k,v in pairs(result) do
        if v.track then
            local song = self.library.song:new()
            song:SetInfo(v.track)
            table.insert(songs, song)
        end
    end
    callback(songs)
end
