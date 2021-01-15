local fps = 0
local width = love.graphics.getWidth()
local height = love.graphics.getHeight()
local triangles = {}
local nextVertix = 1
local circles = {}

local scale = 10

function love.load()
	for i=1, 100 do
		addCircle(math.random()*width, math.random()*height, 1, (100-math.random()*150), math.pi/5)
	end

	for i=1, height/(math.sqrt(3)/2*scale)-1 do
		for j=1, width/scale-1 do
			height = math.sqrt(3)/2*scale
			local x1, y1 = (j+i%2/2)*scale, (i)*height
			addTriangle(x1, y1, x1-0.5*scale, y1+height, x1+0.5*scale, y1+height)
			addTriangle(x1, y1, x1+scale, y1, x1+0.5*scale, y1+height)
		end
	end
end

function love.update(delta)
	fps = love.timer.getFPS()
	for i,v in ipairs(circles) do
		v[1] = v[1] + math.sin(v[5])*v[4]*delta
		v[2] = v[2] + math.cos(v[5])*v[4]*delta
		v[5] = v[5] + delta
		if (v[5] > math.pi) then
			v[5] = -v[5]
		end
	end
end

function love.draw()
	for i,v in ipairs(circles) do
		for j, v2 in ipairs(triangles) do
			xPos, yPos = (v2[1] + v2[3] + v2[5])/3, (v2[2] + v2[4] + v2[6])/3
			d = math.sqrt((xPos-v[1])^2+(yPos-v[2])^2)
			if (d < scale) then
				if(triangleCircleCollision(v2[1], v2[2], v2[3], v2[4], v2[5], v2[6], v[1], v[2], v[3])) then
					love.graphics.polygon("line", v2)
					break
				end
			end
		end
		love.graphics.circle("line", v[1], v[2], v[3])
	end
	love.graphics.setColor(0.0, 1.0, 0.1)
	love.graphics.print(fps, 0, 0)
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
 		triangles[1][nextVertix*2-1] = x
 		triangles[1][nextVertix*2] = y
 		nextVertix = nextVertix + 1
 		if(nextVertix > 3) then
 			nextVertix = 1
 		end
	end
end

function pointOnTriangle(px, py, ax, ay, bx, by, cx, cy)
	local abx, aby = bx - ax, by - ay
	local acx, acy = cx - ax, cy - ay
	local apx, apy = px - ax, py - ay
	-- vertex region outside a
	local d1 = abx*apx + aby*apy
	local d2 = acx*apx + acy*apy
	if d1 <= 0 and d2 <= 0 then
		return ax, ay
	end
	-- vertex region outside b
	local bpx, bpy = px - bx, py - by
	local d3 = abx*bpx + aby*bpy
	local d4 = acx*bpx + acy*bpy
	if d3 >= 0 and d4 <= d3 then
		return bx, by
	end
	-- edge region ab
	if d1 >= 0 and d3 <= 0 and d1*d4 - d3*d2 <= 0 then
		local v = d1/(d1 - d3)
		return ax + abx*v, ay + aby*v
	end
	-- vertex region outside c
	local cpx, cpy = px - cx, py - cy
	local d5 = abx*cpx + aby*cpy
	local d6 = acx*cpx + acy*cpy
	if d6 >= 0 and d5 <= d6 then
		return cx, cy
	end
	-- edge region ac
	if d2 >= 0 and d6 <= 0 and d5*d2 - d1*d6 <= 0 then
		local w = d2/(d2 - d6)
		return ax + acx*w, ay + acy*w
	end
	-- edge region bc
	if d3*d6 - d5*d4 <= 0 then
		local d43 = d4 - d3
		local d56 = d5 - d6
		if d43 >= 0 and d56 >= 0 then
			local w = d43/(d43 + d56)
			return bx + (cx - bx)*w, by + (cy - by)*w
		end
	end
	-- inside face region
	return px, py
end

function pointInCircle(px, py, cx, cy, r)
	local dx, dy = px - cx, py - cy
	return dx*dx + dy*dy <= r*r
end

function triangleCircleCollision(ax, ay, bx, by, cx, cy, sx, sy, r)
	local qx, qy = pointOnTriangle(sx, sy, ax, ay, bx, by, cx, cy)
	return pointInCircle(qx, qy, sx, sy, r)
end -- stolen from 2dengine.com

function addCircle(x, y, r, v, t)
	local circle= {x, y, r, v, t}
	table.insert(circles, circle)
end

function addTriangle(x1, y1, x2, y2, x3, y3)
	local triangle = {x1, y1, x2, y2, x3, y3}
	table.insert(triangles, triangle)
end
