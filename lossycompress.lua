-- inspired by gandalf3
math.randomseed(os.clock())

function samp(...)
    local a = {...}
    return a[math.random(1, #a)]
end

function rep(str, pos, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function compress(s)
    s = s:gsub("u", "o")
    s = s:gsub("you", "u")
    s = s:gsub("es", "z")

    s = s:gsub("ate", "8")
    s = s:gsub("one", "1")
    s = s:gsub("won", "1")
    s = s:gsub("to", "2")
    s = s:gsub("too", "2")
    s = s:gsub("two", "2")
    s = s:gsub("tu", "2")
    s = s:gsub("for", "4")
    s = s:gsub("four", "4")

    s = s:gsub("s", "z")
    s = s:gsub("e[aeiou]", "e")
    s = s:gsub("e[. ]", " ")
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
    s = s:gsub("ss", "s")
    s = s:gsub("tt", "t")
    s = s:lower()
    return s
end

function decompress(s)
    for i = 1, string.len(s) do
        local c = string.sub(s, i, i)
        if c == "o" then
            s = rep(s, i, samp("o", "u"))
        end
        if c == "z" then
            s = rep(s, i, samp("z", "s"))
        end
    end
    s = s:gsub(" th ", " teh ")
    s = s:gsub("[;,.]","")
    return s
end

function getcontents(filename)
    local f = io.open(filename, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

local s = compress(getcontents("test.txt"))
print(s)
print(decompress(s))
