ValueSquare = Object:extend()

function ValueSquare:new()
	self.valueVertices = {}
	for _ = 1, 4 do
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
	local valueVertix
	if (type(value) == "number") then
		valueVertex = {
			value = value or 0,
			x = x,
			y = y}
	elseif (type(value) == "table") then
	    valueVertex = {
			value = value[1] or 0,
			x = value[2],
			y = value[3]}
	end
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
	if not (self.valueVertices[1].value + self.valueVertices[2].value + self.valueVertices[3].value + self.valueVertices[4].value < 0.5) then
		local values = isoValueIntraprolation(self.valueVertices[1], self.valueVertices[2], self.valueVertices[3], self.valueVertices[4], middleValue)

		local triangleVertices = {}

		for i = 1, 4 do
			if not (values[i*2-i%2] == 1/0) then
				table.insert(triangleVertices, {values[i*2-1], values[i*2]})
			end
		end

		if (#triangleVertices == 0) then
			if (self.valueVertices[1].value >= 0.5 and self.valueVertices[2].value >= 0.5 and self.valueVertices[3].value >= 0.5 and self.valueVertices[4].value >= 0.5) then
				return {{self.valueVertices[1].x, self.valueVertices[1].y}, {self.valueVertices[2].x, self.valueVertices[2].y}, {self.valueVertices[3].x, self.valueVertices[3].y}, {self.valueVertices[1].x, self.valueVertices[1].y}, {self.valueVertices[4].x, self.valueVertices[4].y}, {self.valueVertices[3].x, self.valueVertices[3].y}}
			end
			return {}
		elseif (#triangleVertices == 3) then
			for i = 1, 3 do
				if (triangleVertices[i][1] == triangleVertices[i%3 + 1][1]) then
						table.remove(triangleVertices, i%3 + 1)
					break
				end
			end
		end

		

		for i, vertex in ipairs(self.valueVertices) do
			if (vertex.value >= 0.5) then
				table.insert(triangleVertices, {vertex.x, vertex.y})
				for j = i + 1, #self.valueVertices do
					local vertex2 = self.valueVertices[j]
					if (vertex2.value >= 0.5) then
						table.insert(triangleVertices, triangleVertices[#triangleVertices-1])
						if (j + i == 3) then
							triangleVertices[#triangleVertices] = triangleVertices[1]
						end
						table.insert(triangleVertices, triangleVertices[#triangleVertices-1])
						table.insert(triangleVertices, {vertex2.x, vertex2.y})
						for k = j + 1, #self.valueVertices do
							local vertex3 = self.valueVertices[k]
							
							if (vertex3.value >= 0.5) then
								if (i + j + k == 9) then
									triangleVertices[6] = {vertex3.x, vertex3.y}
								elseif (i + j + k == 7) then
									triangleVertices[3] = {vertex3.x, vertex3.y}
									triangleVertices[5] = {vertex3.x, vertex3.y}
								elseif (i + j + k == 6) then
									triangleVertices[6] = {vertex3.x, vertex3.y}
								end
								table.insert(triangleVertices, {vertex.x, vertex.y})
								table.insert(triangleVertices, {vertex2.x, vertex2.y})
								table.insert(triangleVertices, {vertex3.x, vertex3.y})
								break
							end
						end
						break
					end
				end
				break
			end
		end

		if (#triangleVertices%3 == 0) then
			return triangleVertices
		end
	end
	return {}
end

function isoValueIntraprolation(valueVertex1, valueVertex2, valueVertex3, valueVertex4, middleValue)
	local function linearIntraprolation(valueVertex1, valueVertex2)
		local intraValue = (middleValue - valueVertex1.value)/(valueVertex2.value - valueVertex1.value)
		local intraprolatedX = valueVertex1.x + (valueVertex2.x - valueVertex1.x)*intraValue
		local intraprolatedY = valueVertex1.y + (valueVertex2.y - valueVertex1.y)*intraValue
		return intraprolatedX, intraprolatedY
	end

	local intraX1, intraY1 = linearIntraprolation(valueVertex1, valueVertex2)
	local intraX2, intraY2 = linearIntraprolation(valueVertex2, valueVertex3)
	local intraX3, intraY3 = linearIntraprolation(valueVertex3, valueVertex4)
	local intraX4, intraY4 = linearIntraprolation(valueVertex1, valueVertex4)

	if (intraX1 < valueVertex1.x or intraX1 > valueVertex2.x) then
		intraX1 = 1/0
	end
	if (intraY2 < valueVertex2.y or intraY2 > valueVertex3.y) then
		intraY2 = 1/0
	end
	if (intraX3 < valueVertex4.x or intraX3 > valueVertex3.x) then
		intraX3 = 1/0
	end
	if (intraY4 < valueVertex1.y or intraY4 > valueVertex4.y) then
		intraY4 = 1/0
	end
	
	return {intraX1, valueVertex1.y, valueVertex2.x, intraY2, intraX3, valueVertex3.y, valueVertex4.x, intraY4}
end

