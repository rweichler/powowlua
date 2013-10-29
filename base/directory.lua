local dir = {}
dir.type = "directory"
dir.class = "base"

dir.library = nil
dir.style = "basic"
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

function dir:init(items)
    return items
end

function dir:loaditems(callback)
    callback(nil)
end

--[[
--DEPRECATED!
function dir:TitleAtIndex(index)
    local obj = self.items[index]
    return obj.title
end

function dir:SubtitleAtIndex(index)
    local obj = self.items[index]
    return obj.subtitle
end
]]
return dir
