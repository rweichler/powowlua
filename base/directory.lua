local dir = {}
dir.type = "directory"
dir.class = "base"

dir.__objc_classname = "LuaDirectory"

dir.library = nil
dir.header = "All Songs"

dir.title = nil
dir.subtitle = nil
dir.icon = nil

local generate_index = function(base)
    return function(self, key)
        if key == "items" and not base[key] then
            local success = __load_items_from_memory(self)
            if success then
                return self.items
            end
        end
        return base[key]
    end
end

function dir:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = generate_index(self)

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
dir.save = __save_directory

return dir
