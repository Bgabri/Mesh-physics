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

function TerrainChunk:findEdge()
	self:toTri()
	for i,v in ipairs(self.terrainTriangle) do
		v:intraprolated()
	end
end

function TerrainChunk:draw()
	for i,v in ipairs(self.terrainTriangle) do
		v:draw()
	end
end

function TerrainChunk:toTri()
	self.terrainTriangle = {}
	local shiftX = 0.5*self.scale
	for i = 0 , #self.terrainPoints-1, 1 do
		local row = self.terrainPoints[i]
		if not (row == nil) then
			for j = 2-i%2, #row-1, 1 do
				local x, y = (j + i%2/2)*self.scale, i*self.height
				local value = self.terrainPoints[i][j]
				local valueTriangle = ValueTriangle()
				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				if not (valueTriangle:empty()) then
					table.insert(self.terrainTriangle, valueTriangle)
				end

				valueTriangle = ValueTriangle()
				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				if not (valueTriangle:empty()) then
					table.insert(self.terrainTriangle, valueTriangle)
				end
			end
		end
	end
end