TerrainChunk = Object:extend()

function TerrainChunk:new(scale, height)
	self.scale = scale
	self.height = height
	self.terrainPoints = {}
	self.terrainTriangle = {}
	self.edge = {}
end

-- function TerrainChunk:new(terrainPoints)
-- 	self.terrainPoints = terrainPoints
-- 	self.edge = {}
-- end

function TerrainChunk:draw()
	for i,v in ipairs(self.edge) do
		love.graphics.setColor(i/#self.edge, 0, 1-i/#self.edges, 1)
		love.graphics.line(v[1], v[2], v[3], v[4])
	end
end

function TerrainChunk:findEdge()
	for i, valueVertex in ipairs(terrainPoints) do
		local x1, y1, x2, y2, x3, y3 = isoUp(terrain[i][j], terrain[i+1][j+i%2-1], terrain[i+1][j+i%2], x, y)
		if not (x1 + y1 + x2 + y2 == 1/0)	then
			table.insert(edges, {x1, y1, x2, y2})
		end
		if not (x2 + y2 + x3 + y3 == 1/0)	then
			table.insert(edges, {x2, y2, x3 ,y3})
		end
		if not (x1 + y1 + x3 + y3 == 1/0)	then
			table.insert(edges, {x1, y1, x3, y3})
		end
	end
end

function TerrainChunk:newPoint(value, x, y)
	local valueVertex = {
		value = value,
		x = x,
		y = y
	}
	local i = math.floor(y/self.height)
	local j = math.floor(x/self.scale)

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
	for i, row in ipairs(self.terrainPoints) do
		for j, value in ipairs(row) do
			local x, y = (j + i%2/2)*scale, i*height
			local valueVertex = {
				value = value,
				x, y = x, y
			}
			local relativeIsoNeighbours = {
				{
					value = self.terrainPoints[i][j+1],
					x, y = x + scale, y
				}, -- right
				{
					value = self.terrainPoints[i+1][j+i%2],
					x, y = x + shiftX, y + height
				}, -- bottom right
				{
					value = self.terrainPoints[i+1][j+i%2-1],
					x, y = x - shiftX, y + height
				} -- bottom left
			}
			local valueTriangle = ValueTriangle()
			valueTrangle:addVertex(value, x, y)
			valueTrangle:addVertex(relativeIsoNeighbours[1].value, relativeIsoNeighbours[1].x, relativeIsoNeighbours[1].y)
			valueTrangle:addVertex(relativeIsoNeighbours[2].value, relativeIsoNeighbours[2].x, relativeIsoNeighbours[2].y)
			table.insert(self.terrainTriangle, valueTriangle)
			valueTrangle:replaceVertex(2, relativeIsoNeighbours[3].value, relativeIsoNeighbours[3].x, relativeIsoNeighbours[3].y)
			table.insert(self.terrainTriangle, valueTriangle)
		end
	end
end

function vertexAt(x, y)
end

-- function isoUp(top, bottomLeft, bottomRight, x, y)
-- 	local valueTriangle = ValueTriangle()
-- 	local shiftX = 0.5*scale
-- 	valueTriangle:addVertex(top, x, y)
-- 	valueTriangle:addVertex(bottomLeft, x - shiftX, y + height)
-- 	valueTriangle:addVertex(bottomRight, x + shiftX, y + height)

-- 	return valueTriangle:intraprolated()
-- end