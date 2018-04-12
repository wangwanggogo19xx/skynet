
local function copy_table(t)
	local h = {}
	for i=1,#t do
		if type(t[i]) == "table" then
			table.insert(h,copy_table(t[i]))
		else
			table.insert(h,t[i])
		end
	end
	return h
end
local function get_first_pos( class )
	local p  = 1
	for i = 1,#class do
		if class[i] ~= 0 then
			break
		end
		p = p + 1
	end	
	if p == 10 then
		return nil
	end
	return p
end


-- 胡牌时必存在一对将牌，删除可能的将牌
function del_jang(class,p)
	-- print(class[p])
	if class[p] >= 2 then
		class[p] = class[p] -2
		return true
	end
	return false
end




local function check_shun( class ,start)
	if start >7 then
		return false
	end
	if class[start]>0 and class[start + 1] >0 and class[start + 2] > 0 then
		class[start] = class[start] - 1
		class[start + 1] = class[start + 1] - 1
		class[start + 2] = class[start + 2] - 1
		return true
	end
	return false
end

local function  check_ke( class,p )
	if class[p] >= 3 then
		class[p] = class[p] - 1
		class[p] = class[p] - 1
		class[p] = class[p] - 1
		return true
	end 
	return false
end

local function check_rest(class)

	local p = get_first_pos(class)
	if p then
		if class[p] < 3 then
			if check_shun(class,p) then
				return check_rest(class)
			end
			return false
		else
			if check_ke(class,p) then
				return check_rest(class)
			end
			return false
		end	
	end
	-- print("ok......")
	return true
end


---坚持特殊牌型（七对）
function check_special(holds)
	local total = 0
	for i = 1,#holds do
		for j=1,#holds[i] do
			total = total + holds[i][j]
			if holds[i][j] % 2~=0 then
				return false
			end
		end
	end
	if total == 14 then
		print("特殊牌型，七对")
		return true
	end
	return false
end




local function huable(holds)	
	if check_special(holds) then
		return true
	end

	local result 
	for i=1,#holds do
		local h  = copy_table(holds)
		if get_first_pos(h[i]) then ---h[i] 花色有牌，可以胡该花色的牌，可以去将
			result = true
			for j=1,#h do
				if i ~= j then
					result = result and check_rest(h[j])
				end
			end
			if  result then
				local t = copy_table(h[i])
				for j=1,#t do
					if del_jang(t,j) then
						-- for k=1,#t do
						-- 	print(t[k],"-----")
						-- end
						if check_rest(t) then
							return true
						end
						t = copy_table(h[i]) 
					end
				end	
			end
		end
	end
	return false
end 

local function get_ting(holds)
	for i =1,3 do
		if get_first_pos(holds[i]) then
			for j=1,9 do
				holds[i][j] = holds[i][j] + 1
				if huable(holds) then
					print("hu",(i -1 )*10 + j)
				else
					print("pass",(i -1 )*10 + j)
				end
				holds[i][j] = holds[i][j] - 1
			end
		end
	end

end







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
		{0,0,2,0,0,0,0,0,0},
		{3,3,3,3,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
	}
	print(huable(h))	
	-- body
end
test_huable()




function test_ting( )
	local h = {
		{2,2,2,2,2,2,1,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
	}	
	get_ting(h)
	-- body
end
test_ting()