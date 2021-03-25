Terrain = Object:extend()

function Terrain:new(texture, scale, chunkSize, noiseScale, perlinXShift, perlinYShift)
	self.texture = texture
	self.scale = math.floor(scale)
	self.chunkSize = math.floor(chunkSize/self.scale)*self.scale
	self.noiseScale = noiseScale
	self.perlinXShift = perlinXShift
	self.perlinYShift = perlinYShift

	self.screenHeight = love.graphics.getHeight()
	self.screenWidth = love.graphics.getWidth()
	self.terrainChunks = {}
	self.camX = 0
	self.camY = 0

	-- for x = -1, self.screenWidth/self.chunkSize+1 do
	-- for y = -1, self.screenHeight/self.chunkSize+1 do

	for x = -math.floor(700/self.chunkSize), math.ceil(640/self.chunkSize) do
		for y = -math.floor(800/self.chunkSize), math.ceil(300/self.chunkSize) do
			local terrainChunk = TerrainChunk(self.scale, self.texture, {self.chunkSize*x, self.chunkSize*y})
			table.insert(self.terrainChunks, terrainChunk)
		end
	end
	self:generate()
end

function Terrain:draw()
	love.graphics.setColor(1, 1, 1, 1)
	for _, chunk in ipairs(self.terrainChunks) do
		local x, y = chunk:getShift()
		if (rectVsRect(x, y, self.chunkSize, self.chunkSize, self.camX-5, self.camY-5, self.screenWidth + 10, self.screenHeight + 10)) then
			chunk:drawMesh()
		end
	end
end

function Terrain:drawPoints()
	love.graphics.setColor(1, 1, 1, 1)
	for _, chunk in ipairs(self.terrainChunks) do
		local x, y = chunk:getShift()
		if (rectVsRect(x, y, self.chunkSize, self.chunkSize, self.camX-5, self.camY-5, self.screenWidth + 10, self.screenHeight + 10)) then
			chunk:drawPoints()
		end
	end
end

function Terrain:updatePosition(camX, camY)
	self.camX = -camX
	self.camY = -camY
	-- self:loadNewChunks()
end

function Terrain:resize(windowW, windowH)
	self.height = windowW
	self.width = windowH
end

function Terrain:resolveColision(x, y, r, v)
	local xMin, yMin = 1000, 1000
	for _, chunk in ipairs(self.terrainChunks) do
		local chunkX, chunkY = chunk:getShift()
		if circleVsRect(x, y, v, chunkX, chunkY, self.chunkSize, self.chunkSize) then
			qx, qy = chunk:resolveColision(x, y, r)
			if qx and qy then
				-- return qx, qy
			-- end
				if((x-qx)^2 + (y-qy)^2 < (x-xMin)^2 + (y-yMin)^2) then
					xMin, yMin = qx, qy
				end
			end
			-- print(chunkX, chunkY)
		end
	end

	if (xMin == 1000 and yMin == 1000) then
		return false, false
	end
	return xMin, yMin
	-- return false
end

function Terrain:loadNewChunks()
	for _, chunk in ipairs(self.terrainChunks) do
		local x, y = chunk:getShift()
		local test = rectVsRect(x, y, self.chunkSize, self.chunkSize, self.camX - self.chunkSize, self.camY - self.chunkSize, self.screenWidth + self.chunkSize*2, self.screenHeight + self.chunkSize*2)
		if not (test) then
			table.remove(self.terrainChunks, _)
			-- local terrainChunk = TerrainChunk(self.scale, self.texture, {self.chunkSize*x, self.chunkSize*y})
			-- table.insert(self.terrainChunks, terrainChunk)
		end
	end

	-- self.terrainChunks = {}
	-- for x = -1, self.screenWidth/self.chunkSize+1 do
		-- for y = -1, self.screenHeight/self.chunkSize+1 do
			-- local terrainChunk = TerrainChunk(self.scale, self.texture, {self.chunkSize*x, self.chunkSize*y})
			-- table.insert(self.terrainChunks, terrainChunk)
		-- end
	-- end
	-- self:generate()
end

function Terrain:drawOutline()
	for _, chunk in ipairs(self.terrainChunks) do
		local x, y = chunk:getShift()
		love.graphics.rectangle("line", x, y, self.chunkSize, self.chunkSize)
		love.graphics.rectangle("line", self.camX - self.chunkSize, self.camY - self.chunkSize, self.screenWidth + self.chunkSize*2, self.screenHeight + self.chunkSize*2)
	end
end

function Terrain:addPoint(mouseX, mouseY)
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

function Terrain:removePoint(mouseX, mouseY)
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

function Terrain:generate(xShift, yShift)
	local xShift = xShift or self.perlinXShift
	local yShift = yShift or self.perlinYShift
	local points = self.chunkSize/self.scale + 1

	for _, chunk in ipairs(self.terrainChunks) do
		local chunkX, chunkY =  chunk:getShift()
		local xShift = xShift + chunkX/self.scale
		local yShift = yShift + chunkY/self.scale
		for y = 1, points do
			for x = 1, points do
				-- local value = 1
				local value = love.math.noise((x+xShift)/points*self.noiseScale, (y+yShift)/points*self.noiseScale)
				-- value = value + love.math.noise((x+xShift)/points*2, (y+yShift)/points*2)*value
				-- value = value + love.math.noise((x+xShift)/points*5, (y+yShift)/points*5)*value
				if (value < 0) then
					value = 0
				elseif (value > 1) then
					value = 1
				end
				chunk:newPoint(value, y, x)
			end	
		end
		chunk:initialiseThread()
		table.insert(running, chunk)
	end
end