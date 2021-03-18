local scale = 5 -- number of pixels between each sample
local seed = math.floor(love.timer.getTime()) -- change seed for different terrain gen
local wireframe = false -- toggles wire frame display on/off
local noiseScale = 0.5 -- scale at which to generate noise
local chunkSize = 100 -- in pixels
-- to see changes generate terrain ("r")

local fps = 0
-- local shift = 10
local numV = math.floor(chunkSize/scale) + 1
local numH = math.floor(chunkSize/scale) + 1
local terrain = {}
local saveLoad = require "saveLoad"
local camXOffset = 0
local camYOffset = 0
local zoom = 1

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

	local screenWidth = math.ceil(love.graphics.getWidth()/chunkSize)+1
	local screenHeight = math.ceil(love.graphics.getHeight()/chunkSize)+1
	for x = -1, screenWidth do
		for y = -1, screenHeight do
			local terrainChunk = TerrainChunk(scale, terrainTexture, {chunkSize*x, chunkSize*y})
			table.insert(terrain, terrainChunk)
		end
	end

	local loadedPoints = saveLoad.load()
	local points = {}
	local yMax = numV
	local xMax = numH

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
	terrain[1]:initialiseMesh(points)
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
		local value = terrain[1]:valueAtPoint(i, j)
		if (value <= 1) then
			terrain[1]:newPoint(value + delta*math.cos(value*math.pi/2)*3, i, j)
			terrain[1]:isoEdge(i, j, 0.5)
			-- terrain[1]:initialiseMesh()
		end
	end

	if(love.mouse.isDown(2)) then
		local x = love.mouse.getX() - camXOffset
		local y = love.mouse.getY() - camYOffset
		local i = math.floor(y/scale)
		local j = math.floor(x/scale)
		local value = terrain[1]:valueAtPoint(i, j)
		if (value >= 0) then
			terrain[1]:newPoint(value - delta*math.sin(value*math.pi/2)*3, i, j)
			terrain[1]:isoEdge(i, j, 0.5)
			-- terrain[1]:initialiseMesh()
		end
	end

	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		camXOffset = camXOffset + delta*300*zoom
	end
	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		camXOffset = camXOffset - delta*300*zoom
	end
	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		camYOffset = camYOffset - delta*300*zoom
	end
	if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		camYOffset = camYOffset + delta*300*zoom
	end
end

function love.draw()
	love.graphics.setWireframe(wireframe)
		for _, chunk in ipairs(terrain) do
			love.graphics.translate(camXOffset, camYOffset)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.scale(zoom, zoom)
				chunk:drawMesh()
			-- love.graphics.translate(camXOffset, camYOffset)
			-- love.graphics.scale(zoom, zoom)
			-- 	chunk:drawPoints()
		end
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
			local time = love.timer.getTime()
			for i, chunk in ipairs(terrain) do
				local chunkX, chunkY =  chunk:getShift()
				local xShift = xShift + chunkX/scale
				local yShift = yShift + chunkY/scale
				for y = 1, numV do
					for x = 1, numH do
						-- local value = 0
						local value = love.math.noise((x+xShift)/numH*noiseScale, (y+yShift)/numV*noiseScale)
						if (value < 0.40) then
							value = 0
						elseif (value > 0.60) then
							value = 1
						end
						chunk:newPoint(value, y, x)
					end	
				end
				chunk:initialiseMesh()
			end
		local time2 = love.timer.getTime()
		print("t: "..time2-time)
	elseif key == "space" then
		terrain[1]:initialiseMesh()
	elseif key == "=" then
		zoom = zoom + 1
	elseif key == "-" then
		zoom = zoom - 1
	end

end

function love.quit()
	saveLoad.save(terrain[1])
end
