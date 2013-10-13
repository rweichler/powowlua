local JSON = dofile(bundle_path.."libs/json.lua")

SONG.can_cache = true

function SONG:ID()
    if self.info.id then
        return self.info.id
    elseif self.info.nid then
        return self.info.nid
    end
    return nil
end

local function unescape(s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x))", function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

local function decode(s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name)
        value = unescape(value)
        cgi[name] = value
    end
    return cgi
end

function SONG:StreamURL(callback)

    if not self.library.logged_in then
        self.library:Login(function(status)
            if status == 200 then
                self:StreamURL(callback)
            end
        end)
        return
    end

    local id = self:ID()
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

        local sig = hmac_sha1_64(key, id..salt) --I CHEATED: implemented this in C
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
            local json = JSON:decode(response.body)
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
            }

            callback(result, properties)
        else
            local json = JSON:decode(response.body)
            callback(json.url)
        end
    end)
end

function SONG:ArtworkURL(callback)
    local url
    if self.info.albumArtUrl then
        url = "http:"..string.gsub(self.info.albumArtUrl, "s130", "s640")
    elseif type(self.info.albumArtRef) == "table" and #self.info.albumArtRef > 0 then
        url = self.info.albumArtRef[1].url
    end
    callback(url)
end
