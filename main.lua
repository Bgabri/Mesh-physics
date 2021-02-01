-- https://imgur.com/gallery/lMrgZ

local fps = 0
local terrain = {}
local edges = {}
local scale = 10
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1

function love.load()
	love.math.setRandomSeed(1)
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"

	local terrainChunk = TerrainChunk(scale, height)

	for i = 1, numV do
		terrain[i] = {}
		for j = 1, numH do
			-- terrain[i][j] = 0
			-- terrain[i][j] = math.floor(love.math.random()*2*2)/3
			-- print(terrain[i][j])
			-- terrain[i][j] = math.ceil(1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))
			terrain[i][j] = (1.1-(love.math.noise(((j+i%2/2)/numH))+love.math.noise((love.math.noise((i)/numV)))))*10
			-- terrain[i][j] = (1-(math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))-1)*5)/3))

			if (terrain[i][j] < 0 ) then
				terrain[i][j] = 0
			elseif (terrain[i][j] > 1 ) then
				terrain[i][j] = 1
			end
			terrainChunk:newPoint(terrain[i][j], j*scale, i*height)
		end	
	end

	for j = 1, numH do 
		terrain[math.floor(numV/2)][j] = 1
	end
	findEdge(1, 1, numH-1, numV-1)
	-- love.graphics.setBackgroundColor(0.1058823529, 0.1137254902, 0.1176470588)
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 1)) then
			terrain[i][j] = 1
			local radius = 2
			edges = {}
			findEdge(1, 1, numH-1, numV-1)
		end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 0)) then
			terrain[i][j] = 0
			local radius = 2
			edges = {}
			findEdge(1, 1, numH-1, numV-1)
		end
	end
end

function love.update(delta)
	fps = love.timer.getFPS()
end

function love.draw()
	-- love.graphics.setPointSize(2)
	-- for i, row in ipairs(terrain) do
	-- 	for j, v in ipairs(row) do
	-- 		love.graphics.setColor(v+0.1, v+0.1, v+0.1)
	-- 		local x, y = (j + i%2/2)*scale, i*height
	-- 		love.graphics.points(x, y)
	-- 	end
	-- end
	spitEdge()
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end

function spitEdge()
	for i,v in ipairs(edges) do
		love.graphics.setColor(i/#edges, 0, 1-i/#edges, 1)
		love.graphics.line(v[1], v[2], v[3], v[4])
	end
end

function findEdge(minX, minY, maxX, maxY)
	for i = minY, maxY, 1 do
		for j = minX+1-i%2, maxX, 1 do
			local x, y = (j + i%2/2)*scale, i*height
			if(terrain[i][j] + terrain[i+1][j+i%2-1] + terrain[i+1][j+i%2] > 0) then
				local x1, y1, x2, y2, x3, y3 = isoUp(terrain[i][j], terrain[i+1][j+i%2-1], terrain[i+1][j+i%2], x, y)
				if not (x1 + y1 + x2 + y2 == 1/0) then
					table.insert(edges, {x1, y1, x2, y2})
				end
				if not (x2 + y2 + x3 + y3 == 1/0) then
					table.insert(edges, {x2, y2, x3 ,y3})
				end
				if not (x1 + y1 + x3 + y3 == 1/0) then
					table.insert(edges, {x1, y1, x3, y3})
				end
			end

			if(terrain[i][j] + terrain[i][j+1] + terrain[i+1][j+i%2] > 0) then
				local x1, y1, x2, y2, x3, y3 = isoDown(terrain[i][j], terrain[i][j+1], terrain[i+1][j+i%2], x, y)
				if not (x1 + y1 + x2 + y2 == 1/0) then
					table.insert(edges, {x1, y1, x2, y2})
				end
				if not (x2 + y2 + x3 + y3 == 1/0) then
					table.insert(edges, {x2, y2, x3 ,y3})
				end
				if not (x1 + y1 + x3 + y3 == 1/0) then
					table.insert(edges, {x1, y1, x3, y3})
				end
			end
		end
	end
end

function isoUp(top, bottomLeft, bottomRight, x, y)
	local valueTriangle = ValueTriangle()
	local shiftX = 0.5*scale
	valueTriangle:addVertex(top, x, y)
	valueTriangle:addVertex(bottomLeft, x - shiftX, y + height)
	valueTriangle:addVertex(bottomRight, x + shiftX, y + height)

	return valueTriangle:intraprolated()
end

function isoDown(topLeft, topRight, bottom, x, y)
	local valueTriangle = ValueTriangle()
	valueTriangle:addVertex(topLeft, x, y)
	valueTriangle:addVertex(topRight, x + scale, y)
	valueTriangle:addVertex(bottom, x + scale*0.5, y + height)

	return valueTriangle:intraprolated()
end

