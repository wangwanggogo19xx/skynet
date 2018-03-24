Rectangle = {area = 0, length = 0, breadth = 0}

-- 派生类的方法 new
function Rectangle:new (length,breadth)
  local o =  {
		length = length or 0,
	 	breadth = breadth or 0,
	  	area = length*breadth
	}
  setmetatable(o, self)
  self.__index = self

  
  return o
end

-- 派生类的方法 printArea
function Rectangle:printArea ()
  print("矩形面积为 ",self.area)
end

r= Rectangle:new(1,2)

print(r:printArea())

b = Rectangle:new(3,6)
print(b:printArea())

print(r:printArea())