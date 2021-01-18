-- https://imgur.com/gallery/lMrgZ

local fps = 0
local terrain = {}
local test = {10, 10,10,10}
local scale = 10
local height = math.sqrt(3)/2*scale
local numV = love.graphics.getHeight()/height
local numH = love.graphics.getWidth()/scale - 1
local off = 0
function love.load()
	love.math.setRandomSeed(1)
	for i = 1, numV do
		terrain[i] = {}
		for j = 1, numH do
			terrain[i][j] = 0
			-- terrain[i][j] = math.floor(love.math.random()*2*2)/4
			-- terrain[i][j] = math.ceil(1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))
			-- terrain[i][j] = (1.1-(love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))))*10
			-- terrain[i][j] = (1-(math.ceil((love.math.noise((j/numH))+love.math.noise((love.math.noise(i/numV)))-1)*5)/3))
			if (terrain[i][j] < 0 ) then
				terrain[i][j] = 0
			elseif (terrain[i][j] > 1 ) then
				terrain[i][j] = 1
			end

			if (i == math.floor(numV/2)) then
				terrain[i][j] = 1
			end
		end	
	end

	terrain[10][11] = 1
	terrain[11][10] = 1
	terrain[11][11] = 1
	terrain[10][12] = 0.2

	local V = math.floor(numV/2)
	V = V+1-V%2
	local H = math.floor(numH/2)

	terrain[V][H] = 1
	terrain[V][H+1] = 1
	terrain[V][H+2] = 1
	-- terrain[V][H+3] = 0.1

	terrain[V+1][H] = 1
	terrain[V+2][H-1] = 1
	terrain[V+3][H] = 1
	terrain[V+4][H] = 1
	terrain[V+4][H+1] = 1
	terrain[V+4][H+2] = 1
	terrain[V+3][H+3] = 1
	terrain[V+2][H+3] = 1
	terrain[V+1][H+3] = 1


	-- terrain[6][12] = 1
	-- terrain[7][11] = 1
	-- terrain[7][12] = 1
end

function love.update(delta)
fps = love.timer.getFPS()
end

function love.draw()
	love.graphics.setPointSize(2)
	for i, row in ipairs(terrain) do
		for j, v in ipairs(row) do
			love.graphics.setColor(v+0.1, v+0.1, v+0.1)
			local x, y = (j + i%2/2)*scale, i*height
			love.graphics.points(x, y)
		end
	end
	love.graphics.setPointSize(1)
	love.graphics.setColor(0.4, 0.5, 1, 1)
	for i = 1, #terrain-1, 1 do
		for j = 2-i%2, #terrain[i]-1, 1 do
			local x, y = (j + i%2/2)*scale, i*height
			isoUp(terrain[i][j], terrain[i+1][j+i%2-1], terrain[i+1][j+i%2], x, y)
			isoDown(terrain[i][j], terrain[i][j+1], terrain[i+1][j+i%2], x, y)
		end
	end
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end

function newValue(value)
	if (value == nil) then
		value = 0
	end
	return value
end

function isoUp(top, bottomLeft, bottomRight, x, y)
	shiftX = 0.5*scale

	local intraValue = 0.5
	local value = (intraValue-top)/(bottomRight-top) -- right
	local x1 = x + shiftX*value
	local y1 = y + height*value
	local value = (bottomRight-intraValue)/(bottomLeft-bottomRight) -- bottom
	local x2 = x+shiftX + 2*(shiftX)*value
	local y2 = y + height
	local value = (intraValue-top)/(bottomLeft-top) -- left
	local x3 = x - shiftX*value
	local y3 = y + height*value
	return(x1, y1, x2, y2, x3, y3)
end

function isoDown(topLeft, topRight, bottom, x, y)
	shiftX = 0.5*scale
	local intraValue = 0.5
	local value = (intraValue-topLeft)/(topRight-topLeft) -- right
	local x1 = x + scale*value
	local y1 = y
	local value = (intraValue-topRight)/(bottom-topRight)
	local x2 = x + scale + (shiftX-scale)*value
	local y2 = y + height*value
	local value = (intraValue-topLeft)/(bottom-topLeft)
	local x3 = x + shiftX*value
	local y3 = y + height*value
	return(x1, y1, x2, y2, x3, y3)
end
