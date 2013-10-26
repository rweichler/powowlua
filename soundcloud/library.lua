local path = bundle_path.."soundcloud/key.lua"
if not io.open(path) and not private_key then
    error('soundcloud private key missing (put "return \'KEY_HERE\'" in key.lua)')
end
local private_key = private_key or dofile(path)

--actual class
LIB.title = "SoundCloud"
LIB.short_title = "SCloud"
LIB.color = {255, 77, 25}

LIB.search_order = {
    "tracks",
    "users",
    "sets",
}


