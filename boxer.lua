-- Boxer
-- Generate DXF files to laser cut boxes for organizing parts

require('dxf')

ARGV = {...}

function loadcfg(filename)
    local cfg = setmetatable({}, {index = _ENV})
    local chunk = loadfile(filename, 't', cfg)
    chunk()
    setmetatable(cfg, nil)
    return cfg
end

function fixcfg(cfg)
    if not cfg.outer_width and not cfg.inner_width and (not cfg.columns or #cfg.columns == 0) then
        error 'Width not defined'
    end

    if not cfg.outer_height and not cfg.inner_height and (not cfg.rows or #cfg.rows == 0) then
        error 'Height not defined'
    end

    if not cfg.inner_depth and not cfg.outer_depth then
        error 'Depth not defined'
    end

    local defaults = loadcfg('defaults.lua')

    --------------------

    if not cfg.material then
        cfg.material = defaults.material
    else
        for k,v in pairs(defaults.material) do
            if not cfg.material[k] then cfg.material[k] = v end
        end
    end

    --------------------

    if not cfg.inner_width then
        if not cfg.outer_width then
            local t = 0
            for _, c in ipairs(cfg.columns) do
                t = t + c
            end
            cfg.inner_width = t + cfg.material.thickness * (#cfg.columns-1)
            cfg.outer_width = cfg.inner_width + 2 * (cfg.material.thickness + cfg.material.zip_slot_width + cfg.material.margin)
        else
            cfg.inner_width = cfg.outer_width - 2 * (cfg.material.thickness + cfg.material.zip_slot_width + cfg.material.margin)
        end
    end

    if not cfg.columns or #cfg.columns == 0 then
        cfg.columns = { cfg.inner_width }
    end

    if not cfg.outer_width then
        cfg.outer_width = cfg.inner_width + 2 * (cfg.material.thickness + cfg.material.zip_slot_width + cfg.material.margin)
    end

    --------------------

    if not cfg.inner_height then
        if not cfg.outer_height then
            local t = 0
            for _, c in ipairs(cfg.rows) do
                t = t + c
            end
            cfg.inner_height = t + cfg.material.thickness * (#cfg.rows-1)
            cfg.outer_height = cfg.inner_height + 2 * (cfg.material.thickness + cfg.material.margin)
        else
            cfg.inner_height = cfg.outer_height - 2 * (cfg.material.thickness + cfg.material.margin)
        end
    end

    if not cfg.rows or #cfg.rows == 0 then
        cfg.rows = { cfg.inner_height }
    end

    if not cfg.outer_height then
        cfg.outer_height = cfg.inner_height + 2 * (cfg.material.thickness + cfg.material.margin)
    end

    --------------------

    if cfg.has_lid == nil then
        cfg.has_lid = defaults.has_lid
    end

    --------------------

    if not cfg.inner_depth then
        if cfg.has_lid then
            cfg.inner_depth = cfg.outer_depth - 2 * (cfg.material.thickness + cfg.material.margin)
        else
            cfg.inner_depth = cfg.outer_depth - cfg.material.thickness - cfg.material.margin
        end
    elseif not cfg.outer_depth then
        if cfg.has_lid then
            cfg.outer_depth = cfg.inner_depth + 2 * (cfg.material.thickness + cfg.material.margin)
        else
            cfg.outer_depth = cfg.inner_depth + cfg.material.thickness + cfg.material.margin
        end
    end
end

function base(d, cfg)
    local height = cfg.inner_height + 2 * (cfg.material.thickness + cfg.material.margin)
    local width = cfg.inner_width
    local radius = cfg.material.corner_radius
    local tab_width = (cfg.material.thickness + cfg.material.zip_slot_width + cfg.material.margin)
    local side_tab_width = (width - cfg.material.margin*2) / 5
    local col_tab_height = (cfg.inner_height / 5)

    d:path('m', 0, 0,
           'l', width, 0,
           'M', 0, height,
           'l', width, 0)

    d:path('m', 0, 0,
           'l', 0, height/4,
           'M', width, 0,
           'l', 0, height/4,
           'M', 0, height,
           'l', 0, -height/4,
           'M', width, height,
           'l', 0, -height/4)

    d:path('M', 0, height/4,
           'l', -(tab_width - radius), 0,
           'a', 0, radius, radius, 180, 270,
           'm', -radius, radius,
           'l', 0, height/2 - radius*2,
           'a', radius, 0, radius, 90, 180,
           'm', radius, radius,
           'l', (tab_width - radius), 0)

    d:path('M', width, height/4,
           'l', tab_width-radius, 0,
           'a', 0, radius, radius, 270, 360,
           'm', radius, radius,
           'l', 0, height/2 - radius*2,
           'a', -radius, 0, radius, 0, 90,
           'm', -radius, radius,
           'l', -(tab_width-radius), 0)

    d:rect(0-cfg.material.thickness-cfg.material.zip_slot_width,
           height/2-cfg.material.zip_slot_separation/2,
           0-cfg.material.thickness,
           height/2-cfg.material.zip_slot_separation/2-cfg.material.zip_slot_height)

    d:rect(0-cfg.material.thickness-cfg.material.zip_slot_width,
           height/2+cfg.material.zip_slot_separation/2,
           0-cfg.material.thickness,
           height/2+cfg.material.zip_slot_separation/2+cfg.material.zip_slot_height)

    d:rect(width+cfg.material.thickness,
           height/2-cfg.material.zip_slot_separation/2,
           width+cfg.material.thickness+cfg.material.zip_slot_width,
           height/2-cfg.material.zip_slot_separation/2-cfg.material.zip_slot_height)

    d:rect(width+cfg.material.thickness,
           height/2+cfg.material.zip_slot_separation/2,
           width+cfg.material.thickness+cfg.material.zip_slot_width,
           height/2+cfg.material.zip_slot_separation/2+cfg.material.zip_slot_height)

    for x=0, 2 do
        d:rect(cfg.material.margin + x*side_tab_width*2,
               cfg.material.margin + cfg.material.thickness,
               cfg.material.margin + x*side_tab_width*2 + side_tab_width,
               cfg.material.margin)

        d:rect(cfg.material.margin + x*side_tab_width*2,
               height - cfg.material.margin - cfg.material.thickness,
               cfg.material.margin + x*side_tab_width*2 + side_tab_width,
               height - cfg.material.margin)
    end

    local x = 0
    for i=1, #(cfg.columns)-1 do
        x = x + cfg.columns[i]

        d:rect(x,
               cfg.material.margin + cfg.material.thickness + col_tab_height,
               x + cfg.material.thickness,
               cfg.material.margin + cfg.material.thickness + 2*col_tab_height)

        d:rect(x,
               height - cfg.material.margin - cfg.material.thickness - col_tab_height,
               x + cfg.material.thickness,
               height - cfg.material.margin - cfg.material.thickness - 2*col_tab_height)

        x = x + cfg.material.thickness
    end


    x = 0
    for i=1, cfg.split_columns do
        x = x + cfg.columns[i]
        local y = cfg.material.margin + cfg.material.thickness
        for k=1, #(cfg.rows)-1 do
            y = y + cfg.rows[k]

            d:rect(x - cfg.columns[i]/4,
                   y,
                   x - cfg.columns[i]*3/4,
                   y + cfg.material.thickness)

            y = y + cfg.material.thickness
        end
        x = x + cfg.material.thickness
    end
end

function front(d, cfg)
    local thickness = cfg.material.thickness
    local margin = cfg.material.margin
    
    local width = cfg.inner_width
    local side_tab_width = (width - margin*2) / 5
    local radius = cfg.material.corner_radius
    local center = (cfg.outer_depth - thickness)/2 + thickness
    local top = cfg.inner_depth+thickness*2
    local height = cfg.outer_depth - thickness - margin

    d:path('M', 0, thickness,
           'l', margin, 0,
           'l', 0, -thickness,
           'l', side_tab_width, 0,
           'l', 0, thickness,
           'l', side_tab_width, 0,
           'l', 0, -thickness,
           'l', side_tab_width, 0,
           'l', 0, thickness,
           'l', side_tab_width, 0,
           'l', 0, -thickness,
           'l', side_tab_width, 0,
           'l', 0, thickness,
           'l', margin, 0)

    d:line(0, height+thickness,
           cfg.inner_width, height+thickness)

    d:path('M', 0, thickness,
           'l', 0, height / 4,
           'l', -(thickness + cfg.material.zip_slot_width + margin - radius), 0,
           'a', 0, radius, radius, 180, 270,
           'm', -radius, radius,
           'l', 0, height / 2 - radius*2,
           'a', radius, 0, radius, 90, 180,
           'm', radius, radius,
           'l', thickness + cfg.material.zip_slot_width + margin - radius, 0,
           'l', 0, height / 4)

    d:path('M', width, thickness,
           'l', 0, height / 4,
           'l', thickness + cfg.material.zip_slot_width + margin - radius, 0,
           'a', 0, radius, radius, 270, 360,
           'm', radius, radius,
           'l', 0, height / 2 - radius*2,
           'a', -radius, 0, radius, 0, 90,
           'm', -radius, radius,
           'l', -(thickness + cfg.material.zip_slot_width + margin - radius), 0,
           'l', 0, height / 4)

    d:rect(-thickness,
           center - cfg.material.zip_slot_separation/2,
               -thickness - cfg.material.zip_slot_width,
           center - cfg.material.zip_slot_separation/2 - cfg.material.zip_slot_height)

    d:rect(-thickness,
           center + cfg.material.zip_slot_separation/2,
               -thickness - cfg.material.zip_slot_width,
           center + cfg.material.zip_slot_separation/2 + cfg.material.zip_slot_height)

    d:rect(width+thickness,
           center - cfg.material.zip_slot_separation/2,
           width+thickness + cfg.material.zip_slot_width,
           center - cfg.material.zip_slot_separation/2 - cfg.material.zip_slot_height)

    d:rect(width+thickness,
           center + cfg.material.zip_slot_separation/2,
           width+thickness + cfg.material.zip_slot_width,
           center + cfg.material.zip_slot_separation/2 + cfg.material.zip_slot_height)

    local x = 0
    for i=1, #(cfg.columns)-1 do
        x = x + cfg.columns[i]

        d:rect(x, thickness + cfg.inner_depth/4,
               x+thickness, thickness + cfg.inner_depth*3/4)

        x = x + thickness
    end

end

function v_dividers(d, cfg)
    local thickness = cfg.material.thickness
    local width = cfg.inner_height
    local tab_width = cfg.inner_height / 5
    local depth = cfg.inner_depth

    for n=1, #cfg.columns-1 do
        d:path('m', thickness, depth+thickness,
               'l', 0, -depth/4,
               'l', -thickness, 0,
               'l', 0, -depth/2,
               'l', thickness, 0,
               'l', 0, -depth/4,
               'l', tab_width, 0,
               'l', 0, -thickness,
               'l', tab_width, 0,
               'l', 0, thickness,
               'l', tab_width, 0,
               'l', 0, -thickness,
               'l', tab_width, 0,
               'l', 0, thickness,
               'l', tab_width, 0,
               'l', 0, depth/4,
               'l', thickness, 0,
               'l', 0, depth/2,
               'l', -thickness, 0,
               'l', 0, depth/4)

        if cfg.split_columns and cfg.split_columns > n then
            local path = { 'm', thickness, depth+thickness }
            for i=1, #(cfg.rows)-1 do
                local r = cfg.rows[i]
                local subpath = { 'l', r, 0,
                                  'l', 0, -depth/2,
                                  'l', thickness, 0,
                                  'l', 0, depth/2 }
                table.move(subpath, 1, #subpath, #path+1, path)
            end

            local endpath = { 'l', cfg.rows[#cfg.rows], 0 }
            table.move(endpath, 1, #endpath, #path+1, path)

            d:path(table.unpack(path))
        else
            d:line(thickness, depth+thickness, thickness+width, depth+thickness)
        end

        if cfg.split_columns == n then
            local x = thickness
            for i=1, #(cfg.rows)-1 do
                x = x + cfg.rows[i]
                d:rect(x, thickness+3*depth/4,
                       x+thickness, thickness+depth/4)
                x = x + thickness
            end
        end

        d:translate(0, depth+thickness+1)
    end
end

function h_dividers(d, cfg)
    local thickness = cfg.material.thickness
    local depth = cfg.inner_depth

    for i=1, #(cfg.rows)-1 do
        local path = {
            'm', thickness, depth+thickness,
            'l', 0, -depth/4,
            'l', -thickness, 0,
            'l', 0, -depth/2,
            'l', thickness, 0,
            'l', 0, -depth/4
        }

        for i = 1, cfg.split_columns do
            local width = cfg.columns[i]
            local subpath = {
                'l', width/4, 0,
                'l', 0, -thickness,
                'l', width/2, 0,
                'l', 0, thickness,
                'l', width/4, 0
            }
            table.move(subpath, 1, #subpath, #path+1, path)

            if i < cfg.split_columns then
                local subpath = {
                    'l', 0, depth/2,
                    'l', thickness, 0,
                    'l', 0, -depth/2
                }
                table.move(subpath, 1, #subpath, #path+1, path)
            end
        end

        local endpath = {
            'l', 0, depth/4,
            'l', thickness, 0,
            'l', 0, depth/2,
            'l', -thickness, 0,
            'l', 0, depth/4,
            'L', thickness, depth+thickness
        }
        table.move(endpath, 1, #endpath, #path+1, path)

        d:path(table.unpack(path))

        d:translate(0, depth+thickness+1)
    end
end

function side(d, cfg, side)
    local outer_height = cfg.outer_height
    local outer_depth = cfg.outer_depth
    local inner_depth = cfg.inner_depth
    local thickness = cfg.material.thickness
    local margin = cfg.material.margin
    local radius = cfg.material.corner_radius
    local front_height = outer_depth-thickness-margin

    d:path('m', radius, 0,
           'l', outer_height-radius*2, 0,
           'a', 0, radius, radius, 270, 360,
           'm', radius, radius,
           'l', 0, outer_depth-radius,
           'l', -outer_height, 0,
           'l', 0, -outer_depth+radius,
           'a', radius, 0, radius, 180, 270)

    d:rect(outer_height/4, margin,
           3*outer_height/4, margin+thickness)

    d:rect(margin, front_height/4+thickness+margin,
           margin+thickness, 3*front_height/4+thickness+margin)

    d:rect(outer_height-margin, front_height/4+thickness+margin,
           outer_height-margin-thickness, 3*front_height/4+thickness+margin)

    if #cfg.rows > 0 and (side == 'right' or cfg.split_columns == #cfg.columns) then
        x = margin+thickness
        for i=1, #cfg.rows - 1 do
            x = x + cfg.rows[i]
            d:rect(x, margin+thickness+inner_depth/4,
                   x+thickness, margin+thickness+3*inner_depth/4)
            x = x + thickness
        end
    end

    if cfg.has_lid then
        d:rect(margin+thickness, outer_depth-margin-thickness,
               outer_height-margin-thickness, outer_depth-margin)
    end
end

function lid(d, cfg)
    d:rect(0, 0,
           cfg.inner_width + cfg.material.thickness*2 + cfg.material.margin*2,
           cfg.outer_height - cfg.material.margin*2 - cfg.material.thickness*2)

    d:path('m', (cfg.inner_width + cfg.material.thickness*2 + cfg.material.margin*2)*4/5,
           (cfg.outer_height - cfg.material.margin*2 - cfg.material.thickness*2)/2 - cfg.material.finger_height/2,
           'l', 0, cfg.material.finger_height,
           'a', 0, -cfg.material.finger_height/2, cfg.material.finger_height/2, 90, 270)
end

function box(cfg)

    d = DXF.new()

    d:translate(cfg.material.thickness*2 + cfg.material.zip_slot_width, 0)

    base(d, cfg)

    d:push()
    d:translate(0, cfg.outer_height + 1)
    front(d, cfg)
    d:pop()

    d:push()
    d:translate(0, cfg.outer_height + cfg.outer_depth + 2)
    front(d, cfg)
    d:pop()

    d:push()
    d:translate(0, cfg.outer_height + cfg.outer_depth*2 + 3)
    side(d, cfg, 'right')
    d:translate(cfg.outer_height + 1, 0)
    side(d, cfg, 'left')
    d:pop()

    if cfg.has_lid then
        d:push()
        d:translate(0, cfg.outer_height+cfg.outer_depth*3 + 4)
        lid(d, cfg)
        d:pop()
    end

    if #cfg.columns > 0 then
        d:push()
        d:translate(cfg.outer_width - cfg.material.thickness*2-cfg.material.zip_slot_width+1, 0)
        v_dividers(d, cfg)
        d:pop()
    end

    if #cfg.rows > 0 then
        d:push()
        d:translate(cfg.outer_width - cfg.material.thickness*2-cfg.material.zip_slot_width + cfg.inner_height + cfg.material.thickness*2 + 2, 0)
        h_dividers(d, cfg)
        d:pop()
    end

    return d
end

cfg = loadcfg(ARGV[1])
fixcfg(cfg)
box(cfg):write(io.stdout)
