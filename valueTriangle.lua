ValueTriangle = Object:extend()

function ValueTriangle:new()
	self.valueVertices = {}
	self.intraprolatedEdge = {}
end

function ValueTriangle:getVertices()
	return self.valueVertices
end

function ValueTriangle:addVertex(value, x, y)
	local valueVertex = {
		value = value,
		x = x,
		y = y
	}
	table.insert(self.valueVertices, valueVertex)
end

function ValueTriangle:intraprolated()
	x1, y1, x2, y2, x3, y3 = isoIntraprolation(self.valueVertices[1], self.valueVertices[2], self.valueVertices[3])
	if not (x1 + y1 + x2 + y2 == 1/0)	then
		table.insert(self.intraprolatedEdge, {x1, y1, x2, y2})
	end
	if not (x2 + y2 + x3 + y3 == 1/0)	then
		table.insert(self.intraprolatedEdge, {x2, y2, x3 ,y3})
	end
	if not (x1 + y1 + x3 + y3 == 1/0)	then
		table.insert(self.intraprolatedEdge, {x1, y1, x3, y3})
	end
	return x1, y1, x2, y2, x3, y3
end

function ValueTriangle:draw()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	for i,v in ipairs(self.intraprolatedEdge) do
		local x, y = v[1], v[2]
		love.graphics.setColor(x/width, y/height, 1-x/width, 1)
		love.graphics.line(x, y, v[3], v[4])
	end
end

function isoIntraprolation(valueVertex1, valueVertex2, valueVertex3)
	local middle = 0.5
	local intraX1, intraY1 = linearIntraprolation(valueVertex1, valueVertex2, middle)
	local intraX2, intraY2 = linearIntraprolation(valueVertex2, valueVertex3, middle)
	local intraX3, intraY3 = linearIntraprolation(valueVertex1, valueVertex3, middle)

	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX1, intraY1, 0.00000001) then
		intraX1, intraY1 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX2, intraY2, 0.00000001) then
		intraX2, intraY2 = 1/0, 1/0
	end
	if not triangleVsCircle(valueVertex1.x, valueVertex1.y, valueVertex2.x, valueVertex2.y, valueVertex3.x, valueVertex3.y, intraX3, intraY3, 0.00000001) then
		intraX3, intraY3 = 1/0, 1/0
	end
	return intraX1, intraY1, intraX2, intraY2, intraX3, intraY3
end

function linearIntraprolation(valueVertex1, valueVertex2, value)
	local intraValue = (value - valueVertex1.value)/(valueVertex2.value - valueVertex1.value)
	local intraprolatedX = valueVertex1.x + (valueVertex2.x - valueVertex1.x)*intraValue
	local intraprolatedY = valueVertex1.y + (valueVertex2.y - valueVertex1.y)*intraValue
	return intraprolatedX, intraprolatedY
end