
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
        local auth = --do regex to get Auth here
        session.headers.Authorization = "GoogleLogin auth="..auth

        local url = "https://play.google.com/music/listen"
        session:head(url, {}, function(response)
            session.cookies.xt = response.cookies.xt
            session.cookies.sjsaid = response.cookies.sjsaid

            --WE DONE

            self.logged_in = true
            self.session = session

            if callback then
                callback()
            end
        end)

    end)
end

function LIBRARY:GetSongs()
    if not self.logged_in then
        self:Login(function()
            self:GetSongs()
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
            json = --get json from response
            --append the song info somewhere

            if json.continuationToken then
                params.continuationToken = json.continuationToken
            else
                return --if there's no continuation token, then we're done
            end
        end
        self.session:post(url, params, handle_data)
    end

    handle_data()
end
