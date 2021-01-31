-- https://imgur.com/gallery/lMrgZ

local fps = 0
local terrain = {}
local edges = {}
local scale = 1
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local off = 0
function love.load()
	love.math.setRandomSeed(1)
	require('Libraries/collisions')
	test = 0
	for i = 1, numV do
		terrain[i] = {}
		for j = 1, numH do
			-- terrain[i][j] = 0
			-- terrain[i][j] = math.floor(love.math.random()*2*2)/3
			-- print(terrain[i][j])
			-- terrain[i][j] = math.ceil(1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))
			terrain[i][j] = (1.1-(love.math.noise(((j+i%2/2)/numH)+test)+love.math.noise((love.math.noise((i)/numV)))))*10
			-- terrain[i][j] = (1-(math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))-1)*5)/3))

			if (terrain[i][j] < 0 ) then
				terrain[i][j] = 0
			elseif (terrain[i][j] > 1 ) then
				terrain[i][j] = 1
			end
		end	
	end

	for j = 1, numH do 
		terrain[math.floor(numV/2)][j] = 1
	end
	findEdge(1, 1, numH-1, numV-1)
end

function love.update(delta)
	fps = love.timer.getFPS()
	if(love.mouse.isDown(1)) then
		local x = love.mouse.getX()+scale/2
		local y = love.mouse.getY()+scale/2
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 1)) then
			terrain[i][j] = 1
			local radius = 2
			findEdge(j-radius, i-radius, j+radius, i+radius)
		end
	end

	if(love.mouse.isDown(2)) then
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 0)) then
			terrain[i][j] = 0
			local radius = 2
			findEdge(j-radius, i-radius, j+radius, i+radius)
		end
	end
end

function love.draw()
	spitEdge()
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end

function spitEdge()
	for i,v in ipairs(edges) do
		love.graphics.setColor(i/#edges, 0, 1-i/#edges, 1)
		-- rgb
		love.graphics.line(v[1], v[2], v[3], v[4])
	end
end

function findEdge(minX, minY, maxX, maxY)
	for i = minY, maxY, 1 do
		for j = minX+1-i%2, maxX, 1 do
			local x, y = (j + i%2/2)*scale, i*height
			local x1, y1, x2, y2, x3, y3 = isoUp(terrain[i][j], terrain[i+1][j+i%2-1], terrain[i+1][j+i%2], x, y)
			if not (x1 + y1 + x2 + y2 == 1/0)	then
				table.insert(edges, {x1, y1, x2, y2})
			end
			if not (x2 + y2 + x3 + y3 == 1/0)	then
				table.insert(edges, {x2, y2, x3 ,y3})
			end
			if not (x1 + y1 + x3 + y3 == 1/0)	then
				table.insert(edges, {x1, y1, x3, y3})
			end

			local x1, y1, x2, y2, x3, y3 = isoDown(terrain[i][j], terrain[i][j+1], terrain[i+1][j+i%2], x, y)
			if not (x1 + y1 + x2 + y2 == 1/0)	then
				table.insert(edges, {x1, y1, x2, y2})
			end
			if not (x2 + y2 + x3 + y3 == 1/0)	then
				table.insert(edges, {x2, y2, x3 ,y3})
			end
			if not (x1 + y1 + x3 + y3 == 1/0)	then
				table.insert(edges, {x1, y1, x3, y3})
			end
		end
	end
end

function isoUp(top, bottomLeft, bottomRight, x, y)
	local shiftX = 0.5*scale
	local valueVertex1 = {
		value = top,
		x = x, y = y
	}
	local valueVertex2 = {
		value = bottomLeft,
		x = x - shiftX,
		y = y + height
	}
	local valueVertex3 = {
		value = bottomRight,
		x = x + shiftX,
		y = y + height
	}

	return isoIntraprolation(valueVertex1, valueVertex2, valueVertex3)
end

function isoDown(topLeft, topRight, bottom, x, y)
	local valueVertex1 = {
		value = topLeft,
		x = x, y = y
	}
	local valueVertex2 = {
		value = topRight,
		x = x + scale, y = y
	}
	local valueVertex3 = {
		value = bottom,
		x = x + scale*0.5,
		y = y + height
	}

	return isoIntraprolation(valueVertex1, valueVertex2, valueVertex3)
end


function isoIntraprolation(valueVertex1, valueVertex2, valueVertex3)
	local middle = 0.5
	local intraValue = (middle - valueVertex1.value)/(valueVertex2.value - valueVertex1.value)
	local intraX1 = valueVertex1.x + (valueVertex2.x - valueVertex1.x)*intraValue
	local intraY1 = valueVertex1.y + (valueVertex2.y - valueVertex1.y)*intraValue

	local intraValue = (middle - valueVertex2.value)/(valueVertex3.value - valueVertex2.value)
	local intraX2 = valueVertex2.x + (valueVertex3.x - valueVertex2.x)*intraValue
	local intraY2 = valueVertex2.y + (valueVertex3.y - valueVertex2.y)*intraValue

	local intraValue = (middle - valueVertex1.value)/(valueVertex3.value - valueVertex1.value)
	local intraX3 = valueVertex1.x + (valueVertex3.x - valueVertex1.x)*intraValue
	local intraY3 = valueVertex1.y + (valueVertex3.y - valueVertex1.y)*intraValue

	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX1, intraY1, 0.00000001) then
		intraX1, intraY1 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX2, intraY2, 0.00000001) then
		intraX2, intraY2 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX3, intraY3, 0.00000001) then
		intraX3, intraY3 = 1/0, 1/0
	end
	return intraX1, intraY1, intraX2, intraY2, intraX3, intraY3
end
