local lib = {}
lib.type = "library"
lib.class = "base"

lib.title = "Library"
lib.short_title = lib.title
lib.icon = "icon.png"
lib.requires_login = false
lib.num_login_fields = 0
lib.song = nil
lib.color = {0,0,0}
lib.background_color = {0,0,0}

--lib.directory_names = nil

function lib:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    --o.directories = {}
    if o.class then
        --song
        local song = dofile(bundle_path.."base/song.lua")
        SONG = {}
        local path = bundle_path..o.class.."/song.lua"
        if io.open(path) then
            dofile(path)
            for k,v in pairs(SONG) do
                song[k] = v
            end
        end

        song.class = o.class
        song.library = o
        o.song = song

        --directory
        local dir = dofile(bundle_path.."base/directory.lua")
        DIR = {}
        local path = bundle_path..o.class.."/directory.lua"
        if io.open(path) then
            dofile(path)
            for k,v in pairs(DIR) do
                dir[k] = v
            end
        end
        dir.class = o.class
        dir.library = o
        o.directory = dir

        --just in case
        o.library = o
    end

    return o
end

function lib:Search(query, callback, index)
    if not self.searches then
        callback{}
    else
        local search = self.searches[index]
        if search.Search then
            search:Search(query, callback)
        else
            callback{}
        end
    end
end

function lib:Load(callback)
    if type(callback) == "function" then
        callback(false)
    end
end

return lib
