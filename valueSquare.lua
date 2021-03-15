ValueSquare = Object:extend()

function ValueSquare:new()
	self.valueVertices = {}
	for _=1, 4 do
		self:addVertex(0, 0, 0)
	end
end

function ValueSquare:addVertex(value, x, y)
	local valueVertex = {
		value = value,
		x = x,
		y = y
	}
	table.insert(self.valueVertices, valueVertex)
end

function ValueSquare:replaceVertex(pos, value, x, y)
	local valueVertex = {
		value = value,
		x = x,
		y = y
	}
	self.valueVertices[pos] = valueVertex
end

function ValueSquare:empty()
	for i,v in ipairs(self.valueVertices) do
		if not (v.value == 0) then
			return false
		end
	end
	return true
end

function ValueSquare:intraprolated(middleValue)
	-- if not (self.valueVertices[1].value + self.valueVertices[2].value + self.valueVertices[3].value + self.valueVertices[4].value < 0.5) then
	if not (self.valueVertices[1].value + self.valueVertices[2].value + self.valueVertices[3].value + self.valueVertices[4].value == 0) then
		local values = isoValueIntraprolation(self.valueVertices[1], self.valueVertices[2], self.valueVertices[3], self.valueVertices[4], middleValue)

		local triangleVeritices = {}
		local doubled = false

		for i = 1, 4 do
			if (self.valueVertices[i].value > 0.5 and not (values[math.ceil(i/2)*2 - 1] == 1/0 or values[4-math.ceil((i-1)/2)*2%4] == 1/0)) then
				table.insert(triangleVeritices, {self.valueVertices[i].x, self.valueVertices[i].y})
				table.insert(triangleVeritices, {self.valueVertices[i].x, values[4-math.ceil((i-1)/2)*2%4]})
				table.insert(triangleVeritices, {values[math.ceil(i/2)*2 - 1], self.valueVertices[i].y})
			end
		end

		if (self.valueVertices[1].value > 0.5 and self.valueVertices[2].value > 0.5 and self.valueVertices[3].value > 0.5 and self.valueVertices[4].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})

			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
		elseif (self.valueVertices[1].value > 0.5 and self.valueVertices[2].value > 0.5 and self.valueVertices[3].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, values[4]})

			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {values[3], self.valueVertices[3].y})

			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, values[4]})
			table.insert(triangleVeritices, {values[3], self.valueVertices[3].y})
		elseif (self.valueVertices[2].value > 0.5 and self.valueVertices[3].value > 0.5 and self.valueVertices[4].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, values[4]})

			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {values[1], self.valueVertices[2].y})

			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, values[4]})
			table.insert(triangleVeritices, {values[1], self.valueVertices[2].y})
		elseif (self.valueVertices[3].value > 0.5 and self.valueVertices[4].value > 0.5 and self.valueVertices[1].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, values[2]})

			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {values[1], self.valueVertices[1].y})

			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, values[2]})
			table.insert(triangleVeritices, {values[1], self.valueVertices[1].y})
		elseif (self.valueVertices[4].value > 0.5 and self.valueVertices[1].value > 0.5 and self.valueVertices[2].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[2].x, values[2]})

			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {values[3], self.valueVertices[4].y})

			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[2].x, values[2]})
			table.insert(triangleVeritices, {values[3], self.valueVertices[4].y})
		elseif (self.valueVertices[1].value > 0.5 and self.valueVertices[2].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, values[4]})

			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, values[4]})
			table.insert(triangleVeritices, {self.valueVertices[2].x, values[2]})
		elseif (self.valueVertices[2].value > 0.5 and self.valueVertices[3].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[2].x, self.valueVertices[2].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {values[1], self.valueVertices[2].y})

			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {values[1], self.valueVertices[2].y})
			table.insert(triangleVeritices, {values[3], self.valueVertices[3].y})
		elseif (self.valueVertices[3].value > 0.5 and self.valueVertices[4].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[3].x, self.valueVertices[3].y})
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, values[2]})

			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[3].x, values[2]})
			table.insert(triangleVeritices, {self.valueVertices[4].x, values[4]})
		elseif (self.valueVertices[4].value > 0.5 and self.valueVertices[1].value > 0.5) then
			table.insert(triangleVeritices, {self.valueVertices[4].x, self.valueVertices[4].y})
			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {values[3], self.valueVertices[4].y})

			table.insert(triangleVeritices, {self.valueVertices[1].x, self.valueVertices[1].y})
			table.insert(triangleVeritices, {values[3], self.valueVertices[4].y})
			table.insert(triangleVeritices, {values[1], self.valueVertices[1].y})
		end
		if (#triangleVeritices%3 == 0) then
			return triangleVeritices
		end
	end
	return {}
end

function isoValueIntraprolation(valueVertex1, valueVertex2, valueVertex3, valueVertex4, middleValue)
	local function linearIntraprolation(valueVertex1, valueVertex2)
		local intraValue = (middleValue - valueVertex1.value)/(valueVertex2.value - valueVertex1.value)
		-- print(intraValue)
		local intraprolatedX = valueVertex1.x + (valueVertex2.x - valueVertex1.x)*intraValue
		local intraprolatedY = valueVertex1.y + (valueVertex2.y - valueVertex1.y)*intraValue
		return intraprolatedX, intraprolatedY
	end

	local intraX1, intraY1 = linearIntraprolation(valueVertex1, valueVertex2)
	local intraX2, intraY2 = linearIntraprolation(valueVertex2, valueVertex3)
	local intraX3, intraY3 = linearIntraprolation(valueVertex3, valueVertex4)
	local intraX4, intraY4 = linearIntraprolation(valueVertex1, valueVertex4)
	-- print(intraX1)
	if not (intraX1 >= valueVertex1.x and intraX1 <= valueVertex2.x) then
		intraX1 = 1/0, 1/0
	end
	if not (intraY2 >= valueVertex2.y and intraY2 <= valueVertex3.y) then
		intraY2 = 1/0, 1/0
	end
	if not (intraX3 >= valueVertex4.x and intraX3 <= valueVertex3.x) then
		intraX3 = 1/0, 1/0
	end
	if not (intraY4 >= valueVertex1.y and intraY4 <= valueVertex4.y) then
		intraY4 = 1/0, 1/0
	end -- check can be avoided??
	return {intraX1, intraY2, intraX3, intraY4}
end

