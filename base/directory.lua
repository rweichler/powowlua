local dir = {}
dir.type = "directory"
dir.class = "base"

dir.library = nil
dir.all_songs = false

dir.all_songs_title = "All Songs"
dir.title = nil
dir.subtitle = nil
dir.icon = nil

function dir:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function dir:update(indexes)
    self.container:update(indexes)
end
--[[
--implement this method only if it depends on the contents of LIB:Load
function dir:init(items)
    return items
end
]]
function dir:loaditems(callback)
    callback(nil)
end

function dir:SaveData()
    return self.image_url
end

function dir:LoadData(data)
    self.image_url = data
end

return dir
