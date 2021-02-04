-- https://imgur.com/gallery/lMrgZ
local fps = 0
local terrain = {}
local edges = {}
local scale = 5
local height = math.sqrt(3)/2*scale
numV = math.floor(love.graphics.getHeight()/height)
numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk

function love.load()
	love.math.setRandomSeed(1)
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	terrainChunk = TerrainChunk(scale)
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
			terrainChunk:newPoint(terrain[i][j], i, j)
		end	
	end
	terrainChunk:findEdge()
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 1)) then
			terrainChunk:newPoint(1, i, j)
			terrainChunk:findEdge()
		end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/love.graphics.getWidth()*numH), math.floor(y/love.graphics.getHeight()*numV)
		if (j > 0 and j < numH and i > 0 and i < numV and not (terrain[i][j] == 0)) then
			terrainChunk:newPoint(0, i, j)
			terrainChunk:findEdge()
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
 