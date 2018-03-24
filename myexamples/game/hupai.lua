-- 平胡
-- 同广东麻将平胡，需缺门
local function CheckPh_SC( userPai )  
  if CheckPH(userPai) == true then
    return true
  else
    return false
  end
end

-- 检测平胡
local function CheckPH(userPai)
  -- 拷贝数组
  local t_pai = CopyPai(userPai)

  -- 删除将牌
  Deletejiang(t_pai)

  -- 保证只有一组将牌被删除,多组则返回
  if #t_pai ~= ( #userPai - 2 )  then return false end

  -- --检查剩下的牌是否只由顺子组成
  local sort_pai = SortByType(t_pai)
  for i = 1,#sort_pai["My"] do
    if #sort_pai["My"][i] ~= 0 then
      if CheckShun(sort_pai["My"][i],1,#sort_pai["My"][i]) == false then return false end
    end
  end

  return true
end

--复制一副牌并返回
--提示：由于lua传递table时是传递引用，所以在函数内部修改table会影响到外部的table，因此用此函数拷贝一份table
local function CopyPai(userPai)
  local t_pai = {}
  for i = 1,#userPai do
    table.insert(t_pai,userPai[i])
  end
  return t_pai
end


-- 删除传进来的牌中的将牌
-- 仅用于删除 平胡或碰碰胡中的将牌 如 11 11 11 12 12 12 13 13 13 14 14 14 |(43 43)
-- 可能会删除 (11 11) 12 12 13 13 慎用
local function Deletejiang(userPai)
  local count = 0
  local last_pai = 0
  for i = 1,#userPai do
    local cur_pai = userPai[i]
    if cur_pai ~= last_pai then
      last_pai = cur_pai
      if count == 1 then
        table.remove(userPai,i-1)
        table.remove(userPai,i-2)
      end
      count = 0
    else
      count = count + 1
      last_pai = cur_pai
    end
  end

  -- 检测末尾部分
  if count == 1 then
    table.remove(userPai)
    table.remove(userPai)
  end
end

-- 将用户的牌分成 万，条，饼，风，中发白五组并排序返回
local function SortByType(userPai)
  local sort_pai = {
            ["My"]  =  {
                  [MJ_WAN] = {},
                  [MJ_TIAO] = {},
                  [MJ_BING] = {},
                  [MJ_FENG] = {},
                  [MJ_ZFB] = {}
                  },--手牌组
            ["Chi"] = {
                  [MJ_WAN] = {},
                  [MJ_TIAO] = {},
                  [MJ_BING] = {},
                  [MJ_FENG] = {},
                  [MJ_ZFB] = {}
                  },--吃牌组
            ["Peng"] = {
                  [MJ_WAN] = {},
                  [MJ_TIAO] = {},
                  [MJ_BING] = {},
                  [MJ_FENG] = {},
                  [MJ_ZFB] = {}
                  },--碰牌组
            ["Gang"] = {
                  [MJ_WAN] = {},
                  [MJ_TIAO] = {},
                  [MJ_BING] = {},
                  [MJ_FENG] = {},
                  [MJ_ZFB] = {}
                  },--杠牌组
            ["Ting"] = {
                  [MJ_WAN] = {},
                  [MJ_TIAO] = {},
                  [MJ_BING] = {},
                  [MJ_FENG] = {},
                  [MJ_ZFB] = {}
                  }--听牌组
          }
  for i = 1,#userPai,1 do
    if CheckSinglePaiGroup(userPai[i]) == Pai_My then
      local paiType = CheckSinglePaiType(userPai[i])
      table.insert(sort_pai["My"][paiType],userPai[i])
    end
    if CheckSinglePaiGroup(userPai[i]) == Pai_Chi then
      local paiType = CheckSinglePaiType(userPai[i])
      table.insert(sort_pai["Chi"][paiType],userPai[i])
    end
    if CheckSinglePaiGroup(userPai[i]) == Pai_Peng then
      local paiType = CheckSinglePaiType(userPai[i])
      table.insert(sort_pai["Peng"][paiType],userPai[i])
    end
    if CheckSinglePaiGroup(userPai[i]) == Pai_Gang then
      local paiType = CheckSinglePaiType(userPai[i])
      table.insert(sort_pai["Gang"][paiType],userPai[i])
    end
    if CheckSinglePaiGroup(userPai[i]) == Pai_Ting then
      local paiType = CheckSinglePaiType(userPai[i])
      table.insert(sort_pai["Ting"][paiType],userPai[i])
    end
  end

  for i = 1,5,1 do
    table.sort(sort_pai["My"][i])
    table.sort(sort_pai["Chi"][i])
    table.sort(sort_pai["Peng"][i])
    table.sort(sort_pai["Gang"][i])
    table.sort(sort_pai["Ting"][i])
  end

  return sort_pai
end

--递归检测顺子
--IN：用户手牌，检测起点，待检测牌总数
--OUT：是否全是顺子
local function CheckShun(userPai,i,n)
  -- 小于三张不可能是顺子
  if i > n then return true end
  if n - i < 2 then return false end

  if CheckABCPai(userPai[i],userPai[i+1],userPai[i+2]) and CheckShun(userPai,i+3,n) then
    return true
  else
    return false end
end





-- 大对子
-- 同广东麻将碰碰胡，需缺门
local function CheckDdz_SC( userPai )
  if CheckPPH(userPai) == true then
    return true
  else
    return false
  end
end

-- 检测碰碰胡
local function CheckPPH(userPai)
  -- 无顺子即可
  -- 拷贝数组
  local t_pai = CopyPai(userPai)

  -- 删除将牌
  Deletejiang(t_pai)

  -- 保证只有一组将牌被删除,多组则返回
  if #t_pai ~= ( #userPai - 2 ) then return false end

  local sort_pai = SortByType(t_pai)

  --检查剩下的牌是否只由刻组成
  for i = 1,#sort_pai["My"] do
    if #sort_pai["My"][i] ~= 0 then
      if CheckKe(sort_pai["My"][i],1,#sort_pai["My"][i]) == false then return false end
    end
  end

  return true

end


--递归检测刻子
--IN：用户手牌，检测起点，待检测牌总数
--OUT：是否全是刻子
local function CheckKe(userPai,i,n)
  -- 小于三张不可能刻
  if i > n then return true end
  if n - i < 2 then return false end
  if CheckAAAPai(userPai[i],userPai[i+1],userPai[i+2]) and CheckKe(userPai,i+3,n) then
    return true
  else
    return false end
end


-- 清一色
-- 同广东麻将，自身满足缺门条件
local function CheckQys_SC( userPai )
  if CheckQYS(userPai) == true then
    return true
  else
    return false
  end
end


-- 检测清一色
local function CheckQYS(userPai)
  local paitype = CheckSinglePaiType(userPai[1])
  if paitype == MJ_WAN or paitype == MJ_TIAO or paitype == MJ_BING then
    for i = 2,#userPai do
      local t = CheckSinglePaiType(userPai[i])
      if t ~= paitype then
        return false
      end
    end
  elseif paitype == MJ_FENG or paitype == MJ_ZFB then
    for i = 2,#userPai do
      if CheckSinglePaiType(userPai[i]) ~= MJ_FENG and CheckSinglePaiType(userPai[i]) ~= MJ_ZFB then
        return false
      end
    end
  end

  return true
end


--检查单张牌的类型，万饼筒条
local function CheckSinglePaiType(pai)
  return math.floor(pai%100/10)
end

-- 暗七对
-- 七个对子，不遵循一般胡牌规律,需缺门
local function CheckAqd_SC( userPai )
  local sort_pai = {}
  for i=1,#userPai do
    if CheckSinglePaiGroup(userPai[i]) == Pai_My then
      table.insert(sort_pai,userPai[i])
    end
  end
  table.sort( sort_pai )

  if #sort_pai ~= 14 then
    return false
  end

  local isAQD = true
  for i=1,14 do
    if i % 2 == 1 then
      if sort_pai[i] ~=  sort_pai[i+1] then
        isAQD = false
        break
      end
    end
  end

  if isAQD == true then
    return true
  else
    return false
  end
end


-- 清大对
-- 即清一色+大对子
local function CheckQdd_SC( userPai )
  if CheckQys_SC(userPai) and CheckDdz_SC(userPai) then
    return true
  end
  return false
end


local function CheckLqd_SC( userPai )
  if CheckAqd_SC(userPai) == false then
    return false,0
  end

  local num_gen = 0
  local sort_pai = {}
  --取手牌
  for i=1,#userPai do
    if CheckSinglePaiGroup(userPai[i]) == Pai_My then
      table.insert(sort_pai,userPai[i])
    end
  end
  table.sort( sort_pai )

  --双数位与单数位对比（相同则说明两对是相同的）
  for i=1,13 do
    if i%2 == 0 then
      if sort_pai[i] == sort_pai[i+1] then
        num_gen = num_gen + 1 
      end
    end
  end

  if num_gen ~= 0 then
    return true,num_gen
  else
    return false,0
  end
end


-- 清龙七对
-- 清一色+龙七对
-- 返回值同龙七对
local function CheckQlqd_SC( userPai )
  local qys = CheckQys_SC(userPai);
  local lqd,num_gen = CheckLqd_SC(userPai)

  if qys and lqd then
    return true,num_gen
  else
    return false,0
  end
end