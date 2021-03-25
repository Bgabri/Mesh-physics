local scale = 20 -- number of pixels between each sample
local chunkSize = 100 -- in pixels
local seed = math.floor(love.timer.getTime()) -- change seed for different terrain gen
local noiseScale = 0.1 -- scale at which to generate noise
local playerSpeed = 200
local wireframe = false -- toggles wire frame display on/off
local persistantWindow = false
-- to see changes generate terrain ("r")

running = {}
local timer1 = 0
local fps = 0
-- local shift = 10
local numV = math.floor(chunkSize/scale) + 1
local numH = math.floor(chunkSize/scale) + 1
local terrain
local saveLoad = require "Modules/saveLoad"
local camXOffset = 0
local camYOffset = 0
local zoom = 1
local qx, qy = 300,300
local screenWidth = 1280
local screenHeight = 800


local player = {
	t = nil,
	x = 0,
	y = 0,
	r = 13,
	theta = 0,
	thetaV = 3,
	v = playerSpeed
}

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
	player.t = love.graphics.newImage("Assets/nautilus.png")
	timer1 = love.timer.getTime()
	terrain = Terrain(terrainTexture, scale, chunkSize, noiseScale, love.math.random()*1000000, love.math.random()*1000000)

	-- love.graphics.setBackgroundColor(51/255, 26/255, 51/255)
end

local test = 0
function love.update(delta)
	fps = love.timer.getFPS()

	if(love.mouse.isDown(1)) then
		terrain:addPoint()
	end

	if(love.mouse.isDown(2)) then
		terrain:removePoint()
	end

	if (#running > 0 and running[1]:update()) then
		table.remove(running, 1)
		if (#running == 0) then
			print("t: "..love.timer.getTime()-timer1)
		end
	end

	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		player.theta = player.theta - player.thetaV*delta
	end
	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		player.theta = player.theta + player.thetaV*delta
	end

	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		-- camYOffset = camYOffset - delta*300*math.sqrt(math.abs(zoom))
		-- terrain:updatePosition(camXOffset, camYOffset)
		local prevX = player.x
		local prevY = player.y

		player.x = player.x + player.v*delta*math.cos(player.theta)
		-- if(terrain:resolveColision(player.x, player.y, player.r)) then
		-- 	player.x = prevX
		-- end

		player.y = player.y + player.v*delta*math.sin(player.theta)
		-- if(terrain:resolveColision(player.x, player.y, player.r)) then
		-- 	player.y = prevY
		-- end
		qx, qy = terrain:resolveColision(player.x, player.y, player.r, player.v)
	elseif (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		-- camYOffset = camYOffset + delta*300*math.sqrt(math.abs(zoom))
		-- terrain:updatePosition(camXOffset, camYOffset)
		local prevX = player.x
		local prevY = player.y

		player.x = player.x - player.v*delta*math.cos(player.theta)
		-- if(terrain:resolveColision(player.x, player.y, player.r)) then
		-- 	player.x = prevX
		-- end

		player.y = player.y - player.v*delta*math.sin(player.theta)

		-- if(terrain:resolveColision(player.x, player.y, player.r)) then
		-- 	player.y = prevY
		-- end
		-- player.x, player.y = terrain:resolveColision(player.x, player.y, player.r)
		-- if (terrain:resolveColision(player.x, player.y, player.r)) then

		-- end
		qx, qy = terrain:resolveColision(player.x, player.y, player.r, player.v)
		-- qx, qy = 0, 0
		if (qx and qy) then
			-- player.x = prevX
			-- player.y = prevY

		local Δx = qx - player.x
		local Δy = qy - player.y
		local d = math.sqrt((Δx)^2 + (Δy)^2)

		if(d < player.r) then
			-- player.x = prevX
			-- player.y = prevY
		-- print(Δx, Δy)

			local Δx = qx - prevX
			local Δy = qy - prevY
			local d = math.sqrt((Δx)^2 + (Δy)^2)		
			d = (d - player.r)/d
			-- if not (player.r/d == 1/0) then
				player.x = player.x + Δx*d
				player.y = player.y + Δy*d
			-- end
			end
		end
		-- print(qx, qy)
		-- print(terrain:resolveColision(player.x, player.y, player.r))
	end
	if not (persistantWindow) then
	love.window.setPosition(screenWidth/2 - love.graphics.getWidth()/2 + player.x, screenHeight/2 - love.graphics.getHeight()/2 + player.y)
	end
	camYOffset = love.graphics.getHeight()/2-player.y
	camXOffset = love.graphics.getWidth()/2-player.x
	terrain:updatePosition(camXOffset, camYOffset)
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

	love.graphics.setColor(1.0, 1.0, 1.0)
		-- 35, 23
		love.graphics.draw(player.t, player.x, player.y, player.theta, 1, 1, player.t:getWidth()/2, player.t:getHeight()/2)
	love.graphics.setColor(0.0, 1.0, 0.1)
		terrain:drawOutline()
		love.graphics.circle("line", player.x, player.y, player.r)
		love.graphics.setPointSize(2)
		-- love.graphics.points(qx, qy)

	love.graphics.setWireframe(false)
	love.graphics.origin()
		love.graphics.print(fps, 0, 0)
		love.graphics.print(math.floor(camXOffset)..", "..math.floor(camYOffset), 0, 20)
		love.graphics.print(zoom, 0, 40)

		local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
		local x, y = love.mouse.getX(), love.mouse.getY()
		love.graphics.setColor(x/windowWidth, y/windowHeight, 1-x/windowWidth, 1)
			local x = math.floor(x/scale)*scale
			local y = math.floor(y/scale)*scale
			-- love.graphics.circle("line", x, y, 0.5*scale/2)
		-- love.graphics.points(player.x-4 + player.r+4, player.y+2 + player.r-2)
end

function love.keypressed(key)
	if key == "r" then
		local xShift = love.math.random()*1000000
		local yShift = love.math.random()*1000000

		if (#running == 0) then
			timer1 = love.timer.getTime()
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

