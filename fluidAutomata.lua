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
	local grav = delta*40
	-- print(grav)
	local shiftX = 0.5*self.scale
	for i = #self.fluidValues-2, 2+1, -1 do
		local row = self.fluidValues[i]
		for j = 2-i%2+1, #row-2 do
			-- local x, y = (j + i%2/2)*self.scale, i*self.height
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
					self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j] = relativeOctValues[4].value + grav/2
					self.fluidValues[relativeOctValues[5].i][relativeOctValues[5].j] = relativeOctValues[5].value + grav/2
					self.fluidValues[i][j] = value - grav



					self.fluidChunk:newPoint(self.fluidValues[i][j], i, j)
					self.fluidChunk:isoEdge(i, j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j], relativeOctValues[4].i, relativeOctValues[4].j)
					self.fluidChunk:isoEdge(relativeOctValues[4].i, relativeOctValues[4].j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[5].i][relativeOctValues[5].j], relativeOctValues[5].i, relativeOctValues[5].j)
					self.fluidChunk:isoEdge(relativeOctValues[5].i, relativeOctValues[5].j)
				end

				if(relativeOctValues[4].value <= 1 and relativeOctValues[3].value > 0 and i%2 == 1) then
					self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j] = relativeOctValues[4].value + grav
					self.fluidValues[relativeOctValues[3].i][relativeOctValues[3].j] = relativeOctValues[3].value - grav/2
					self.fluidValues[i][j] = value - grav/2



					self.fluidChunk:newPoint(self.fluidValues[i][j], i, j)
					self.fluidChunk:isoEdge(i, j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j], relativeOctValues[4].i, relativeOctValues[4].j)
					self.fluidChunk:isoEdge(relativeOctValues[4].i, relativeOctValues[4].j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[3].i][relativeOctValues[3].j], relativeOctValues[3].i, relativeOctValues[3].j)
					self.fluidChunk:isoEdge(relativeOctValues[3].i, relativeOctValues[3].j)

				elseif(relativeOctValues[5].value <= 1 and relativeOctValues[6].value > 0 and i%2 == 1) then
					self.fluidValues[relativeOctValues[5].i][relativeOctValues[5].j] = relativeOctValues[5].value + grav
					self.fluidValues[relativeOctValues[6].i][relativeOctValues[6].j] = relativeOctValues[6].value - grav/2
					self.fluidValues[i][j] = value - grav/2



					self.fluidChunk:newPoint(self.fluidValues[i][j], i, j)
					self.fluidChunk:isoEdge(i, j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[5].i][relativeOctValues[5].j], relativeOctValues[5].i, relativeOctValues[5].j)
					self.fluidChunk:isoEdge(relativeOctValues[5].i, relativeOctValues[5].j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[6].i][relativeOctValues[6].j], relativeOctValues[6].i, relativeOctValues[6].j)
					self.fluidChunk:isoEdge(relativeOctValues[6].i, relativeOctValues[6].j)

				elseif (relativeOctValues[4].value <= 1 and i%2 == 1) then
					self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j] = relativeOctValues[4].value + grav
					self.fluidValues[i][j] = value - grav



					self.fluidChunk:newPoint(self.fluidValues[i][j], i, j)
					self.fluidChunk:isoEdge(i, j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[4].i][relativeOctValues[4].j], relativeOctValues[4].i, relativeOctValues[4].j)
					self.fluidChunk:isoEdge(relativeOctValues[4].i, relativeOctValues[4].j)
				elseif (relativeOctValues[3].value <= 1 or relativeOctValues[6].value <= 1) and (relativeOctValues[4].value >= 1 or relativeOctValues[5].value >=1) then
					local value = 3 + math.floor(love.math.random()*2)*3
					self.fluidValues[relativeOctValues[value].i][relativeOctValues[value].j] = relativeOctValues[value].value - grav
					self.fluidValues[i][j] = value + grav


					self.fluidChunk:newPoint(self.fluidValues[i][j], i, j)
					self.fluidChunk:isoEdge(i, j)

					self.fluidChunk:newPoint(self.fluidValues[relativeOctValues[value].i][relativeOctValues[value].j], relativeOctValues[value].i, relativeOctValues[value].j)
					self.fluidChunk:isoEdge(relativeOctValues[value].i, relativeOctValues[value].j)
				end
			end
			-- else()
		end
	end
	-- self.fluidChunk:findEdge()
end

function FluidAutomata:draw()
	self.fluidChunk:draw()
end

function FluidAutomata:drawPoints()
	self.fluidChunk:drawPoints()
end






