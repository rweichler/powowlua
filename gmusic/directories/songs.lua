DIR.header = "All Songs"
DIR.title = "Songs"
DIR.icon = "BarSongs.png"

function DIR:init(songs)
    local start = os.clock()
    --alphabetize that shit
    table.sort(songs, function(a, b)
        return a.info.titleNorm < b.info.titleNorm
    end)

    local result = {}

    for k,song in pairs(songs) do
        table.insert(result, song)
    end
    return result
end

local function comp(a,b)
    return string.lower(a.title) < string.lower(b.title)
end

function DIR:add(song)
    local index = table.bininsert(self.items, song, comp)
    table.insert(self.items, index, song)
end

function DIR:remove(song)
    local index = table.bininsert(self.items, song, comp)
    if self.items[index].id == song.id then
        table.remove(self.items, index)
        return true
    end
    return false
end
