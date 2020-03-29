local utils = {}
function utils.drawImage(nTerm, imageLoc, x, y, clear, retain)
	clear = clear or false
	retain = retain or false
	local img = paintutils.loadImage(imageLoc)
    x = x-1
    y = y-1
    if clear then
        nTerm.clear()
    end
    for i=1, #img do
        local imgL = img[i]
        for j=1, #imgL do
            nTerm.setCursorPos(j+x,i+y)
            nTerm.setBackgroundColor(imgL[j])
            nTerm.write(" ")
        end
	end
	if not retain then
		nTerm.setBackgroundColor(colors.black)
	end
end

function utils.drawOnMonitor(imageLoc, x, y, clear, retain)
	clear = clear or false
	retain = retain or false
    x = x-1
    y = y-1
    local img = paintutils.loadImage(imageLoc)
    --t = term.current()
    local nTerm = peripheral.find('monitor')
    if clear then
        nTerm.clear()
    end
    --term.redirect(nTerm)
    for i=1, #img do
        local imgL = img[i]
        for j=1, #imgL do
            nTerm.setCursorPos(j+x,i+y)
            nTerm.setBackgroundColor(imgL[j])
            nTerm.write(" ")
        end
    end
	--term.redirect(t)
	if not retain then
		nTerm.setBackgroundColor(colors.black)
	end
end

function utils.paintPixel(T,x,y,c,retain)
	retain = retain or false
	T.setCursorPos(x,y)
	T.setBackgroundColor(c)
	T.write(" ")
	if not retain then
		T.setBackgroundColor(colors.black)
	end
end

function utils.drawWindow(W, cborder, cfill, retain)
	cborder = cborder or colors.white
	cfill = cfill or colors.black
	retain = retain or false
	local wx, wy = W.getSize()
	for i = 1, wy do
		for j = 1, wx do
			local hborder = i==1 or i==wy
			local vborder = j==1 or j==wx
			if hborder or vborder then
				utils.paintPixel(W,j,i,cborder,retain)
			else
				utils.paintPixel(W,j,i,cfill,retain)
			end
		end
	end
end

function utils.stringMiddle(S,w)
	local len = #S
	local mid = math.floor((w-len)/2)
	if mid < 0 then
		return nil
	end

	local ans = string.rep(" ", mid)..S
	return ans
end

return utils