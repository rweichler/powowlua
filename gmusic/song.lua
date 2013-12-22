SONG.can_cache = true

local function decode(s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        cgi[name] = value
    end
    return cgi
end

function SONG:SetInfo(info)
    if type(info) == "nil" then
        NSLog("WHAT THE FUCK INFO IS NIL")
    end
    self.info = info
    self.artist = info.artist or self.artist
    self.title = info.title or self.title
    self.album = info.album or self.album
    if info.id then
        self.id = info.id
    elseif info.nid then
        self.id = info.nid
    end
    self.subtitle = (self.artist or "Unknown Artist").." - "..(self.album or "Unknown Album")
    if info.durationMillis then
        self.duration = info.durationMillis/1000.0
    else
        NSLog("What the fuck: "..http.json.encode(info))
    end
    --tooltip stuff
    if string.sub(self.id, 1, 1) == 'T' then --all access
        self.options = {}
        self.options['Add to Library'] = function(callback)
            local func = self.library.AddAllAccessSongs
            NSLog(type(func))
            func(self.library, self, callback)
        end
    end
    --album art
    local url
    if type(self.info.albumArtUrl) == "string" then
        url = "http:"..string.gsub(self.info.albumArtUrl, "s130", "s640")
    elseif type(self.info.albumArtRef) == "table" and type(self.info.albumArtRef[1]) == "table" then
        url = self.info.albumArtRef[1].url
    end
    self.album_art_url = url
end

function SONG:SaveData()
    return http.json.encode{
        album_art_url = self.album_art_url,
        duration = self.duration,
        track_number = self.track_number,
    }
end

function SONG:StreamURL(callback)

    if not self.library.logged_in then
        self.library:Login(function(success)
            if success then
                self:StreamURL(callback)
            end
        end)
        return
    end

    local id = self.id
    if not id then
        callback(nil, "error getting stream URL")
        return
    end

    local url = "https://play.google.com/music/play"
    local params = {
        --random ass parameters you gotta set for some reason
        u = 0,
        pt = 'e',
    }
    --[[
    https://github.com/simon-weber/Unofficial-Google-Music-API/issues/137
    there are three cases when streaming:
      | track type              | guid songid? | slt/sig needed? |
       user-uploaded              yes            no
       AA track in library        yes            yes
       AA track not in library    no             yes

    without the track['type'] field we can't tell between 1 and 2, but
    include slt/sig anyway; the server ignores the extra params.
    ]]
    local key = '27f7313e-f75d-445a-ac99-56386a5fe879'
    local salt = 'djvk4idpqo93' --this should be a generated random string of characters but im too lazy and decided to just mash my keyboard.

    local sig = crypto.hmac.digest(crypto.hmac.sha1, key, id..salt)
    sig = string.sub(sig, 1, #sig - 1) --get rid of = at the end
    --replace + and / with - and _ respectively (for URL encode)
    sig = string.gsub(sig, "[+|/]", function(char)
        if char == "+" then return "-" end
        if char == "/" then return "_" end
    end)

    params['slt'] = salt
    params['sig'] = sig

    if string.sub(id, 1, 1) == 'T' then -- all access
        params['mjck'] = id
    else
        params['songid'] = id
    end
    self.library.session:get(url, params, function(response)
        if response.failed then
            callback(nil, response)
        else
            local json = http.json.decode(response.body)
            if json.url then --song is from locker
                callback(json.url)
            else --song is from all access

                --[[
                Original python code: http://git.io/aomOTQ

                For all access, Google instead returns an array of a bunch of stream URLs
                instead of just one, I imagine because of contracts with the record labels.
                If you stitch all of them together, you will notice that there are
                miniscule parts in the song where it lags. Turns out they don't stitch
                together perfectly.

                HOWEVER, each URL comes with a bunch of parameters, including a range
                property. You can use this range property to shave off the extra parts
                of the MP3 stream and get a seamless playback experience. I included
                the functionality to stitch the URLs together and to shave off certain
                parts of the URL in my HTTPAudioPlayer, which is on GitHub:

                https://github.com/rweichler/HTTPAudioPlayer

                This HTTPAudioPlayer class is used to play LuaSongs in Powow, so
                if you need some sort of odd functionality like this for the API you
                are implementing, don't hesitate to send a pull request and I will
                implement it if it is reasonable enough.

                The rest of the Lua code should be self-explanitory.
                ]]
                local result = {}
                local prev_end = 0
                for k,v in pairs(json.urls) do
                    local decoded = decode(v)

                    local start, this_end = string.match(decoded['range'], "(%d+)-(%d+)")
                    start = prev_end - start

                    local dict = {
                        start = start,
                        url = v
                    }
                    table.insert(result, dict)
                    prev_end = this_end + 1
                end

                local properties = {
                    size = string.match(decode(json.urls[#json.urls])['range'], "-(%d+)"),
                    expire_time = 30,
                }

                callback(result, properties)
            end
        end
    end)
end

function SONG:ArtworkURL(callback)
    if type(callback) == "function" then
        callback(self.album_art_url)
    end
    return self.album_art_url
end
