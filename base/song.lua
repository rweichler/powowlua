local song = {}
song.type = "song"
song.class = "base"

song.can_cache = false
song.filetype = "mp3"
song.library = nil

function song:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.info = o.info or {}

    return o
end

function song:ID()
    return self.info.id
end

function song:SetInfo(info)
    self.info = info
end

function song:StreamURL(callback)
    if callback then
        callback(self.info.stream_url)
    end
end

function song:ArtworkURL(callback)
    if callback then
        callback(self.info.artwork_url)
    end
end

function song:Serialize()
    return self.info
end


return song
