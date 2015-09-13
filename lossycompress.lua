-- inspired by gandalf3
math.randomseed(os.clock())

function samp(...)
    local a = {...}
    return a[math.random(1, #a)]
end

function rep(str, pos, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function keyn(T) -- number of keys in a table
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function serialize(T)
    o = "{"
    for k,v in pairs(T) do
        o = o .. string.char(v) .. k .. ","
    end
    o = o:gsub(",$", "") .. "}"
    return o
end

function getcontents(filename)
    local f = io.open(filename, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function compress(s)
    local vowels = {"a", "e", "i", "o", "u"}
    local consonents = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"}
    s = s:lower()

    s = s:gsub("[;,.'\"]","")
    s = s:gsub("you", "u")
    s = s:gsub("[^ ]u[^ ]", "o")
    s = s:gsub("es", "z")
    s = s:gsub("see", "c")
    s = s:gsub("and", "&")
    s = s:gsub("please", "plz") -- really specific, but couldn't think of any other case where 'ease' can be turned into just 'z'

    s = s:gsub("ate", "8")
    s = s:gsub("eat", "8")
    s = s:gsub("one", "1")
    s = s:gsub("won", "1")
    s = s:gsub("to", "2")
    s = s:gsub("too", "2")
    s = s:gsub("two", "2")
    s = s:gsub("tu", "2")
    s = s:gsub("for", "4")
    s = s:gsub("four", "4")

    s = s:gsub("s", "z")
    s = s:gsub("e["..table.concat(vowels).."]", "e")
    s = s:gsub("e ", " ")
    s = s:gsub("bb", "b")
    s = s:gsub("cc", "c")
    s = s:gsub("dd", "d")
    s = s:gsub("ee", "e")
    s = s:gsub("ff", "f")
    s = s:gsub("gg", "g")
    s = s:gsub("ll", "l")
    s = s:gsub("mm", "m")
    s = s:gsub("nn", "n")
    s = s:gsub("oo", "o")
    s = s:gsub("pp", "p")
    s = s:gsub("ss", "s")
    s = s:gsub("tt", "t")
    s = s:gsub("zz", "z") -- can sometimes happen when a double s is turned into a double z
    s = s:gsub("gh", "g")

    --[[
    for i = 1, string.len(s) do
        local c = string.sub(s, i, i)
        if c == " " then
            s = rep(s, i, samp(" ", " ", " ", " ", " ", ""))
        end
    end
    ]]--
    return s
end

function decompress(s)
    for i = 1, string.len(s) do
        local c = string.sub(s, i, i)
        if c == "o" then
            s = rep(s, i, samp("o", "u"))
        end
        if c == "z" then
            s = rep(s, i, samp("z", "s", "es"))
        end
    end
    s = s:gsub(" th ", " teh ")
    return s
end

function legit_compression(s)
    -- actually (somewhat) useful.
    -- uses slightly lossy lzw compression
    -- TODO: expand on 255 char
    local d = {}

    for i = 1, string.len(s) do -- first pass
        local c = string.sub(s, i, i)
        if d[c] == nil then
            d[c] = keyn(d)
        end
    end

    local f = io.open("out.bin", "wb")
    for i = 1, string.len(s) do -- compression
        local c = string.sub(s, i, i)
        local nc = string.sub(s, i + 1, i + 1)
        f:write(string.char(d[c]))
        if d[c .. nc] == nil then
            d[c .. nc] = keyn(d)
        end
    end
    f:write(serialize(d)) -- write the dict
    f:close()
end

function legit_decompression(s)
    local ds = (function() -- parse out dictionary string
        for i=string.len(s), 0, -1 do
            if string.sub(s, i, i) == '{' then
                return string.sub(s, i, string.len(s))
            end
        end
    end)()
    local d = {}
    o = ""
    for w in ds:gmatch('([^,]+)') do
        d[w:sub(1, 1)] = w:sub(2, w:len())
    end

    for i = 1, string.len(s) do
        local c = string.sub(s, i, i)
        if d[c] ~= nil then
            o = o .. d[c]
        end
    end
    print("-----")
    print(o)
    print("-----")
end

local orig = getcontents("test.txt")
local s = compress(orig)
legit_compression(s)
legit_decompression(getcontents("out.bin"))
print(s)
print(decompress(s))

-- print some stats
savings = string.len(orig) - string.len(s)
print("saved ".. savings .." chars (".. math.floor(savings / string.len(orig) * 100 + 0.5) .."%)")
