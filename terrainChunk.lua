TerrainChunk = Object:extend()

function TerrainChunk:new(scale)
	self.scale = scale
	self.height = math.sqrt(3)/2*scale
	self.terrainPoints = {}
	self.terrainTriangle = {}
	self.edge = {}
end

function TerrainChunk:newPoint(value, i, j)
	if(self.terrainPoints[i] == nil) then
		table.insert(self.terrainPoints, i, {})
	end

	table.insert(self.terrainPoints[i], j, value)

	-- local xyValue = y*10000 + x
	-- local index = binarySearch(xyValue, self.terrainPoints, 1, #self.terrainPoints)
	-- if not (index == -1) then
	-- 	table.insert(self.terrainPoints, index, valueVertex)
	-- else
	-- 	if (#self.terrainPoints == 0 or xyValue > self.terrainPoints[#self.terrainPoints].y*10000 + self.terrainPoints[#self.terrainPoints].x) then
	-- 		table.insert(self.terrainPoints, valueVertex)
	-- 	elseif(xyValue < self.terrainPoints[1].y*10000 + self.terrainPoints[1].x) then
	-- 		table.insert(self.terrainPoints, 0, valueVertex)
	-- 	end
	-- end -- this maybe
end

function TerrainChunk:findEdge()
	for i,v in ipairs(self.terrainTriangle) do
		v:intraprolated()
	end
end

function TerrainChunk:draw()
	for i,v in ipairs(self.terrainTriangle) do
		v:draw()
	end
end

function binarySearch(value, table, lowerIndex, higherIndex)
	if(higherIndex <= lowerIndex) then
		return -1
	else
		local middleI = math.ceil((higherIndex+lowerIndex)/2)
		local middle = table[middleI].y*10000 + table[middleI].x -- max of 10000x points
		if (value < middle) then
			return binarySearch(value, table, lowerIndex, middleI)
		elseif (value > middle) then
			return binarySearch(value, table, middleI, higherIndex)
		else
			return middleI
		end
	end
end

function TerrainChunk:transform()
	local shiftX = 0.5*self.scale
	-- for i, row in ipairs(self.terrainPoints) do
	-- 	for j, value in ipairs(row) do
	for i = 0 , #self.terrainPoints-1, 1 do
		local row = self.terrainPoints[i]
		-- print(self.terrainPoints[i])
		if not (row == nil) then
			for j = 2-i%2, #row-1, 1 do
				local x, y = (j + i%2/2)*self.scale, i*self.height
				local value = self.terrainPoints[i][j]
				local valueTriangle = ValueTriangle()

				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				table.insert(self.terrainTriangle, valueTriangle)

				valueTriangle = ValueTriangle()
				valueTriangle:addVertex(value, x, y)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height)
				valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height)
				table.insert(self.terrainTriangle, valueTriangle)
			end
		end
	end
end