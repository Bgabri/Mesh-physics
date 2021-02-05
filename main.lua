local fps = 0
local scale = 10
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk

function love.load()
	love.math.setRandomSeed(1)
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	terrainChunk = TerrainChunk(scale)
	local time = love.timer.getTime()
	for i = 1, numV do
		for j = 1, numH do
			local value = (1.1-(love.math.noise(((j+i%2/2+100)/numH*2))+love.math.noise((love.math.noise((i)/numV*2)))))*10
			if (value < 0 ) then
				value = 0
			elseif (value > 1 ) then
				value = 1
			end
			terrainChunk:newPoint(value, i, j)
		end	
	end
	local time2 = love.timer.getTime()
	print(time2-time)
	terrainChunk:findEdge()
	local time3 = love.timer.getTime()
	print(time3-time2)
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		time = love.timer.getTime()
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV) then
			terrainChunk:newPoint(1, i, j-i%2+1)
			terrainChunk:isoEdge(i, j-i%2+1)
		end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV) then
			terrainChunk:newPoint(0, i, j)
			terrainChunk:isoEdge(i, j)
		end
	end
end

function love.update(delta)
	fps = love.timer.getFPS()
end

function love.draw()
	terrainChunk:draw()
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end