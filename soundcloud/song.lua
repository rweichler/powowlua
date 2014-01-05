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
    --for some reason there's a bug in the soundcloud API that causes the stream URL to not work sometimes
    --this is an elaborate fix
    local url = nil
    local request_type = nil
    if self.stream_failed then
        if self.download_failed or not self.download_url then
            popup("There is something wrong with this song. Sorrry :(")
            return
        else
            url = self.download_url
            request_type = "GET"
        end
    else
        url = self.stream_url
        request_type = "HEAD"
    end
    url = url.."?client_id="..private_key

    http.session:request(request_type, url, "", function(result)
        if result.failed and result.status ~= 0 then
            if self.stream_failed then
                self.download_failed = true
                self:StreamURL(callback)
            else
                self.stream_failed = true
                NSLog("Stream failed, trying download URL if it exists")
                self:StreamURL(callback)
            end
        else
            callback(url)
        end
    end)
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
    if info.downloadable then
        self.download_url = info.download_url
    end
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
    local data = {
        stream_url = self.stream_url,
        album_art_url = self.album_art_url,
        download_url = self.download_url
    }

    return http.json.encode(data)
end
