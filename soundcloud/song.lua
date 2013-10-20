local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = dofile(path) or private_key

SONG.can_cache = true

function SONG:ID()
    return self.info.id
end

function SONG:StreamURL(callback)
    callback(self.info.stream_url.."?client_id="..private_key)
end

function SONG:ArtworkURL(callback)
    local url
    if type(self.info.artwork_url) == "string" then
        url = self.info.artwork_url
    end
    url = url or self.info.user.avatar_url
    if not string.find(url, "default_avatar") then
        url = string.gsub(url, "large", "t500x500")
        callback(url)
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
