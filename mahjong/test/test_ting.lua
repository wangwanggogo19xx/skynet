package.path = package.path ..';../game_mgr/sc_hulib.lua';


local hu = require "sc_hulib"



function test_check_rest( )
	local holds_1 = {0,4,2,2,1,0,0,0,0}
	print(check_rest(holds_1))
	-- a = "s"
	print(type(holds_1) == "table")
end

function test_table_copy()
	local t1 = {1,2,3}
	local t1_copy = copy_table(t1)
	for i=1,#t1_copy do
		print(t1_copy[i])
	end

	local t2 = {
		{1,2,3},
		{4,5,6},
		{7,8,9}
	}
	local t2_copy = copy_table(t2)
	for i=1,#t2_copy do
		for j=1,#t2_copy[i] do
			print(t2_copy[i][j])
		end
	end
end


function test_huable( )
	local h = {
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
	}
	-- print(huable(h))
	--  h = {
	-- 	{2,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0},
	-- }
	-- print(huable(h))
	h = {
		{0,0,0,0,0,0,0,0,0},
		{0,0,2,0,0,0,0,2,0},
		{0,0,0,0,0,0,0,0,0},
	}

	local huable,types = hu.huable(h)
	print(huable)
	if type(types) == "table" then
		for k,v in pairs(types) do
			print(k,v)
		end
	end
	-- body
end
-- test_huable()




function test_ting( )
	local h = {
		{2,2,2,2,2,3,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
	}
	h = {
		{2,2,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
	}	
	local t = hu.get_ting(h)
	for k,v in pairs(t) do
		print(k)
		for m,n in pairs(v) do
			print(m,n)
		end
	end

	-- print(t[1])
	-- for i=1,#t do 
	-- 	print(t[i])

	-- end
	-- body
end
test_ting()
-- function test()
-- 	return true,1
-- 	-- body
-- end
-- a = test()
-- print(a)