--This is all psuedocode.

LIB.url = "https://ws.audioscrobbler.com/2.0/?format=json"
LIB.api_key = "4f45357ba82e435404fbb486ddb12b97"
LIB.api_secret = nil --gotta figure out a way to include this without showing the source code.....

local secret = LIB.api_secret
local api_key = LIB.api_key
local function sign(params)
    --parameters need to be alphabetized
    local alpha = {}
    if not params['api_key'] then
        params['api_key'] = api_key
    end
    if self.sk and not params['sk'] then
        params['sk'] = self.sk
    end
    for k,v in pairs(params) do
        table.insert(alpha, k)
    end
    table.sort(alpha)

    --build the hash
    local str = ""
    for i, k in ipairs(alpha) do
        local v = params[k]
        str = str..k..v
    end
    str = str..secret
    params['api_sig'] = crypto.md5(str)
    return params
end


function LIB:Login(username, password, callback)
    if not self.session then
        self.session = http.session:new()
    end

    local params = sign{
        username = username,
        password = password,
        method = "auth.getMobileSession"
    }

    self.session:post(self.url, params, function(response)
        if response.failed then callback(false) return end

        local json = http.json.decode(response.body)

        if json.session and json.session.key then
            self.sk = json.session.key
            callback(true)
        else
            callback(false)
        end

    end)
end

local function send_song(self, song, method, params)
    params = params or {}
    params.method = method
    params.artist = song.artist
    params.track = song.title
    params.album = song.album
    params.duration = song.duration
    params.trackNumber = song.track_number

    sign(params)

    self.session:post(self.url, params, function(response)

    end)
end

function LIB:UpdateNowPlaying(song)
    song.started_playing = os.time()
    send_song(self, song, "track.updateNowPlaying")
end

function LIB:Scrobble(song)
    params = {}
    params.timestamp = song.started_playing
    send_song(self, song, "track.scrobble", params)
end
