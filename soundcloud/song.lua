
SONG.can_cache = true

function SONG:ID()
    return self.info.id
end

function SONG:StreamURL(callback)
    callback(self.info.stream_url)
end

function SONG:ArtworkURL(callback)
    local url
    if self.info.artwork_url then
        url = self.info.artwork_url
    end

    url = url or self.info.user.avatar_url
    if not string.find(url, "default_avatar") then
        callback(string.gsub(url, "large", "t500x500"))
    end
end

function SONG:Title()
    return self.info.title
end

function SONG:Artist()
    return self.info.user.username
end

function SONG:Album()
    return "SoundCloud"
end