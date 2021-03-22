TerrainChunk = Object:extend()

function TerrainChunk:new(scale, image, pos)
	self.texture = image
	self.textureHeight = 0
	self.textureWidth = 0
	self.x = 0
	self.y = 0
	self.id = love.math.random()
	if not (pos == nil) then
		self.x = pos.x or pos[1]
		self.y = pos.y or pos[2]
	end
	if not (self.texture == nil) then
		self.texture:setWrap("repeat", "repeat")
		self.textureHeight = self.texture:getHeight()
		self.textureWidth = self.texture:getWidth()
	end

	self.scale = scale

	self.terrainPoints = {}
	self.mesh = nil
	self.workingLength = 0
	self.meshVertices = {}
end

function TerrainChunk:valueAtPoint(i, j)
	if (self.terrainPoints[i] == nil) then
		return nil
	end
	return self.terrainPoints[i][j]
end

function TerrainChunk:getPoints()
	return self.terrainPoints
end

function TerrainChunk:newPoint(value, i, j)
	if (self.terrainPoints[i] == nil) then
		table.insert(self.terrainPoints, i, {})
	end
	if (self.terrainPoints[i][j] == nil) then
		table.insert(self.terrainPoints[i], j, value)
	else
		self.terrainPoints[i][j] = value
	end
end

function TerrainChunk:initialiseThread(points)
	self.meshVertices = {}

	self.generate = love.thread.newThread("Modules/counterGenerationThread.lua")
	self.generate:start(self.id, self.x, self.y, self.textureHeight, self.textureWidth, self.scale, self.terrainPoints)
end

function TerrainChunk:getThreadValue()
	while love.thread.getChannel("vertices"..self.id):getCount() > 0 do
		local vertixTable = love.thread.getChannel("vertices"..self.id):pop()
		if not (vertixTable == nil) then
			table.insert(self.meshVertices, vertixTable)
		end
	end

	if not (self.generate:isRunning()) then
		self.workingLength = #self.meshVertices
		self.mesh = love.graphics.newMesh(self.workingLength+36000, "triangles")
		self.mesh:setTexture(self.texture)
		if (self.workingLength > 0) then
			self.mesh:setVertices(self.meshVertices, 1, self.workingLength)
			self.mesh:setDrawRange(1, self.workingLength)
		end
		local error = self.generate:getError()
		assert(not error, error)
		
		return true
	end
	return false
end

function TerrainChunk:isoEdge(i, j, middleValue)
	local shiftX = 0.5*self.scale

	local function addVertices(vertices)
		for _, v in ipairs(vertices) do
			local vertixTable = {
				v[1], v[2],
				v[1]/self.textureWidth/2, v[2]/self.textureHeight/2,
				1, 1, 1, 1
			}

			self.workingLength = self.workingLength + 1
			table.insert(self.meshVertices,vertixTable)

			if (self.workingLength > self.mesh:getVertexCount()) then
				self.mesh = love.graphics.newMesh(self.workingLength + 36000, "triangles")
				self.mesh:setTexture(self.texture)
				self.mesh:setDrawRange(1, self.workingLength)
				self.mesh:setVertices(self.meshVertices, 1, self.workingLength)
				print("newLength: "..self.workingLength)
			end
			self.mesh:setVertex(self.workingLength, vertixTable)
		end
	end

	local x, y = j*self.scale + self.x, i*self.scale + self.y
	local valueSquare = ValueSquare()

	local relativeVertices = {
		{self.terrainPoints[i-1][j-1], x - self.scale, y - self.scale}, -- upper left
		{self.terrainPoints[i-1][j  ], x, y - self.scale},              -- upper middle
		{self.terrainPoints[i-1][j+1], x + self.scale, y - self.scale}, -- upper right
		{self.terrainPoints[i  ][j+1], x + self.scale, y},              -- middle right
		{self.terrainPoints[i+1][j+1], x + self.scale, y + self.scale}, -- lower right
		{self.terrainPoints[i+1][j  ], x, y + self.scale},              -- lower middle
		{self.terrainPoints[i+1][j-1], x - self.scale, y + self.scale}, -- lower left
		{self.terrainPoints[i  ][j-1], x - self.scale, y},              -- middle left
		{self.terrainPoints[i  ][j  ], j*self.scale, i*self.scale}}     -- current

	for k = 1, 4 do
		valueSquare:replaceVertex(1, relativeVertices[2^(k-1)   + (1-k)*(2-k)*(4-k)*2.5])
		valueSquare:replaceVertex(2, relativeVertices[k + 1     - (1-k)*(2-k)*(3-k)/6*4])
		valueSquare:replaceVertex(3, relativeVertices[k + 2     + (2-k)*(3-k)*(4-k)])
		valueSquare:replaceVertex(4, relativeVertices[(k+2)%4+5 - (1-k)*(3-k)*(4-k)*2])
		addVertices(valueSquare:intraprolated(middleValue))
	end

	if (self.workingLength > 1) then
		self.mesh:setDrawRange(1, self.workingLength)
	end
end

function TerrainChunk:getShift()
	return self.x, self.y
end

function TerrainChunk:drawMesh()
	if not (self.mesh == nil) then
		love.graphics.draw(self.mesh)
	end
end

function TerrainChunk:drawPoints()
	for i, row in ipairs(self.terrainPoints) do
		for j,v in ipairs(row) do
			if (v >= 0.5) then
				love.graphics.setColor(v+0.1, v+0.1, v+0.1)
				love.graphics.points(j*self.scale + self.x, i*self.scale + self.y)
			end
		end
	end
end
