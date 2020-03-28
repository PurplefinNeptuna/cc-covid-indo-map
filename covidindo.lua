--Data provided by Kawal Corona API
local utils = require('lib/utils')
local Pair = require('lib/Pair')
local json = require('lib/json')
local tableExt = require('lib/tableExt')

--code to color
local function getColor(n)
	local ans = colors.white
	if n > 5/6 then
		ans = colors.black
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

--catch --log argument
local logMode = false
if #arg > 0 then
	if arg[1] == "--log" then
		logMode = true
	end
end

--build windows
local mapWindow = window.create(m,1,9,121,44)
local titleWindow = window.create(m,2,2,97,6)
local dataWindow = window.create(m,1,8,33,1)
local creatorWindow = window.create(m,100,2,20,1)
local timeWindow = window.create(m,92,8,30,1)

--read timestamp
local tstampfile = fs.open("tsindo","r")
local tstamp = tonumber(tstampfile.readAll())
tstampfile.close()
local tstampnow = os.time(os.date("*t"))

local cvdata
local function updateData()
    print("Updating data...")
    local getdata = http.get("https://api.kawalcorona.com/indonesia/provinsi")
	tstampnow = os.time(os.date("*t"))
	tstamp = tstampnow
    cvdata = getdata.readAll()
    local savedata = fs.open("dataindo.json","w")
    savedata.write(cvdata)
    savedata.close()
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
    local data = fs.open("dataindo.json","r")
    cvdata = data.readAll()
    data.close()
end

local function drawHeader()
	--paint title
	utils.drawImage(titleWindow,'titleindo',1,1,true)
	creatorWindow.write("by Purplefin Neptuna")
	dataWindow.write("Data provided by Kawal Corona API")
	timeWindow.write(os.date("Last Update: %x %X",tstamp))
	--paint map
	utils.drawImage(mapWindow,'indo',1,1,true)
end
drawHeader()

local cv = {}
local codeToColor = {}
local function calculateData()
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
	local maxCase = 0
	for k,v in pairs(cv) do
		maxCase = math.max(v.confi,maxCase)
	end

	for k,v in pairs(cv) do
		if logMode then
			codeToColor[k] = getColor(math.log(v.confi)/math.log(maxCase))
		else
			codeToColor[k] = getColor(v.confi/maxCase)
		end
	end
end
calculateData()

--read mapdata
print("Load Map Data")
local data = fs.open("mapindo.json","r")
cvdata = data.readAll()
data.close()
local mapData = json.decode(cvdata)

--draw map color based on case
local function drawHeat()
	for i = 1, 121 do
		for j = 1, 44 do
			local pData = mapData[i][j]
			if pData ~= 0 then
				local cData = codeToColor[pData]
				if cData ~= nil then
					utils.paintPixel(mapWindow,i,j,cData)
				end
			end
		end
	end
end
drawHeat()

--for force recalculate
local function recalculate()
	updateData()
	calculateData()
	drawHeat()
end

--for redraw all windows
local function reDraw()
	drawHeader()
	drawHeat()
end

--[[
Last Update: 99/99/99 99:99:99
30 char %x %X

Color scale (log):
	" > 0
	" > 0
	" > 0
	" > 0
	" > 0
	" > 0

18x7 size
]]--
