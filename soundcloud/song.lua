waxClass{"SCSong", StreamSong}

local API_KEY = "Your api key here"

function initWithDictionary(self, dictionary)
    self.super:init()
    self:setDictionary(dictionary)

    return self
end

function initWithIdentifier(self, identifier)
    self:initWithDictionary({})
    local songURL = "https://api.soundcloud.com/tracks/"..identifier..".json"
    songURL = songURL.."?client_id="..API_KEY
    wax.http.request{songURL, callback = function(json, response)
        if response:statusCode() == 200 then
            self:setDictionary(json)
        end
    end}

    return self
end

function setDictionary(self, dictionary)
    self.dictionary = dictionary
    if dictionary["stream_url"] then
        self:setHTTPURL(NSURL:URLWithString(dictionary["stream_url"]))
    end
end

function setHTTPURL(self, streamURL)
    if streamURL == nil then
        self:httpPlayer():fileSaver():setHTTPURL(nil)
    else
        local streamString = streamURL:absoluteString()
        if streamURL:query() then
            streamString = streamString.."&"
        else
            streamString = streamString.."?"
        end
        streamString = streamString.."client_id="..API_KEY
        self:httpPlayer():fileSaver():setHTTPURL(NSURL:URLWithString(streamString))
    end
end



function load(self)
    if not self.dictionary["streamable"] then
        global:popup_withTitle("Try again in a few seconds. If it doesn't work a second time then give up.", "This song is permanently/temporarily unavailable")
        return
    end
    
    local path = global:makeDocumentsDirectory("soundcloud_songs")
    print(path)
    path = path.."/"..self.dictionary["id"]..".mp3"
    --path = NSString:stringWithString(path):stringByAppendingPathComponent(self.dictionary["id"]..".mp3")
    self:httpPlayer():fileSaver():setLocalURL(NSURL:URLWithString(path))
    self.super:load()

    --set album artwork
    if self:artwork() == nil then

        local artworkString = self.dictionary["artwork_url"]

        --if not found, get artist avatar
        if not artworkString then
            artworkString= self.dictionary["user"]["avatar_url"]
        end

        --NSRange isn't defined in wax
        wax.struct.create("_NSRange", "II", "location","length")

        local loc = toobjc(artworkString):rangeOfString("default_avatar").location

        --only continue if an avatar is found and it is not the default avatar
        if artworkString and loc == 2147483647 then
            artworkString = toobjc(artworkString):stringByReplacingOccurrencesOfString_withString("large", "t500x500")
            self:setArtworkUsingURL(NSURL:URLWithString(artworkString))
        end
    end
end

function identifier(self)
    return self.dictionary["id"]
end

function title(self)
    if not self.dictionary or self.dictionary == nil or self.dictionary["title"] == nil then
        return self.super:title()
    end
    return self.dictionary["title"]
end

function artist(self)
    if not self.dictionary or self.dictionary == nil or self.dictionary["user"]["username"] == nil then
        return self.super:title()
    end
    return self.dictionary["user"]["username"]
end

function album(self)
    return "SoundCloud"
end
