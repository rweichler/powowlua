local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = private_key or dofile(path)

SONG.can_cache = true
SONG.album = "SoundCloud"

function SONG:new(o)
    o = self.super.new(self, o)
    o.options = o.options or {}
    o.options['Save'] = o.options['Save'] or function(callback)
        o:download(function()
            o.options['Save'] = nil
        end)
        callback(true)
    end
    return o
end

function SONG:StreamURL(callback)
    callback(self.stream_url.."?client_id="..private_key)
end

function SONG:ArtworkURL(callback)
    if type(callback) == 'function' then
        callback(self.album_art_url)
    end
    return self.album_art_url
end

function SONG:SetInfo(info)
    self.info = info
    self.title = info.title
    self.artist = info.user.username
    self.id = info.id
    self.subtitle = self.artist.." - "..self.album
    self.stream_url = info.stream_url
    local url
    if type(self.info.artwork_url) == "string" then
        url = self.info.artwork_url
    end
    url = url or self.info.user.avatar_url
    if not string.find(url, "default_avatar") then
        self.album_art_url = string.gsub(url, "large", "t500x500")
    end
end

function SONG:SaveData()
    return http.json.encode{
        stream_url = self.stream_url,
        album_art_url = self.album_art_url,
    }
end
