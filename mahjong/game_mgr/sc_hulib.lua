function copy_table(t)
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

local M = {}
local has_shun = false

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

		has_shun = true
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




function che_qingyise(holds)
	local count = 0
	for i=1,#holds do
		if get_first_pos(holds[i]) then 
			count = count + 1 
		end
	end
	if  count == 1 then
		return true
	end
	return false
end



function M.huable(holds)
	has_shun = false	
	local result,types

	if check_special(holds) then
		-- return true,{qidui=true,qingyise = che_qingyise(holds)}
		return true,{qidui=true}
	end

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
				
				local other_has_shun = has_shun --其他花色是否有顺

				local t = copy_table(h[i])
				for j=1,#t do
					if del_jang(t,j) then
						has_shun = false

						-- has_shun = false
						-- for k=1,#t do
						-- 	print(t[k],"-----")
						-- end
						if check_rest(t) then

							if has_shun or other_has_shun then
								print(has_shun,other_has_shun,"==============")
								-- return true,{pinghu=true,qingyise = che_qingyise(holds)}
								return true,{pinghu=true}
							else
								-- return true,{pongponghu=true,qingyise = che_qingyise(holds)}
								return true,{pongponghu=true}
							end


							-- return true
						end
						t = copy_table(h[i]) 
					end
				end	
			end
		end
	end
	return false
end 



function M.get_ting(holds)
	local temp = {}
	for i =1,3 do
		if get_first_pos(holds[i]) then
			for j=1,9 do
				holds[i][j] = holds[i][j] + 1
				local huable,types = M.huable(holds)
				if huable then
					temp[(i -1 )*10 + j] = types
				else
				end
				holds[i][j] = holds[i][j] - 1
			end
		end
	end
	return temp

end

return M
