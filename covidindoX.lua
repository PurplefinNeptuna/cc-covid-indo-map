--Data provided by Kawal Corona API
local utils = require('lib/utils')
local json = require('lib/json')
local tableExt = require('lib/tableExt')
local WinX = require('lib/WinX')

--catch argument
local logMode = false
local redGradientMode = false
local ops = utils.getOptions(arg)
--print(tableExt.dump(ops))
if #ops > 0 then
	for k,v in ipairs(ops) do
		if v == "log" or v=="l" then
			logMode = true
		elseif v == "red" or v=="r" then
			redGradientMode = true
		end
	end
end

--code to color
local function getColor(n)
	local ans = colors.white
	if n > 5/6 then
		ans = colors.purple
	elseif n > 4/6 then
		ans = colors.red
	elseif n > 3/6 then
		ans = colors.orange
	elseif n > 2/6 then
		ans = colors.green
	elseif n > 1/6 then
		ans = colors.lime
	else
		ans = colors.yellow
	end
	return ans
end

--get and clear monitor
local m = peripheral.wrap('left')
m.setTextScale(0.5)
m.clear()

--get current terminal
local t = term.current()

--enable red gradient mode
local function setColor(mode)
	if mode then
		m.setPaletteColor(colors.yellow, 0xebcdc6)
		m.setPaletteColor(colors.lime, 0xe3ab9e)
		m.setPaletteColor(colors.green, 0xd88877)
		m.setPaletteColor(colors.orange, 0xc96651)
		m.setPaletteColor(colors.red, 0xb8412e)
		m.setPaletteColor(colors.purple, 0xa50a0a)
	else
		m.setPaletteColor(colors.yellow, 0xDEDE6C)
		m.setPaletteColor(colors.lime, 0x7FCC19)
		m.setPaletteColor(colors.green, 0x57A64E)
		m.setPaletteColor(colors.orange, 0xF2B233)
		m.setPaletteColor(colors.red, 0xCC4C4C)
		m.setPaletteColor(colors.purple, 0x191919)
	end
end
setColor(redGradientMode)

--read mapdata
local data = fs.open("mapindo.json","r")
local cvdata = data.readAll()
data.close()
local mapData = json.decode(cvdata)

--read code to region name
data = fs.open("c2nindo.json","r")
cvdata = data.readAll()
data.close()
local c2name = json.decode(cvdata)

--build windows
local titleWindow = window.create(m,2,2,97,6)
local dataWindow = window.create(m,1,8,33,1)
local creatorWindow = window.create(m,100,2,20,3)
local timeWindow = window.create(m,92,8,30,1)

local mapWindow = WinX("mapWindow",m,1,9,121,44)
local legendWindow = WinX("legendWindow",mapWindow,6,32,14,10)
local totalWindow = WinX("totalWindow",mapWindow,102,6,19,6)
local popupWindow = WinX("popupWindow",mapWindow,1,1,27,6,false)

--read timestamp
local tstampfile = fs.open("tsindo","r")
local tstamp = tonumber(tstampfile.readAll())
tstampfile.close()
local tstampnow = os.time(os.date("*t"))

local totalData
local function updateData()
    print("Updating data...")
	local getdata = http.get("https://api.kawalcorona.com/indonesia/provinsi")
    cvdata = getdata.readAll()

	local savedata = fs.open("dataindo.json","w")
    savedata.write(cvdata)
    savedata.close()

	getdata = http.get("https://api.kawalcorona.com/indonesia")
    totalData = getdata.readAll()

	savedata = fs.open("indototal.json","w")
    savedata.write(totalData)
    savedata.close()

	tstampnow = os.time(os.date("*t"))
	tstamp = tstampnow

	savedata = fs.open("tsindo","w")
    savedata.write(tstampnow)
    savedata.close()
end

if tstampnow-tstamp >= 600 then
	--update saved data
	updateData()
else
    --read saved data
    print("Opening data...")
    data = fs.open("dataindo.json","r")
    cvdata = data.readAll()
    data.close()

	data = fs.open("indototal.json","r")
    totalData = data.readAll()
    data.close()
end

local function drawLegend()
	legendWindow:drawWindow(colors.lightBlue, colors.lightGray)
	totalWindow:drawWindow(colors.lightBlue, colors.lightGray)
	legendWindow:paintPixel(4,3,colors.white)
	legendWindow:paintPixel(4,4,colors.yellow)
	legendWindow:paintPixel(4,5,colors.lime)
	legendWindow:paintPixel(4,6,colors.green)
	legendWindow:paintPixel(4,7,colors.orange)
	legendWindow:paintPixel(4,8,colors.red)
	legendWindow:paintPixel(4,9,colors.purple)

	legendWindow:setTextColor(colors.black)
	legendWindow:setBackgroundColor(colors.lightGray)
	legendWindow:setCursorPos(2,2)
	legendWindow:write("Color Scale:")
	legendWindow:setCursorPos(6,3)
	legendWindow:write("= 0.00")
	legendWindow:setCursorPos(6,4)
	legendWindow:write("> 0.00")
	legendWindow:setCursorPos(6,5)
	legendWindow:write("> 0.17")
	legendWindow:setCursorPos(6,6)
	legendWindow:write("> 0.33")
	legendWindow:setCursorPos(6,7)
	legendWindow:write("> 0.50")
	legendWindow:setCursorPos(6,8)
	legendWindow:write("> 0.67")
	legendWindow:setCursorPos(6,9)
	legendWindow:write("> 0.83")

	totalWindow:setTextColor(colors.black)
	totalWindow:setBackgroundColor(colors.lightGray)
	totalWindow:setCursorPos(2,2)
	totalWindow:write("   Total Cases")
	totalWindow:setCursorPos(2,3)
	totalWindow:write("Confirmed: "..totalData.positif)
	totalWindow:setCursorPos(2,4)
	totalWindow:write("Deaths   : "..totalData.meninggal)
	totalWindow:setCursorPos(2,5)
	totalWindow:write("Recovered: "..totalData.sembuh)
end

local function drawMap()
	--paint map
	mapWindow:drawImage('indo',1,1,true)
end
drawMap()

local function drawHeader()
	--paint title
	utils.drawImage(titleWindow,'titleindo',1,1,true)
	creatorWindow.write("by Purplefin Neptuna")
	creatorWindow.setCursorPos(1,3)
	creatorWindow.write("WinX Mode")
	dataWindow.write("Data provided by Kawal Corona API")
	timeWindow.write(os.date("Last Update: %x %X",tstamp))
end
drawHeader()

local cv = {}
local codeToColor = {}
local maxCase = 0
local function parseData()
	--process json
	local cvdata = json.decode(cvdata)
	print("Got "..tableExt.length(cvdata).." confirmed regions")

	-- CV is region based covid cv[region_code]
	local cvlen = tableExt.length(cvdata)
	for i = 1, cvlen, 1 do
    	local region = cvdata[i].attributes
    	cv[region.Kode_Provi] = {
        	["death"] = region.Kasus_Meni,
        	["recov"] = region.Kasus_Semb,
        	["confi"] = region.Kasus_Posi
    	}
	end

	--get max case
	for k,v in pairs(cv) do
		maxCase = math.max(v.confi,maxCase)
	end

	--process total json
	totalData = json.decode(totalData)
	totalData = totalData[1]
	totalData.positif = string.gsub(totalData.positif, ',', '')
	totalData.sembuh = string.gsub(totalData.sembuh, ',', '')
	totalData.meninggal = string.gsub(totalData.meninggal, ',', '')
end
parseData()

local function calculateData()
	--calculate heat level per region
	for k,v in pairs(cv) do
		if logMode then
			codeToColor[k] = getColor(math.log(v.confi)/math.log(maxCase))
		else
			codeToColor[k] = getColor(v.confi/maxCase)
		end
	end
end
calculateData()

--draw popup window for region data
local popupDrawn = false
local function drawPopup(cid, x, y)
	local rx = x
	local ry = y
	local nx = x
	local ny = y

	local popName = c2name[tostring(cid)]
	local numPos
	local numDed
	local numRec
	if cv[cid] ~= nil then
		numPos = cv[cid].confi
		numDed = cv[cid].death
		numRec = cv[cid].recov
	else
		numPos = 0
		numDed = 0
		numRec = 0
	end
	local popPos = "Confirmed: "..numPos
	local popDed = "Deaths   : "..numDed
	local popRec = "Recovered: "..numRec

	local maxL = math.max(#popName, #popPos, #popDed, #popRec)
	local maxD = math.max(#popPos, #popDed, #popRec)
	popPos = popPos..string.rep(" ",maxD-#popPos)
	popDed = popDed..string.rep(" ",maxD-#popDed)
	popRec = popRec..string.rep(" ",maxD-#popRec)
	maxL = maxL

	if rx > 60 then
		nx = nx - maxL - 2
	else
		nx = nx + 1
	end

	if ry > 22 then
		ny = ny - 6
	else
		ny = ny + 1
	end

	popupWindow:reposition(nx,ny,maxL+2,6)
	popupWindow:drawWindow(colors.lightBlue, colors.lightGray)
	popupWindow:setTextColor(colors.black)
	popupWindow:setBackgroundColor(colors.lightGray)
	popupWindow:setCursorPos(2,2)
	popupWindow:write(utils.stringMiddle(popName,maxL))
	popupWindow:setCursorPos(2,3)
	popupWindow:write(utils.stringMiddle(popPos,maxL))
	popupWindow:setCursorPos(2,4)
	popupWindow:write(utils.stringMiddle(popDed,maxL))
	popupWindow:setCursorPos(2,5)
	popupWindow:write(utils.stringMiddle(popRec,maxL))
end

--draw map color based on case
local function drawHeat()
	for i = 1, 121 do
		for j = 1, 44 do
			local pData = mapData[i][j]
			if pData ~= 0 then
				local cData = codeToColor[pData]
				if cData ~= nil then
					mapWindow:paintPixel(i,j,cData)
				end
			end
		end
	end
end
drawHeat()
drawLegend()

--for force recalculate
local function recalculate()
	calculateData()
	drawHeat()
end

--for force update data
local function forceUpdate()
	updateData()
	parseData()
	drawHeader()
	recalculate()
end

local running = true
while running do
	local p = {}
	p[1], p[2], p[3], p[4], p[5] = os.pullEventRaw()
    if p[1] == 'monitor_touch' then
		local nx = p[3]
		local ny = p[4] - 8
		if ny > 0 and nx > 0 then
			local reg = mapData[nx][ny]
			if reg == 0 and popupDrawn then
				popupDrawn = false
				popupWindow:setVisible(false)
			elseif reg ~= 0 then
				if not popupDrawn then
					popupWindow:setVisible(true)
				end
				drawPopup(reg, p[3], p[4]-8)
				popupDrawn = true
			end
		end
	elseif p[1] == "terminate" then
		printError("App Terminated.")
		setColor(false)
		m.setPaletteColor(colors.purple, 0xb266e5)
		running = false
	end
end