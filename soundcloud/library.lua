--actual class
LIB.title = "SoundCloud"
LIB.short_title = "SCloud"
LIB.color = {255, 77, 25}

local function generate_create_dir(base)
    return function (dir, path, kind, env_var)
        if type(dir) == "string" then
            env_var = kind
            kind = path
            path = dir
            dir = base:new()
        end
        if not kind then
            kind = "directories"
            env_var = "DIR"
        end
        if not env_var then
            env_var = string.upper(kind)
        end
        if path then
            path = bundle_path..self.class.."/"..kind.."/"..path
            local env = {}
            env[env_var] = dir
            setmetatable(env, {__index=_ENV})
            loadfile(path, "bt", env)()
        end
        return dir
    end
end

function LIB:Load(callback)
    local create_dir = generate_create_dir(self.directory)
    local search = create_dir()
    search.style = "search"
    search.title = "Search"
    search.icon = "magnifier@2x.png"
    search.items = {
        create_dir("tracks.lua", "search"),
        create_dir("users.lua", "search"),
        create_dir("sets.lua", "search")
    }
    callback{search}
end

