local scale = 10 -- lower value more samples, higher value less samples
local seed = math.floor(love.timer.getTime()) -- change seed for different terrain gen
-- local wireframe = true -- toggles wire frame display on/off
local wireframe = false -- toggles wire frame display on/off
local noiseScale = 1 -- scale at which to generate noise
-- generate terrain ("r") to see changes


local fps = 0
local shift = 10
local height = math.sqrt(3)/2*scale
local numV = math.floor(love.graphics.getHeight()/height)
local numH = math.floor(love.graphics.getWidth()/scale) - 1
local terrainChunk
local value = 1
local normalValue = 1
local canvasTest
local bitser = require "Libraries/bitser"
local saveLoad = require "saveLoad"
-- local water = nil

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.math.setRandomSeed(seed)
	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueTriangle"
	require "terrainChunk"
	require "fluidAutomata"

	local terrainTexture = love.graphics.newImage("mesh.png")
	local waterTexture = love.graphics.newImage("water.png")
	terrainChunk = TerrainChunk(scale, terrainTexture)
	-- water = FluidAutomata(scale, waterTexture)

	local loadedPoints = saveLoad.load()
	local points = {}
	local yMax = numV+shift*2
	local xMax = numH+shift*2

	if(#loadedPoints < yMax) then
		yMax = #loadedPoints
	end

	if(#loadedPoints < xMax) then
		if(loadedPoints[1] == nil) then
			xMax = 0
		else
			xMax = #loadedPoints[1]
		end
	end

	for y = 1, yMax do
		table.insert(points, {})
		for x = 1, xMax do
			table.insert(points[y], loadedPoints[y][x])
		end
	end

	local time = love.timer.getTime()
	terrainChunk:initialiseMesh(points)
	local time2 = love.timer.getTime()
	print("t: ", time2-time)


	-- for y = 1, numV+shift*2 do
	-- 	for x = 1, numH+shift*2 do
	-- 		-- local value = (love.math.noise((x+y%2/2+xShift)/numH*noiseScale, (y+yShift)/numV*noiseScale))
	-- 		local value = 0
	-- 		if (value < 0.45) then
	-- 			value = 0
	-- 		elseif (value > 0.55) then
	-- 			value = 1
	-- 		end
	-- 		water:newAutomaton(value, y, x)
	-- 	end	
	-- end

	-- water:intialiseAutomata()
end

local test = 0
function love.update(delta)
	fps = love.timer.getFPS()
	-- test = test + 1
	-- if(test%4 == 0) then
	-- 	water:update(delta)
	-- 	test = 0
	-- end
end

function love.draw()
	love.graphics.setWireframe(wireframe)
	love.graphics.translate(-shift*scale, -shift*scale)
		terrainChunk:drawMesh()
		terrainChunk:drawPoints()
		-- water:drawPoints()

		-- water:draw()

	love.graphics.setWireframe(false)
		local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
		local x, y = love.mouse.getX()+shift*scale, love.mouse.getY()+shift*scale
		love.graphics.setColor(x/windowWidth, y/windowHeight, 1-x/windowWidth, 1)
		love.graphics.circle("line", x, y, normalValue*scale/2)
		love.graphics.setColor(0.0, 1.0, 0.1)

	love.graphics.origin()
		love.graphics.print(fps, 0, 0)
		love.graphics.print("value: " .. normalValue, 0, 20)
		love.graphics.setColor(1,1,1,1)
end

function love.mousemoved(x, y, dx, dy)
	local x = x + shift*scale
	local y = y + shift*scale
	if(love.mouse.isDown(1)) then
		local j, i = math.floor(x/scale), math.floor(y/(height))
		if not (terrainChunk:valueAtPoint(i, j) == 1) then
			terrainChunk:newPoint(normalValue, i, j)
			terrainChunk:isoEdge(i, j, 0.5)
			-- terrainChunk:initialiseMesh()
		end
	end

	if(love.mouse.isDown(2)) then
		local j, i = math.floor(x/scale), math.floor(y/(height))
		-- if not (terrainChunk:valueAtPoint(i, j) == 0) then
			-- terrainChunk:newPoint(0, i, j)
			-- -- terrainChunk:isoEdge(i, j, 0.5)
			-- terrainChunk:initialiseMesh()
		-- end
			-- water:newAutomaton(1, i, j)
			-- water:isoEdge(i, j, 0.5)
			-- water:intialiseAutomata()
	end
end

function love.wheelmoved(dx, dy)
	value = value + dy
	normalValue = math.min(math.ceil(value*2)/100, 1)
	if normalValue >= 1 and normalValue <= 0 then
		value = 1
		normalValue = math.min(math.ceil(value*2)/100, 1)
	end
end

function love.keypressed(key)
	local xShift = love.math.random()*1000000
	local yShift = love.math.random()*1000000
	if key == "r" then
		for y = 1, numV+shift*2 do
			for x = 1, numH+shift*2 do
				local value = (love.math.noise((x+y%2/2+xShift)/numH*noiseScale, (y+yShift)/numV*noiseScale))
				if (value < 0.40) then
					value = 0
				elseif (value > 0.60) then
					value = 1
				end
				terrainChunk:newPoint(value, y, x)
			end	
		end
		terrainChunk:initialiseMesh()
	end
end

function love.quit()
	saveLoad.save(terrainChunk)
end