TerrainChunk = Object:extend()

function TerrainChunk:new(scale, image)
	self.texture = image
	self.scale = scale
	self.height = math.sqrt(3)/2*scale
	self.terrainPoints = {}
	self.mesh = nil
	self.chunkVertices = {}
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

function TerrainChunk:initialiseMesh()
	local shiftX = 0.5*self.scale
	for i = 1, #self.terrainPoints-1 do
		local row = self.terrainPoints[i]
		for j = 2-i%2, #row-1 do
			local x, y = (j + i%2/2)*self.scale, i*self.height
			local value = self.terrainPoints[i][j]

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y) -- left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- bottom node
			local vertices = valueTriangle:intraprolated(0.5)
			for k,v in ipairs(vertices) do
				local vertixTable = {
					v[1], v[2],
					0, 1,
 					1, 1, 1, 1
				}
				table.insert(self.chunkVertices, vertixTable) -- iso up
			end

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height) -- b left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- b right node
			local vertices = valueTriangle:intraprolated(0.5)
			for k,v in ipairs(vertices) do
				local vertixTable = {
					v[1], v[2],
					0, 1,
 					1, 1, 1, 1
				}
				table.insert(self.chunkVertices, vertixTable) -- iso down
			end
		end
	end
	self.mesh = love.graphics.newMesh(self.chunkVertices, "points")
	self.mesh:setTexture(self.texture)
end

function TerrainChunk:isoEdge(i, j, middleValue)
	local shiftX = 0.5*self.scale
	local numV = math.floor(love.graphics.getHeight()/self.height)
	local numH = math.floor(love.graphics.getWidth()/self.scale) - 1

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
		local vertices = valueTriangle:intraprolated(middleValue)
			for k,v in ipairs(vertices) do
				local vertixTable = {
					v[1], v[2],
					0, 1,
 					1, 1, 1, 1
				}
				table.insert(self.chunkVertices, vertixTable)
			end
	end
	self.mesh = love.graphics.newMesh(self.chunkVertices, "points")
	self.mesh:setTexture(self.texture)
end

function TerrainChunk:drawMesh()
	love.graphics.draw(self.mesh, 0, 0)
end

function TerrainChunk:drawPoints()
	for i, row in ipairs(self.terrainPoints) do
		for j,v in ipairs(row) do
			if (v > 0) then
				local x, y = (j + i%2/2)*self.scale, i*self.height
				love.graphics.setColor(v, v, v)
				love.graphics.points(x, y)
			end
		end
	end
end
