local bitser = require "Libraries/bitser"
local saveLoader = {
	save = function(terrain)
		local serializedPoints = bitser.dumps(terrain:getPoints())
		return love.filesystem.write("data.wld", serializedPoints)
	end,
	load = function ()
		local serializedPoints = love.filesystem.read("data.wld")
		if (serializedPoints == nil) then
			return {}
		end
		return bitser.loads(serializedPoints)
	end 
}
return saveLoader
