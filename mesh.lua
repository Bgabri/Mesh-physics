-- https://imgur.com/gallery/lMrgZ

local fps = 0
local terrain = {}
local test = {10, 10,10,10}
local scale = 10
local height = math.sqrt(3)/2*scale
local numV = love.graphics.getHeight()/height
local numH = love.graphics.getWidth()/scale - 1
local off = 0
function love.load()
	love.math.setRandomSeed(1)
	for i = 1, numV do
		terrain[i] = {}
		for j = 1, numH do
			terrain[i][j] = 0
			-- terrain[i][j] = math.floor(love.math.random()*2*2)/4
			-- terrain[i][j] = math.ceil(1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))
			-- terrain[i][j] = (1.1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))*10
			-- terrain[i][j] = (1-(math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))-1)*5)/3))
			if (terrain[i][j] < 0 ) then
				terrain[i][j] = 0
			elseif (terrain[i][j] > 1 ) then
				terrain[i][j] = 1
			end

			if (i == math.floor(numV/2)) then
				terrain[i][j] = 1
			end
		end	
	end
	local V = math.floor(numV/2)
	V = V+1-V%2
	local H = math.floor(numH/2)

	terrain[V][H] = 1
	terrain[V][H+1] = 1
	terrain[V][H+2] = 1
	terrain[V][H+3] = 0.1

	terrain[V+1][H] = 1
	terrain[V+2][H-1] = 1
	terrain[V+3][H] = 1
	terrain[V+4][H] = 1
	terrain[V+4][H+1] = 1
	terrain[V+4][H+2] = 1
	terrain[V+3][H+3] = 1
	terrain[V+2][H+3] = 1
	terrain[V+1][H+3] = 1


	-- terrain[6][12] = 1
	-- terrain[7][11] = 1
	-- terrain[7][12] = 1
end

function love.update(delta)
fps = love.timer.getFPS()
end

function love.draw()
	love.graphics.setPointSize(2)
	for i, row in ipairs(terrain) do
		for j, v in ipairs(row) do
			love.graphics.setColor(v+0.1, v+0.1, v+0.1)
			local x, y = (j + i%2/2)*scale, i*height
			love.graphics.points(x, y)
		end
	end
	love.graphics.setPointSize(1)
	love.graphics.setColor(0.4, 0.5, 1, 1)
	for i = 1, #terrain-1, 1 do
		for j = 2-i%2, #terrain[i]-1, 1 do
			local x, y = (j + i%2/2)*scale, i*height
			isoUp(terrain[i][j], terrain[i+1][j+i%2-1], terrain[i+1][j+i%2], x, y)
			isoDown(terrain[i][j], terrain[i][j+1], terrain[i+1][j+i%2], x, y)
		end
	end
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end

function newValue(value)
	if (value == nil) then
		value = 0
	end
	return value
end

function isoUp(top, bottomLeft, bottomRight, x, y)
	shiftX = 0.5*scale

	local intraValue = 0.5
	local value = (intraValue-top)/(bottomRight-top) -- right
	local x1 = x + shiftX*value
	local y1 = y + height*value
	local value = (bottomRight-intraValue)/(bottomLeft-bottomRight) -- bottom
	local x2 = x+shiftX + 2*(shiftX)*value
	local y2 = y + height
	local value = (intraValue-top)/(bottomLeft-top) -- left
	local x3 = x - shiftX*value
	local y3 = y + height*value
	love.graphics.line(x1, y1, x2, y2)
	love.graphics.line(x2, y2, x3, y3)
	love.graphics.line(x1, y1, x3, y3)
end

function isoDown(topLeft, topRight, bottom, x, y)
	shiftX = 0.5*scale
	local intraValue = 0.5
	local value = (intraValue-topLeft)/(topRight-topLeft) -- right
	local x1 = x + scale*value
	local y1 = y
	local value = (intraValue-topRight)/(bottom-topRight)
	local x2 = x + scale + (shiftX-scale)*value
	local y2 = y + height*value
	local value = (intraValue-topLeft)/(bottom-topLeft)
	local x3 = x + shiftX*value
	local y3 = y + height*value
	love.graphics.line(x1, y1, x2, y2)
	love.graphics.line(x2, y2, x3, y3)
	love.graphics.line(x1, y1, x3, y3)
end
-- generate mesh
-- marching squares - collisions ***cries in big sad***
-- 	- merge meshes
-- remove and add vertices in mesh
-- terrain with phys
-- if less than x vertices grav = true

-- -- -- https://imgur.com/gallery/lMrgZ
-- -- fps = 0
-- -- terrain = {}
-- -- test = {10, 10,10,10}
-- -- scale =  10
-- -- numV = love.graphics.getHeight()/scale - 1
-- -- numH = love.graphics.getWidth()/scale - 1
-- -- off = 0
-- -- function love.load()
-- -- 	Object = require("Libraries/classic")
-- -- 	for i = 1, numH do
-- -- 		terrain[i] = {}
-- -- 		for j = 1, numV do
-- -- 			-- terrain[i][j] = math.floor(love.math.random()*2)
-- -- 			-- terrain[i][j] = math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)*2))-1)*10)/5+0.2
-- -- 			-- terrain[i][j] = math.floor(love.math.noise((j/numH))+love.math.noise(i/numV-0.8)-0.5)
-- -- 			terrain[i][j] = 0
-- -- 			-- print(terrain[i][j])
-- -- 		end	
-- -- 	end

-- -- 	terrain[10][10] = 1

-- -- 	terrain[1][1] = 1
-- -- 	terrain[numH][1] = 1
-- -- 	terrain[1][numV] = 1
-- -- 	terrain[numH][numV] = 1
-- -- 	-- terrain[11][10] = 1
-- -- 	-- terrain[10][11] = 1
-- -- 	-- terrain[11][11] = 1
-- -- 	-- terrain[11][10] = 1

-- -- 	terrain[10][30] = 1
-- -- 	terrain[11][30] = 1
-- -- 	terrain[12][30] = 1
-- -- 	terrain[12][31] = 1
-- -- 	terrain[12][32] = 1
-- -- 	terrain[11][32] = 1
-- -- 	terrain[10][32] = 1
-- -- 	terrain[10][31] = 1
-- -- end

-- -- function love.update(delta)
-- -- fps = love.timer.getFPS()
-- -- -- 	for i = 1, numH do
-- -- -- 		terrain[i] = {}
-- -- -- 		for j = 1, numV do
-- -- -- 			terrain[i][j] = 1-math.floor(love.math.noise(((j)/50))+love.math.noise(((i)/50))+love.math.noise(off)/30)
-- -- -- 		end	
-- -- -- 	end
-- -- end

-- -- function love.draw()
-- -- 	love.graphics.setPointSize(2)
-- -- 	for i, row in ipairs(terrain) do
-- -- 		for j, v in ipairs(row) do
-- -- 			love.graphics.setColor(v+0.2, v+0.2, v+0.2)
-- -- 			-- love.graphics.setColor(v, v, v)
-- -- 			love.graphics.points(i*scale, j*scale)
-- -- 		end
-- -- 	end
-- -- 	for i = 1, #terrain-1, 1 do
-- -- 		for j = 1, #terrain[i]-1, 1 do
-- -- 			x = i*scale
-- -- 			y = j*scale
-- -- 			-- love.graphics.setColor(1-j/numV, 1-i/numV, j/numH)
-- -- 			-- topPoint = {
-- -- 			-- 	x = x + scale/2,
-- -- 			-- 	y = y
-- -- 			-- }

-- -- 			-- rightPoint = {
-- -- 			-- 	x = x + scale,
-- -- 			-- 	y = y + scale/2
-- -- 			-- }

-- -- 			-- bottomPoint =  {
-- -- 			-- 	x = x + scale/2,
-- -- 			-- 	y = y + scale
-- -- 			-- }

-- -- 			-- leftPoint = {
-- -- 			-- 	x = x,
-- -- 			-- 	y = y + scale/2
-- -- 			-- }

-- -- 			-- switch = {
-- -- 			-- 	{0,0,0,0}, -- 0
-- -- 			-- 	{leftPoint.x, leftPoint.y, bottomPoint.x, bottomPoint.y}, -- 1
-- -- 			-- 	{rightPoint.x, rightPoint.y, bottomPoint.x, bottomPoint.y}, -- 2
-- -- 			-- 	{rightPoint.x, rightPoint.y, leftPoint.x, leftPoint.y}, -- 3
-- -- 			-- 	{topPoint.x, topPoint.y, rightPoint.x, rightPoint.y}, -- 4
-- -- 			-- 	{leftPoint.x, leftPoint.y, topPoint.x, topPoint.y, x+scale, y, rightPoint.x, rightPoint.y, bottomPoint.x, bottomPoint.y}, -- 5
-- -- 			-- 	{topPoint.x, topPoint.y, bottomPoint.x, bottomPoint.y}, -- 6
-- -- 			-- 	{leftPoint.x, leftPoint.y, topPoint.x, topPoint.y}, -- 7
-- -- 			-- 	{leftPoint.x, leftPoint.y, topPoint.x, topPoint.y}, -- 8
-- -- 			-- 	{topPoint.x, topPoint.y, bottomPoint.x, bottomPoint.y}, -- 9
-- -- 			-- 	{bottomPoint.x, bottomPoint.y, leftPoint.x, leftPoint.y, x, y, topPoint.x, topPoint.y, rightPoint.x, rightPoint.y}, -- 10
-- -- 			-- 	{topPoint.x, topPoint.y, rightPoint.x, rightPoint.y}, -- 11
-- -- 			-- 	{rightPoint.x, rightPoint.y, leftPoint.x, leftPoint.y}, -- 12
-- -- 			-- 	{rightPoint.x, rightPoint.y, bottomPoint.x, bottomPoint.y}, -- 13
-- -- 			-- 	{leftPoint.x, leftPoint.y, bottomPoint.x, bottomPoint.y}, -- 4
-- -- 			-- 	{0,0,0,0}, -- 15
-- -- 			-- }
			
-- -- 			-- case = 1
-- -- 			drawLine(terrain[i][j],terrain[i+1][j],terrain[i+1][j+1],terrain[i][j+1], x, y)
-- -- 		end
-- -- 	end
-- -- 	love.graphics.setColor(0.0, 1.0, 0.1)
-- -- 	love.graphics.print(fps, 0, 0)
-- -- end

-- -- function drawLine(topLeft, topRight, bottomRight, bottomLeft, x, y)
-- -- 	-- relativeLine = {
-- -- 	-- 	x1 = 0,
-- -- 	-- 	y1 = 0,
-- -- 	-- 	x2 = 0,
-- -- 	-- 	y2 = 0
-- -- 	-- }

-- -- 	top = (topLeft + topRight)/2
-- -- 	right = (topRight + bottomRight)/2
-- -- 	bottom = (bottomRight + bottomLeft)/2
-- -- 	left = (bottomLeft + topLeft)/2
-- -- 	love.graphics.setColor(0.5, 0.5, 0.5)
-- -- 	love.graphics.line(x+(top)*scale, y+(right)*scale, x+(bottom)*scale, y+(left)*scale)
-- -- 	-- love.graphics.polygon("line", x+(top)*scale, y, x+scale, y+(right)*scale, x+(bottom)*scale, y+scale)
-- -- 	if not (topLeft+topRight+bottomRight+bottomLeft == 0) then
-- -- 		love.graphics.setColor(0, 0, 1) --blue
-- -- 		love.graphics.points(x+(top)*scale, y)

-- -- 		love.graphics.setColor(0, 1, 0) --green
-- -- 		love.graphics.points(x+scale, y+(right)*scale)

-- -- 		love.graphics.setColor(1, 0, 0) -- red
-- -- 		love.graphics.points(x+(bottom)*scale, y+scale)

-- -- 		love.graphics.setColor(1, 0, 1) -- pink
-- -- 		love.graphics.points(x, y+(left)*scale)
-- -- 	end



-- -- 	-- relativeLine.y1 = relativeLine.y1 - (topLeft + bottomRight)/2






-- -- 	-- relativeLine.x1 = relativeLine.x1 - topLeft
-- -- 	-- -- relativeLine.x2 = relativeLine.x2 - topLeft
-- -- 	-- relativeLine.y2 = relativeLine.y2 - topLeft
-- -- 	-- -- relativeLine.y1 = relativeLine.y1 - topLeft

-- -- 	-- -- relativeLine.x1 = relativeLine.x1 + bottomRight
-- -- 	-- -- relativeLine.x2 = relativeLine.x2 + bottomRight
-- -- 	-- relativeLine.y2 = relativeLine.y2 + bottomRight
-- -- 	-- -- relativeLine.y1 = relativeLine.y1 + bottomRight

-- -- 	-- -- relativeLine.x1 = relativeLine.x1 - bottomLeft
-- -- 	-- relativeLine.x2 = relativeLine.x2 - bottomLeft
-- -- 	-- -- relativeLine.y2 = relativeLine.y2 + bottomLeft
-- -- 	-- relativeLine.y1 = relativeLine.y1 + bottomLeft

-- -- 	-- -- relativeLine.x1 = relativeLine.x1 + topRight
-- -- 	-- relativeLine.x2 = relativeLine.x2 + topRight
-- -- 	-- -- relativeLine.y2 = relativeLine.y2 - topRight
-- -- 	-- relativeLine.y1 = relativeLine.y1 - topRight


-- -- 	--straight

-- -- 	-- relativeLine.y1 = relativeLine.y1 - topRight
-- -- 	-- relativeLine.y2 = relativeLine.y2 + bottomRight

-- -- 	-- relativeLine.x1 = relativeLine.x1 + bottomRight
-- -- 	-- relativeLine.x2 = relativeLine.x2 - bottomLeft
-- -- 	-- if not (relativeLine.x1 + relativeLine.x2 + relativeLine.y1 + relativeLine.y1 == 0) then
-- -- 	-- 	love.graphics.points(x+(relativeLine.x1+1)*scale/2, y+(relativeLine.y1+1)*scale/2, x+(relativeLine.x2+1)*scale/2, y+(relativeLine.y2+1)*scale/2)
-- -- 	-- end
-- -- 	-- love.graphics.line(x+(relativeLine.x1)*scale, y+(relativeLine.y1)*scale, x+(relativeLine.x2)*scale, y+(relativeLine.y2)*scale)
-- -- 	-- love.graphics.line(x+top*scale, y+topLeft, x+topLeft, y+left*scale)
-- -- 	-- love.graphics.line(x+top*scale, y+bottomRight, x+bottomRight, y+left*scale)
-- -- end
-- -- -- generate mesh
-- -- -- marching squares - collisions ***cries in big sad***
-- -- -- 	- merge meshes
-- -- -- remove and add vertices in mesh
-- -- -- terrain with phys
-- -- -- if less than x vertices grav = true
-- -- -- 
-- -- -- 
-- -- -- 
-- -- -- 






















-- -- https://imgur.com/gallery/lMrgZ
-- fps = 0
-- terrain = {}
-- test = {10, 10,10,10}
-- scale = 60
-- numV = love.graphics.getHeight()/scale - 1
-- numH = love.graphics.getWidth()/scale - 1
-- off = 0
-- function love.load()
-- 	for i = 1, numH do
-- 		terrain[i] = {}
-- 		for j = 1, numV do
-- 			terrain[i][j] = 0
-- 		end	
-- 	end

-- 	terrain[6][6] = 1
-- 	terrain[3][3] = 1

-- 	-- terrain[1][1] = 1
-- 	-- terrain[numH][1] = 1
-- 	-- terrain[1][numV-4] = 1
-- 	-- terrain[numH][numV-4] = 1
-- end

-- function love.update(delta)
-- fps = love.timer.getFPS()
-- end

-- function love.draw()
-- 	love.graphics.setPointSize(2)
-- 	for i, row in ipairs(terrain) do
-- 		for j, v in ipairs(row) do
-- 			love.graphics.setColor(v+0.2, v+0.2, v+0.2)
-- 			x = i+j%2/2
-- 			y = j*math.sqrt(3)/2
-- 			love.graphics.points(x*scale, y*scale)
-- 			love.graphics.print("i: "..i.." j: "..j,x*scale, y*scale)
-- 		end
-- 	end

-- 	for i = 1, #terrain-1, 1 do
-- 		for j = 1, #terrain[i]-1, 1 do
-- 			x = (i+j%2/2)
-- 			y = j*math.sqrt(3)/2
-- 			isoUp(terrain[i][j], terrain[i+1-j%2][j+1], terrain[i+j%2][j+1], x, y)
-- 			isoDown(terrain[i][j], terrain[i][j+1], terrain[i+1][j], x, y)
-- 		end
-- 	end
-- 	love.graphics.setColor(0.0, 1.0, 0.1)
-- 	love.graphics.print(fps, 0, 0)
-- end

-- function isoUp(top, bottomLeft, bottomRight, x, y)
-- 	love.graphics.setColor(0.7,0.7,0.7)
-- 	if (top == 1 and bottomRight == 0 and bottomLeft == 0) or (top == 0 and bottomRight == 1 and bottomLeft == 1) then
-- 		shiftY = math.sin(math.pi/3)*0.5
-- 		shiftX = math.cos(math.pi/3)*0.5
-- 		love.graphics.line((x-shiftX)*scale, (y+shiftY)*scale, (x+shiftX)*scale, (y+shiftY)*scale)
-- 	elseif (top == 0 and bottomRight == 1 and bottomLeft == 0) or (top == 1 and bottomRight == 0 and bottomLeft == 1) then
-- 		shiftY = math.sin(math.pi/3)*0.5
-- 		shiftX = math.cos(math.pi/3)*0.5
-- 		love.graphics.line(x*scale, (y+shiftY*2)*scale, (x+shiftX)*scale, (y+shiftY)*scale)
-- 	elseif (top == 0 and bottomRight == 0 and bottomLeft == 1) or (top == 1 and bottomRight == 1 and bottomLeft == 0) then
-- 		shiftY = math.sin(math.pi/3)*0.5
-- 		shiftX = math.cos(math.pi/3)*0.5
-- 		love.graphics.line(x*scale, (y+shiftY*2)*scale, (x-shiftX)*scale, (y+shiftY)*scale)
-- 	end
-- end
-- function isoDown(topLeft, topRight, bottom, x, y)
-- 	love.graphics.setColor(0.7,0.7,0.2)
-- 	if (bottom == 1 and topRight == 0 and topLeft == 0) or (bottom == 0 and topRight == 1 and topLeft == 1) then
-- 		shiftY = math.sin(math.pi/3)*0.5
-- 		shiftX = math.cos(math.pi/3)*0.5
-- 		love.graphics.line((x)*scale, (y)*scale, (x+shiftX)*scale, (y+shiftY)*scale)
-- 	elseif (bottom == 0 and topRight == 1 and topLeft == 0) or (bottom == 1 and topRight == 0 and topLeft == 1) then
-- 		-- shiftY = math.sin(math.pi/3)*0.5
-- 		-- shiftX = math.cos(math.pi/3)*0.5
-- 		-- love.graphics.line(x*scale, (y+shiftY*2)*scale, (x+shiftX)*scale, (y+shiftY)*scale)
-- 	elseif (bottom == 0 and topRight == 0 and topLeft == 1) or (bottom == 1 and topRight == 1 and topLeft == 0) then
-- 		-- shiftY = math.sin(math.pi/3)*0.5
-- 		-- shiftX = math.cos(math.pi/3)*0.5
-- 		-- love.graphics.line(x*scale, (y+shiftY*2)*scale, (x-shiftX)*scale, (y+shiftY)*scale)
-- 	end
-- end
-- -- generate mesh
-- -- marching squares - collisions ***cries in big sad***
-- -- 	- merge meshes
-- -- remove and add vertices in mesh
-- -- terrain with phys
-- -- if less than x vertices grav = true
