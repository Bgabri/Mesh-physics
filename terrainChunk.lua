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
	self.height = math.sqrt(3)/2*scale

	self.terrainPoints = {}
	self.mesh = nil
	self.workingLength = 0
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
	local meshVertices = {}
	local function addVertices(vertices)
		for k,v in ipairs(vertices) do
			local vertixTable = {
				v[1], v[2],
				v[1]/self.textureWidth/self.scale, v[2]/self.textureHeight/self.scale,
				1, 1, 1, 1
			}
			table.insert(meshVertices, vertixTable)
		end
	end

	if not (points == nil) then
		self.terrainPoints = points
	end
	local shiftX = 0.5*self.scale
	for i = 1, #self.terrainPoints-1 do
		local row = self.terrainPoints[i]
		for j = #row-1, 2-i%2, -1 do
			local x, y = (j + i%2/2)*self.scale, i*self.height
			local value = self.terrainPoints[i][j]

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y) -- left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- bottom node
			addVertices(valueTriangle:intraprolated(0.5)) -- iso up

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height) -- b left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- b right node
			addVertices(valueTriangle:intraprolated(0.5)) -- iso down
		end
	end
	self.workingLength = #meshVertices
	if (self.workingLength > 0) then
		self.mesh = love.graphics.newMesh(self.workingLength+18000, "triangles")
		self.mesh:setVertices(meshVertices, 1, self.workingLength)
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
	local height = love.graphics.getHeight()
	local width = love.graphics.getWidth()
	local shiftX = 0.5*self.scale
	local numV = math.floor(love.graphics.getHeight()/self.height)
	local numH = math.floor(love.graphics.getWidth()/self.scale) - 1

	local function addVertices(vertices)
		for k,v in ipairs(vertices) do
			self.workingLength = self.workingLength + 1
			local vertixTable = {
				v[1], v[2],
				v[1]/self.textureWidth/self.scale, v[2]/self.textureHeight/self.scale,
				1, 1, 1, 1
			}

			if (self.workingLength > self.mesh:getVertexCount()) then
				break
				-- self.mesh = love.graphics.newMesh(self.workingLength+100000, "triangles")
				-- self.mesh:setTexture(self.texture)
				-- self.mesh:setDrawRange(1, self.workingLength)
				-- self.mesh:setVertices(tempVertexMap, 1, self.workingLength)
			end
			self.mesh:setVertex(self.workingLength, vertixTable)
		end
	end

	local x, y = (j + i%2/2)*self.scale, i*self.height
	local value = self.terrainPoints[i][j]
	local relativeOctValues = {
		{
			value = self.terrainPoints[i-1][j+i%2-1],--  • ·
			x = x - shiftX,							 -- · · ·
			y = y - self.height						 --  · ·
		},{
			value = self.terrainPoints[i-1][j+i%2],  --  · •
			x = x + shiftX,							 -- · · ·
			y = y - self.height						 --  · ·
		},{
			value = self.terrainPoints[i][j+1], 	 --  · ·
			x = x + self.scale,					  	 -- · · •
			y = y								  	 --  · ·
		},{
			value = self.terrainPoints[i+1][j+i%2],	 --  · ·
			x = x + shiftX,							 -- · · ·
			y = y + self.height						 --  · •
		},{
			value = self.terrainPoints[i+1][j+i%2-1],--  · ·
			x = x - shiftX,							 -- · · ·
			y = y + self.height						 --  • ·
		},{
			value = self.terrainPoints[i][j-1], 	 --  · ·
			x = x - self.scale,					  	 -- • · ·
			y = y								  	 --  · ·
		}
	}
	local relativeTableCords = {
		{						--  * •
			i = i-1,			-- · • ·
			j = (j+i%2-1)*2		--  · ·
		},{						--  · *
			i = i-1,			-- · • •
			j = (j+i%2)*2+1		--  · ·
		},{						--  · ·
			i = i,				-- · * •
			j = j*2				--  · •
		},{						--  · ·
			i = i,				-- · * ·
			j = j*2+1			--  • •
		},{						--  · ·
			i = i,				-- * • ·
			j = (j-1)*2			--  • ·
		},{						--  * ·
			i = i-1,			-- • • ·
			j = (j+i%2-1)*2+1	--  · ·
		}
	}
	for k = 0, 5 do
		local valueTriangle = ValueTriangle()
		valueTriangle:addVertex(value, x, y)
		valueTriangle:addVertex(relativeOctValues[k%6+1].value, relativeOctValues[k%6+1].x, relativeOctValues[k%6+1].y)
		valueTriangle:addVertex(relativeOctValues[(k+1)%6+1].value, relativeOctValues[(k+1)%6+1].x, relativeOctValues[(k+1)%6+1].y)
		addVertices(valueTriangle:intraprolated(middleValue))
	end
	self.mesh:setDrawRange(1, self.workingLength)
end

function TerrainChunk:drawMesh()
	if not (self.mesh == nil) then
		love.graphics.draw(self.mesh)
	end
end

function TerrainChunk:drawPoints()
	for i, row in ipairs(self.terrainPoints) do
		for j,v in ipairs(row) do
			-- if (v > 0) then
				local x, y = (j + i%2/2)*self.scale, i*self.height
				love.graphics.setColor(v+0.1, v+0.1, v+0.1)
				love.graphics.points(x, y)
			-- end
		end
	end
end
