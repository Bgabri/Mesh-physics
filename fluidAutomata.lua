FluidAutomata = Object:extend()

function FluidAutomata:new(scale)
	self.scale = scale
	self.height = math.sqrt(3)/2*scale
	self.world = {}
	self.fluidValues = {}
	self.fluidChunk = TerrainChunk(scale)
end

function FluidAutomata:newAutomaton(value, i, j)
	if(self.fluidValues[i] == nil) then
		table.insert(self.fluidValues, i, {})
		-- table.setn(self.fluidValues, i)
	end
	if(self.fluidValues[i][j] == nil) then
		table.insert(self.fluidValues[i], j, value)
		-- table.setn(self.fluidValues[i], j)
	else
		self.fluidValues[i][j] = value
	end
	self.fluidChunk:newPoint(value, i, j)
end

function FluidAutomata:intializeAutomata()
	self.fluidChunk:findEdge()
end

function FluidAutomata:update(delta)
	local grav = 30*delta
	print(grav)
	-- print(table.getn(self.fluidValues))
	-- table.setn(self.fluidValues, 10)
	-- for i,row in ipairs(self.fluidValues) do
	local shiftX = 0.5*self.scale
	for i = 2, #self.fluidValues-1 do
		local row = self.fluidValues[i]
		for j = 2-i%2, #row-1 do
			-- local x, y = (j + i%2/2)*self.scale, i*self.height
			local value = self.fluidValues[i][j]
			local relativeOctValues = {
				{
					value = self.fluidValues[i-1][j+i%2-1], --  • ·
					j = j + i%2 - 1,						-- · · ·
					i = i - 1						        --  · ·
				},{
					value = self.fluidValues[i-1][j+i%2], --  · •
					j = j + i%2,						  -- · · ·
					i = i - 1					          --  · ·
				},{
					value = self.fluidValues[i][j+1], 	 --  · ·
					j = j + 1,			           		 -- · · •
					i = i								 --  · ·
				},{
					value = self.fluidValues[i+1][j+i%2], --  · ·
					j = j + i%2,						  -- · · ·
					i = i + 1					          --  · •
				},{
					value = self.fluidValues[i+1][j+i%2-1], --  · ·
					j = j + i%2-1,						    -- · · ·
					i = i + 1					            --  • ·
				},{
					value = self.fluidValues[i][j-1],--  · ·
					j = j - 1,				         -- • · ·
					i = i							 --  · ·
				}
			}
			if (value > 0) then
				local yes = 0
				-- if(relativeOctValues[6].value < 1 and relativeOctValues[3].value < 1) then
				-- 	self.fluidValues[relativeOctValues[3+3*yes].i][relativeOctValues[3+3*yes].j] = self.fluidValues[relativeOctValues[3+3*yes].i][relativeOctValues[3+3*yes].j] + grav
				-- 	self.fluidValues[i][j] = self.fluidValues[i][j] - grav
				-- 	self.fluidChunk:newPoint(value, i, j)
				-- 	self.fluidChunk:isoEdge(i, j)
				-- end
				if(relativeOctValues[4].value < 1 and relativeOctValues[5].value < 1) then
					self.fluidValues[relativeOctValues[4+1*yes].i][relativeOctValues[4+1*yes].j] = self.fluidValues[relativeOctValues[4+1*yes].i][relativeOctValues[4+1*yes].j] + grav
					self.fluidValues[i][j] = self.fluidValues[i][j] - grav
					self.fluidChunk:newPoint(value, i, j)
					self.fluidChunk:isoEdge(i, j)
				end
			end
			-- else()
			-- self.fluidChunk:isoEdge(i, j)
		end
	end
end

function FluidAutomata:draw()
	self.fluidChunk:draw()
end

function FluidAutomata:drawPoints()
	self.fluidChunk:drawPoints()
end
