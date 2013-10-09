local JSON = dofile("json.lua")

function LIBRARY:Login(email, password, callback)
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

    assert(email)
    assert(password)
    assert(not response or type(response) == 'function')

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
                callback(response.status)
            end
            return response.status
        end

        --get auth token
        local auth = string.match(response.body, "\nAuth=(%g+)\n")
        session.headers['Authorization'] = "GoogleLogin auth="..auth

        local url = "https://play.google.com/music/listen"
        session:head(url, {}, function(response)
            --have to manually set the session cookies in order to preserve them HELLA SECURE
            session.cookies.xt = response.cookies.xt
            session.cookies.sjsaid = response.cookies.sjsaid

            --WE DONE

            self.logged_in = true
            self.session = session

            if callback then
                callback(200)
                return 200
            end
        end)

    end)
end

function LIBRARY:GetSongs()
    if not self.logged_in then
        self:Login(function(status)
            if status == 200 then
                self:GetSongs()
            end
        end)
        return
    end

    local url = "https://play.google.com/music/services/loadalltracks"

    local params = {
        xt = self.session.cookies.xt
    }

    --recursive fetch of all song info
    local function handle_data(response)
        if response then
            local json = JSON:decode(response.body)
            --append the song info somewhere

            if json.continuationToken then
                params['json'] = '{"continuationToken":"'..json.continuationToken..'"}'
                print("got "..string.len(response.body).." bytes")
            else
                print("done")
                return --if there's no continuation token, then we're done
            end
        end
        self.session:post(url, params, handle_data)
    end

    handle_data()
end

function LIBRARY:GetSongUrl(id)
    local url = "https://play.google.com/music/play"
    local params = {
        songid = id,
        u = 0,
        pt = 'e',
    }
    self.session:get(url, params, function(response)
        local json = JSON:decode(response.body)
        print(json.url) --copy paste this shit and it'll download dat shit, breh
    end)

end
