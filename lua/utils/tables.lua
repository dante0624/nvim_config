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

return M
