SONG.can_cache = true

local function decode(s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        cgi[name] = value
    end
    return cgi
end

function SONG:SetInfo(info)
    self.info = info
    self.artist = info.artist
    self.title = info.title
    self.album = info.album
    if info.id then
        self.id = info.id
    elseif info.nid then
        self.id = info.nid
    end
    self.subtitle = self.artist.." - "..self.album
    self.duration = info.durationMillis/1000.0
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

    local is_all_access = string.sub(id, 1, 1) == 'T'

    local url = "https://play.google.com/music/play"
    local params = {
        --random ass parameters you gotta set for some reason
        u = 0,
        pt = 'e',
    }
    if is_all_access then
        params['mjck'] = id

        --needa generate hashes
        local key = '27f7313e-f75d-445a-ac99-56386a5fe879'
        local salt = 'djvk4idpqo93' --this should be a random string of characters but im too lazy

        local sig = crypto.hmac.digest(crypto.hmac.sha1, key, id..salt)
        sig = string.sub(sig, 1, #sig - 1) --get rid of = at the end
        --weird shit
        sig = string.gsub(sig, "[+|/]", function(char)
            if char == "+" then return "-" end
            if char == "/" then return "_" end
        end)

        params['slt'] = salt
        params['sig'] = sig
    else
        params['songid'] = id
    end
    print('boutta call')
    self.library.session:get(url, params, function(response)
        print('got response')
        if response.failed then
            callback(nil, response)
        elseif is_all_access then
            local json = http.json.decode(response.body)
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
                size = string.match(decode(json.urls[#json.urls])['range'], "-(%d+)") + 1,
                expire_time = 30,
            }

            callback(result, properties)
        else
            local json = http.json.decode(response.body)
            callback(json.url)
        end
    end)
end

function SONG:ArtworkURL(callback)
    if not type(self.info) == "table" then
        callback(nil)
        return
    end

    local url
    if type(self.info.albumArtUrl) == "string" then
        url = "http:"..string.gsub(self.info.albumArtUrl, "s130", "s640")
    elseif type(self.info.albumArtRef) == "table" and type(self.info.albumArtRef[1]) == "table" then
        url = self.info.albumArtRef[1].url
    end
    callback(url)
end
