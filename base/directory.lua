local DIR = {}
DIR.type = "directory"
DIR.class = "base"

DIR.__objc_classname = "LuaDirectory"

DIR.library = nil
DIR.header = "All Songs"

DIR.title = nil
DIR.subtitle = nil
DIR.icon = nil

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

function DIR:new(o)
    o = o or {}
    setmetatable(o, {__index=generate_index(self)})
    o.super = self

    return o
end

function DIR:loaditems(callback)
    callback(nil)
end

function DIR:SaveData()
    return self.image_url
end

function DIR:LoadData(data)
    self.image_url = data
end

--implemented in C
DIR.save = __save_directory
DIR.load = __load_items_from_memory

return DIR
