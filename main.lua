local scale = 5 -- lower value more samples, higher value less samples
local seed = math.floor(love.timer.getTime()) -- change seed for different terrain gen
local wireframe = true -- toggles wire frame display on/off
local noiseScale = 2 -- scale at which to generate noise
-- to see changes generate terrain ("r")

local fps = 0
local shift = 10
local numV = math.floor(love.graphics.getHeight()/scale)
local numH = math.floor(love.graphics.getWidth()/scale)
local terrainChunk
local canvasTest
local bitser = require "Libraries/bitser"
local saveLoad = require "saveLoad"
-- local water = nil
local camXOffset = -shift*scale
local camYOffset = -shift*scale

function love.load()
	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.math.setRandomSeed(seed)

	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "valueSquare"
	require "terrainChunk"
	require "fluidAutomata"

	local terrainTexture = love.graphics.newImage("Assets/mesh.png")
	local waterTexture = love.graphics.newImage("Assets/water.png")

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
	print("t: "..time2-time)

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
	-- if (test%4 == 0) then
	-- 	water:update(delta)
	-- 	test = 0
	-- end

	if(love.mouse.isDown(1)) then
		local x = love.mouse.getX() - camXOffset
		local y = love.mouse.getY() - camYOffset
		local i = math.floor(y/scale)
		local j = math.floor(x/scale)
		local value = terrainChunk:valueAtPoint(i, j)
		if (value < 1) then
			terrainChunk:newPoint(value + delta*math.cos(value*math.pi/2)*3, i, j)
			terrainChunk:isoEdge(i, j, 0.5)
			-- terrainChunk:initialiseMesh()
		end
	end

	if(love.mouse.isDown(2)) then
		local x = love.mouse.getX() - camXOffset
		local y = love.mouse.getY() - camYOffset
		local i = math.floor(y/scale)
		local j = math.floor(x/scale)
		local value = terrainChunk:valueAtPoint(i, j)
		if (value > 0) then
			terrainChunk:newPoint(value - delta*math.sin(value*math.pi/2)*3, i, j)
			terrainChunk:isoEdge(i, j, 0.5)
			-- terrainChunk:initialiseMesh()
		end
	end

	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		camXOffset = camXOffset + delta*300
	end
	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		camXOffset = camXOffset - delta*300
	end
	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		camYOffset = camYOffset - delta*300
	end
	if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		camYOffset = camYOffset + delta*300
	end
end

function love.draw()
	love.graphics.setWireframe(wireframe)
	love.graphics.translate(camXOffset, camYOffset)
		terrainChunk:drawMesh()
		-- terrainChunk:drawPoints()
		-- water:drawPoints()
		-- water:draw()

	love.graphics.setWireframe(false)
	love.graphics.origin()
		local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
		local x, y = love.mouse.getX(), love.mouse.getY()
		love.graphics.setColor(x/windowWidth, y/windowHeight, 1-x/windowWidth, 1)
			local x = math.floor(x/scale)*scale
			local y = math.floor(y/scale)*scale
			love.graphics.circle("line", x, y, 0.5*scale/2)
		love.graphics.setColor(0.0, 1.0, 0.1)
			love.graphics.print(fps, 0, 0)
		love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key)
	local xShift = love.math.random()*1000000
	local yShift = love.math.random()*1000000
	if key == "r" then
		for y = 1, numV+shift*2 do
			for x = 1, numH+shift*2 do
				-- local value = 1
				local value = love.math.noise((x+xShift)/numH*noiseScale, (y+yShift)/numV*noiseScale)
				-- if (value < 0.40) then
				-- 	value = 0
				-- elseif (value > 0.60) then
				-- 	value = 1
				-- end
				terrainChunk:newPoint(value, y, x)
			end	
		end
		terrainChunk:initialiseMesh()
	elseif key == "space" then
		terrainChunk:initialiseMesh()
	end
end

function love.quit()
	saveLoad.save(terrainChunk)
end