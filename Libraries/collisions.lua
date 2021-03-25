--[[collision detection library from 2dengine.com/?p=intersections]]


function pointOnSegment(px, py, x1, y1, x2, y2)
  local cx, cy = px - x1, py - y1
  local dx, dy = x2 - x1, y2 - y1
  local d = (dx*dx + dy*dy)
  if d == 0 then
    return x1, y1
  end
  local u = (cx*dx + cy*dy)/d
  if u < 0 then
    u = 0
  elseif u > 1 then
    u = 1
  end
  return x1 + u*dx, y1 + u*dy
end

function pointOnCircle(px, py, cx, cy, r)
  local dx, dy = px - cx, py - cy
  local d = math.sqrt(dx*dx + dy*dy)
  if d <= r then
    return px, py
  end
  return dx/d*r + cx, dy/d*r + cy
end

function pointOnRect(px, py, l, t, w, h)
  px = math.max(px, l)
  px = math.min(px, l + w)
  py = math.max(py, t)
  py = math.min(py, t + h)
  return px, py
end

local function dot(ax, ay, bx, by)
  return ax*bx + ay*by
end
function pointOnTriangle(px, py, ax, ay, bx, by, cx, cy)
  local abx, aby = bx - ax, by - ay
  local acx, acy = cx - ax, cy - ay
  local apx, apy = px - ax, py - ay
  -- vertex region outside a
  local d1 = dot(abx, aby, apx, apy)
  local d2 = dot(acx, acy, apx, apy)
  if d1 <= 0 and d2 <= 0 then
    return ax, ay
  end
  -- vertex region outside b
  local bpx, bpy = px - bx, py - by
  local d3 = dot(abx, aby, bpx, bpy)
  local d4 = dot(acx, acy, bpx, bpy)
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
  local d5 = dot(abx, aby, cpx, cpy)
  local d6 = dot(acx, acy, cpx, cpy)
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

function pointInRect(px, py, l, t, w, h)
  if px < l or px > l + w then
    return false
  end
  if py < t or py > t + h then
    return false
  end
  return true
end

function pointInTriangle(px, py, x1, y1, x2, y2, x3, y3)
  local ax, ay = x1 - px, y1 - py
  local bx, by = x2 - px, y2 - py
  local cx, cy = x3 - px, y3 - py
  local sab = ax*by - ay*bx < 0
  if sab ~= (bx*cy - by*cx < 0) then
    return false
  end
  return sab == (cx*ay - cy*ax < 0)
end

function segmentVsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
  local dx1, dy1 = x2 - x1, y2 - y1
  local dx2, dy2 = x4 - x3, y4 - y3
  local dx3, dy3 = x1 - x3, y1 - y3
  local d = dx1*dy2 - dy1*dx2
  if d == 0 then
    return false
  end
  local t1 = (dx2*dy3 - dy2*dx3)/d
  if t1 < 0 or t1 > 1 then
    return false
  end
  local t2 = (dx1*dy3 - dy1*dx3)/d
  if t2 < 0 or t2 > 1 then
    return false
  end
  -- point of intersection
  return true, x1 + t1*dx1, y1 + t1*dy1
end

local function segmentVsCircle(x1, y1, x2, y2, cx, cy, cr)
  local qx, qy = pointOnSegment(cx, cy, x1, y1, x2, y2)
  return pointInCircle(qx, qy, cx, cy, cr)
end

function segmentVsCircle2(x1, y1, x2, y2, cx, cy, cr) -- expanded version which also finds the point of the intersection
  -- normalize segment
  local dx, dy = x2 - x1, y2 - y1
  local d = math.sqrt(dx*dx + dy*dy)
  if d == 0 then
    return false
  end
  local nx, ny = dx/d, dy/d
  local mx, my = x1 - cx, y1 - cy
  local b = mx*nx + my*ny
  local c = mx*mx + my*my - cr*cr
  if c > 0 and b > 0 then
    return false
  end
  local discr = b*b - c
  if discr < 0 then
    return false
  end
  discr = math.sqrt(discr)
  local tmin = math.max(-b - discr, 0)
  if tmin > d then
    return false
  end
  local tmax = math.min(discr - b, d)
  -- points of intersection
  -- first point
  local qx, qy = x1 + tmin*nx, y1 + tmin*ny
  if tmax == tmin then
    return true, qx, qy
  end
  -- second point
  return true, qx, qy, x1 + tmax*nx, y1 + tmax*ny
end

function segmentVsAABB(x1, y1, x2, y2, l, t, r, b)
  -- normalize segment
  local dx, dy = x2 - x1, y2 - y1
  local d = math.sqrt(dx*dx + dy*dy)
  if d == 0 then
    return false
  end
  local nx, ny = dx/d, dy/d
  -- minimum and maximum intersection values
  local tmin, tmax = 0, d
  -- x-axis check
  if nx == 0 then
    if x1 < l or x1 > r then
      return false
    end
  else
    local t1, t2 = (l - x1)/nx, (r - x1)/nx
    if t1 > t2 then
      t1, t2 = t2, t1
    end
    tmin = math.max(tmin, t1)
    tmax = math.min(tmax, t2)
    if tmin > tmax then
      return false
    end
  end
  -- y-axis check
  if ny == 0 then
    if y1 < t or y1 > b then
      return false
    end
  else
    local t1, t2 = (t - y1)/ny, (b - y1)/ny
    if t1 > t2 then
      t1, t2 = t2, t1
    end
    tmin = math.max(tmin, t1)
    tmax = math.min(tmax, t2)
    if tmin > tmax then
      return false
    end
  end
  -- points of intersection
  -- one point
  local qx, qy = x1 + nx*tmin, y1 + ny*tmin
  if tmin == tmax then
    return true, qx, qy
  end
  -- two points
  return true, qx, qy, x1 + nx*tmax, y1 + ny*tmax
end


function circleVsCircle(cx, cy, r, cx2, cy2, r2)
  return pointInCircle(cx, cy, cx2, cy2, r + r2)
end

function circleVsCircle2(cx, cy, r, cx2, cy2, r2) -- expanded version which also finds the point of the intersection
  local sradii = r + r2
  local dx, dy = px - cx, py - cy
  return dx*dx + dy*dy <= sradii*sradii
end

function circleVsRect(cx, cy, cr, x, y, w, h)
  local qx, qy = pointOnRect(cx, cy, x, y, w, h)
  return pointInCircle(qx, qy, cx, cy, cr)
end

local function clamp(n, min, max)
  if n < min then
    n = min
  elseif n > max then
    n = max
  end
  return n
end
function circleVsRect(cx, cy, cr, l, t, w, h)
  local dx = clamp(cx, l, l + w) - cx
  local dy = clamp(cy, t, t + h) - cy
  return dx*dx + dy*dy <= cr*cr
end

function triangleVsCircle(ax, ay, bx, by, cx, cy, sx, sy, r)
  local qx, qy = pointOnTriangle(sx, sy, ax, ay, bx, by, cx, cy)
  return pointInCircle(qx, qy, sx, sy, r)
end


function rectVsRect(l, t, w, h, l2, t2, w2, h2)
  if l > l2 + w2 or l2 > l + w then
    return false
  end
  if t > t2 + h2 or t2 > t + h then
    return false
  end
  return true
end

local function cross2(x1,y1,x2,y2,x3,y3, ax,ay,bx,by,cx,cy)
  local dXa, dYa = ax - x3, ay - y3
  local dXb, dYb = bx - x3, by - y3
  local dXc, dYc = cx - x3, cy - y3
  local dX21, dY12 = x3 - x2, y2 - y3
  local x13, y13 = x1 - x3, y1 - y3
  local D = dY12*x13 + dX21*y13
  local sa = dY12*dXa + dX21*dYa
  local sb = dY12*dXb + dX21*dYb
  local sc = dY12*dXc + dX21*dYc
  local ta = x13*dYa - y13*dXa
  local tb = x13*dYb - y13*dXb
  local tc = x13*dYc - y13*dXc
  if D < 0 then
    return ((sa >= 0 and sb >= 0 and sc >= 0)
      or (ta >= 0 and tb >= 0 and tc >= 0)
      or (sa+ta <= D and sb+tb <= D and sc+tc <= D))
  else
    return ((sa <= 0 and sb <= 0 and sc <= 0)
      or (ta <= 0 and tb <= 0 and tc <= 0)
      or (sa+ta >= D and sb+tb >= D and sc+tc >= D))
  end
end

function triangleVsTriangle(x1,y1,x2,y2,x3,y3, ax,ay,bx,by,cx,cy)
  return not (cross2(x1,y1,x2,y2,x3,y3, ax,ay,bx,by,cx,cy) or
    cross2(ax,ay,bx,by,cx,cy, x1,y1,x2,y2,x3,y3))
end