--gets a table of whatever is in the current directory
--and returns a list separated by commas up until num
function f(num)
    local d = dir(".")
    local result = ""
    local i = 0
    for k,v in next, d do
    	result = result..v..", "
    	i = i + 1
    	if i == num then
    		break
    	end
    end
    return result
end