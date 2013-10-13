local lib = {}
lib.type = "library"
lib.class = "base"

lib.title = "Library"
lib.short_title = lib.title
lib.icon = "icon.png"
lib.requires_login = false
lib.num_login_fields = 0
lib.song = nil

--lib.directory_names = nil

function lib:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.directories = {}
    if o.class then
        local song = dofile(bundle_path.."base/song.lua")
        SONG = {}
        dofile(bundle_path..o.class.."/song.lua")
        for k,v in pairs(SONG) do
            song[k] = v
        end
        song.class = o.class
        song.library = o
        o.song = song
    end

    return o
end

function lib:Load(callback)
    if type(callback) == "function" then
        callback(false)
    end
end

return lib
