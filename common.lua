
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

---Drops everything in the string after the last occurrence of `needle`, including `needle`
---@param haystack string
---@param separator string
---@return string
function string.drop(haystack, separator)
    local lastIndex = haystack:lastIndexOf(separator)
    return haystack:sub(1, (lastIndex or 0) - 1)
end
