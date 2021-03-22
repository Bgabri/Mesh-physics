local scale = 5 -- number of pixels between each sample
local chunkSize = 150 -- in pixels
local seed = math.floor(love.timer.getTime()) -- change seed for different terrain gen
local wireframe = false -- toggles wire frame display on/off
local noiseScale = 1 -- scale at which to generate noise
-- to see changes generate terrain ("r")
running = {}

local fps = 0
-- local shift = 10
local numV = math.floor(chunkSize/scale) + 1
local numH = math.floor(chunkSize/scale) + 1
local terrain
local saveLoad = require "Modules/saveLoad"
local camXOffset = 0
local camYOffset = 0
local zoom = 1

function love.load()
	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.math.setRandomSeed(seed)

	Object = require "Libraries/classic/classic"
	require "Libraries/collisions"
	require "Modules/valueSquare"
	require "Modules/terrainChunk"
	require "Modules/fluidAutomata"
	require "Modules/terrain"

	local terrainTexture = love.graphics.newImage("Assets/mesh.png")
	local waterTexture = love.graphics.newImage("Assets/water.png")
	terrain = Terrain(terrainTexture, scale, chunkSize, noiseScale, love.math.random()*1000000, love.math.random()*1000000)

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

		local value = terrain[1]:valueAtPoint(i, j) or 1
		if (value < 1) then
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
		local value = terrain[1]:valueAtPoint(i, j) or 0
		if (value > 0) then
			terrain[1]:newPoint(value - delta*math.sin(value*math.pi/2)*3, i, j)
			terrain[1]:isoEdge(i, j, 0.5)
			-- terrain[1]:initialiseMesh()
		end
	end

	if (#running > 0 and running[1]:getThreadValue()) then
		table.remove(running, 1)
	end

	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		camXOffset = camXOffset + delta*300*math.sqrt(math.abs(zoom))
	end
	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		camXOffset = camXOffset - delta*300*math.sqrt(math.abs(zoom))
	end
	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		camYOffset = camYOffset - delta*300*math.sqrt(math.abs(zoom))
	end
	if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		camYOffset = camYOffset + delta*300*math.sqrt(math.abs(zoom))
	end
end

function love.draw()
	love.graphics.setWireframe(wireframe)
	love.graphics.translate(camXOffset, camYOffset)
	if (zoom < 0) then love.graphics.scale(-1/zoom, -1/zoom) else
		love.graphics.scale(zoom, zoom)
	end

	terrain:draw()
	-- terrain:drawPoints()
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
			love.graphics.print(math.floor(camXOffset)..", "..math.floor(camYOffset), 0, 20)
			love.graphics.print(zoom, 0, 40)
end

function love.keypressed(key)
	if key == "r" then
		local xShift = love.math.random()*1000000
		local yShift = love.math.random()*1000000
		if (#running == 0) then
			terrain:generate(xShift, yShift)
		end
	elseif key == "=" then
		zoom = zoom + 1
		camXOffset = camXOffset - love.graphics.getHeight()/2
		camYOffset = camYOffset - love.graphics.getWidth()/2
	elseif key == "-" then
		zoom = zoom - 1
		-- camXOffset = camXOffset + love.graphics.getHeight()/4
		-- camYOffset = camYOffset + love.graphics.getWidth()/4
	end

end

function love.quit()
	-- saveLoad.save(terrain[1])
end


function love.resize()
end