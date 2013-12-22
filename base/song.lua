local SONG = {}
SONG.type = "song"
SONG.class = "base"

SONG.__objc_classname = "LuaSong"

SONG.can_cache = false
SONG.filetype = "mp3"

function SONG:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.info = o.info or {}

    return o
end

function SONG:SetInfo(info)
    self.info = info
end

function SONG:StreamURL(callback)
    callback(self.info.stream_url)
end

function SONG:ArtworkURL(callback)
    callback(self.info.artwork_url)
end

function SONG:LoadData(data)
    if not data or string.len(data) == 0 then return end
    data = http.json.decode(data)
    for k,v in pairs(data) do
        self[k] = v
    end
end

return SONG
