TerrainChunk = Object:extend()

function TerrainChunk:new(scale)
	self.scale = scale
	self.height = math.sqrt(3)/2*scale
	self.terrainPoints = {}
	self.terrainTriangle = {}
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

function TerrainChunk:toTri()
	local shiftX = 0.5*self.scale
	for i = 1, #self.terrainPoints-1, 1 do
		self.terrainTriangle[i] = {}
		local row = self.terrainPoints[i]
		if not (row == nil) then
			for j = 2-i%2, #row-1, 1 do
				local x, y = (j + i%2/2)*self.scale, i*self.height
				local value = self.terrainPoints[i][j]
				local valueTriangle = ValueTriangle()
				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				table.insert(self.terrainTriangle[i], j*2, valueTriangle)

				local valueTriangle = ValueTriangle()
				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				table.insert(self.terrainTriangle[i], j*2+1, valueTriangle)
			end
		end
	end
end

function TerrainChunk:findEdge()
	self:toTri()
	for i = 1, #self.terrainTriangle do
		local row = self.terrainTriangle[i]
		for j = 1, #row do
			local value = row[j]
			if not (value == nil) then
				value:intraprolated()
			end
		end
	end
end

function TerrainChunk:isoEdge(i, j, r)
	local shiftX = 0.5*self.scale
	local numV = math.floor(love.graphics.getHeight()/self.height)
	local numH = math.floor(love.graphics.getWidth()/self.scale) - 1
	for i2 = i-r, i+r do
		if (i2 > 0 and i2 < numV) then
			for j2 = j-r, j+r do
				if (j2 > 0 and j2 < numH) then
					local x, y = (j2 + i2%2/2)*self.scale, i2*self.height
					local value = self.terrainPoints[i2][j2]
					local valueTriangle = ValueTriangle()

					valueTriangle:addVertex(value, x, y)
					valueTriangle:addVertex(self.terrainPoints[i2][j2+1], x + self.scale, y)
					valueTriangle:addVertex(self.terrainPoints[i2+1][j2+i2%2], x + shiftX, y + self.height)
					valueTriangle:intraprolated()
					self.terrainTriangle[i2][j2*2] = valueTriangle

					local valueTriangle = ValueTriangle()
					valueTriangle:addVertex(value, x, y)
					valueTriangle:addVertex(self.terrainPoints[i2+1][j2+i2%2-1], x - shiftX, y + self.height)
					valueTriangle:addVertex(self.terrainPoints[i2+1][j2+i2%2], x + shiftX, y + self.height)
					valueTriangle:intraprolated()
					self.terrainTriangle[i2][j2*2+1] = valueTriangle
				end
			end
		end
	end
	self.terrainTriangle[10][10*2]:intraprolated()
end

function TerrainChunk:draw()
	for i = 1, #self.terrainTriangle do
		local row = self.terrainTriangle[i]
		for j = 1, #row do
			local value = row[j]
			if not (value == nil) then
				value:draw()
			end
		end
	end
end