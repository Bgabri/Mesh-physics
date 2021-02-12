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
	local shiftX = 0.5*self.scale
	for i = 1, #self.terrainPoints-1 do
		self.terrainTriangle[i] = {}
		local row = self.terrainPoints[i]
		for j = 2-i%2, #row-1 do
			local x, y = (j + i%2/2)*self.scale, i*self.height
			local value = self.terrainPoints[i][j]

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i][j+1], x + self.scale, y) -- left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- bottom node
			valueTriangle:intraprolated()
			table.insert(self.terrainTriangle[i], j*2, valueTriangle) -- iso down

			local valueTriangle = ValueTriangle()
			valueTriangle:addVertex(value, x, y) -- current node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2-1], x - shiftX, y + self.height) -- b left node
			valueTriangle:addVertex(self.terrainPoints[i+1][j+i%2], x + shiftX, y + self.height) -- b right node
			valueTriangle:intraprolated()
			table.insert(self.terrainTriangle[i], j*2+1, valueTriangle) -- iso up
		end
	end
end

function TerrainChunk:isoEdge(i, j)
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
	local relativeOctCords = {
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
		valueTriangle:intraprolated()
		self.terrainTriangle[relativeOctCords[k+1].i][relativeOctCords[k+1].j] = valueTriangle
	end
end

function TerrainChunk:draw()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	for i, row in ipairs(self.terrainTriangle) do
		for j = 1, #row do
			local value = row[j]
			if not (value == nil) then
				value:draw(width, height)
			end
		end
	end
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


