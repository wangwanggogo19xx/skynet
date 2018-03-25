local id_mgr  = {}

function id_mgr:init()
	self.id = {}
	for i = 1,100 do
		self.i[i] = false
	end
end

function id_mgr:gen_id()
	for i=1,100 do
		if not self.id[i] then
			self.id[i]  = true
			return i
	end
	return false


end

return id_mgr