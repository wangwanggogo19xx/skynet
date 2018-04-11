local function check_Hu(hold)
	local t = copy(hold)

	for i = 1,9 do

		hold[i] = hold[i] + 1

		del_jang(t)
		check_shun()



		hold[i] = hold[i] - 1
	end


end 

local function check_shun(hold)
	for i =1,#hold then
		if hold[i] > 0 then
			if (i>1 or i<9) and hold[i-1] == 0 and hold[i+1] ==0  then
				return false
			end
		end
	end

end


local function check_ting()

end


local function copy(table)
	local t = {}
	for i=1,#table do
		table.insert(t,table[i])
	end
	return t
end



-- 胡牌时必存在一对将牌，删除可能的将牌
function del_jang(hold)
	for i=1,#hold do
		if hold[i] >=2 then
			hold[i] = hold[i] -2
			return
		end
	end
end

local a = {2,1,1}
del_jang(a)
