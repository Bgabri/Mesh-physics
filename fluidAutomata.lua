FluidAutomata = Object:extend()

function FluidAutomata:new(scale)
	self.world = {}
	self.fluidValues = {}
	self.fluidChunk = TerrainChunk(scale)
end

function FluidAutomata:newAutomaton(value, i, j)
	if(self.fluidValues[i] == nil) then
		table.insert(self.fluidValues, i, {})
	end
	if(self.fluidValues[i][j] == nil) then
		table.insert(self.fluidValues[i], j, value)
	else
		self.fluidValues[i][j] = value
	end
	self.fluidChunk:newPoint(value, i, j)
end

function FluidAutomata:intialiseAutomata()
	self.fluidChunk:initialiseMesh()
end

function FluidAutomata:update(delta)
	local grav = delta*3
	-- print(grav)
	for i = #self.fluidValues-2, 2+1, -1 do
		local row = self.fluidValues[i]
		for j = 2-i%2+1, #row-2 do
			local value = self.fluidValues[i][j]
			if (value > 0) then
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

				if (relativeOctValues[4].value <= 1 and relativeOctValues[5].value <= 1 and i%2 == 0) then
					self:updateValue(i, j, -grav)
					self:updateValue(relativeOctValues[5].i, relativeOctValues[5].j, grav/2)
					self:updateValue(relativeOctValues[4].i, relativeOctValues[4].j, grav/2)
				elseif(relativeOctValues[4].value <= 1 and relativeOctValues[3].value > 0 and i%2 == 1) then
					self:updateValue(relativeOctValues[4].i, relativeOctValues[4].j, grav)
					self:updateValue(relativeOctValues[3].i, relativeOctValues[3].j, -grav/2)
					self:updateValue(i, j, -grav/2)
				elseif(relativeOctValues[5].value <= 1 and relativeOctValues[6].value > 0 and i%2 == 1) then
					self:updateValue(relativeOctValues[5].i, relativeOctValues[5].j, grav)
					self:updateValue(relativeOctValues[6].i, relativeOctValues[6].j, -grav/2)
					self:updateValue(i, j, -grav/2)
				elseif (relativeOctValues[4].value <= 1 and i%2 == 1) then
					self:updateValue(relativeOctValues[4].i, relativeOctValues[4].j, grav)
					self:updateValue(i, j, -grav)
				end if (relativeOctValues[3].value <= 1 or relativeOctValues[6].value <= 1) and (relativeOctValues[4].value >= 0.5 or relativeOctValues[5].value >= 0.5) then
					local value = 3 + math.floor(love.math.random()*2)*3
					self:updateValue(i, j, -grav*3)
					self:updateValue(relativeOctValues[value].i, relativeOctValues[value].j, grav*3)
				end
			end
		end
	end
end

function FluidAutomata:updateValue(i, j, value)
	if(i > 0 and j > 0) then
		local tempValue = self.fluidValues[i][j] + value
		self.fluidValues[i][j] = tempValue
		local middleValue = 0.5
		if(tempValue < 0.5 and tempValue > 0.1) then
			middleValue = tempValue-0.1
		end
		self.fluidChunk:newPoint(tempValue, i, j)
		self.fluidChunk:isoEdge(i, j, middleValue)
	end
end

function FluidAutomata:draw()
	self.fluidChunk:drawMesh()
end

function FluidAutomata:drawPoints()
	self.fluidChunk:drawPoints()
end