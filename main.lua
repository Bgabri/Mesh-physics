-- https://imgur.com/gallery/lMrgZ
local fps = 0
local scale = 6
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk
local r = 1

function love.load()
	love.math.setRandomSeed(1)
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	terrainChunk = TerrainChunk(scale)
	for i = 1, numV do
		for j = 1, numH do
			-- local value = 0
			-- local value = math.floor(love.math.random()*2*2)/3
			-- local value = math.ceil(1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))
			local value = (1.1-(love.math.noise(((j+i%2/2)/numH))+love.math.noise((love.math.noise((i)/numV)))))*10
			-- local value = (1-(math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))-1)*5)/3))

			if (value < 0 ) then
				value = 0
			elseif (value > 1 ) then
				value = 1
			end
			terrainChunk:newPoint(value, i, j)
		end	
	end
	terrainChunk:newPoint(1, 10, 10)
	terrainChunk:findEdge()
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
			-- for i2 = i-r, i+r do
			-- 	for j2 = j-r, j+r do
			-- 		if (j2 > 0 and j2 < numH and i2 > 0 and i2 < numV) then
					terrainChunk:newPoint(1, i, j)
					terrainChunk:isoEdge(i, j, 1)
		-- 		end
		-- 	end
		-- end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		-- if (j > 0 and j < numH and i > 0 and i < numV) then
			terrainChunk:newPoint(0, i, j)
			terrainChunk:isoEdge(i, j, 1)
		-- end
	end
end

function love.wheelmoved(x, y)
	r = r +1
end

function love.update(delta)
	fps = love.timer.getFPS()
end

function love.draw()
	terrainChunk:draw()
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end