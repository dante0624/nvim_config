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

--[[  Args:
    tbl is an array table
    function is a func(any) which returns a boolean
filter_array() returns an array table:
    The returned_tbl is a subset of tbl, such that each value in 
    returned_tbl returns true when func(value) is called.
    The returned_tbl is a shallow copy of tbl!
    tbl[key] and returned_tbl[key] are the same objects ]]-- 
function M.filter_array(tbl, func)
    local filtered_tbl = {}
    for _, value in ipairs(tbl) do
        if func(value) then
           table.insert(filtered_tbl, value)
        end
    end
    return filtered_tbl
end

return M
