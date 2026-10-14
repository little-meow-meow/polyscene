
function printf(fmt, ...)
    print(string.format(fmt, ...))
end

function errorf(fmt, ...)
    error(string.format(fmt, ...), 2)
end

---@param haystack string
---@param needle string
---@return number?
function string.lastIndexOf(haystack, needle)
    local found = haystack:reverse():find(needle:reverse(), nil, true)
    if found then
        return haystack:len() - needle:len() - found + 2
    end
end

---Drops everything in the string after the last occurrence of `separator`, including `separator`
---@param haystack string
---@param separator string
---@return string
function string.drop(haystack, separator)
    local lastIndex = haystack:lastIndexOf(separator)
    return haystack:sub(1, (lastIndex or 0) - 1)
end

---Drops everything in the string before the last occurrence of `separator`, including `separator`
---@param haystack any
---@param separator any
function string.pickup(haystack, separator)
    local lastIndex = haystack:lastIndexOf(separator)
    return haystack:sub((lastIndex or 0) + 1)
end

function string.contains(s, sub)
    return string.find(s, sub, 1, true) ~= nil
end

function string.startswith(s, start)
    return string.sub(s, 1, #start) == start
end

function string.endswith(s, ending)
    return ending == "" or string.sub(s, -#ending) == ending
end

function string.replace(s, old, new)
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

math.randomseed(os.time())
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local result, _ = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
    return result
end
