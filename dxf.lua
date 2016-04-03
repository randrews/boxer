DXF = {}

function DXF.new()
    local instance = setmetatable({}, {__index=DXF})
    instance.lines = setmetatable({}, {__index=table})
    instance.arcs = setmetatable({}, {__index=table})
    instance.origin = {x=0, y=0}
    instance.translations = {}
    return instance
end

function DXF:line(x1, y1, x2, y2)
    x1 = x1 + self.origin.x
    y1 = y1 + self.origin.y
    x2 = x2 + self.origin.x
    y2 = y2 + self.origin.y
    table.insert(self.lines,{x1=x1, y1=y1, x2=x2, y2=y2})
end

-- Draws a circular arc with center x,y, radius r, counterclockwise from angle a1 to a2.
-- Angles are in degrees and angle 0 is point (x+r, y).
function DXF:arc(x, y, r, a1, a2)
    x = x + self.origin.x
    y = y + self.origin.y
    table.insert(self.arcs,{x=x, y=y, r=r, a1=a1, a2=a2})
end

function DXF:translate(x, y)
    self.origin.x = self.origin.x + x
    self.origin.y = self.origin.y + y
end

function DXF:reset()
    self.origin = {x=0, y=0}
    self.translations = {}
end

function DXF:push()
    table.insert(self.translations, {x=self.origin.x, y=self.origin.y})
end

function DXF:pop()
    if #self.translations > 0 then
        local t = table.remove(self.translations)
        self.origin.x = t.x
        self.origin.y = t.y
    end
end

function DXF:path(...)
    local x,y = 0, 0
    local points = {...}
    local i = 1

    while i <= #points do
        local cmd = points[i]
        if cmd == 'move' or cmd == 'm' then
            x,y = x+points[i+1], y+points[i+2]
            i = i + 3
        elseif cmd == 'line' or cmd == 'l' then
            local nx, ny = points[i+1], points[i+2]
            self:line(x,y, x+nx, y+ny)
            x = x+nx; y = y+ny
            i = i + 3
        elseif cmd == 'arc' or cmd == 'a' then
            local cx, cy = x+points[i+1], y+points[i+2]
            local r = points[i+3]
            local a1,a2 = points[i+4], points[i+5]
            self:arc(cx, cy, r, a1, a2)
            i = i + 6
        elseif cmd == 'MOVE' or cmd == 'M' then
            x,y = points[i+1], points[i+2]
            i = i + 3
        elseif cmd == 'LINE' or cmd == 'L' then
            local nx, ny = points[i+1], points[i+2]
            self:line(x,y, nx, ny)
            x = nx; y = ny
            i = i + 3
        elseif cmd == 'ARC' or cmd == 'A' then
            local cx, cy = points[i+1], y+points[i+2]
            local r = points[i+3]
            local a1,a2 = points[i+4], points[i+5]
            self:arc(cx, cy, r, a1, a2)
            i = i + 6
        end
    end
end

function DXF:rect(x1, y1, x2, y2)
    self:path('M', x1, y1,
              'l', x2-x1, 0,
              'l', 0, y2-y1,
              'l', x1-x2, 0,
              'l', 0, y1-y2)
end

function DXF:write(stream)
    if not stream then stream = io.stdout end

    -- Header
    stream:write("0\nSECTION\n")
    stream:write("2\nENTITIES\n")

    -- Lines
    for _, line in ipairs(self.lines) do
        stream:write("0\nLINE\n")
        stream:write("10\n", line.x1, "\n")
        stream:write("20\n", line.y1, "\n")
        stream:write("11\n", line.x2, "\n")
        stream:write("21\n", line.y2, "\n")
    end

    -- Arcs
    for _, arc in ipairs(self.arcs) do
        stream:write("0\nARC\n")
        stream:write("10\n", arc.x, "\n")
        stream:write("20\n", arc.y, "\n")
        stream:write("40\n", arc.r, "\n")
        stream:write("50\n", arc.a1, "\n")
        stream:write("51\n", arc.a2, "\n")
    end

    -- Footer
    stream:write("0\nENDSEC\n")
    stream:write("0\nEOF")
end

return DXF
