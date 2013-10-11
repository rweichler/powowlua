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

    o.items = o.items or {}

    return o
end

function dir:update(indexes)
    self.container:update(indexes)
end

function dir:init(callback)
    if not self.library then
        callback(false)
    end
end

function dir:TitleAtIndex(index)
    local obj = self.items[index]
    if obj.type == "song" then
        return obj:Title()
    elseif obj.type == "directory" then
        return obj.title
    end
    return nil
end

function dir:SubtitleAtIndex(index)
    local obj = self.items[index]
    if obj.type == "song" then
        return obj:Artist().." - "..obj:Album()
    elseif obj.type == "directory" then
        return obj.subtitle
    end
    return nil
end
return dir
