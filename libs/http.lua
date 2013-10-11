
local http = {}

local session = {}
http.session = session

session.MALFORMED_RESPONSE = 23894 --random ass number

function session:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    o.cookies = {}
    o.headers = {}

    return o
end

function session:post(...)
    return self:request("POST", ...)
end

function session:get(...)
    return self:request("GET", ...)
end

function session:head(...)
    return self:request("HEAD", ...)
end

function session:put(...)
    return self:request("PUT", ...)
end

function session:patch(...)
    return self:request("PATCH", ...)
end

function session:delete(...)
    return self:request("DELETE", ...)
end

return http