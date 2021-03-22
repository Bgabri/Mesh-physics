---[[ inputs
Object = require "Libraries/classic/classic"
require "Modules/valueSquare"
local id, x, y, textureHeight, textureWidth, scale, terrainPoints = ... 
--]]
local function addVertices(vertices)
	for k,v in ipairs(vertices) do
		---[[ output
		local vertixTable = {
			v[1], v[2],
			v[1]/textureWidth/2, v[2]/textureHeight/2,
			1, 1, 1, 1
		}
		love.thread.getChannel("vertices"..id):push(vertixTable)
		--]]
	end
end

local shiftX = scale/2
local valueSquare = ValueSquare()

for i = 1, #terrainPoints-1 do
	for j = 1, #terrainPoints[i]-1 do
		local x, y = j*scale + x, i*scale + y
		valueSquare:replaceVertex(1, terrainPoints[i][j], x, y) -- current node (top left)
		valueSquare:replaceVertex(2, terrainPoints[i][j+1], x + scale, y) -- top right node
		valueSquare:replaceVertex(3, terrainPoints[i+1][j+1], x + scale, y + scale) -- bottom right node
		valueSquare:replaceVertex(4, terrainPoints[i+1][j], x, y + scale) -- bottom left node
		addVertices(valueSquare:intraprolated(0.5))
	end
end