--SHOUT OUT TO SIMON WEBER FOR MAKING THE BEST GOOGLE MUSIC API EVER (which is what this is based on)
--https://github.com/simon-weber/Unofficial-Google-Music-API/

LIB.title = "Google Music"
LIB.short_title = "GMusic"
LIB.color = {255,0,255}

LIB.requires_login = true
LIB.num_login_fields = 2

LIB.logged_in = false

local function generate_create_dir(self)
    return function (dir, path, kind, env_var)
        if type(dir) == "string" then
            env_var = kind
            kind = path
            path = dir
            dir = nil
        end
        if not dir then
            dir = self.directory:new()
        end
        if not kind then
            kind = "directories"
        end
        if not env_var then
            env_var = "DIR"
        end

        path = bundle_path..self.class.."/"..kind.."/"..path
        local env = {}
        env[env_var] = dir
        setmetatable(env, {__index=_ENV})
        local f = loadfile(path, "bt", env)
        f()
        return dir
    end
end

function LIB:Load(callback, info)
    if info then
        self.last_update = tonumber(info)
    end

    local create_dir = generate_create_dir(self)

    local callback_called = false

    --load directories if they have already been saved
    local directories = self:GetSavedDirectories()
    --create search
    local search = nil
    local query = "eminem crack a bottle"
    local function search_callback(success, result)
        if not success then
            if result.status == 0 then
                self:Search(query, search_callback)
            end
        else
            search = self.directory:new()
            search.style = "search"
            search.title = "Search All Access"
            search.icon = "magnifier@2x.png"
            search.items = {
                create_dir("songs.lua", "search"),
                create_dir("albums.lua", "search"),
                create_dir("artists.lua", "search")
            }
            if callback_called then
                self:InsertDirectory(search, 2)
            end
        end
    end
    self:Search(query, search_callback)
    --create playlists
    local playlists = create_dir("playlists.lua")

    if not directories or #directories == 0 then
        self:GetSongs(function(result)
            if type(result) == "table" then
                local artists = create_dir("artists.lua")
                local songs = create_dir("songs.lua")

                artists.items = artists:init(result)
                songs.items = songs:init(result)

                artists:save("artists")
                songs:save("songs")

                local directories = {}
                table.insert(directories, artists)
                if search then
                    table.insert(directories, search)
                end
                table.insert(directories, songs)
                table.insert(directories, playlists)
                self.directories = directories
                callback(directories)
                callback_called = true
            elseif type(result) == "string" then
                callback(result)
            else
                callback(false)
            end
        end)
    else
        --directories just contains the songs (dir.items), but we still want them to have their special functions, so we will initialize them this way
        local songs = nil
        local artists = nil

        for k,v in pairs(directories) do
            v:load()
            if v.id == "songs" then
                songs = v
            elseif v.id == "artists" then
                artists = v
            end
        end

        create_dir(songs, "songs.lua")
        create_dir(artists, "artists.lua")

        --self:UpdateSongs(function(result)
            if result and #result > 0 then
                for k, dir in pairs(directories) do
                    for k, song in pairs(songs) do
                        if song.deleted then
                            dir:remove(song)
                        else
                            dir:add(song)
                        end
                    end
                    dir:save()
                end
            end

            local directories = {}
            table.insert(directories, artists)
            if search then
                table.insert(directories, search)
            end
            table.insert(directories, songs)
            table.insert(directories, playlists)
            self.directories = directories
            callback(directories)
            callback_called = true
        --end)
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

    assert(type(email) == "string")
    assert(type(password) == "string")
    assert(not callback or type(callback) == 'function')

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
        --timeout/wrong credentials
        if response.status ~= 200 then
            if callback then
                local msg
                if response.status == 0 then
                    msg = "Could not connect to Google"
                elseif response.status == 403 then
                    msg = "Wrong username or password"
                else
                    msg = "Unknown error ("..response.status.."). Take a screenshot of this and send to rweichler@gmail.com"
                end
                callback(false, response.status, msg)
            end
            return
        end

        --get auth token
        local auth = string.match(response.body, "\nAuth=(%g+)\n")
        --set the headers for every subsequent session.request
        session.headers['Authorization'] = "GoogleLogin auth="..auth

        local url = "https://play.google.com/music/listen"
        --normally we would use get, but we don't need all the HTML crap. head saves some bandwidth
        --if this thing breaks, try changing 'head' to 'get' as a first resort
        session:head(url, {}, function(response)
            if response.status ~= 200 then
                if callback then
                    callback(false, response.status, "can't get xt")
                end
                return
            end

            --set the cookies for every subsequent session.request
            session.cookies.xt = response.cookies.xt --used for getting library info
            session.cookies.sjsaid = response.cookies.sjsaid --used for getting the actual music

            --WE DONE

            self.logged_in = true
            self.session = session --needa save the session for other shit

            if callback then
                callback(true, response.status)
                return
            end
        end)

    end)
end

LIB.sj_url = "https://www.googleapis.com/sj/v1.1/"

function LIB:Search(query, callback, search)
    local url = self.sj_url.."query"

    local params = {
        q = query
    }
    params['max-results'] = 40

    self.session:get(url, params, function(result)
        if result.status ~= 200 then
            callback(false, result)
        else
            local json = http.json.decode(result.body)
            if json.entries ~= nil then
                search:Filter(json.entries, callback)
            else
                callback({})
            end
        end
    end)

end

function LIB:SavePlaylist(songs, callback)


end

function LIB:AddAllAccessSongs(songs, callback)
    if not songs[1] then
        if songs.type == "song" then
            songs = {songs}
        else
            callback(false, "malformed songs")
            return
        end
    end

    local body_table = {
        mutations = {}
    }
    local default = {
        playCount =  0,
        rating = '0',
        genre = '',
        lastModifiedTimestamp = '0',
        deleted = false,
        beatsPerMinute = -1,
        composer = '',
        creationTimestamp = '-1',
        totalDiscCount = 0,
    }
    local remove = {'kind', 'trackAvailableForPurchase', 'albumAvailableForPurchase', 'albumArtRef', 'artistId'}

    for k,song in pairs(songs) do
        if song.library ~= self then
            callback(false, "The song is part of this library")
            return
        elseif string.sub(song.id, 1, 1) ~= 'T' then
            callback(false, "Not All Access Song")
            return
        end
        local dict = {}
        for k,v in pairs(song.info) do
            dict[k] = v
        end

        for k,v in pairs(remove) do
            dict[v] = nil
        end

        for k,v in pairs(default) do
            if not dict[k] then
                dict[k] = v
            end
        end

        --TODO unsure about this
        dict['trackType'] = 8

        table.insert(body_table.mutations, {create = dict})
    end

    local body = http.json.encode(body_table)
    local url = self.sj_url.."trackbatch?alt=json"

    local session = http.session:new()
    session.headers['Authorization'] = self.session.headers['Authorization']
    session.headers['Content-Type'] = "application/json"

    session:post(url, body, function(response)
        --{'mutate_response': [{'response_code': 'OK', 'id': '17f9fff3-ffc5-3141-abf2-0c9b588cbf77', 'client_id': ''}]}
        if not response.failed and response.status == 200 then
            local ids = {}
            local json = http.json.decode(response.body)
            for k,v in pairs(json.mutate_response) do
                if v.response_code == 'OK' then
                    table.insert(ids, v.id)
                else
                    table.insert(ids, false)
                end
            end
            callback(true, ids)
        else
            callback(false, "Fucked up "..response.status)
        end
    end)

end

function LIB:UpdateTime()
    self.last_update = os.time()
    self:save(tostring(self.last_update))
end

function LIB:UpdateSongs(callback)
    local url = "https://play.google.com/music/services/streamingloadalltracks"
    local params = {
        u = 0,
        xt = self.session.cookies['xt'],
        lastUpdated = self.info.lastUpdated,
        format='json',
    }

    self.session:get(url, params, function(response)
        self:UpdateTime()

        local str = string.match(response.body, "\"playlist\":(.*)}%);\n")
        if true or not str then callback(nil) return end


        local songs = http.json.decode(str)
        for k,v in pairs(songs) do
            local song = self.song:new()
            song:SetInfo(v)
            songs[k] = song
        end


    end)
end

function LIB:GetSongs(callback)
    if not callback then
        callback = function() end
    end
    assert(type(callback) == "function")
    if not self.logged_in then
        self:Login(function(success)
            if success then
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

    callback("Getting library from Google Music..")

    --recursive fetch of all song info
    local function handle_data(response)
        if response then
            if response.status ~= 200 then
                callback(response.status)
                return
            end
            local start = os.clock()
            local json = http.json.decode(response.body)
            NSLog("http.json.decode took"..(os.clock()-start).." seconds")
            if not type(json) == "table" or not type(json.playlist) == "table" then
                callback(http.session.MALFORMED_RESPONSE)
            end
            --append the song info somewhere
            if self.songs then
                for k,v in pairs(json.playlist) do
                    local song = self.song:new()
                    song:SetInfo(v)
                    table.insert(self.songs, song)
                end
            else
                self.songs = json.playlist
                for k,v in pairs(self.songs) do
                    local song = self.song:new()
                    song:SetInfo(v)
                    self.songs[k] = song
                end
            end
            if json.continuationToken then
                params['json'] = '{"continuationToken":"'..json.continuationToken..'"}'
            else
                self:UpdateTime()
                callback(self.songs)
                return --if there's no continuation token, then we're done
            end
        end
        self.session:post(url, params, handle_data)
    end

    handle_data()
end


