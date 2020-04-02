local WinX = {}
local meta = {__index = WinX}

setmetatable(WinX, {
	__call = function (cls, ...)
	  return cls.new(...)
	end,
})

local function p2test(n,src)
	assert(type(n)=="number", "not number from "..src)
	return n~=0 and bit32.band(n,(n-1))==0
end

local function getOverlapRect(x1,y1,w1,h1,x2,y2,w2,h2)
	local xOver = math.max(x1,x2)
	local yOver = math.max(y1,y2)
	local wOver = math.max(0, math.min(x1+w1,x2+w2) - xOver)
	local hOver = math.max(0, math.min(y1+h1,y2+h2) - yOver)
	return xOver,yOver,wOver,hOver
end

function WinX.isWin(p)
	return getmetatable(p) == meta
end

function WinX:containParentPos(px,py)
	return px>=self.x and py>=self.y and px<self.x+self.width and py<self.y+self.height
end

function WinX:equal(W)
	assert(WinX.isWin(W))
	return self.x == W.x and self.y == W.y and self.width == W.width and self.height == W.height and self.visible == W.visible
end

function WinX:setPixelMemory(nX,nY,c)
	assert(type(nX)=="number")
	assert(type(nY)=="number")
	assert(p2test(c,self.name))
	if nX<=self.width and nY<=self.height then
		self.realColor[nX][nY] = c
		if WinX.isWin(self.parent) then
			local px = nX + self.x - 1
			local py = nY + self.y - 1
			self.parent:setPixelMemory(px,py,c)
		end
	end
end

function WinX.new(nm,T,x,y,w,h,ar)
	assert(type(T)=="table")
	assert(type(x)=="number")
	assert(type(y)=="number")
	assert(type(w)=="number")
	assert(type(h)=="number")
	ar = (ar ~= false)
	assert(type(ar)=="boolean")

	local self = setmetatable({}, meta)
	self.name = nm
	self.childs = {}
	self.parent = T
	local winParent = T
	if WinX.isWin(T) then
		table.insert(T.childs,self)
		winParent = T.window
	end
	self.x = x
	self.y = y
	self.curX = 1
	self.curY = 1
	self.width = w
	self.height = h
	self.charData = {}
	self.colorData = {}
	self.realColor = {}
	self.bgColor = colors.black
	self.fgColor = colors.white
	for i=1, w do
		self.charData[i] = {}
		self.colorData[i] = {}
		self.realColor[i] = {}
		for j=1, h do
			self.charData[i][j] = " "
			self.colorData[i][j] = colors.black
			self:setPixelMemory(i,j,colors.black)
		end
	end
	self.visible = true
	self.window = window.create(winParent,x,y,w,h,true)
	self.autoRedraw = ar
	return self
end

function WinX.findInTable(T,s)
	assert(type(T)=="table")
	assert(WinX.isWin(s))
	for k,v in ipairs(T) do
		if WinX.isWin(v) then
			if v:equal(s) then
				return true, k
			end
		end
	end
	return false, nil
end

function WinX:findInTable(T)
	return WinX.findInTable(T,self)
end

function WinX:getColor(sX,sY,nX,nY)
	local ans = {}
	for i=1, nX do
		local rX = sX+i-1
		ans[i] = {}
		for j=1, nY do
			local rY = sY+j-1
			ans[i][j] = self.realColor[rX][rY]
		end
	end
	return ans
end

function WinX:reposition(newX, newY, newWidth, newHeight)
	assert(type(newX)=="number")
	assert(type(newY)=="number")
	newWidth = newWidth or self.width
	newHeight = newHeight or self.height
	assert(type(newWidth)=="number")
	assert(type(newHeight)=="number")

	if newX == self.x and newY == self.y and newWidth == self.width and newHeight == self.height then
		return
	end

	if WinX.isWin(self.parent) then
		self.parent:redraw(self.x,self.y,self.width,self.height)
	end

	self.x = newX
	self.y = newY

	self.width = newWidth
	self.height = newHeight

	if WinX.isWin(self.parent) then
		self.realColor = self.parent:getColor(newX, newY, newWidth, newHeight)
	end

	self.window.reposition(newX, newY, newWidth, newHeight)

	self:setVisible(true)
end

function WinX:getCursorPos()
	return self.curX, self.curY
end

function WinX:setCursorPos(nX, nY)
	assert(type(nX)=="number")
	assert(type(nY)=="number")
	self.curX = nX
	self.curY = nY
	self.window.setCursorPos(nX, nY)
end

function WinX:getBackgroundColor()
	return self.bgColor
end

function WinX:setBackgroundColor(newC)
	assert(p2test(newC,self.name))
	self.bgColor = newC
	self.window.setBackgroundColor(newC)
end

function WinX:getTextColor()
	return self.fgColor
end

function WinX:setTextColor(newC)
	assert(p2test(newC,self.name))
	self.fgColor = newC
	self.window.setTextColor(newC)
end

function WinX:write(S)
	assert(type(S)=="string")
	if self.visible then
		local len = #S
		for i=0, len-1 do
			local nX = self.curX + i
			if nX <= self.width then
				self.charData[nX][self.curY] = S:sub(i+1,i+1)
				self.colorData[nX][self.curY] = self.bgColor
				self:setPixelMemory(nX,self.curY,self.bgColor)
			end
		end
		self.window.write(S)
		self.curX, self.curY = self.window.getCursorPos()
	end
end

function WinX:refreshMemoryFromParent(px,py,c)
	if self:containParentPos(px,py) then
		local sx = px - self.x + 1
		local sy = py - self.y + 1
		self.realColor[sx][sy]=c
		for k,v in ipairs(self.childs) do
			v:refreshMemoryFromParent(sx,sy,c)
		end
	end
end

function WinX:paintPixel(x,y,c,w,retain)
	w = w or " "
	retain = retain or false
	local oldColor = self.bgColor
	self:setCursorPos(x,y)
	self:setBackgroundColor(c)
	if x<=self.width and y<=self.height then
		if self.realColor[x][y]~=c and self.visible then
			self:write(w)
			self:setPixelMemory(x,y,c)
			for k,v in ipairs(self.childs) do
				v:refreshMemoryFromParent(x,y,c)
			end
		end
		self.colorData[x][y]=c
	end
	if not retain then
		self:setBackgroundColor(oldColor)
	end
end

function WinX:drawImage(imageLoc, x, y, clear, retain)
	clear = clear or false
	retain = retain or false
	local img = paintutils.loadImage(imageLoc)
    x = x-1
    y = y-1
    if clear then
        self:clear()
    end
    for i=1, #img do
        local imgL = img[i]
		for j=1, #imgL do
			self:paintPixel(j+x, i+y, imgL[j], " ", retain)
        end
	end
end

function WinX:getPosition()
	return self.x, self.y
end

function WinX:getSize()
	return self.width, self.height
end

function WinX:drawWindow(cborder, cfill, retain)
	cborder = cborder or colors.white
	cfill = cfill or colors.black
	retain = retain or false
	local wx, wy = self:getSize()
	for i = 1, wy do
		for j = 1, wx do
			local hborder = i==1 or i==wy
			local vborder = j==1 or j==wx
			if hborder or vborder then
				self:paintPixel(j,i,cborder," ",retain)
			else
				self:paintPixel(j,i,cfill," ",retain)
			end
		end
	end
end

function WinX:clear()
	local wx, wy = self:getSize()
	for i = 1, wx do
		for j = 1, wy do
			self:paintPixel(i,j,self.bgColor," ",true)
		end
	end
end

function WinX:clearLine()
	local wx, wy = self:getSize()
	for i = 1, wx do
		self:paintPixel(i,self.curY,self.bgColor," ",true)
	end
end

function WinX:redraw(sX,sY,nX,nY)
	if self.visible then
		sX = sX or 1
		sY = sY or 1
		nX = nX or self.width
		nY = nY or self.height
		assert(type(sX)=="number")
		assert(type(sY)=="number")
		assert(type(nX)=="number")
		assert(type(nY)=="number")

		for i = sX, sX+nX-1 do
			for j = sY, sY+nY-1 do
				local ch = self.charData[i][j]
				self:paintPixel(i,j,self.colorData[i][j],ch,true)
			end
		end

		for k,v in ipairs(self.childs) do
			if v.autoRedraw then
				local xo,yo,wo,ho = getOverlapRect(sX,sY,nX,nY,v.x,v.y,v.width,v.height)
				if wo>0 and ho>0 then
					xo = xo-v.x+1
					yo = yo-v.y+1
					v:redraw(xo,yo,wo,ho)
				end
			end
		end
	end
end

function WinX:setVisible(vis)
	assert(type(vis)=="boolean")
	if self.visible == vis then
		return
	end
	self.visible = vis
	if vis then
		if WinX.isWin(self.parent) and self.parent.vis then
			self:redraw()
		elseif not WinX.isWin(self.parent) then
			self:redraw()
		end
	else
		for k,v in ipairs(self.childs) do
			v:setVisible(false)
		end
		if WinX.isWin(self.parent) then
			self.parent:redraw(self.x,self.y,self.width,self.height)
		end
	end
end

return WinX