
SONG.class = "gmusic"
SONG.can_cache = true

function SONG:ID()
    if self.info.id then
        return self.info.id
    elseif self.info.nid then
        return self.info.nid
    end
    return nil
end

function SONG:StreamURL(callback)
    local id = self:ID()
    if not id then
        print("ERROR getting stream URL")
        callback(false)
        return
    end
    self.library:GetSongUrl(id, function(response)
        if type(response) == "string" or type(response) == "table" then
            if type(response) == "table" and response.failed then
                print(response.body)
            end
            callback(response)
        else
            callback(false)
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
