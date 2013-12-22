local song = {}
song.type = "song"
song.class = "base"

song.__objc_classname = "LuaSong"

song.can_cache = false
song.filetype = "mp3"

function song:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.info = o.info or {}

    return o
end

function song:SetInfo(info)
    self.info = info
end

function song:StreamURL(callback)
    callback(self.info.stream_url)
end

function song:ArtworkURL(callback)
    callback(self.info.artwork_url)
end

function SONG:LoadData(data)
    if not data or string.len(data) == 0 then return end
    data = http.json.decode(data)
    for k,v in pairs(data) do
        self[k] = v
    end
end

return song
