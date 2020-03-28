utils = {}
function utils.drawImage(nTerm, imageLoc, x, y, clear)
	clear = clear or false
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
    nTerm.setBackgroundColor(colors.black)
end

function utils.drawOnMonitor(imageLoc, x, y, clear)
    clear = clear or false
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
	nTerm.setBackgroundColor(colors.black)
end

function utils.paintPixel(T,x,y,c)
	T.setCursorPos(x,y)
	T.setBackgroundColor(c)
	T.write(" ")
	T.setBackgroundColor(colors.black)
end
return utils