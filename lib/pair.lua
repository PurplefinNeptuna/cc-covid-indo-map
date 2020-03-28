Pair = {}
local meta = {__index = Pair}

setmetatable(Pair, {
	__call = function (cls, ...)
	  return cls.new(...)
	end,
})

function Pair.new(x,y)
	assert(type(x)=="number")
	assert(type(y)=="number")
	local self = setmetatable({}, meta)
	self.x = x
	self.y = y
	return self
end

function Pair.isPair(p)
	return getmetatable(p) == meta
end

function Pair.searchPair(T,s)
	assert(type(T)=="table")
	assert(Pair.isPair(s))
	for k,v in ipairs(T) do
		if Pair.isPair(v) then
			if v:equal(s) then
				return true, k
			end
		end
	end
	return false, nil
end

function Pair:equal(b)
	assert(Pair.isPair(b))
	return self.x == b.x and self.y == b.y
end
return Pair