local fps = 0
local scale = 3
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk
local value = 1
local normalValue = 1
local water
local terrainTexture

function love.load()

	love.graphics.setDefaultFilter("nearest", "nearest")
	print(numV*numH)
	love.math.setRandomSeed(100) -- change seed for different terrain gen
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	require "fluidAutomata"
	terrainTexture = love.graphics.newImage("mesh.png")

	terrainChunk = TerrainChunk(scale, terrainTexture)
	-- water = FluidAutomata(scale)
	local xShift = love.math.random()*1000
	local yShift = love.math.random()*1000
	for y = 1, numV do
		for x = 1, numH do
			local value = (love.math.noise((x+y%2/2+ xShift)/numH, (y+yShift)/numV))
			if (value < 0.45) then
				value = 0
			elseif (value > 0.55) then
				value = 1
			end
			terrainChunk:newPoint(value, y, x)
			-- water:newAutomaton(0, i, j)
		end	
	end

	local time = love.timer.getTime()
	terrainChunk:initialiseMesh()
	local time2 = love.timer.getTime()
	print(time2-time)

	-- local i = 2
	-- local j = 2
	-- local value = 1
	-- water:newAutomaton(value, i, j)
	-- water:intialiseAutomata()
end
local test = 0
function love.update(delta)
	test = test + 1
	fps = love.timer.getFPS()
	if(test%4 == 0) then
		-- water:update(delta)
		test = 0
	end
end

function love.draw()
	-- terrainChunk:drawPoints()
	terrainChunk:drawMesh()
	-- water:drawPoints()
	-- water:draw()
	local x, y = love.mouse.getX(), love.mouse.getY()
	local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.setColor(x/windowWidth, y/windowHeight, 1-x/windowWidth, 1)
	love.graphics.circle("line", x, y, normalValue*scale/2)
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
	love.graphics.print("value: " .. normalValue, 0, 20)
	love.graphics.setColor(1,1,1,1)
end

function love.mousemoved(x, y, dx, dy)
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/scale), math.floor(y/(height))
		if (j > 2 and j < numH-2 and i > 2 and i < numV-2) then
			terrainChunk:newPoint(normalValue, i, j)
			terrainChunk:isoEdge(i, j, 0.5)
		end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/scale), math.floor(y/(height))
		if (j > 0 and j < numH and i > 0 and i < numV) then
			-- water:newAutomaton(normalValue, i, j)
			-- water:isoEdge(i, j, 0.5)
		end
	end
end

function love.wheelmoved(dx, dy)
	value = value + dy
	normalValue = math.min(math.ceil(math.abs(value/50)*100)/100, 1)
end

function love.keypressed()
end