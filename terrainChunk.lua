TerrainChunk = Object:extend()

function TerrainChunk:new(scale, image)
	self.texture = image
	self.textureHeight = 0
	self.textureWidth = 0
	if not (self.texture == nil) then
		self.texture:setWrap("repeat", "repeat")
		self.textureHeight = self.texture:getHeight()
		self.textureWidth = self.texture:getWidth()
	end

	self.scale = scale

	-- self.terrainPoints = {}
	self.mesh = nil
	self.workingLength = 0
	self.meshVertices = {}
end

function TerrainChunk:valueAtPoint(i, j)
	return self.terrainPoints[i][j]
end

function TerrainChunk:getPoints()
	return self.terrainPoints
end

function TerrainChunk:newPoint(value, i, j)
	if(self.terrainPoints[i] == nil) then
		table.insert(self.terrainPoints, i, {})
	end
	if(self.terrainPoints[i][j] == nil) then
		table.insert(self.terrainPoints[i], j, value)
	else
		self.terrainPoints[i][j] = value
	end
end

function TerrainChunk:initialiseMesh(points)
	self.meshVertices = {}
	local function addVertices(vertices)
		for k,v in ipairs(vertices) do
			local vertixTable = {
				v[1], v[2],
				v[1]/self.textureWidth/2, v[2]/self.textureHeight/2,
				1, 1, 1, 1
			}
			table.insert(self.meshVertices, vertixTable)
		end
	end

	if not (points == nil) then
		self.terrainPoints = points
	end
	local shiftX = self.scale/2

	local valueSquare = ValueSquare()

	for i = 1, #self.terrainPoints-1 do
		local row = self.terrainPoints[i]
		for j = 1, #row-1 do
			local x, y = j*self.scale, i*self.scale
			local value = self.terrainPoints[i][j]

			valueSquare:replaceVertex(1, value, x, y) -- current node (top left)
			valueSquare:replaceVertex(2, self.terrainPoints[i][j+1], x + self.scale, y) -- top right node
			valueSquare:replaceVertex(3, self.terrainPoints[i+1][j+1], x + self.scale, y + self.scale) -- bottom right node
			valueSquare:replaceVertex(4, self.terrainPoints[i+1][j], x, y + self.scale) -- bottom left node
			addVertices(valueSquare:intraprolated(0.5))
		end
	end

	self.workingLength = #self.meshVertices
	if (self.workingLength > 0) then
		self.mesh = love.graphics.newMesh(self.workingLength+36000, "triangles")
		self.mesh:setVertices(self.meshVertices, 1, self.workingLength)
		self.mesh:setTexture(self.texture)
		self.mesh:setDrawRange(1, self.workingLength)
	end

	print("points: ".. self.workingLength)
end

function reorder(table)
	local tempTable = {}
	for i, vertix in ipairs(table) do
		for j, vertix2 in ipairs(table) do
		end
	end
end

function TerrainChunk:isoEdge(i, j, middleValue)
	local shiftX = 0.5*self.scale

	local function addVertices(vertices)
		for k,v in ipairs(vertices) do
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

	local x, y = j*self.scale, i*self.scale
	local value = self.terrainPoints[i][j]
	local valueSquare = ValueSquare()
	-- for k = 1, 4 do
		-- print(2*((k+2)%4+1), k*2-1, k*2)
		
		-- valueSquare:replaceVertex(2, self.terrainPoints[i + nygh[k*2          ].y][j + nygh[k*2          ].x], x + self.scale*nygh[k*2          ].x, y + self.scale*nygh[k*2          ].y) --
		-- valueSquare:replaceVertex(3, self.terrainPoints[i + nygh[k*2-1        ].y][j + nygh[k*2-1        ].x], x + self.scale*nygh[k*2-1        ].x, y + self.scale*nygh[k*2-1        ].y) -- opposite corner
		-- valueSquare:replaceVertex(4, self.terrainPoints[i + nygh[2*((k+2)%4+1)].y][j + nygh[2*((k+2)%4+1)].x], x + self.scale*nygh[2*((k+2)%4+1)].x, y + self.scale*nygh[2*((k+2)%4+1)].y) --
		valueSquare:replaceVertex(1, self.terrainPoints[i - 1][j - 1], x - self.scale, y - self.scale)
		valueSquare:replaceVertex(2, self.terrainPoints[i - 1][j + 0], x, y - self.scale) -- ••·
		valueSquare:replaceVertex(3, value, x, y) --                                         •*·
		valueSquare:replaceVertex(4, self.terrainPoints[i + 0][j - 1], x - self.scale, y) -- ···
		addVertices(valueSquare:intraprolated(middleValue))

		valueSquare:replaceVertex(1, self.terrainPoints[i - 1][j + 0], x, y - self.scale)
		valueSquare:replaceVertex(2, self.terrainPoints[i - 1][j + 1], x + self.scale, y - self.scale) -- ·••
		valueSquare:replaceVertex(3, self.terrainPoints[i + 0][j + 1], x + self.scale, y)              -- ·*•
		valueSquare:replaceVertex(4, value, x, y)                                                      -- ···
		addVertices(valueSquare:intraprolated(middleValue))

		valueSquare:replaceVertex(1, value, x, y)
		valueSquare:replaceVertex(2, self.terrainPoints[i + 0][j + 1], x + self.scale, y)              -- ···
		valueSquare:replaceVertex(3, self.terrainPoints[i + 1][j + 1], x + self.scale, y + self.scale) -- ·*•
		valueSquare:replaceVertex(4, self.terrainPoints[i + 1][j + 0], x, y + self.scale)              -- ·••
		addVertices(valueSquare:intraprolated(middleValue))

		valueSquare:replaceVertex(1, self.terrainPoints[i + 0][j - 1], x - self.scale, y)
		valueSquare:replaceVertex(2, value, x, y)                                                      -- ···
		valueSquare:replaceVertex(3, self.terrainPoints[i + 1][j + 0], x, y + self.scale)              -- •*·
		valueSquare:replaceVertex(4, self.terrainPoints[i + 1][j - 1], x - self.scale, y + self.scale) -- ••·
		addVertices(valueSquare:intraprolated(middleValue))

	self.mesh:setDrawRange(1, self.workingLength)
end

function TerrainChunk:drawMesh()
	if not (self.mesh == nil) then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.mesh)
	end
end

function TerrainChunk:drawPoints()
	for i, row in ipairs(self.terrainPoints) do
		for j,v in ipairs(row) do
			-- if (v >= 0.4) then
				love.graphics.setColor(v+0.1, v+0.1, v+0.1)
				love.graphics.points(j*self.scale, i*self.scale)
			-- end
		end
	end
end
