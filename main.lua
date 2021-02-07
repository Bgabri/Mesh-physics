local fps = 0
local scale = 4
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk
local value = 1
local normalValue = 1

function love.load()
	love.math.setRandomSeed(496) -- change seed for different terrain gen
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	-- require "waterAutomaton"
	terrainChunk = TerrainChunk(scale)
	local time = love.timer.getTime()
	local xShift = love.math.random()*100000
	local yShift = love.math.random()*100000
	for i = 1, numV do
		for j = 1, numH do
			local value = (love.math.noise((j+i%2/2 + xShift)/numH, (i+yShift)/numV))
			if (value < 0.45 ) then
				value = 0
			elseif (value > 0.55 ) then
				value = 1
			end
			terrainChunk:newPoint(value, i, j)
		end	
	end
	for i=10, 50, 2 do
		terrainChunk:newPoint(1, i, 10)
		terrainChunk:newPoint(0.500001, i+1, 10)
		terrainChunk:newPoint(0.500001, i+1, 9)
	end

	local time2 = love.timer.getTime()
	print(time2-time)
	terrainChunk:findEdge()
	local time3 = love.timer.getTime()
	print(time3-time2)
end

function love.update(delta)
	fps = love.timer.getFPS()
end

function love.draw()
	-- terrainChunk:drawPoints()
	terrainChunk:draw()
	love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), normalValue*scale/2)
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
	love.graphics.print("value: " .. normalValue, 0, 20)
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV) then
			terrainChunk:newPoint(normalValue, i, j-i%2+1)
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

function love.wheelmoved(dx, dy)
	value = value + dy
	normalValue = math.min(math.ceil(math.abs(value/50)*100)/100, 1)
end