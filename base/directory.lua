local dir = {}
dir.type = "directory"
dir.class = "base"

dir.library = nil
dir.header = "All Songs"

dir.title = nil
dir.subtitle = nil
dir.icon = nil

function dir:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = function(slf, key)
        if key == "items" and not self[key] then
            local items = __load_items_from_memory(slf)
            slf.items = items
            return items
        end
        return self[key]
    end

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

--implemented in C
dir.save = __save_directory --TODO implement this

return dir
