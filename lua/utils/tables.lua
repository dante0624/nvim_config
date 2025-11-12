local M = {}

-- Useful for hashing reason
-- With this "set", you can check if an element is "in" in O(1)
-- Can write code like "if set[x] then .."
function M.array_to_set(array)
	local set = {}
	for _,x in ipairs(array) do
		set[x] = 1
	end

	return set
end

--- Apply a filter to all elements of an array
--- @param tbl table an array table
--- @param filter_func fun(value: any):boolean the filter function
--- @return table filtered_tbl a shallow copy tbl, after flitering
function M.filter_array(tbl, filter_func)
    local filtered_tbl = {}
    for _, value in ipairs(tbl) do
        if filter_func(value) then
           table.insert(filtered_tbl, value)
        end
    end
    return filtered_tbl
end

--- Merge two hash-set tables, adding all their keys and values
--- @param first_tbl table
--- @param second_tbl table
--- @return table merged
function M.merge_tables(first_tbl, second_tbl)
	local merged = {}
	for key, value in pairs(first_tbl) do
		merged[key] = value
	end
	for key, value in pairs(second_tbl) do
		merged[key] = value
	end
	return merged
end

return M
