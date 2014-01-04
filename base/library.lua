local LIB = {}
LIB.type = "library"
LIB.class = "base"

LIB.__objc_classname = "LuaLibrary"

LIB.title = "Library"
LIB.short_title = LIB.title
LIB.icon = "icon.png"
LIB.requires_login = false
LIB.num_login_fields = 0
LIB.song = nil
LIB.color = {0,0,0}
LIB.background_color = {0,0,0}

--LIB.directory_names = nil

function LIB:new(o)
    o = o or {}
    setmetatable(o, {__index=self})
    o.super = self

    --o.directories = {}
    if o.class then
        --song
        local song = dofile(bundle_path.."base/song.lua")
        local path = bundle_path..o.class.."/song.lua"
        if io.open(path) then
            local old_song = SONG
            SONG = {}
            dofile(path)
            song = song:new(SONG)
            SONG = old_song
        end

        song.class = o.class
        song.library = o
        o.song = song

        --directory
        local dir = dofile(bundle_path.."base/directory.lua")
        local path = bundle_path..o.class.."/directory.lua"
        if io.open(path) then
            local old_dir = DIR
            DIR = {}
            dofile(path)
            dir = dir:new(DIR)
            DIR = old_dir
        end
        dir.class = o.class
        dir.library = o
        o.directory = dir

        --just in case
        o.library = o
    end

    return o
end

function LIB:Search(query, callback, search)
    if type(search.Search) == "function" then
        search:Search(query, callback)
    else
        callback{}
    end
end

function LIB:Load(callback)
    if type(callback) == "function" then
        callback(false)
    end
end

LIB.InsertDirectory = __insert_directory_into_library
LIB.GetSavedDirectories = __get_saved_directories
LIB.save = __save_library

return LIB
