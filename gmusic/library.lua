--SHOUT OUT TO SIMON WEBER FOR MAKING THE BEST GOOGLE MUSIC API EVER
--https://github.com/simon-weber/Unofficial-Google-Music-API/

local JSON = dofile(bundle_path.."json.lua")
dofile(bundle_path.."sha.lua")

LIB.class = "gmusic"
LIB.title = "Google Music"
LIB.short_title = "GMusic"
LIB.icon = "gmusic_icon@2x.png"

LIB.directory_names = {
    "gmusic_songs"
}
LIB.song_name = "googlemusic_song"

LIB.requires_login = true
LIB.num_login_fields = 2

LIB.logged_in = false

function LIB:Load(callback)
    if not self.logged_in then
        callback(false)
    else
        self:GetSongs(function(status)
            if status ~= 200 then
                callback(false)
            else
                callback(self.songs)
            end
        end)
    end
end

function LIB:Login(email, password, callback)
    if type(email) == "function" then
        callback = email
        email = nil
    end

    if not email then
        email = self.email
    end
    if not password then
        password = self.password
    end

    assert(email and type(email) == "string")
    assert(password and type(password) == "string")
    assert(not response or type(response) == 'function')

    self.email = email
    self.password = password

    local session = http.session:new()

    local params = {
        accountType = "HOSTED_OR_GOOGLE",
        Email = email,
        Passwd = password,
        service = "sj",
        source = "Reed-Weichler"
    }

    local url = "https://google.com/accounts/ClientLogin"

    session:post(url, params, function(response)
        --wrong credentials
        if response.status ~= 200 then
            if callback then
                callback(false, callback.status, "Wrong Credentials")
            end
            return
        end

        --get auth token
        local auth = string.match(response.body, "\nAuth=(%g+)\n")
        session.headers['Authorization'] = "GoogleLogin auth="..auth

        local url = "https://play.google.com/music/listen"
        --normally we would use get, but we don't need all the HTML crap. head saves some bandwidth
        --if this thing breaks, try changing head to get as a first resort
        session:head(url, {}, function(response)
            if response.status ~= 200 then
                if callback then
                    callback(false, response.status, "can't get xt")
                end
                return
            end
            --xt is used for getting library info
            session.cookies.xt = response.cookies.xt
            --sjsaid is for getting the actual music
            session.cookies.sjsaid = response.cookies.sjsaid

            --WE DONE

            self.logged_in = true
            self.session = session

            if callback then
                callback(true, response.status)
                return
            end
        end)

    end)
end

function LIB:Search(query, max_results, callback)
    if not callback and type(max_results) == "function" then
        callback = max_results
        max_results = 20
    end


    local url = "https://www.googleapis.com/sj/v1.1/query"

    local params = {
        q = query
    }
    params['max-results'] = max_results

    self.session:get(url, params, function(result)
        if result.failed or result.status ~= 200 then
            callback(false, result)
        else
            local json = JSON:decode(result.body)
            local entries = json.entries
            local songs = {}
            for k,v in pairs(entries) do
                if v.track then
                    local song = self.song:new()
                    song:SetInfo(v.track)
                    song.library = self
                    table.insert(songs, song)
                end
            end
            callback(songs)
        end
    end)
end

function LIB:GetSongs(callback)
    if not callback then
        callback = function() end
    end
    assert(type(callback) == "function")
    if not self.logged_in then
        self:Login(function(status)
            if status == 200 then
                self:GetSongs(callback)
            end
        end)
        return
    end

    local url = "https://play.google.com/music/services/loadalltracks"

    local params = {
        xt = self.session.cookies.xt
    }

    self.songs = nil

    --recursive fetch of all song info
    local function handle_data(response)
        if response then
            if response.status ~= 200 then
                callback(response.status)
                return
            end
            local json = JSON:decode(response.body)
            if not type(json) == "table" or not type(json.playlist) == "table" then
                callback(http.session.MALFORMED_RESPONSE)
            end
            --append the song info somewhere
            if self.songs then
                for k,v in pairs(json.playlist) do
                    table.insert(self.songs, v)
                end
            else
                self.songs = json.playlist
            end
            if json.continuationToken then
                params['json'] = '{"continuationToken":"'..json.continuationToken..'"}'
            else
                callback(response.status)
                return --if there's no continuation token, then we're done
            end
        end
        self.session:post(url, params, handle_data)
    end

    handle_data()
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


function LIB:GetSongUrl(id, callback)
    assert(id and type(id) == "string")
    assert(callback and type(callback) == "function")


    if not self.logged_in then
        self:Login(function(status)
            if status == 200 then
                self:GetSongUrl(id, callback)
            end
        end)
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
        local salt = 'djvk4idpqo93'
        local sig = hmac_sha1_64(key, id..salt) --hash that shit
        sig = string.sub(sig, 1, #sig - 1) --get rid of = at the end

        params['slt'] = salt
        params['sig'] = sig
    else
        params['songid'] = id
    end
    self.session:get(url, params, function(response)
        if response.failed then
            callback(response)
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

            callback(result)
        else
            local json = JSON:decode(response.body)
            callback(json.url)
        end
    end)

end
