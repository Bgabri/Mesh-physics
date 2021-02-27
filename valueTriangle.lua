ValueTriangle = Object:extend()

function ValueTriangle:new()
	self.valueVertices = {}
	self.intraprolatedVertices = {}
end

function ValueTriangle:addVertex(value, x, y)
	local valueVertex = {
		value = value,
		x = x,
		y = y
	}
	table.insert(self.valueVertices, valueVertex)
end

function ValueTriangle:empty(valueVertex1, valueVertex2, value)
	for i,v in ipairs(self.valueVertices) do
		if not (v.value == 0) then
			return false
		end
	end
	return true
end

function ValueTriangle:intraprolated(middleValue)
	if (not idklol(self.valueVertices[1], self.valueVertices[2], self.valueVertices[3])) then
		local x1, y1, x2, y2, x3, y3 = isoValueIntraprolation(self.valueVertices[1], self.valueVertices[2], self.valueVertices[3], middleValue)
		if not (x1 + y1 == 1/0) then
			table.insert(self.intraprolatedVertices, {x1, y1})
		end
		if not (x2 + y2 == 1/0) then
			table.insert(self.intraprolatedVertices, {x2, y2})
		end
		if not (x3 + y3 == 1/0) then
			table.insert(self.intraprolatedVertices, {x3, y3})
		end
	end
	return self.intraprolatedVertices
end

function idklol(valueVertex1, valueVertex2, valueVertex3)
	local total = valueVertex1.value + valueVertex2.value + valueVertex3.value
	return total == 3 or total == 0
end

function isoValueIntraprolation(valueVertex1, valueVertex2, valueVertex3, middleValue)
	-- local middleValue = 0.5
	local intraX1, intraY1 = linearIntraprolation(valueVertex1, valueVertex2, middleValue)
	local intraX2, intraY2 = linearIntraprolation(valueVertex2, valueVertex3, middleValue)
	local intraX3, intraY3 = linearIntraprolation(valueVertex1, valueVertex3, middleValue)

	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX1, intraY1, 0.0000000001) then
		intraX1, intraY1 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX2, intraY2, 0.0000000001) then
		intraX2, intraY2 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX3, intraY3, 0.0000000001) then
		intraX3, intraY3 = 1/0, 1/0
	end -- check isn't efficient/ can be avoided?? 
	return intraX1, intraY1, intraX2, intraY2, intraX3, intraY3
end

function linearIntraprolation(valueVertex1, valueVertex2, middleValue)
	local intraValue = (middleValue - valueVertex1.value)/(valueVertex2.value - valueVertex1.value)
	local intraprolatedX = valueVertex1.x + (valueVertex2.x - valueVertex1.x)*intraValue
	local intraprolatedY = valueVertex1.y + (valueVertex2.y - valueVertex1.y)*intraValue
	return intraprolatedX, intraprolatedY
end