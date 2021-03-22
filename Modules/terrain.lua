Terrain = Object:extend()

function Terrain:new(texture, scale, chunkSize, noiseScale, perlinXShift, perlinYShift)
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

	for x = -1, self.screenWidth/chunkSize+1 do
		for y = -1, self.screenHeight/chunkSize+1 do
			local terrainChunk = TerrainChunk(self.scale, texture, {self.chunkSize*x, self.chunkSize*y})
			table.insert(self.terrainChunks, terrainChunk)
		end
	end
	self:generate()
end

function Terrain:draw()
	love.graphics.setColor(1, 1, 1, 1)
	for _, chunk in ipairs(self.terrainChunks) do
		chunk:drawMesh()
	end
end

function Terrain:drawPoints()
	love.graphics.setColor(1, 1, 1, 1)
	for _, chunk in ipairs(self.terrainChunks) do
		chunk:drawPoints()
	end
end

function Terrain:updatePosition(camX, camY)
	self.camX = camX
	self.camY = camY
end

function Terrain:resize(windowW, windowH)
	self.height = windowW
	self.width = windowH
end

function Terrain:removePoint(mouseX, mouseY)
	-- body
end

function Terrain:addPoint(mouseX, mouseY)
	-- body
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
				-- if (value < 0.40) then
				-- 	value = 0
				-- elseif (value > 0.60) then
				-- 	value = 1
				-- end
				chunk:newPoint(value, y, x)
			end	
		end
		chunk:initialiseThread()
		table.insert(running, chunk)
	end
end