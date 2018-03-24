function table_sum(table)
	local sum = 0
	for i=1,#table do
		sum  = sum + table[i]
	end
	return sum
end